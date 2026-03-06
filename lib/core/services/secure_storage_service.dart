import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 기기 로컬 암호화 저장소(Keychain, Keystore)를 사용하여 API Key를 안전하게 보관하는 서비스입니다.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(),
        );

  static const String _keyGoogleAi = 'api_key_google';
  static const String _keyOpenAi = 'api_key_openai';
  static const String _keyClaude = 'api_key_claude';

  // --- Google AI (Gemini) ---
  Future<void> saveGoogleApiKey(String key) async {
    await _storage.write(key: _keyGoogleAi, value: key);
  }

  Future<String?> getGoogleApiKey() async {
    return await _storage.read(key: _keyGoogleAi);
  }

  // --- OpenAI ---
  Future<void> saveOpenAiKey(String key) async {
    await _storage.write(key: _keyOpenAi, value: key);
  }

  Future<String?> getOpenAiKey() async {
    return await _storage.read(key: _keyOpenAi);
  }

  // --- Claude (Anthropic) ---
  Future<void> saveClaudeKey(String key) async {
    await _storage.write(key: _keyClaude, value: key);
  }

  Future<String?> getClaudeKey() async {
    return await _storage.read(key: _keyClaude);
  }

  // 전체 키 초기화 (로그아웃 또는 초기화 시)
  Future<void> clearAllKeys() async {
    await _storage.delete(key: _keyGoogleAi);
    await _storage.delete(key: _keyOpenAi);
    await _storage.delete(key: _keyClaude);
  }
}
