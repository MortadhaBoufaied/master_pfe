import 'package:flutter/foundation.dart';

import '../models/scouting_models.dart';
import '../services/scouting_service.dart';

class ScoutingController extends ChangeNotifier {
  ScoutingController({ScoutingService? service})
      : _service = service ?? ScoutingService();

  final ScoutingService _service;

  bool loading = false;
  bool syncing = false;
  String? error;

  List<Map<String, dynamic>> sports = [];
  List<Map<String, dynamic>> sportDivisions = [];
  List<Map<String, dynamic>> sportFilters = [];
  String? selectedSportName;

  List<ScoutingPlayerCard> searchResults = [];
  List<ScoutingPlayerCard> comparedPlayers = [];
  Map<String, int> compareHighlights = {};

  String shortlistTitle = 'Scouting Shortlist';
  String shortlistStrategy = 'balanced';
  List<ScoutingPlayerCard> shortlistPlayers = [];

  final Map<int, Map<String, dynamic>> potentialByPlayer = {};
  final Map<int, Map<String, dynamic>> evolutionByPlayer = {};
  final Map<int, Map<String, dynamic>> churnByPlayer = {};

  Future<void> loadSports() async {
    error = null;
    notifyListeners();

    try {
      sports = await _service.getSports();
    } catch (e) {
      error = e.toString();
      sports = [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadSportTemplate(int? sportId) async {
    error = null;
    if (sportId == null) {
      sportDivisions = [];
      sportFilters = [];
      selectedSportName = null;
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    try {
      final result = await Future.wait<dynamic>([
        _service.getSportDivisions(sportId),
        _service.getSportFilters(sportId),
      ]);

      sportDivisions = result[0] as List<Map<String, dynamic>>;
      final config = result[1] as Map<String, dynamic>;
      selectedSportName = config['sportName']?.toString();
      sportFilters = (config['filters'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      error = e.toString();
      sportDivisions = [];
      sportFilters = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> search({
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
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.searchPlayers(
        q: q,
        position: position,
        ageMin: ageMin,
        ageMax: ageMax,
        minPotential: minPotential,
        maxChurn: maxChurn,
        trendLabel: trendLabel,
        minAvgRating: minAvgRating,
        limit: limit,
      );
      searchResults = result.items;
    } catch (e) {
      error = e.toString();
      searchResults = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> searchSportPlayers({
    required int sportId,
    int? divisionId,
    String? q,
    Map<String, dynamic> filters = const {},
    String orderBy = 'potentialScore',
    int page = 0,
    int size = 30,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.searchSportPlayers(
        sportId: sportId,
        divisionId: divisionId,
        q: q,
        filters: filters,
        orderBy: orderBy,
        page: page,
        size: size,
      );
      searchResults = result.items;
    } catch (e) {
      error = e.toString();
      searchResults = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> compare(List<int> playerExternalIds) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.comparePlayers(playerExternalIds);
      comparedPlayers = result.players;
      compareHighlights = result.highlights;
    } catch (e) {
      error = e.toString();
      comparedPlayers = [];
      compareHighlights = {};
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> generateShortlist({
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
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.generateShortlist(
        title: title,
        strategy: strategy,
        q: q,
        position: position,
        ageMin: ageMin,
        ageMax: ageMax,
        minPotential: minPotential,
        maxChurn: maxChurn,
        trendLabel: trendLabel,
        minAvgRating: minAvgRating,
        topN: topN,
      );

      shortlistTitle = result.title;
      shortlistStrategy = result.strategy;
      shortlistPlayers = result.players;
    } catch (e) {
      error = e.toString();
      shortlistPlayers = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadInsights(int playerExternalId, {int window = 8}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final potential = await _service.getPotential(playerExternalId);
      final evolution = await _service.getEvolution(playerExternalId, window: window);
      final churn = await _service.getChurn(playerExternalId);

      potentialByPlayer[playerExternalId] = potential;
      evolutionByPlayer[playerExternalId] = evolution;
      churnByPlayer[playerExternalId] = churn;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> syncFromBackend() async {
    syncing = true;
    error = null;
    notifyListeners();

    try {
      return await _service.syncFromFootballAcademy();
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  String formatPercent(double value) {
    return (value * 100).toStringAsFixed(1);
  }
}


