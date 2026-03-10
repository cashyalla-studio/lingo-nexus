import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';
import '../models/chat_message.dart';
import '../services/secure_storage_service.dart';

final llmServiceProvider = Provider<LlmService>((ref) {
  return LlmService(ref.read(secureStorageProvider));
});

/// Routes all AI requests through the LingoNexus server.
/// No direct API provider calls — auth token is required.
class LlmService {
  final SecureStorageService _storage;
  final _client = http.Client();

  LlmService(this._storage);

  Future<String> askGrammar(String sentence, {String uiLang = 'ko'}) async {
    return await _postText('/api/v1/ai/grammar', {
      'sentence': sentence,
      'ui_language': uiLang,
    });
  }

  Future<String> askVocabulary(String word, String contextSentence, {String uiLang = 'ko'}) async {
    return await _postText('/api/v1/ai/vocabulary', {
      'word': word,
      'context': contextSentence,
      'ui_language': uiLang,
    });
  }

  Future<String> chat(
    List<ChatMessage> history,
    String newMessage, {
    String systemPrompt = '',
  }) async {
    final messages = [
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': newMessage},
    ];
    return await _postText('/api/v1/ai/chat', {
      'messages': messages,
      'system_prompt': systemPrompt,
    });
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<String> _postText(String path, Map<String, dynamic> body) async {
    final token = await _storage.getAccessToken();
    if (token == null) return _authError();

    try {
      final resp = await _client.post(
        Uri.parse('${ServerConfig.baseUrl}$path'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 401) return _authError();
      if (resp.statusCode == 402) {
        final err = _parseError(resp.body);
        return '크레딧이 부족합니다. 크레딧을 충전해주세요.\n$err';
      }
      if (resp.statusCode != 200) {
        final err = _parseError(resp.body);
        throw Exception('Server error ${resp.statusCode}: $err');
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return json['reply'] as String? ?? '';
    } on TimeoutException {
      return '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.';
    } catch (e) {
      debugPrint('LlmService error: $e');
      return 'AI 요청 실패: $e';
    }
  }

  String _authError() =>
      '로그인이 필요합니다. 설정에서 로그인해주세요.';

  String _parseError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['error'] as String? ?? body;
    } catch (_) {
      return body;
    }
  }
}
