import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/server_config.dart';
import '../../core/models/sync_item.dart';
import '../../core/services/native_stt_service.dart';
import '../../core/services/srt_parser_service.dart';

final autoSyncServiceProvider = Provider((ref) => AutoSyncService());

class AutoSyncService {
  final _nativeStt = NativeSttService();

  /// 오디오 파일을 전사 + 발음기호 + 번역으로 변환합니다.
  ///
  /// iOS: 기기 내장 STT(SFSpeechRecognizer)로 전사 후 서버에서 어노테이션만 수행.
  /// 그 외 / 기기 STT 불가: 서버 API로 전체 처리.
  ///
  /// [language]: 오디오 언어 코드 (zh, ja, en, ko, es, de, fr, pt, ar)
  /// [targetLanguage]: 번역 대상 언어 코드 (ko, en, ja 등)
  Future<({List<SyncItem> syncItems, String script})> transcribe(
    String audioFilePath,
    String language,
    Duration audioDuration, {
    String targetLanguage = 'ko',
  }) async {
    final file = File(audioFilePath);
    if (!await file.exists()) throw Exception('오디오 파일을 찾을 수 없습니다.');

    // iOS에서 기기 내장 STT 시도
    if (!kIsWeb && Platform.isIOS) {
      try {
        final available = await _nativeStt.isAvailable(language);
        if (available) {
          debugPrint('AutoSync: 기기 내장 STT 사용 (lang=$language)');
          return await _transcribeWithNativeStt(
            audioFilePath,
            language,
            audioDuration,
            targetLanguage: targetLanguage,
          );
        }
      } catch (e) {
        debugPrint('AutoSync: 기기 내장 STT 실패, 서버 폴백: $e');
      }
    }

    debugPrint('AutoSync: 서버 API 전사 사용 (lang=$language)');
    return await _transcribeWithServer(
      file,
      language,
      audioDuration,
      targetLanguage: targetLanguage,
    );
  }

  // ── 기기 내장 STT 경로 ──────────────────────────────────────────────────────

  Future<({List<SyncItem> syncItems, String script})> _transcribeWithNativeStt(
    String audioFilePath,
    String language,
    Duration audioDuration, {
    required String targetLanguage,
  }) async {
    // Step 1: 기기 STT로 단어 단위 세그먼트 추출
    final jsonString = await _nativeStt.transcribeFile(audioFilePath, language);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final fullText = json['text'] as String? ?? '';
    final rawSegments = json['segments'] as List<dynamic>? ?? [];

    final segments = rawSegments.map((s) {
      final m = s as Map<String, dynamic>;
      return _WordSegment(
        word: m['word'] as String,
        startSec: (m['start_sec'] as num).toDouble(),
        endSec: (m['end_sec'] as num).toDouble(),
      );
    }).toList();

    if (segments.isEmpty) {
      throw Exception('기기 STT: 인식된 단어가 없습니다.');
    }

    // Step 2: 단어 세그먼트를 문장 단위로 그룹화
    final sentenceGroups = _groupSegmentsIntoSentences(segments, audioDuration);

    // Step 3: 서버에서 발음기호 + 번역 어노테이션
    final sentences = sentenceGroups.map((g) => g.text).toList();
    final annotations = await _fetchAnnotations(sentences, language, targetLanguage);

    // Step 4: SyncItem 조합
    final syncItems = List.generate(sentenceGroups.length, (i) {
      final group = sentenceGroups[i];
      final ann = i < annotations.length ? annotations[i] : null;
      return SyncItem(
        startTime: group.startTime,
        endTime: group.endTime,
        sentence: group.text,
        phonetics: ann?['phonetics'] as String?,
        translation: ann?['translation'] as String?,
      );
    });

    debugPrint('AutoSync (native): ${syncItems.length}개 문장 완료');
    return (syncItems: syncItems, script: fullText);
  }

