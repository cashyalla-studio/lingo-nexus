import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/chat_message.dart';
import '../../core/providers/ai_provider.dart';
import '../../core/services/llm_service.dart';

// Selected language for conversation practice
final conversationLanguageProvider = StateProvider<String>((ref) => 'English');

// Conversation history (separate from grammar tutor history)
class ConversationHistoryNotifier extends StateNotifier<List<ChatMessage>> {
  ConversationHistoryNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clear() {
    state = [];
  }
}

final conversationHistoryProvider =
    StateNotifierProvider.autoDispose<ConversationHistoryNotifier, List<ChatMessage>>((ref) {
  return ConversationHistoryNotifier();
});

// Topic suggestions per language
const Map<String, List<String>> conversationTopics = {
  'English': [
    'Tell me about your weekend plans',
    'Describe your hometown',
    'What\'s your favorite food and why?',
    'Talk about a movie you recently watched',
    'What are your hobbies?',
    'Describe your daily routine',
    'Talk about travel destinations you\'d like to visit',
  ],
  'Japanese': [
    '週末の予定を教えてください',
    'あなたの故郷について話してください',
    '好きな食べ物は何ですか？',
    '最近見た映画について教えてください',
    '趣味は何ですか？',
    '一日のルーティンを説明してください',
  ],
  'Korean': [
    '주말 계획을 말해보세요',
    '고향에 대해 설명해보세요',
    '좋아하는 음식은 무엇인가요?',
    '최근에 본 영화에 대해 이야기해보세요',
    '취미가 무엇인가요?',
  ],
  'Spanish': [
    '¿Cuáles son tus planes para el fin de semana?',
    'Describe tu ciudad natal',
    '¿Cuál es tu comida favorita y por qué?',
    'Habla de una película que hayas visto recientemente',
    '¿Cuáles son tus pasatiempos?',
  ],
  'French': [
    'Parlez-moi de vos projets pour le week-end',
    'Décrivez votre ville natale',
    'Quel est votre plat préféré et pourquoi?',
    'Parlez d\'un film que vous avez récemment regardé',
    'Quels sont vos loisirs?',
  ],
};

String getSystemPrompt(String language) {
  return """You are a friendly, patient native $language speaker helping someone practice conversational $language.

Rules:
1. Always respond in $language (keep responses 2-4 sentences — natural conversation length)
2. If the user makes a grammar or vocabulary mistake, gently correct it by using the correct form naturally in your response (don't explicitly say "you made an error")
3. Ask follow-up questions to keep the conversation flowing
4. If the user writes in Korean or asks for help, briefly respond in Korean to clarify, then continue in $language
5. Be encouraging and warm — this person is learning!
6. If this is the first message, introduce yourself briefly and ask an opening question""";
}

// Provider that sends a message and gets AI response
final sendConversationMessageProvider = FutureProvider.family<String, String>((ref, message) async {
  final language = ref.read(conversationLanguageProvider);
  final activeAi = ref.read(activeAiProvider);
  final apiKey = await ref.read(currentApiKeyProvider.future);
  final history = ref.read(conversationHistoryProvider);

  if (apiKey == null || apiKey.isEmpty) {
    return "API 키가 설정되지 않았습니다. 설정에서 API 키를 입력해주세요.";
  }

  final service = ref.read(llmServiceProvider);

  // Use a conversation-specific system prompt via the chat method
  // We pass the system prompt as the first "assistant" message context
  final contextualHistory = <ChatMessage>[
    ChatMessage(role: 'user', content: getSystemPrompt(language)),
    ChatMessage(role: 'assistant', content: 'Understood! I\'ll be your $language conversation partner.'),
    ...history,
  ];

  return await service.chat(activeAi, apiKey, contextualHistory, message);
});
