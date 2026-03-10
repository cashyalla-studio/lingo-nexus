import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/llm_service.dart';
import '../../core/models/chat_message.dart';

final grammarExplanationProvider = FutureProvider.family<String, String>((ref, sentence) async {
  final service = ref.read(llmServiceProvider);
  return await service.askGrammar(sentence);
});

final vocabularyProvider = FutureProvider.family<String, ({String word, String context})>((ref, params) async {
  final service = ref.read(llmServiceProvider);
  return await service.askVocabulary(params.word, params.context);
});

class ChatHistoryNotifier extends StateNotifier<List<ChatMessage>> {
  ChatHistoryNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clear() {
    state = [];
  }
}

final chatHistoryProvider = StateNotifierProvider<ChatHistoryNotifier, List<ChatMessage>>((ref) {
  return ChatHistoryNotifier();
});

final sendChatMessageProvider = FutureProvider.family<String, String>((ref, message) async {
  final history = ref.read(chatHistoryProvider);
  final service = ref.read(llmServiceProvider);
  return await service.chat(
    history,
    message,
    systemPrompt: 'You are a helpful language tutor. Answer in Korean unless the user asks in another language. Keep responses concise.',
  );
});
