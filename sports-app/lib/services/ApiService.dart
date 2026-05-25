import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../components/Constants.dart';
import 'auth_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException({required this.message, this.statusCode});
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiClient {
  // ---- Singleton ----
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  final http.Client _client = http.Client();

  Duration get _timeout => API_TIMEOUT;

  void _debugLog(Object? message) {
    if (kDebugMode) debugPrint(message?.toString());
  }

  Uri _uri(String path, {Map<String, dynamic>? query}) {
    // If caller already passed an absolute URL, don't prefix API_BASE_URL.
    if (path.contains('://')) {
      return Uri.parse(path).replace(
        queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())),
      );
    }

    if (!path.startsWith('/')) path = '/$path';
    return Uri.parse(API_BASE_URL + path).replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())),
    );
  }

  Future<void> _saveTokens({required String access, String? refresh}) async {
    // Single source of truth for auth tokens in the app is AuthStorage
    // (FlutterSecureStorage). Using SharedPreferences here breaks refresh because
    // subsequent requests still read the old token from AuthStorage.
    if (refresh != null && refresh.isNotEmpty) {
      await AuthStorage.saveTokens(access, refresh);
      return;
    }

    // Backend may omit refreshToken on refresh; keep the existing one if present.
    final existingRefresh = await AuthStorage.getRefreshToken() ?? '';
    await AuthStorage.saveTokens(access, existingRefresh);
  }

  Future<Map<String, String>> _headers({String? contentType}) async {
    final h = <String, String>{'Accept': 'application/json'};
    if (contentType != null) h['Content-Type'] = contentType;

    final token = await AuthStorage.getAccessToken();
    if (kDebugMode) {
      debugPrint(
        '[ApiClient] Token retrieved from storage: ${token != null ? 'Present (${token.length} chars)' : 'NULL'}',
      );
    }
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        debugPrint('[ApiClient] Authorization header added');
      }
    } else {
      if (kDebugMode) {
        debugPrint('[ApiClient] No valid token available for Authorization header');
      }
    }
    return h;
  }

  // ============================================================
  // ============================================================

  bool _shouldAttemptRefresh(String path) {
    // Never try refresh for auth endpoints; during login/signup there are no tokens yet,
    // and refreshing on a 401 from /auth/login just adds misleading logs.
    String p;
    if (path.contains('://')) {
      // Absolute URL passed in (e.g. http://host/.../api/auth/login).
      try {
        p = Uri.parse(path).path;
      } catch (_) {
        p = path;
      }
    } else {
      p = path.startsWith('/') ? path : '/$path';
    }

    // Match both "/auth/*" (client-relative) and "/api/auth/*" (server path).
    if (p.contains('/auth/')) return false;
    if (p.endsWith('/auth')) return false;
    return true;
  }

  Future<http.Response> get(String path, {Map<String, dynamic>? query}) async {
    return _sendWithRefresh(path, () async {
      _debugLog(_uri(path, query: query));
      return _client
          .get(_uri(path, query: query), headers: await _headers())
          .timeout(_timeout);
    });
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    return _sendWithRefresh(path, () async {
      final uri = _uri(path, query: query);
      final headers = await _headers(contentType: 'application/json');
      _debugLog(uri);
      return _client
          .post(
            uri,
            headers: headers,
            body: body is String ? body : jsonEncode(body ?? {}),
          )
          .timeout(_timeout);
    });
  }

  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    _debugLog(_uri(path, query: query));

    return _sendWithRefresh(path, () async {
      return _client
          .put(
            _uri(path, query: query),
            headers: await _headers(contentType: 'application/json'),
            body: body is String ? body : jsonEncode(body ?? {}),
          )
          .timeout(_timeout);
    });
  }

  Future<http.Response> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    _debugLog(_uri(path, query: query));
    return _sendWithRefresh(path, () async {
      return _client
          .delete(
            _uri(path, query: query),
            headers: await _headers(contentType: 'application/json'),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout);
    });
  }

  // ---- Refresh-on-401 wrapper ----

  // ============================================================
  // Absolute URL helpers (use when you already have full URL)
  // ============================================================
  Future<http.Response> getAbsolute(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    final uri = Uri.parse(url).replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
    return _sendWithRefresh(url, () async {
      return _client.get(uri, headers: await _headers()).timeout(_timeout);
    });
  }

  Future<http.Response> postAbsolute(
    String url, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    final uri = Uri.parse(url).replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
    return _sendWithRefresh(url, () async {
      final payload =
          body == null
              ? null
              : (body is String || body is List<int>)
              ? body
              : jsonEncode(body);
      return _client
          .post(
            uri,
            headers: await _headers(contentType: 'application/json'),
            body: payload,
          )
          .timeout(_timeout);
    });
  }

  Future<http.Response> deleteAbsolute(
    String url, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    final uri = Uri.parse(url).replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
    return _sendWithRefresh(url, () async {
      final payload =
          body == null
              ? null
              : (body is String || body is List<int>)
              ? body
              : jsonEncode(body);
      return _client
          .delete(
            uri,
            headers: await _headers(contentType: 'application/json'),
            body: payload,
          )
          .timeout(_timeout);
    });
  }

  Future<http.Response> _sendWithRefresh(
    String pathOrUrl,
    Future<http.Response> Function() request,
  ) async {
    final resp = await request();

    if (resp.statusCode != 401) {
      if (kDebugMode && resp.statusCode >= 400) {
        _debugLog('[ApiClient] Response status: ${resp.statusCode} for $pathOrUrl');
      }
      return resp;
    }

    if (kDebugMode) {
      _debugLog('[ApiClient] 401 Unauthorized received for $pathOrUrl');
    }

    if (!_shouldAttemptRefresh(pathOrUrl)) {
      if (kDebugMode) {
        _debugLog('[ApiClient] Not attempting refresh for auth endpoints');
      }
      return resp;
    }

    // 401: Try to refresh token
    if (kDebugMode) {
      _debugLog('[ApiClient] 401 received, attempting token refresh...');
    }

    final access = await AuthStorage.getAccessToken();
    final refresh = await AuthStorage.getRefreshToken();
    if (kDebugMode) {
      _debugLog(
        '[ApiClient] Tokens state - access: ${access != null ? 'Present' : 'Missing'}, refresh: ${refresh != null ? 'Present' : 'Missing'}',
      );
    }

    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      if (kDebugMode) {
        _debugLog('[ApiClient] Token refresh failed. Tokens may be expired.');
      }
      return resp;
    }

    if (kDebugMode) {
      _debugLog('[ApiClient] Token refresh succeeded, retrying request...');
    }
    // retry once after refresh
    return request();
  }

  Future<bool> _refreshAccessToken() async {
    final token = await AuthStorage.getRefreshToken();
    if (token == null || token.isEmpty) {
      _debugLog('[ApiClient] No refresh token available');
      return false;
    }

    try {
      // your backend uses @RequestParam refreshToken
      final uri = _uri('/auth/refresh', query: {'refreshToken': token});
      _debugLog('[ApiClient] Refreshing token at: $uri');

      final resp = await _client
          .post(uri, headers: await _headers(contentType: 'application/json'))
          .timeout(_timeout);

      _debugLog('[ApiClient] Refresh response: ${resp.statusCode}');

      if (resp.statusCode != 200) {
        _debugLog(
          '[ApiClient] Refresh failed: ${resp.statusCode} - ${resp.body}',
        );
        return false;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;

      if (newAccess == null || newAccess.isEmpty) {
        _debugLog('[ApiClient] Refresh response missing accessToken');
        return false;
      }

      await _saveTokens(access: newAccess, refresh: newRefresh);
      _debugLog('[ApiClient] Tokens refreshed successfully');
      return true;
    } catch (e) {
      _debugLog('[ApiClient] Token refresh exception: $e');
      return false;
    }
  }
}