  /// 단어 세그먼트를 문장으로 묶습니다.
  /// 문장 종결 조건: 마지막 단어가 문장 부호로 끝남 OR 다음 단어와 간격 > 0.8초
  List<_SentenceGroup> _groupSegmentsIntoSentences(
    List<_WordSegment> segments,
    Duration audioDuration,
  ) {
    const sentenceEndChars = {'.', '?', '!', '。', '？', '！', '…'};
    const silenceThresholdSec = 0.8;

    final groups = <_SentenceGroup>[];
    final current = <_WordSegment>[];

    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      current.add(seg);

      final isLastWord = i == segments.length - 1;
      final endsWithPunct = sentenceEndChars.any((c) => seg.word.endsWith(c));
      final nextGapTooLong = !isLastWord &&
          (segments[i + 1].startSec - seg.endSec) > silenceThresholdSec;

      if (endsWithPunct || nextGapTooLong || isLastWord) {
        if (current.isNotEmpty) {
          final text = current.map((s) => s.word).join(' ').trim();
          final startTime = Duration(
            milliseconds: (current.first.startSec * 1000).round(),
          );
          final endTime = Duration(
            milliseconds: (current.last.endSec * 1000).round(),
          );
          groups.add(_SentenceGroup(
            text: text,
            startTime: startTime,
            endTime: endTime,
          ));
          current.clear();
        }
      }
    }

    return groups;
  }

  /// 서버 `/api/v1/sync/annotate`에 문장 목록을 보내고 발음기호+번역을 받습니다.
  Future<List<Map<String, dynamic>>> _fetchAnnotations(
    List<String> sentences,
    String language,
    String targetLanguage,
  ) async {
    final body = jsonEncode({
      'sentences': sentences,
      'language': language,
      'target_language': targetLanguage,
    });

    final response = await http
        .post(
          Uri.parse('${ServerConfig.baseUrl}/api/v1/sync/annotate'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('어노테이션 서버 오류 (${response.statusCode}): ${response.body}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  // ── 서버 전체 처리 경로 ──────────────────────────────────────────────────────

  Future<({List<SyncItem> syncItems, String script})> _transcribeWithServer(
    File file,
    String language,
    Duration audioDuration, {
    required String targetLanguage,
  }) async {
    final audioBytes = await file.readAsBytes();
    final audioBase64 = base64Encode(audioBytes);

    final body = jsonEncode({
      'audio_base64': audioBase64,
      'language': language,
      'duration_ms': audioDuration.inMilliseconds,
      'target_language': targetLanguage,
    });

    final response = await http
        .post(
          Uri.parse('${ServerConfig.baseUrl}/api/v1/sync/transcribe'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 180));

    if (response.statusCode != 200) {
      throw Exception('서버 오류 (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final script = json['script'] as String? ?? '';
    final rawItems = json['sync_items'] as List<dynamic>? ?? [];

    final syncItems = rawItems.map((item) {
      final map = item as Map<String, dynamic>;
      return SyncItem(
        startTime: Duration(milliseconds: (map['start_ms'] as num).toInt()),
        endTime: Duration(milliseconds: (map['end_ms'] as num).toInt()),
        sentence: map['sentence'] as String,
        phonetics: map['phonetics'] as String?,
        translation: map['translation'] as String?,
      );
    }).toList();

    debugPrint('AutoSync (server): ${syncItems.length}개 문장 전사+어노테이션 완료');
    return (syncItems: syncItems, script: script);
  }

  // ── 유틸리티 ──────────────────────────────────────────────────────────────

  /// SyncItem 목록으로 언어 학습용 스크립트 파일 내용을 생성합니다.
  ///
  /// 포맷:
  /// [MM:SS] 원문 문장
  ///         발음기호
  ///         번역
  String generateAnnotatedScript(List<SyncItem> items) {
    final buffer = StringBuffer();
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.write('[${item.formattedTime}] ${item.sentence}');
      if (item.phonetics != null && item.phonetics!.isNotEmpty) {
        buffer.write('\n        ${item.phonetics}');
      }
      if (item.translation != null && item.translation!.isNotEmpty) {
        buffer.write('\n        ${item.translation}');
      }
      if (i < items.length - 1) buffer.write('\n\n');
    }
    return buffer.toString();
  }

  /// SRT 파일을 직접 파싱하여 SyncItem 목록으로 변환합니다.
  List<SyncItem> parseSrtSync(String srtContent) {
    return SrtParserService().parse(srtContent);
  }
}

// ── 내부 데이터 클래스 ──────────────────────────────────────────────────────

class _WordSegment {
  final String word;
  final double startSec;
  final double endSec;
  const _WordSegment({required this.word, required this.startSec, required this.endSec});
}

class _SentenceGroup {
  final String text;
  final Duration startTime;
  final Duration endTime;
  const _SentenceGroup({required this.text, required this.startTime, required this.endTime});
}
