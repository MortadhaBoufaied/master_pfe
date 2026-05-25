import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// A tiny app-wide auth state holder.
/// - No external packages required.
/// - UI reads `isAuthenticated.value`.
/// - Call signIn/signOut in your flows.
class AuthState {
  AuthState({AuthService? authService}) : _auth = authService ?? AuthService();

  final AuthService _auth;

  /// Reactive boolean the UI can listen to.
  /// Use ValueListenableBuilder or read value directly.
  final ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);

  /// Optionally store tokens/claims if you want to expose them.
  String? accessToken;
  String? refreshToken;

  /// Try to restore session from storage (tokens/cookies) on app start.
  Future<void> tryRestoreSession() async {
    final ok = await _auth.checkAuthentication();
    isAuthenticated.value = ok;
  }

  Future<bool> signIn(String email, String password) async {
    final ok = await _auth.login(email, password);
    if (ok) {
      isAuthenticated.value = true;
    }
    return ok;
  }

  Future<void> signOut() async {
    await _auth.logout();
    isAuthenticated.value = false;
  }
}

/// A globally accessible singleton you can use anywhere.
/// Example:
///   AuthSession.instance.state.isAuthenticated.value = true;
class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  /// The single source of truth for the UI.
  final AuthState state = AuthState();
}


