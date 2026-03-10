import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((_) => SecureStorageService());

/// 기기 로컬 암호화 저장소(Keychain, Keystore)를 사용하여 인증 토큰을 안전하게 보관합니다.
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefreshToken);

  Future<void> clearAuthTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  // Legacy API key methods (unused after migration, kept for graceful migration)
  Future<void> clearAllKeys() => clearAuthTokens();
}
