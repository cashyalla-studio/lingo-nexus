import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';

/// 지원하는 AI 프로바이더 종류
enum AiProviderType { google, openai, claude }

/// 1. SecureStorageService 싱글톤 프로바이더 (앱 전역 사용)
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// 2. 사용자가 현재 선택한 '기본 AI 프로바이더'의 상태를 관리하는 StateNotifier
class ActiveAiProviderNotifier extends StateNotifier<AiProviderType> {
  ActiveAiProviderNotifier() : super(AiProviderType.google);

  void switchProvider(AiProviderType type) {
    state = type;
  }
}

final activeAiProvider =
    StateNotifierProvider<ActiveAiProviderNotifier, AiProviderType>((ref) {
  return ActiveAiProviderNotifier();
});

/// 3. 현재 선택된 AI 프로바이더에 맞는 API Key를 로드하는 비동기 프로바이더
final currentApiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final currentType = ref.watch(activeAiProvider);

  switch (currentType) {
    case AiProviderType.google:
      return await storage.getGoogleApiKey();
    case AiProviderType.openai:
      return await storage.getOpenAiKey();
    case AiProviderType.claude:
      return await storage.getClaudeKey();
  }
});
