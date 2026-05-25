import 'dart:convert';

import 'ApiService.dart';

class PlayerDevelopmentService {
  final ApiClient _api;

  PlayerDevelopmentService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  Future<Map<String, dynamic>?> createObservation({
    required int playerId,
    required String sourceType,
    int? sourceId,
    required double summaryRating,
    required double rolePerformanceIndex,
    required double confidence,
    String? notes,
    Map<String, num>? metrics,
    DateTime? observedAt,
  }) async {
    final response = await _api.post(
      '/scouting/performance/observations',
      body: _compact({
        'playerId': playerId,
        'sourceType': sourceType,
        'sourceId': sourceId,
        'observedAt': (observedAt ?? DateTime.now()).toIso8601String().split('.').first,
        'summaryRating': summaryRating,
        'rolePerformanceIndex': rolePerformanceIndex,
        'confidence': confidence,
        'notes': notes,
        'metrics': metrics,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _asMap(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw ApiException(
      message: _error(response.bodyBytes, 'Could not save player report'),
      statusCode: response.statusCode,
    );
  }

  Future<List<Map<String, dynamic>>> getPlayerHistory(int playerId) async {
    final response = await _api.get('/scouting/performance/players/$playerId/history');
    if (response.statusCode == 200) {
      return _asList(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw ApiException(
      message: _error(response.bodyBytes, 'Could not load player history'),
      statusCode: response.statusCode,
    );
  }

  Future<List<Map<String, dynamic>>> getSportMetrics(int sportId) async {
    final response = await _api.get('/sport-statistics/sport/$sportId');
    if (response.statusCode == 200) {
      return _asList(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    return [];
  }

  Future<Map<String, dynamic>?> recordInjury({
    required int playerId,
    required String injuryType,
    required String severity,
    required String startDate,
    String? endDate,
    String? notes,
    bool recovered = false,
  }) async {
    final response = await _api.post(
      '/injuries',
      body: _compact({
        'playerId': playerId,
        'injuryType': injuryType,
        'severity': severity,
        'startDate': startDate,
        'endDate': endDate,
        'recovered': recovered,
        'notes': notes,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return _asMap(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw ApiException(
      message: _error(response.bodyBytes, 'Could not save injury'),
      statusCode: response.statusCode,
    );
  }

  Future<List<Map<String, dynamic>>> getPlayerInjuries(int playerId) async {
    final response = await _api.get('/injuries/player/$playerId');
    if (response.statusCode == 200) {
      return _asList(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    return [];
  }

  Future<bool> recoverInjury(int injuryId, {String? endDate}) async {
    final response = await _api.post(
      '/injuries/$injuryId/recover',
      body: _compact({'endDate': endDate}),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Map<String, dynamic> _compact(Map<String, dynamic> data) {
    final out = <String, dynamic>{};
    data.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is Map && value.isEmpty) return;
      out[key] = value;
    });
    return out;
  }

  List<Map<String, dynamic>> _asList(dynamic decoded) {
    if (decoded is List) {
      return decoded.whereType<Map>().map((item) => _asMap(item)).toList();
    }
    if (decoded is Map) return [_asMap(decoded)];
    return [];
  }

  Map<String, dynamic> _asMap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  String _error(List<int> bodyBytes, String fallback) {
    try {
      final decoded = jsonDecode(utf8.decode(bodyBytes));
      if (decoded is Map && decoded['error'] != null) return decoded['error'].toString();
      if (decoded is Map && decoded['message'] != null) return decoded['message'].toString();
    } catch (_) {}
    return fallback;
  }
}
