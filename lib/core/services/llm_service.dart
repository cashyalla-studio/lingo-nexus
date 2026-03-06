import 'dart:async'; // for TimeoutException
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/ai_provider.dart';
import '../models/chat_message.dart';

final llmServiceProvider = Provider<LlmService>((ref) => LlmService());

class LlmService {
  Future<String> askGrammar(AiProviderType type, String apiKey, String sentence) async {
    if (apiKey.isEmpty) return "API Key 누락";

    final prompt = "You are a professional language tutor. Explain the grammar of the following sentence and provide 2 examples. Use Korean for the explanation.\n\nSentence: \"$sentence\"";

    try {
      if (type == AiProviderType.openai) {
        return await _askOpenAi(apiKey, prompt);
      } else if (type == AiProviderType.google) {
        return await _askGemini(apiKey, prompt);
      } else {
        return await _askClaude(apiKey, prompt);
      }
    } on TimeoutException {
      return "요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.";
    } catch (e) {
      debugPrint('LlmService error: $e');
      return "AI 요청 실패: $e";
    }
  }

  Future<String> _askOpenAi(String key, String prompt) async {
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $key'},
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [{"role": "user", "content": prompt}]
      })
    ).timeout(const Duration(seconds: 30));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final choices = json['choices'] as List?;
      if (choices == null || choices.isEmpty) throw Exception("OpenAI: empty response");
      final content = (choices[0] as Map<String, dynamic>?)?['message']?['content'] as String?;
      if (content == null) throw Exception("OpenAI: missing content");
      return content;
    }
    throw Exception("OpenAI Error: ${res.body}");
  }

  Future<String> _askGemini(String key, String prompt) async {
    final res = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [{"parts": [{"text": prompt}]}]
      })
    ).timeout(const Duration(seconds: 30));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) throw Exception("Gemini: empty response");
      final parts = ((candidates[0] as Map<String, dynamic>?)?['content'] as Map<String, dynamic>?)?['parts'] as List?;
      if (parts == null || parts.isEmpty) throw Exception("Gemini: missing parts");
      final text = (parts[0] as Map<String, dynamic>?)?['text'] as String?;
      if (text == null) throw Exception("Gemini: missing text");
      return text;
    }
    throw Exception("Gemini Error: ${res.body}");
  }

  Future<String> _askClaude(String key, String prompt) async {
    final res = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': key,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        "model": "claude-haiku-4-5-20251001",
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": prompt}]
      }),
    ).timeout(const Duration(seconds: 30));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final content = json['content'] as List?;
      if (content == null || content.isEmpty) throw Exception("Claude: empty response");
      final text = (content[0] as Map<String, dynamic>?)?['text'] as String?;
      if (text == null) throw Exception("Claude: missing text");
      return text;
    }
    throw Exception("Claude Error: ${res.body}");
  }

  Future<String> chat(
    AiProviderType type,
    String apiKey,
    List<ChatMessage> history,
    String newMessage,
  ) async {
    if (apiKey.isEmpty) return "API Key 누락";

    try {
      if (type == AiProviderType.openai) {
        return await _chatOpenAi(apiKey, history, newMessage);
      } else if (type == AiProviderType.google) {
        return await _chatGemini(apiKey, history, newMessage);
      } else {
        return await _chatClaude(apiKey, history, newMessage);
      }
    } on TimeoutException {
      return "요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.";
    } catch (e) {
      debugPrint('LlmService error: $e');
      return "AI 요청 실패: $e";
    }
  }

  Future<String> _chatOpenAi(String key, List<ChatMessage> history, String newMessage) async {
    final messages = [
      {"role": "system", "content": "You are a helpful language tutor. Answer in Korean unless the user asks in another language. Keep responses concise."},
      ...history.map((m) => {"role": m.role, "content": m.content}),
      {"role": "user", "content": newMessage},
    ];
    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $key'},
      body: jsonEncode({"model": "gpt-4o-mini", "messages": messages}),
    ).timeout(const Duration(seconds: 30));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final choices = json['choices'] as List?;
      if (choices == null || choices.isEmpty) throw Exception("OpenAI: empty response");
      final content = (choices[0] as Map<String, dynamic>?)?['message']?['content'] as String?;
      if (content == null) throw Exception("OpenAI: missing content");
      return content;
    }
    throw Exception("OpenAI Error: ${res.body}");
  }

  Future<String> _chatGemini(String key, List<ChatMessage> history, String newMessage) async {
    final contents = [
      ...history.map((m) => {
        "role": m.role == 'assistant' ? 'model' : 'user',
        "parts": [{"text": m.content}]
      }),
      {"role": "user", "parts": [{"text": newMessage}]},
    ];
    final res = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"contents": contents}),
    ).timeout(const Duration(seconds: 30));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) throw Exception("Gemini: empty response");
      final parts = ((candidates[0] as Map<String, dynamic>?)?['content'] as Map<String, dynamic>?)?['parts'] as List?;
      if (parts == null || parts.isEmpty) throw Exception("Gemini: missing parts");
      final text = (parts[0] as Map<String, dynamic>?)?['text'] as String?;
      if (text == null) throw Exception("Gemini: missing text");
      return text;
    }
    throw Exception("Gemini Error: ${res.body}");
  }

  Future<String> askVocabulary(AiProviderType type, String apiKey, String word, String contextSentence) async {
    if (apiKey.isEmpty) return "API Key 누락";

    final prompt = """You are a professional language tutor. For the word or phrase "$word" used in the sentence: "$contextSentence"

Provide in Korean:
1. **뜻**: Primary meaning in this context
2. **품사**: Part of speech
3. **예문**: 2 example sentences using this word
4. **뉘앙스**: Usage notes, nuance, or common mistakes

Keep the response concise and practical.""";

    try {
      if (type == AiProviderType.openai) {
        return await _askOpenAi(apiKey, prompt);
      } else if (type == AiProviderType.google) {
        return await _askGemini(apiKey, prompt);
      } else {
        return await _askClaude(apiKey, prompt);
      }
    } on TimeoutException {
      return "요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.";
    } catch (e) {
      debugPrint('LlmService error: $e');
      return "AI 요청 실패: $e";
    }
  }

  Future<String> _chatClaude(String key, List<ChatMessage> history, String newMessage) async {
    final messages = [
      ...history.map((m) => {"role": m.role, "content": m.content}),
      {"role": "user", "content": newMessage},
    ];
    final res = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': key,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        "model": "claude-haiku-4-5-20251001",
        "max_tokens": 1024,
        "system": "You are a helpful language tutor. Answer in Korean unless the user asks in another language. Keep responses concise.",
        "messages": messages,
      }),
    ).timeout(const Duration(seconds: 30));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final content = json['content'] as List?;
      if (content == null || content.isEmpty) throw Exception("Claude: empty response");
      final text = (content[0] as Map<String, dynamic>?)?['text'] as String?;
      if (text == null) throw Exception("Claude: missing text");
      return text;
    }
    throw Exception("Claude Error: ${res.body}");
  }
}
