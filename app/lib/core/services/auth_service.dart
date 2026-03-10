import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';
import 'secure_storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(secureStorageProvider));
});

class AuthUser {
  final int id;
  final String email;
  final String name;
  final String avatarUrl;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl = '',
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String? ?? '',
      );
}

class AuthService {
  final SecureStorageService _storage;
  final _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.readonly',
  ]);
  final _client = http.Client();

  AuthService(this._storage);

  /// Signs in with Google and exchanges for server JWT.
  Future<AuthUser> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Google sign-in cancelled');

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('Google ID token is null');

    return await _loginWithServer(idToken: idToken, provider: 'google');
  }

  /// Restores session silently (on app start).
  /// Returns the current user if a valid token exists, null otherwise.
  Future<AuthUser?> restoreSession() async {
    final accessToken = await _storage.getAccessToken();
    if (accessToken == null) return null;

    // Try fetching user profile with existing token
    try {
      final resp = await _client.get(
        Uri.parse('${ServerConfig.baseUrl}/api/v1/user/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        return AuthUser.fromJson(jsonDecode(resp.body));
      }

      // Token expired — try refresh
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        await _storage.clearAuthTokens();
        return null;
      }
      return await _refreshAndGetUser(refreshToken);
    } catch (e) {
      debugPrint('AuthService.restoreSession error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _storage.clearAuthTokens();
  }

  Future<String?> getValidAccessToken() async {
    return await _storage.getAccessToken();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<AuthUser> _loginWithServer({
    required String idToken,
    required String provider,
  }) async {
    final resp = await _client.post(
      Uri.parse('${ServerConfig.baseUrl}/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'provider': provider, 'id_token': idToken}),
    ).timeout(const Duration(seconds: 15));

    if (resp.statusCode != 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Login failed');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    await _storage.saveAccessToken(data['access_token'] as String);
    await _storage.saveRefreshToken(data['refresh_token'] as String);
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<AuthUser> _refreshAndGetUser(String refreshToken) async {
    final resp = await _client.post(
      Uri.parse('${ServerConfig.baseUrl}/api/v1/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    ).timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) {
      await _storage.clearAuthTokens();
      throw Exception('Session expired, please log in again');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    await _storage.saveAccessToken(data['access_token'] as String);
    await _storage.saveRefreshToken(data['refresh_token'] as String);
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }
}
