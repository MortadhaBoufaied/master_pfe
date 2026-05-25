import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/scouting_models.dart';
import 'ApiService.dart';

class ScoutingService {
  final ApiClient _api = ApiClient();

  Future<List<Map<String, dynamic>>> getSports() async {
    final resp = await _api.get('/scouting-ai/sports');
    final data = _requireList(resp, op: 'load sports');
    return data;
  }

  Future<List<Map<String, dynamic>>> getSportDivisions(int sportId) async {
    final resp = await _api.get('/scouting-ai/sports/$sportId/divisions');
    return _requireList(resp, op: 'load sport divisions');
  }

  Future<Map<String, dynamic>> getSportFilters(int sportId) async {
    final resp = await _api.get('/scouting-ai/sports/$sportId/filters');
    return _requireMap(resp, op: 'load sport filters');
  }

  Future<ScoutingSearchResult> searchPlayers({
    String? q,
    String? position,
    int? ageMin,
    int? ageMax,
    double? minPotential,
    double? maxChurn,
    String? trendLabel,
    double? minAvgRating,
    int limit = 20,
  }) async {
    final resp = await _api.get(
      '/scouting/players/search',
      query: {
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (position != null && position.trim().isNotEmpty) 'position': position.trim(),
        if (ageMin != null) 'age_min': ageMin,
        if (ageMax != null) 'age_max': ageMax,
        if (minPotential != null) 'min_potential': minPotential,
        if (maxChurn != null) 'max_churn': maxChurn,
        if (trendLabel != null && trendLabel.trim().isNotEmpty) 'trend_label': trendLabel.trim(),
        if (minAvgRating != null) 'min_avg_rating': minAvgRating,
        'limit': limit,
      },
    );

    final data = _requireMap(resp, op: 'search players');
    return ScoutingSearchResult.fromJson(data);
  }

  Future<ScoutingSearchResult> searchSportPlayers({
    required int sportId,
    int? divisionId,
    String? q,
    Map<String, dynamic> filters = const {},
    String orderBy = 'potentialScore',
    int page = 0,
    int size = 20,
  }) async {
    final resp = await _api.post(
      '/scouting-ai/search',
      body: {
        'sportId': sportId,
        if (divisionId != null) 'divisionId': divisionId,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        'filters': filters,
        'orderBy': orderBy,
        'page': page,
        'size': size,
      },
    );
    final data = _requireMap(resp, op: 'sport scouting search');
    return ScoutingSearchResult.fromJson(data);
  }

  Future<ScoutingCompareResult> comparePlayers(List<int> playerExternalIds) async {
    final resp = await _api.post(
      '/scouting/players/compare',
      body: {
        'player_external_ids': playerExternalIds,
      },
    );

    final data = _requireMap(resp, op: 'compare players');
    return ScoutingCompareResult.fromJson(data);
  }

  Future<ScoutingShortlistResult> generateShortlist({
    required String title,
    required String strategy,
    String? q,
    String? position,
    int? ageMin,
    int? ageMax,
    double? minPotential,
    double? maxChurn,
    String? trendLabel,
    double? minAvgRating,
    int topN = 10,
  }) async {
    final resp = await _api.post(
      '/scouting/shortlists/generate',
      body: {
        'title': title,
        'strategy': strategy,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (position != null && position.trim().isNotEmpty) 'position': position.trim(),
        if (ageMin != null) 'age_min': ageMin,
        if (ageMax != null) 'age_max': ageMax,
        if (minPotential != null) 'min_potential': minPotential,
        if (maxChurn != null) 'max_churn': maxChurn,
        if (trendLabel != null && trendLabel.trim().isNotEmpty) 'trend_label': trendLabel.trim(),
        if (minAvgRating != null) 'min_avg_rating': minAvgRating,
        'top_n': topN,
      },
    );

    final data = _requireMap(resp, op: 'generate shortlist');
    return ScoutingShortlistResult.fromJson(data);
  }

  Future<Map<String, dynamic>> getPotential(int playerExternalId) async {
    final resp = await _api.get('/scouting/ml/potential/$playerExternalId');
    return _requireMap(resp, op: 'get potential');
  }

  Future<Map<String, dynamic>> getEvolution(int playerExternalId, {int window = 8}) async {
    final resp = await _api.get(
      '/scouting/ml/evolution/$playerExternalId',
      query: {'window': window},
    );
    return _requireMap(resp, op: 'get evolution');
  }

  Future<Map<String, dynamic>> getChurn(int playerExternalId) async {
    final resp = await _api.get('/scouting/ml/churn/$playerExternalId');
    return _requireMap(resp, op: 'get churn');
  }

  Future<Map<String, dynamic>> syncFromFootballAcademy({
    String? baseUrl,
    bool includePlayers = true,
    bool includePayments = true,
    bool createObservationSnapshot = true,
  }) async {
    final resp = await _api.post(
      '/scouting/sync',
      body: {
        if (baseUrl != null && baseUrl.trim().isNotEmpty) 'base_url': baseUrl.trim(),
        'include_players': includePlayers,
        'include_payments': includePayments,
        'create_observation_snapshot': createObservationSnapshot,
      },
    );

    return _requireMap(resp, op: 'sync sports academy');
  }

  Map<String, dynamic> _requireMap(http.Response resp, {required String op}) {
    final body = utf8.decode(resp.bodyBytes);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('$op failed (${resp.statusCode}): $body');
    }

    if (body.trim().isEmpty) return <String, dynamic>{};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw Exception('Unexpected response for $op: expected JSON object');
  }

  List<Map<String, dynamic>> _requireList(http.Response resp, {required String op}) {
    final body = utf8.decode(resp.bodyBytes);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('$op failed (${resp.statusCode}): $body');
    }
    if (body.trim().isEmpty) return const [];
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (decoded is Map && decoded['items'] is List) {
      return (decoded['items'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }
}

