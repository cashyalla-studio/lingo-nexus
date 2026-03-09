import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/sync_item.dart';
import '../../core/providers/ai_provider.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/srt_parser_service.dart';

final autoSyncServiceProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AutoSyncService(storage);
});

class AutoSyncService {
  final SecureStorageService _storage;

  AutoSyncService(this._storage);

  /// Whisper API를 사용해 오디오 파일을 전사하고 타임스탬프가 있는 SyncItem 목록을 생성합니다.
  /// Whisper API 키가 없거나 실패하면 글자 수 비례 분할(폴백)을 사용합니다.
  Future<List<SyncItem>> generateSync(String audioFilePath, String scriptText, Duration audioDuration) async {
    // Whisper API 시도 (OpenAI API 키 사용)
    final openAiKey = await _storage.getOpenAiKey();
    if (openAiKey != null && openAiKey.isNotEmpty) {
      try {
        return await _transcribeWithWhisper(openAiKey, audioFilePath, scriptText);
      } catch (e) {
        // Whisper 실패 시 폴백
        debugPrint('Whisper fallback: $e');
      }
    }

    // 폴백: 글자 수 비례 분할
    return _fallbackSync(scriptText, audioDuration);
  }

  Future<List<SyncItem>> _transcribeWithWhisper(String apiKey, String audioFilePath, String scriptText) async {
    final file = File(audioFilePath);
    if (!await file.exists()) throw Exception('오디오 파일을 찾을 수 없습니다.');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
    );
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = 'whisper-1';
    request.fields['response_format'] = 'verbose_json';
    request.fields['timestamp_granularities[]'] = 'segment';

    final fileExtension = audioFilePath.split('.').last.toLowerCase();
    final mimeType = fileExtension == 'mp3'
        ? 'audio/mpeg'
        : fileExtension == 'm4a'
            ? 'audio/mp4'
            : 'audio/wav';

    request.files.add(await http.MultipartFile.fromPath(
      'file', audioFilePath,
      contentType: MediaType.parse(mimeType),
    ));

    final response = await request.send().timeout(const Duration(seconds: 120));
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) throw Exception('Whisper 오류: $body');

    final json = jsonDecode(body);
    final segments = json['segments'] as List?;

    if (segments == null || segments.isEmpty) {
      return _fallbackSync(scriptText, Duration(seconds: (json['duration'] as num?)?.toInt() ?? 0));
    }

    return segments.map((seg) {
      final startMs = ((seg['start'] as num) * 1000).round();
      final endMs = ((seg['end'] as num) * 1000).round();
      return SyncItem(
        startTime: Duration(milliseconds: startMs),
        endTime: Duration(milliseconds: endMs),
        sentence: (seg['text'] as String).trim(),
      );
    }).toList();
  }

  /// SRT 파일을 직접 파싱하여 SyncItem 목록으로 변환합니다.
  List<SyncItem> parseSrtSync(String srtContent) {
    return SrtParserService().parse(srtContent);
  }

  List<SyncItem> _fallbackSync(String fullText, Duration audioDuration) {
    if (fullText.trim().isEmpty) return [];
    final RegExp sentenceRegex = RegExp(r'[^.!?]+[.!?]+');
    final matches = sentenceRegex.allMatches(fullText);
    List<String> sentences = matches.map((m) => m.group(0)!.trim()).toList();
    if (sentences.isEmpty) sentences = [fullText.trim()];

    final int totalLength = sentences.fold(0, (sum, s) => sum + s.length);
    final int totalMs = audioDuration.inMilliseconds;
    List<SyncItem> syncItems = [];
    int currentMs = 0;

    for (String sentence in sentences) {
      final double ratio = sentence.length / totalLength;
      final int durationMs = (totalMs * ratio).round();
      syncItems.add(SyncItem(
        startTime: Duration(milliseconds: currentMs),
        endTime: Duration(milliseconds: currentMs + durationMs),
        sentence: sentence,
      ));
      currentMs += durationMs;
    }
    return syncItems;
  }
}
