import 'package:flutter/foundation.dart';

import '../models/activity.dart';
import '../models/division.dart';
import '../models/match.dart';
import '../models/parent.dart';
import '../models/payment.dart';
import '../models/player.dart';
import '../models/trainer.dart';

import '../services/activity_service.dart';
import '../services/division_service.dart';
import '../services/match_service.dart';
import '../services/parent_service.dart';
import '../services/payment_service.dart';
import '../services/PlayerServices.dart';
import '../services/trainer_service.dart';

class DataManagementController extends ChangeNotifier {
  static const int unassignedDivisionKey = -1;

  final DivisionService _divisionService = DivisionService();
  final PlayerService _playerService = PlayerService();
  final TrainerService _trainerService = TrainerService();
  final ParentService _parentService = ParentService();
  final MatchService _matchService = MatchService();
  final ActivityService _activityService = ActivityService();
  final PaymentService _paymentService = PaymentService();

  bool isLoading = false;
  String? error;

  List<Division> academyDivisions = [];
  List<Division> allDivisions = [];
  List<Player> allPlayers = [];
  List<Player> unassignedPlayersRemote = [];
  List<Trainer> allTrainers = [];
  List<Parent> allParents = [];
  List<MatchModel> allMatches = [];
  List<Activity> allActivities = [];

  final Map<int, List<Payment>> _paymentsByPlayer = {};
  int? _paymentsLoadedForDivision;

  int? selectedDivisionId;
  bool get isAllSelected => selectedDivisionId == null;
  bool get isUnassignedSelected => selectedDivisionId == unassignedDivisionKey;

  Future<void> bootstrap() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await Future.wait([
        refreshDivisions(),
        refreshPlayers(),
        refreshUnassignedPlayers(),
        refreshTrainers(),
        refreshParents(),
        refreshMatches(),
        refreshActivities(),
      ]);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // CRUD wrappers used by tabs
  Future<bool> createActivity(Activity a) async {
    final created = await _activityService.createActivity(a);
    if (created != null) { await refreshActivities(); return true; }
    return false;
  }
  Future<bool> updateActivity(int id, Activity a) async {
    final updated = await _activityService.updateActivity(id, a);
    if (updated != null) { await refreshActivities(); return true; }
    return false;
  }
  Future<bool> deleteActivity(int id) async {
    final ok = await _activityService.deleteActivity(id);
    if (ok) await refreshActivities();
    return ok;
  }
  Future<bool> deleteMatch(int id) async {
    final ok = await _matchService.delete(id);
    if (ok) await refreshMatches();
    return ok;
  }
  Future<bool> createTrainer(Map<String,dynamic> data) async {
    final t = await _trainerService.createTrainer(data);
    if (t != null) { await refreshTrainers(); return true; }
    return false;
  }
  Future<bool> updateTrainer(int id, Map<String,dynamic> data) async {
    final t = await _trainerService.updateTrainer(id, data);
    if (t != null) { await refreshTrainers(); return true; }
    return false;
  }
  Future<bool> deleteTrainer(int id) async {
    final ok = await _trainerService.deleteTrainer(id);
    if (ok) await refreshTrainers();
    return ok;
  }
  Future<bool> createParent(Map<String,dynamic> data) async {
    final p = await _parentService.createParent(data);
    if (p != null) { await refreshParents(); return true; }
    return false;
  }
  Future<bool> updateParent(int id, Map<String,dynamic> data) async {
    final p = await _parentService.updateParent(id, data);
    if (p != null) { await refreshParents(); return true; }
    return false;
  }
  Future<bool> deleteParent(int id) async {
    final ok = await _parentService.deleteParent(id);
    if (ok) await refreshParents();
    return ok;
  }
  Future<bool> deletePlayer(int id) async {
    final ok = await _playerService.deletePlayer(id);
    if (ok) { await refreshPlayers(); await refreshUnassignedPlayers(); }
    return ok;
  }
  Future<bool> assignPlayerRelations({required int playerId,int? divisionId,int? trainerId,int? parentId}) async {
    final ok = await _playerService.assignRelations(playerId: playerId, divisionId: divisionId, trainerId: trainerId, parentId: parentId);
    if (ok) { await refreshPlayers(); await refreshUnassignedPlayers(); }
    return ok;
  }
  Future<bool> assignTrainerDivision(int trainerId, int? divisionId) async {
    final ok = await _trainerService.assignDivision(trainerId, divisionId);
    if (ok) await refreshTrainers();
    return ok;
  }

