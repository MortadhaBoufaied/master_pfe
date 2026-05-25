import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'ApiService.dart';
import 'auth_storage.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  /* ========================= LOGIN ========================= */

  Future<bool> login(String email, String password) async {
    try {
      final http.Response resp = await _api.post(
        "/auth/login",
        body: {"email": email, "password": password},
      );

      if (resp.statusCode != 200) {
        if (kDebugMode) {
          debugPrint(
            '[AuthService] Login failed: ${resp.statusCode} - ${resp.body}',
          );
        }
        return false;
      }

      final dynamic data = _safeJson(resp.body);

      if (data is! Map) return false;

      final accessToken = data["accessToken"]?.toString();
      final refreshToken = data["refreshToken"]?.toString();
      final userRaw = data["user"];

      if (accessToken == null || accessToken.isEmpty) return false;

      await AuthStorage.saveTokens(accessToken, refreshToken ?? "");
      if (userRaw is Map) {
        await AuthStorage.saveUser(Map<String, dynamic>.from(userRaw));
      }

      await _persistCurrentUserSafe();
      return true;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  /* ========================= SIGNUP ========================= */

  Future<bool> signup({
    String? nom,
    required String email,
    required String password,
    Map<String, dynamic>? extra,
    String mainRole = "PLAYER",
  }) async {
    try {
      final body = {
        "nom": nom ?? email.split('@').first,
        "email": email,
        "mdp": password,
        "mainRole": mainRole,
        if (extra != null) ...extra,
      };

      final http.Response resp = await _api.post("/auth/signup", body: body);

      if (resp.statusCode != 200 && resp.statusCode != 201) return false;

      final dynamic data = _safeJson(resp.body);
      if (data is Map) {
        await AuthStorage.saveUser(Map<String, dynamic>.from(data));
      }
      return true;
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  Future<String> forgotPassword(String email) async {
    final http.Response resp = await _api.post(
      '/auth/forgot-password',
      body: {'email': email},
    );
    final dynamic data = _safeJson(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return data is Map
          ? (data['message']?.toString() ?? 'If this email exists, a reset code has been sent.')
          : 'If this email exists, a reset code has been sent.';
    }
    throw Exception(data is Map ? data['error'] ?? 'Reset request failed' : 'Reset request failed');
  }

  Future<String> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final http.Response resp = await _api.post(
      '/auth/verify-reset-code',
      body: {'email': email, 'code': code},
    );
    final dynamic data = _safeJson(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300 && data is Map) {
      return data['resetToken']?.toString() ?? '';
    }
    throw Exception(data is Map ? data['error'] ?? 'Invalid reset code' : 'Invalid reset code');
  }

  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final http.Response resp = await _api.post(
      '/auth/reset-password',
      body: {
        'resetToken': resetToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    final dynamic data = _safeJson(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return data is Map ? data['message']?.toString() ?? 'Password updated successfully.' : 'Password updated successfully.';
    }
    throw Exception(data is Map ? data['error'] ?? 'Password reset failed' : 'Password reset failed');
  }

  Future<String> contactSupport({
    required String name,
    String? email,
    required String subject,
    required String message,
  }) async {
    final http.Response resp = await _api.post(
      '/support/contact',
      body: {
        'name': name,
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        'subject': subject,
        'message': message,
      },
    );
    final dynamic data = _safeJson(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return data is Map ? data['message']?.toString() ?? 'Support request sent successfully.' : 'Support request sent successfully.';
    }
    throw Exception(data is Map ? data['error'] ?? 'Support request failed' : 'Support request failed');
  }

  /* ========================= TOKEN REFRESH (manual) =========================
     Note: ApiClient already has auto-refresh on 401.
     This method is used only as fallback for checkAuthentication.
  */

  Future<String?> _refreshAccessToken() async {
    try {
      final refresh = await AuthStorage.getRefreshToken();
      if (refresh == null || refresh.isEmpty) return null;

      // IMPORTANT:
      // - Your ApiClient internal refresh uses query param refreshToken
      // - So we match it here too
      final http.Response resp = await _api.post(
        "/auth/refresh",
        query: {"refreshToken": refresh},
      );

      if (resp.statusCode != 200) return null;

      final dynamic data = _safeJson(resp.body);
      if (data is! Map) return null;

      final accessToken = data["accessToken"]?.toString();
      final refreshToken = data["refreshToken"]?.toString();

      if (accessToken == null || accessToken.isEmpty) return null;

      await AuthStorage.saveTokens(accessToken, refreshToken ?? refresh);

      return accessToken;
    } catch (_) {
      return null;
    }
  }

  /* ========================= CHECK USER ========================= */

  Future<bool> checkAuthentication() async {
    final access = await AuthStorage.getAccessToken();
    if (access == null || access.isEmpty) return false;

    try {
      final http.Response resp = await _api.get("/auth/validate");

      // If backend returns 200 and body is boolean or {"valid":true}, we support both.
      if (resp.statusCode == 200) {
        final dynamic data = _safeJson(resp.body);

        // Case 1: plain boolean true/false
        if (data is bool) return data;

        // Case 2: { "valid": true }
        if (data is Map && data["valid"] == true) return true;

        // Some APIs return empty body on 200 -> treat as valid
        if (resp.body.trim().isEmpty) return true;
      }

      // If validate fails, attempt manual refresh
      return await _refreshAccessToken() != null;
    } catch (_) {
      return false;
    }
  }

  /* ========================= LOGOUT ========================= */

  Future<void> logout() async {
    try {
      await _api.post("/auth/logout");
    } catch (_) {
      // ignore
    }
    await AuthStorage.clear();
  }

  /* ========================= USER PROFILE ========================= */

  Future<Map<String, dynamic>?> fetchCurrentUserFromServer() async {
    try {
      final http.Response resp = await _api.get("/profile/me-lite");

      if (resp.statusCode != 200) return null;

      final dynamic data = _safeJson(resp.body);

      if (data is Map) {
        final user = Map<String, dynamic>.from(data);
        await AuthStorage.saveUser(user);
        return user;
      }

      // some backends wrap as {data:{...}}
      if (data is Map && data["data"] is Map) {
        final user = Map<String, dynamic>.from(data["data"]);
        await AuthStorage.saveUser(user);
        return user;
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  // ------------------------
  // Helpers
  // ------------------------

  dynamic _safeJson(String body) {
    final b = body.trim();
    if (b.isEmpty) return null;
    try {
      return jsonDecode(b);
    } catch (_) {
      // Some APIs return "true"/"false" as plain text
      if (b.toLowerCase() == "true") return true;
      if (b.toLowerCase() == "false") return false;
      return b;
    }
  }

  /// After login/signup, persist current user so role-based UI can render immediately.
  Future<void> _persistCurrentUserSafe() async {
    try {
      final me = await fetchCurrentUserFromServer();
      if (me != null) {
        await AuthStorage.saveUser(me);
      }
    } catch (_) {
      // ignore
    }
  }
}

