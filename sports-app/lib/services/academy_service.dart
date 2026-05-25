import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/academy_info.dart';
import 'ApiService.dart';

class AcademyService {
  final ApiClient _api = ApiClient();

  /// Tries common academy info endpoints; update paths if your backend differs.
  Future<AcademyInfo?> getAcademyInfo() async {
    final candidates = <String>[
      '/academy',
      '/academy/info',
      '/admin/academy',
      '/profile/academy',
    ];

    int? lastStatus;
    String? lastBodyPreview;
    String? lastPath;
    bool sawAuthError = false;

    for (final path in candidates) {
      try {
        final resp = await _api.get(path);
        lastStatus = resp.statusCode;
        lastPath = path;

        if (kDebugMode) {
          debugPrint(
            '[AcademyService] GET $path - Status: ${resp.statusCode}',
          );
        }

        // Only treat 401/403 from the first endpoint as auth error
        // Other endpoints might legitimately not exist (404) or be forbidden for this user (403)
        if (path == '/academy' && (resp.statusCode == 401 || resp.statusCode == 403)) {
          sawAuthError = true;
          if (kDebugMode) {
            debugPrint(
              '[AcademyService] Auth error on primary endpoint. Status: ${resp.statusCode}',
            );
          }
        }

        if (resp.statusCode == 200) {
          final body = utf8.decode(resp.bodyBytes);
          if (kDebugMode) {
            lastBodyPreview =
                body.length > 280 ? '${body.substring(0, 280)}ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦' : body;
          }
          final decoded = jsonDecode(body);
          if (decoded is Map) {
            final data = Map<String, dynamic>.from(decoded);
            final innerRaw = data['data'];
            final inner =
                innerRaw is Map ? Map<String, dynamic>.from(innerRaw) : data;

            final hasId =
                inner.containsKey('id') ||
                inner.containsKey('academyId') ||
                inner.containsKey('academy_id');
            final hasName =
                inner.containsKey('name') ||
                inner.containsKey('nom') ||
                inner.containsKey('academyName');

            if (hasName && (hasId || inner['id'] != null)) {
              return AcademyInfo.fromJson(inner);
            }

            // Some endpoints may return { academy: {...} } or { info: {...} }.
            final nested =
                (inner['academy'] is Map)
                    ? Map<String, dynamic>.from(inner['academy'] as Map)
                    : (inner['info'] is Map)
                    ? Map<String, dynamic>.from(inner['info'] as Map)
                    : null;
            if (nested != null) {
              return AcademyInfo.fromJson(nested);
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[AcademyService] Exception on $path: $e');
        }
        // try next
      }
    }

    if (kDebugMode && lastPath != null) {
      debugPrint(
        '[AcademyService] Academy info not resolved. lastPath=$lastPath lastStatus=$lastStatus bodyPreview=${lastBodyPreview ?? ''}',
      );
    }

    if (sawAuthError) {
      throw Exception(
        'Unauthorized to load academy info. Please sign in again.',
      );
    }
    return null;
  }
}


