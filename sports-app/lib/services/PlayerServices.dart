import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/player.dart';
import 'ApiService.dart';
import '../controllers/session_controller.dart';

/// Player API service
class PlayerService {
  final ApiClient _api;
  PlayerService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  // ---------------------------
  // Public API
  // ---------------------------

  /// GET /players
  Future<List<Player>> getAllPlayers() async {
    try {
      final res = await _api.get('/players');
      final decoded = _decode(res.bodyBytes);
      final payload = _unwrap(decoded);
      final list = _asList(payload);

      final players = <Player>[];
      for (final e in list) {
        if (e == null) continue;
        final m = _asMap(e);
        if (m['id'] == null) continue; // skip malformed row
        try {
          players.add(Player.fromJson(m));
        } catch (_) {
          // swallow individual row parse errors
        }
      }
      return players;
    } catch (e) {
      debugPrint('getAllPlayers error: $e');
      rethrow;
    }
  }

  /// GET /players/{id}
  Future<Player?> getPlayerById(int id) async {
    try {
      final res = await _api.get('/players/$id');
      final decoded = _decode(res.bodyBytes);
      final payload = _unwrap(decoded);
      if (payload == null) return null;
      return Player.fromJson(_asMap(payload));
    } catch (e) {
      debugPrint('getPlayerById($id) error: $e');
      rethrow;
    }
  }

  /// GET /players/division/{divisionId}
  Future<List<Player>> getPlayersByDivision(int divisionId) async {
    try {
      final res = await _api.get('/players/division/$divisionId');
      final decoded = _decode(res.bodyBytes);
      final payload = _unwrap(decoded);
      final list = _asList(payload);

      final players = <Player>[];
      for (final e in list) {
        if (e == null) continue;
        final m = _asMap(e);
        if (m['id'] == null) continue;
        try { players.add(Player.fromJson(m)); } catch (_) {}
      }
      return players;
    } catch (e) {
      debugPrint('getPlayersByDivision($divisionId) error: $e');
      rethrow;
    }
  }

  /// GET /players/unassigned
  Future<List<Player>> getUnassignedPlayers() async {
    try {
      final res = await _api.get('/players/unassigned');
      final decoded = _decode(res.bodyBytes);
      final payload = _unwrap(decoded);
      final list = _asList(payload);

      final players = <Player>[];
      for (final e in list) {
        if (e == null) continue;
        final m = _asMap(e);
        if (m['id'] == null) continue;
        try { players.add(Player.fromJson(m)); } catch (_) {}
      }
      return players;
    } catch (e) {
      debugPrint('getUnassignedPlayers error: $e');
      rethrow;
    }
  }

  /// POST /players
  Future<Player?> createPlayer(Map<String, dynamic> data) async {
    // Auto-assign division when admin/trainer is scoped to a division
    data = Map<String, dynamic>.from(data);
    if (!data.containsKey('divisionId') || data['divisionId'] == null) {
      final did = AppSession.instance.session.divisionId;
      if (did != null) data['divisionId'] = did;
    }

    try {
      final body = jsonEncode(_compact(data));
      final res = await _api.post('/players', body: body);
      final decoded = _decode(res.bodyBytes);
      final payload = _unwrap(decoded);
      if (payload == null) return null;
      return Player.fromJson(_asMap(payload));
    } catch (e) {
      debugPrint('createPlayer error: $e');
      rethrow;
    }
  }

  /// PUT /players/{playerId}
  Future<bool> updatePlayer({
    required int playerId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final body = jsonEncode(_compact(data));
      final res = await _api.put('/players/$playerId', body: body);
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('updatePlayer($playerId) error: $e');
      rethrow;
    }
  }

