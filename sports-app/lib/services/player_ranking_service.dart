import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'ApiService.dart';

/// Player Ranking DTO model
class PlayerRanking {
  final int playerId;
  final String playerName;
  final int rank;
  final double rankingScore;
  final String tier; // ELITE, CORE, DEVELOPING
  final int matchesPlayed;
  final int goals;
  final int assists;
  final double playerRating;

  PlayerRanking({
    required this.playerId,
    required this.playerName,
    required this.rank,
    required this.rankingScore,
    required this.tier,
    required this.matchesPlayed,
    required this.goals,
    required this.assists,
    required this.playerRating,
  });

  factory PlayerRanking.fromJson(Map<String, dynamic> json) {
    return PlayerRanking(
      playerId: json['playerId'] ?? 0,
      playerName: json['playerName'] ?? '',
      rank: json['rank'] ?? 0,
      rankingScore: (json['rankingScore'] ?? 0).toDouble(),
      tier: json['tier'] ?? 'DEVELOPING',
      matchesPlayed: json['matchesPlayed'] ?? 0,
      goals: json['goals'] ?? 0,
      assists: json['assists'] ?? 0,
      playerRating: (json['playerRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'playerName': playerName,
    'rank': rank,
    'rankingScore': rankingScore,
    'tier': tier,
    'matchesPlayed': matchesPlayed,
    'goals': goals,
    'assists': assists,
    'playerRating': playerRating,
  };
}

/// Player Ranking API service
class PlayerRankingService {
  final ApiClient _api;

  PlayerRankingService({ApiClient? apiClient}) 
      : _api = apiClient ?? ApiClient();

  // ---------------------------
  // Public API
  // ---------------------------

  /// GET /player-rankings/top?limit={limit}&divisionId={divisionId}&position={position}
  /// Returns top ranked players with full details
  /// [limit] - Number of top players to return (default: 10)
  /// [divisionId] - Optional: filter by division ID
  /// [position] - Optional: filter by position (FWD, MID, DEF, GK)
  Future<List<PlayerRanking>> getTopPlayers({
    int limit = 10,
    int? divisionId,
    String? position,
  }) async {
    try {
      String url = '/player-rankings/top?limit=$limit';
      if (divisionId != null) {
        url += '&divisionId=$divisionId';
      }
      if (position != null) {
        url += '&position=$position';
      }

      final res = await _api.get(url);
      final decoded = _decode(res.bodyBytes);
      final payload = _unwrap(decoded);
      final list = _asList(payload);

      final rankings = <PlayerRanking>[];
      for (final e in list) {
        if (e == null) continue;
        final m = _asMap(e);
        if (m['playerId'] == null) continue; // skip malformed row
        try {
          rankings.add(PlayerRanking.fromJson(m));
        } catch (err) {
          debugPrint('PlayerRanking parse error: $err');
          // swallow individual row parse errors
        }
      }
      return rankings;
    } catch (e) {
      debugPrint('getTopPlayers error: $e');
      rethrow;
    }
  }

  /// GET /player-rankings/top/ids?limit={limit}
  /// Returns only top player IDs (lightweight)
  /// [limit] - Number of top players to return (default: 10)
  Future<List<int>> getTopPlayerIds({int limit = 10}) async {
    try {
      final res = await _api.get('/player-rankings/top/ids?limit=$limit');
      final decoded = _decode(res.bodyBytes);
      final payload = _unwrap(decoded);
      final list = _asList(payload);

      final ids = <int>[];
      for (final e in list) {
        if (e == null) continue;
        try {
          if (e is int) {
            ids.add(e);
          } else if (e is double) {
            ids.add(e.toInt());
          }
        } catch (_) {
          // swallow individual row parse errors
        }
      }
      return ids;
    } catch (e) {
      debugPrint('getTopPlayerIds error: $e');
      rethrow;
    }
  }

  /// POST /player-rankings/recompute
  /// Manually triggers player ranking recomputation
  /// (Usually runs automatically at 02:05 AM daily)
  Future<void> recomputeRankings() async {
    try {
      await _api.post('/player-rankings/recompute');
    } catch (e) {
      debugPrint('recomputeRankings error: $e');
      rethrow;
    }
  }

  /// Convenience method: Get top scorers (sorted by goals)
  Future<List<PlayerRanking>> getTopScorers({int limit = 10, int? divisionId}) async {
    return getTopPlayers(
      limit: limit,
      divisionId: divisionId,
      position: 'FWD',
    );
  }

  /// Convenience method: Get top defenders
  Future<List<PlayerRanking>> getTopDefenders({int limit = 10, int? divisionId}) async {
    return getTopPlayers(
      limit: limit,
      divisionId: divisionId,
      position: 'DEF',
    );
  }

  // ---------------------------
  // Private helpers
  // ---------------------------

  static dynamic _decode(List<int> bytes) {
    return jsonDecode(utf8.decode(bytes));
  }

  static dynamic _unwrap(dynamic obj) {
    // Handle "{\"data\": [...]}" or "{\"status\": \"success\", \"data\": [...]}"
    if (obj is Map<String, dynamic>) {
      if (obj.containsKey('data')) return obj['data'];
    }
    return obj;
  }

  static List<dynamic> _asList(dynamic obj) {
    if (obj is List) return obj;
    if (obj is Map) return [];
    return [];
  }

  static Map<String, dynamic> _asMap(dynamic obj) {
    if (obj is Map) return obj.cast<String, dynamic>();
    return {};
  }
}


