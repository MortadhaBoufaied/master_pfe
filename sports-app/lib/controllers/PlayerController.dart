import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/PlayerServices.dart';

class PlayerController extends ChangeNotifier {
  final PlayerService _service = PlayerService();

  List<Player> players = [];
  bool loading = false;
  String? error;

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setError(Object e) {
    error = e.toString();
    notifyListeners();
  }

  Future<void> loadPlayers() async {
    _setLoading(true);
    error = null;
    try {
      players = await _service.getAllPlayers();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Player>> loadPlayersByDivision(int divisionId) async {
    _setLoading(true);
    error = null;
    try {
      players = await _service.getPlayersByDivision(divisionId);
      return players;
    } catch (e) {
      _setError(e);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Player>> searchPlayersAdvanced(
      Map<String, dynamic> filters) async {
    try {
      return await _service.searchPlayersAdvanced(filters);
    } catch (e) {
      _setError(e);
      return [];
    }
  }

  Future<Player?> getPlayerById(int id) async {
    try {
      return await _service.getPlayerById(id);
    } catch (e) {
      _setError(e);
      return null;
    }
  }

  Future<Player?> createPlayer(Map<String, dynamic> data) async {
    try {
      final created = await _service.createPlayer(data);
      if (created != null) {
        players.add(created);
        notifyListeners();
      }
      return created;
    } catch (e) {
      _setError(e);
      return null;
    }
  }

  Future<bool> updatePlayer({
    required int playerId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final ok = await _service.updatePlayer(playerId: playerId, data: data);
      if (!ok) return false;

      final updated = await _service.getPlayerById(playerId);
      if (updated != null) {
        final idx = players.indexWhere((p) => p.id == playerId);
        if (idx >= 0) {
          players[idx] = updated;
        } else {
          players.add(updated);
        }
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> updatePlayerStats({
    required int playerId,
    int? goals,
    int? assists,
    int? matches,
    double? rating,
    bool? played,
  }) async {
    try {
      final ok = await _service.updatePlayerStats(
        playerId: playerId,
        goals: goals,
        assists: assists,
        matches: matches,
        rating: rating,
        played: played,
      );
      if (!ok) return false;

      // update local list only (no extra API call)
      final idx = players.indexWhere((p) => p.id == playerId);
      if (idx >= 0) {
        players[idx] = players[idx].copyWith(
          goals: goals ?? players[idx].goals,
          assists: assists ?? players[idx].assists,
          matches: matches ?? players[idx].matches,
          rating: rating ?? players[idx].rating,
          played: played ?? players[idx].played,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> deletePlayer(int id) async {
    try {
      final ok = await _service.deletePlayer(id);
      if (ok) {
        players.removeWhere((p) => p.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      _setError(e);
      return false;
    }
  }
}


