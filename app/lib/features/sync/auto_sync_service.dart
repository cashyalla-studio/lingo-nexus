import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/server_config.dart';
import '../../core/models/sync_item.dart';
import '../../core/services/srt_parser_service.dart';

final autoSyncServiceProvider = Provider((ref) => AutoSyncService());

class AutoSyncService {
  /// 오디오 파일을 서버로 전송해 전사 + 발음기호 + 번역을 요청합니다.
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

    debugPrint('AutoSync: ${syncItems.length}개 문장 전사+어노테이션 완료');
    return (syncItems: syncItems, script: script);
  }

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
