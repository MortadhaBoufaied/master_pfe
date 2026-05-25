import 'package:flutter/foundation.dart';
import '../services/PlayerServices.dart';
import '../services/payment_service.dart';
import '../services/division_service.dart';
import '../services/match_service.dart';
import '../services/activity_service.dart';
import '../models/player.dart';
import '../models/payment.dart';
import '../models/division.dart';
import '../models/match.dart';
import '../models/activity.dart';

class StatisticsController extends ChangeNotifier {
  final PlayerService _playerService = PlayerService();
  final PaymentService _paymentService = PaymentService();
  final DivisionService _divisionService = DivisionService();
  final MatchService _matchService = MatchService();
  final ActivityService _activityService = ActivityService();

  bool isLoading = false;
  String? error;

  Map<String, dynamic> playerStats = {};
  Map<String, dynamic> divisionStats = {};
  Map<String, dynamic> financialStats = {};
  Map<String, dynamic> activityStats = {};

  Future<void> loadAllStatistics() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadPlayerStatistics(),
        _loadDivisionStatistics(),
        _loadFinancialStatistics(),
        _loadActivityStatistics(),
      ]);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --------------------- PLAYERS ---------------------

  Future<void> _loadPlayerStatistics() async {
    try {
      final players = await _playerService.getAllPlayers();

      final totalPlayers = players.length;
      final totalGoals = players.fold<int>(0, (sum, p) => sum + (p.goals ?? 0));
      final totalAssists = players.fold<int>(0, (sum, p) => sum + (p.assists ?? 0));
      final totalMatches = players.fold<int>(0, (sum, p) => sum + (p.matches ?? 0));
      final averageRating = players.isNotEmpty
          ? players.fold<double>(0.0, (sum, p) => sum + (p.rating ?? 0)) / players.length
          : 0.0;

      final positionDistribution = <String, int>{};
      for (final player in players) {
        final pos = player.position;
        if (pos != null && pos.isNotEmpty) {
          positionDistribution[pos] = (positionDistribution[pos] ?? 0) + 1;
        }
      }

      // Top 5 scorers / assists (fixed: .take(5).toList())
      final topScorers = List<Player>.from(players)
        ..sort((a, b) => (b.goals ?? 0).compareTo(a.goals ?? 0));
      final topAssists = List<Player>.from(players)
        ..sort((a, b) => (b.assists ?? 0).compareTo(a.assists ?? 0));

      playerStats = {
        'total_players': totalPlayers,
        'total_goals': totalGoals,
        'total_assists': totalAssists,
        'total_matches': totalMatches,
        'average_rating': averageRating.toStringAsFixed(2),
        'position_distribution': positionDistribution,
        'top_scorers': topScorers.take(5).map((p) => {
          'name': p.nom ?? 'Unknown',
          'goals': p.goals ?? 0,
        }).toList(),
        'top_assists': topAssists.take(5).map((p) => {
          'name': p.nom ?? 'Unknown',
          'assists': p.assists ?? 0,
        }).toList(),
        'players_by_age_group': _groupPlayersByAge(players),
      };
    } catch (e) {
      throw Exception('Failed to load player statistics: $e');
    }
  }

  Map<String, int> _groupPlayersByAge(List<Player> players) {
    final ageGroups = <String, int>{
      'Under 18': 0,
      '18-21': 0,
      '22-25': 0,
      '26-30': 0,
      'Over 30': 0,
    };
    for (final p in players) {
      final age = p.age ?? 0;
      if (age < 18) {
        ageGroups['Under 18'] = ageGroups['Under 18']! + 1;
      } else if (age <= 21) {
        ageGroups['18-21'] = ageGroups['18-21']! + 1;
      } else if (age <= 25) {
        ageGroups['22-25'] = ageGroups['22-25']! + 1;
      } else if (age <= 30) {
        ageGroups['26-30'] = ageGroups['26-30']! + 1;
      } else {
        ageGroups['Over 30'] = ageGroups['Over 30']! + 1;
      }
    }
    return ageGroups;
  }

  List<Map<String, dynamic>> getPlayerAgeDistribution() {
    final ageGroups =
        (playerStats['players_by_age_group'] as Map<String, int>?) ?? {};
    return ageGroups.entries
        .map((e) => {'ageGroup': e.key, 'count': e.value})
        .toList();
  }

  List<Map<String, dynamic>> getPositionDistribution() {
    final distribution =
        (playerStats['position_distribution'] as Map<String, int>?) ?? {};
    return distribution.entries
        .map((e) => {'position': e.key, 'count': e.value})
        .toList();
  }

  // --------------------- DIVISIONS ---------------------

  Future<void> _loadDivisionStatistics() async {
    try {
      final divisions = await _divisionService.getAllDivisions();
      final totalDivisions = divisions.length;
      final totalPlayersInDivisions =
      divisions.fold<int>(0, (sum, d) => sum + (d.playersCount ?? 0));
      final averagePlayersPerDivision = totalDivisions > 0
          ? (totalPlayersInDivisions / totalDivisions)
          : 0.0;

      final categoryDistribution = <String, int>{};
      for (final d in divisions) {
        final cat = d.categorie;
        if (cat != null && cat.isNotEmpty) {
          categoryDistribution[cat] = (categoryDistribution[cat] ?? 0) + 1;
        }
      }

      final topDivisionsByPlayers = List<Division>.from(divisions)
        ..sort((a, b) => (b.playersCount ?? 0).compareTo(a.playersCount ?? 0));

      divisionStats = {
        'total_divisions': totalDivisions,
        'total_players_in_divisions': totalPlayersInDivisions,
        'average_players_per_division': averagePlayersPerDivision.toStringAsFixed(1),
        'category_distribution': categoryDistribution,
        'top_divisions_by_players': topDivisionsByPlayers.take(5).map((d) => {
          'name': d.nom ?? 'Unknown',
          'players_count': d.playersCount ?? 0,
          'coaches_count': d.coachesCount ?? 0,
        }).toList(),
      };
    } catch (e) {
      throw Exception('Failed to load division statistics: $e');
    }
  }

  // --------------------- FINANCE ---------------------

  Future<void> _loadFinancialStatistics() async {
    try {
      final allPayments = await _paymentService.getAllPayments();

      final totalRevenue =
      allPayments.fold<double>(0.0, (sum, p) => sum + (p.montant));
      final paidRevenue = allPayments
          .where((p) => p.isPaid)
          .fold<double>(0.0, (sum, p) => sum + (p.montant));
      final pendingRevenue = allPayments
          .where((p) => !p.isPaid)
          .fold<double>(0.0, (sum, p) => sum + (p.montant));

      final revenueByMonth = <String, double>{};
      for (final payment in allPayments.where((p) => p.isPaid)) {
        final m = payment.mois;
        final monthKey = '${m.year}-${m.month.toString().padLeft(2, '0')}';
        revenueByMonth[monthKey] = (revenueByMonth[monthKey] ?? 0.0) + payment.montant;
      }

      final paymentRate = totalRevenue > 0
          ? ((paidRevenue / totalRevenue) * 100).toStringAsFixed(1)
          : '0';

      financialStats = {
        'total_revenue': totalRevenue,
        'paid_revenue': paidRevenue,
        'pending_revenue': pendingRevenue,
        'payment_rate': paymentRate,
        'revenue_by_month': revenueByMonth,
        'total_payments_count': allPayments.length,
        'paid_payments_count': allPayments.where((p) => p.isPaid).length,
        'pending_payments_count': allPayments.where((p) => !p.isPaid).length,
      };
    } catch (e) {
      throw Exception('Failed to load financial statistics: $e');
    }
  }

  List<Map<String, dynamic>> getRevenueByMonth() {
    final map =
        (financialStats['revenue_by_month'] as Map<String, double>?) ?? {};
    return map.entries
        .map((e) => {'month': e.key, 'revenue': e.value})
        .toList();
  }

  // --------------------- ACTIVITIES ---------------------

  Future<void> _loadActivityStatistics() async {
    try {
      final activities = await _activityService.getAllActivities();
      final matches = await _matchService.getAll();

      final totalActivities = activities.length;
      final totalMatches = matches.length;

      final activitiesByMonth = <String, int>{};
      for (final a in activities) {
        final d = a.date; // expect 'YYYY-MM-DD' or 'YYYY-MM'
        if (d.isNotEmpty) {
          final monthKey = d.length >= 7 ? d.substring(0, 7) : d;
          activitiesByMonth[monthKey] = (activitiesByMonth[monthKey] ?? 0) + 1;
        }
      }

      final matchResults = <String, int>{
        'Win': 0,
        'Loss': 0,
        'Draw': 0,
        'Unknown': 0,
      };

      for (final m in matches) {
        final res = (m.result ?? '').toLowerCase();
        if (res.contains('win')) {
          matchResults['Win'] = matchResults['Win']! + 1;
        } else if (res.contains('loss')) {
          matchResults['Loss'] = matchResults['Loss']! + 1;
        } else if (res.contains('draw')) {
          matchResults['Draw'] = matchResults['Draw']! + 1;
        } else {
          matchResults['Unknown'] = matchResults['Unknown']! + 1;
        }
      }

      activityStats = {
        'total_activities': totalActivities,
        'total_matches': totalMatches,
        'activities_by_month': activitiesByMonth,
        'match_results': matchResults,
        'win_rate': totalMatches > 0
            ? (matchResults['Win']! / totalMatches * 100).toStringAsFixed(1)
            : '0',
      };
    } catch (e) {
      throw Exception('Failed to load activity statistics: $e');
    }
  }

  List<Map<String, dynamic>> getMatchResults() {
    final map = (activityStats['match_results'] as Map<String, int>?) ?? {};
    return map.entries
        .map((e) => {'result': e.key, 'count': e.value})
        .toList();
  }

  // --------------------- SUMMARY ---------------------

  Map<String, dynamic> getSummary() {
    final topScorers = (playerStats['top_scorers'] as List?)
        ?.cast<Map<String, dynamic>>() ??
        const [];
    final firstTop = topScorers.isNotEmpty ? topScorers.first : null;

    return {
      'players': {
        'total': playerStats['total_players'] ?? 0,
        'top_scorer': firstTop?['name'] ?? 'N/A',
        'top_scorer_goals': firstTop?['goals'] ?? 0,
      },
      'divisions': {
        'total': divisionStats['total_divisions'] ?? 0,
        'average_players': divisionStats['average_players_per_division'] ?? '0',
      },
      'finance': {
        'total_revenue': financialStats['total_revenue'] ?? 0.0,
        'payment_rate': financialStats['payment_rate'] ?? '0',
      },
      'activities': {
        'total': activityStats['total_activities'] ?? 0,
        'win_rate': activityStats['win_rate'] ?? '0',
      },
    };
  }
}