  // Refresh
  Future<void> refreshDivisions() async { academyDivisions = await _divisionService.getAcademyDivisions(); allDivisions = await _divisionService.getAllDivisions(); notifyListeners(); }
  Future<void> refreshPlayers() async { try { allPlayers = await _playerService.getAllPlayers(); } catch (e) { error = e.toString(); allPlayers = []; } notifyListeners(); }
  Future<void> refreshUnassignedPlayers() async { try { unassignedPlayersRemote = await _playerService.getUnassignedPlayers(); } catch (e) { unassignedPlayersRemote = allPlayers.where((p)=>p.divisionId==null).toList(); error = e.toString(); } notifyListeners(); }
  Future<void> refreshTrainers() async { allTrainers = await _trainerService.getAllTrainers(); notifyListeners(); }
  Future<void> refreshParents() async { allParents = await _parentService.getAllParents(); notifyListeners(); }
  Future<void> refreshMatches() async { allMatches = await _matchService.getAll(); notifyListeners(); }
  Future<void> refreshActivities() async { allActivities = await _activityService.getAllActivities(); notifyListeners(); }

  // Getters used by UI
  List<Division> get availableDivisionsToAdd { final ids = academyDivisions.map((d)=>d.id).toSet(); final list = allDivisions.where((d)=>!ids.contains(d.id)).toList(); list.sort((a,b)=>a.nom.toLowerCase().compareTo(b.nom.toLowerCase())); return list; }
  List<Player> get filteredPlayers { if (isAllSelected) return List<Player>.from(allPlayers); if (isUnassignedSelected) return List<Player>.from(unassignedPlayersRemote); return allPlayers.where((p)=>p.divisionId==selectedDivisionId).toList(); }
  List<Player> get unassignedPlayers => List<Player>.from(unassignedPlayersRemote);
  List<Trainer> get filteredTrainers { if (isAllSelected) return List<Trainer>.from(allTrainers); if (isUnassignedSelected) return allTrainers.where((t)=>t.divisionId==null).toList(); return allTrainers.where((t)=>t.divisionId==selectedDivisionId).toList(); }
  List<Parent> get filteredParents { if (isAllSelected) return List<Parent>.from(allParents); final pids = filteredPlayers.map((p)=>p.parentId).whereType<int>().toSet(); return allParents.where((pa)=>pids.contains(pa.id)).toList(); }
  List<MatchModel> get filteredMatches { if (isAllSelected) return List<MatchModel>.from(allMatches); if (isUnassignedSelected) return allMatches.where((m)=>m.divisionId==null).toList(); return allMatches.where((m)=>m.divisionId==selectedDivisionId).toList(); }
  List<Activity> get filteredActivities { if (isAllSelected) return List<Activity>.from(allActivities); final trainerIds = filteredTrainers.map((t)=>t.id).whereType<int>().toSet(); if (trainerIds.isEmpty) return []; return allActivities.where((a)=>a.trainerId!=null && trainerIds.contains(a.trainerId)).toList(); }


  /// UI helper: attach an existing division to the academy.
  /// Returns true when backend confirms the attach.
  Future<bool> attachDivisionToAcademy(int divisionId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final ok = await _divisionService.assignDivisionToAcademy(divisionId);
      if (ok) {
        await refreshDivisions();
      }
      return ok;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// UI helper: delete a division after unassigning players/trainers from it.
  /// This prevents common backend constraint errors (division still referenced).
  Future<bool> deleteDivisionAndUnassignPlayers(int divisionId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // 1) Unassign players from this division (best-effort).
      final players = allPlayers.where((p) => p.divisionId == divisionId).toList();
      for (final p in players) {
        try {
          await _divisionService.removePlayerFromDivision(divisionId, p.id);
        } catch (e) {
          debugPrint('removePlayerFromDivision(${p.id}) failed: $e');
        }
      }

      // 2) Unassign trainers from this division (best-effort).
      final trainers = allTrainers.where((t) => t.divisionId == divisionId).toList();
      for (final t in trainers) {
        final int? tid = t.id;
        if (tid == null) continue;
        try {
          await _trainerService.assignDivision(tid, null);
        } catch (e) {
          debugPrint('assignDivision($tid, null) failed: $e');
        }
      }

      // 3) Remove from academy list if the backend models this separately.
      try {
        await _divisionService.removeDivisionFromAcademy(divisionId);
      } catch (_) {
        // ignore
      }

      // 4) Delete the division.
      final ok = await _divisionService.deleteDivision(divisionId);
      if (ok) {
        await Future.wait([
          refreshDivisions(),
          refreshPlayers(),
          refreshUnassignedPlayers(),
          refreshTrainers(),
        ]);
      }
      return ok;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Selection used by Players/Trainers/Matches/Activities filters.
  

/// Assign the same parent to multiple players in one action.
/// Uses existing PlayerService.assignRelations endpoint per player (safe fallback).
Future<bool> assignParentToPlayers({required int parentId, required List<int> playerIds}) async {
  if (playerIds.isEmpty) return true;
  try {
    for (final pid in playerIds) {
      await _playerService.assignRelations(playerId: pid, divisionId: null, trainerId: null, parentId: parentId);
    }
    await Future.wait([refreshPlayers(), refreshUnassignedPlayers(), refreshParents()]);
    return true;
  } catch (e) {
    error = e.toString();
    notifyListeners();
    return false;
  }
}
void setSelectedDivision(int? divisionId) {
    selectedDivisionId = divisionId;
    notifyListeners();
  }
}