  /// PUT /players/{playerId}/stats
  Future<bool> updatePlayerStats({
    required int playerId,
    int? goals,
    int? assists,
    int? matches,
    double? rating,
    bool? played,
  }) async {
    try {
      final body = jsonEncode(_compact({
        'goals': goals,
        'assists': assists,
        'matches': matches,
        'rating': rating,
        'played': played,
      }));
      final res = await _api.put('/players/$playerId/stats', body: body);
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('updatePlayerStats($playerId) error: $e');
      rethrow;
    }
  }

  /// PUT /players/{id}/relations
  Future<bool> assignRelations({
    required int playerId,
    int? divisionId,
    int? trainerId,
    int? parentId,
  }) async {
    try {
      final body = jsonEncode(_compact({
        'divisionId': divisionId,
        'trainerId': trainerId,
        'parentId': parentId,
      }));
      final res = await _api.put('/players/$playerId/relations', body: body);
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('assignRelations($playerId) error: $e');
      rethrow;
    }
  }

  /// DELETE /players/{id}
  Future<bool> deletePlayer(int id) async {
    try {
      final res = await _api.delete('/players/$id');
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('deletePlayer($id) error: $e');
      rethrow;
    }
  }

  /// POST /players/search/advanced
  Future<List<Player>> searchPlayersAdvanced(Map<String, dynamic> filters) async {
    try {
      final body = jsonEncode(_compact(filters));
      final res = await _api.post('/players/search/advanced', body: body);
      final decoded = _decode(res.bodyBytes);
      final payload = _unwrap(decoded);
      final list = _asList(payload);

      final players = <Player>[];
      for (final e in list) {
        if (e == null) continue;
        final m = _asMap(e);
        if (m['id'] == null) continue;
        try { players.add(Player.fromJson(m)); } catch (_) {}
      }
      return players;
    } catch (e) {
      debugPrint('searchPlayersAdvanced error: $e');
      rethrow;
    }
  }

  /// GET /players/search?name=...
  Future<List<Player>> searchPlayers(String name) async {
    try {
      final encoded = Uri.encodeQueryComponent(name);
      final res = await _api.get('/players/search?name=$encoded');
      final decoded = _decode(res.bodyBytes);
      final payload = _unwrap(decoded);
      final list = _asList(payload);

      final players = <Player>[];
      for (final e in list) {
        if (e == null) continue;
        final m = _asMap(e);
        if (m['id'] == null) continue;
        try { players.add(Player.fromJson(m)); } catch (_) {}
      }
      return players;
    } catch (e) {
      debugPrint('searchPlayers("$name") error: $e');
      rethrow;
    }
  }

  // ---------------------------
  // Helpers (robust decoding)
  // ---------------------------

  dynamic _decode(List<int> bodyBytes) {
    final raw = utf8.decode(bodyBytes);
    if (raw.trim().isEmpty) return null;
    return jsonDecode(raw);
  }

  /// Unwrap common patterns:
  /// - { data: ... }
  /// - { results: ... }
  /// - { content: ... }
  dynamic _unwrap(dynamic decoded) {
    if (decoded == null) return null;
    if (decoded is Map) {
      if (decoded['data'] != null) return decoded['data'];
      if (decoded['results'] != null) return decoded['results'];
      if (decoded['content'] != null) return decoded['content'];
    }
    return decoded; // no wrapper
  }

  List<dynamic> _asList(dynamic payload) {
    if (payload == null) return <dynamic>[];
    if (payload is List) return payload;
    if (payload is Map) {
      final candidates = ['items', 'players', 'list'];
      for (final k in candidates) {
        final v = payload[k];
        if (v is List) return v;
      }
    }
    return <dynamic>[payload]; // single object -> list of one
  }

  Map<String, dynamic> _asMap(dynamic payload) {
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return payload.map((k, v) => MapEntry(k.toString(), v));
    throw FormatException('Expected Map but got ${payload.runtimeType}');
  }

  /// Remove nulls and blank strings (backend-friendly body)
  Map<String, dynamic> _compact(Map<String, dynamic> data) {
    final out = <String, dynamic>{};
    data.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      out[k] = v;
    });
    return out;
  }
}


