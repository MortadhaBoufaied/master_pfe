import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  // Fix the signup method signature
  Future<bool> signup({
    String? nom,
    required String email,
    required String password,
    String mainRole = 'PLAYER',
    Map<String, dynamic>? extra,
  }) async {
    return await _authService.signup(
      nom: nom ?? "",
      email: email,
      password: password,
      mainRole: mainRole,
      extra: extra,
    );
  }

  Future<bool> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<bool> isLoggedIn() async {
    return await _authService.checkAuthentication();
  }

  Future<Map<String, dynamic>?> getCurrentUserRemote() async {
    return await _authService.fetchCurrentUserFromServer();
  }

}


