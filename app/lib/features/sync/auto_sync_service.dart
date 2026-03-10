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
  /// 오디오 파일을 서버로 전송해 전사(transcription)를 요청합니다.
  /// 서버가 LLM(zh→Qwen, 그 외→Gemini)으로 스크립트를 추출하고
  /// 길이 비례 타임스탬프가 포함된 SyncItem 목록을 반환합니다.
  ///
  /// [language]: kStudyLanguages 코드 (zh, ja, en, ko, es, de, fr, pt, ar)
  Future<({List<SyncItem> syncItems, String script})> transcribe(
    String audioFilePath,
    String language,
    Duration audioDuration,
  ) async {
    final file = File(audioFilePath);
    if (!await file.exists()) throw Exception('오디오 파일을 찾을 수 없습니다.');

    final audioBytes = await file.readAsBytes();
    final audioBase64 = base64Encode(audioBytes);

    final body = jsonEncode({
      'audio_base64': audioBase64,
      'language': language,
      'duration_ms': audioDuration.inMilliseconds,
    });

    final response = await http
        .post(
          Uri.parse('${ServerConfig.baseUrl}/api/v1/sync/transcribe'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 120));

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
      );
    }).toList();

    debugPrint('AutoSync: ${syncItems.length}개 문장 전사 완료');
    return (syncItems: syncItems, script: script);
  }

  /// SRT 파일을 직접 파싱하여 SyncItem 목록으로 변환합니다.
  List<SyncItem> parseSrtSync(String srtContent) {
    return SrtParserService().parse(srtContent);
  }
}
