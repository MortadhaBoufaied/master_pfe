import 'dart:convert';

import 'ApiService.dart';

class ScouterDashboardService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getDashboard({
    int? sportId,
    int? academyId,
    int? divisionId,
    String? watchStatus,
    String? priority,
  }) async {
    final response = await _api.get(
      '/scouter/dashboard',
      query: {
        if (sportId != null) 'sportId': sportId,
        if (academyId != null) 'academyId': academyId,
        if (divisionId != null) 'divisionId': divisionId,
        if (watchStatus != null && watchStatus.isNotEmpty) 'watchStatus': watchStatus,
        if (priority != null && priority.isNotEmpty) 'priority': priority,
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Dashboard failed: ${response.statusCode}');
  }

  Future<void> updateWatchedPlayer({
    required int watchId,
    String? watchStatus,
    String? priority,
    String? notes,
  }) async {
    final response = await _api.put(
      '/scouter/watched-players/$watchId',
      body: {
        if (watchStatus != null) 'watchStatus': watchStatus,
        if (priority != null) 'priority': priority,
        if (notes != null) 'notes': notes,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Update failed: ${response.statusCode}');
    }
  }
}
