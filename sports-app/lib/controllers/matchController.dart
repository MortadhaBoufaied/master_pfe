import 'package:flutter/foundation.dart';
import '../services/match_service.dart';
import '../models/match.dart';

class MatchController extends ChangeNotifier {
  String _norm(String? s) => (s ?? '').trim().toLowerCase();
  final MatchService _service = MatchService();
  List<MatchModel> matches = [];
  bool loading = false;
  String? error;

  Future<void> loadAll() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      matches = await _service.getAll();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> create(Map<String, dynamic> body) async {
    try {
      final m = await _service.create(body);
      if (m != null) {
        matches.insert(0, m);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> body) async {
    try {
      final m = await _service.update(id, body);
      if (m != null) {
        final i = matches.indexWhere((x) => x.id == id);
        if (i >= 0) matches[i] = m;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      final ok = await _service.delete(id);
      if (ok) {
        matches.removeWhere((x) => x.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Nouvelle m pour filtrer les matchs
  List<MatchModel> filterByStatus(String status) {
    if (status == 'all') return matches;
    return matches.where((match) => match.result?.toLowerCase() == status).toList();
  }

  // Nouvelle m pour obtenir les statistiques
  Map<String, dynamic> getStatistics() {
    final total = matches.length;
    final wins = matches.where((m) => _norm(m.result) == 'win' || _norm(m.result) == 'won').length;
    final losses = matches.where((m) => _norm(m.result) == 'loss' || _norm(m.result) == 'lost').length;
    final draws = matches.where((m) => _norm(m.result) == 'draw' || _norm(m.result) == 'tie').length;

    return {
      'total': total,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'winRate': total > 0 ? (wins / total * 100).toStringAsFixed(1) : '0.0',
    };
  }
}


