import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/ai_provider.dart';
import '../../core/services/llm_service.dart';
import '../../core/models/chat_message.dart';
import '../subscription/subscription_provider.dart';

final llmServiceProvider = Provider((ref) => LlmService());

final grammarExplanationProvider = FutureProvider.family<String, String>((ref, sentence) async {
  final activeAi = ref.watch(activeAiProvider);
  final apiKey = await ref.watch(currentApiKeyProvider.future);

  if (apiKey == null || apiKey.isEmpty) {
    return "API Key가 설정되지 않았습니다.\n앱 설정에서 [${activeAi.name}]의 API 키를 입력해주세요.";
  }

  final canUseAI = await ref.read(subscriptionServiceProvider).canUseAI();
  if (!canUseAI) {
    return "이번 달 무료 AI 사용 한도(20회)에 도달했습니다.\n프리미엄으로 업그레이드하면 무제한으로 사용할 수 있어요! ✨";
  }

  await ref.read(subscriptionServiceProvider).recordAiCall();
  final service = ref.watch(llmServiceProvider);
  return await service.askGrammar(activeAi, apiKey, sentence);
});

final vocabularyProvider = FutureProvider.family<String, ({String word, String context})>((ref, params) async {
  final activeAi = ref.watch(activeAiProvider);
  final apiKey = await ref.watch(currentApiKeyProvider.future);

  if (apiKey == null || apiKey.isEmpty) {
    return "API Key가 설정되지 않았습니다.\n앱 설정에서 [${activeAi.name}]의 API 키를 입력해주세요.";
  }

  final canUseAI = await ref.read(subscriptionServiceProvider).canUseAI();
  if (!canUseAI) {
    return "이번 달 무료 AI 사용 한도(20회)에 도달했습니다.\n프리미엄으로 업그레이드하면 무제한으로 사용할 수 있어요! ✨";
  }

  await ref.read(subscriptionServiceProvider).recordAiCall();
  final service = ref.watch(llmServiceProvider);
  return await service.askVocabulary(activeAi, apiKey, params.word, params.context);
});

// Chat history per session (cleared when a new sheet opens)
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

// Send a chat message and get AI response
final sendChatMessageProvider = FutureProvider.family<String, String>((ref, message) async {
  final activeAi = ref.watch(activeAiProvider);
  final apiKey = await ref.watch(currentApiKeyProvider.future);
  final history = ref.read(chatHistoryProvider);

  if (apiKey == null || apiKey.isEmpty) {
    return "API Key가 설정되지 않았습니다.";
  }

  final canUseAI = await ref.read(subscriptionServiceProvider).canUseAI();
  if (!canUseAI) {
    return "이번 달 무료 AI 사용 한도(20회)에 도달했습니다.\n프리미엄으로 업그레이드하면 무제한으로 사용할 수 있어요! ✨";
  }

  await ref.read(subscriptionServiceProvider).recordAiCall();
  final service = ref.watch(llmServiceProvider);
  return await service.chat(activeAi, apiKey, history, message);
});
