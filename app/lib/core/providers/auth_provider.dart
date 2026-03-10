import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Holds the currently authenticated user, or null if not logged in.
final authUserProvider = StateNotifierProvider<AuthUserNotifier, AsyncValue<AuthUser?>>(
  (ref) => AuthUserNotifier(ref.read(authServiceProvider)),
);

class AuthUserNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  final AuthService _authService;

  AuthUserNotifier(this._authService) : super(const AsyncValue.loading()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final user = await _authService.restoreSession();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }

  bool get isLoggedIn => state.valueOrNull != null;
  AuthUser? get user => state.valueOrNull;
}
