import 'package:flutter/foundation.dart';
import '../models/trainer.dart';
import '../services/trainer_service.dart';

class TrainerController extends ChangeNotifier {
  final TrainerService _service = TrainerService();

  List<Trainer> trainers = [];
  Trainer? current;
  bool isLoading = false;
  String? error;

  Future<void> fetchAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      trainers = await _service.getAllTrainers();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// For compatibility with other screens that call fetchTrainerById
  Future<Trainer?> fetchTrainerById(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      current = await _service.getTrainerById(id);
      return current;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTrainer(Map<String, dynamic> body) async {
    try {
      final t = await _service.createTrainer(body);
      if (t != null) {
        trainers.insert(0, t);
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

  Future<bool> updateTrainer(int id, Map<String, dynamic> body) async {
    try {
      final t = await _service.updateTrainer(id, body);
      if (t != null) {
        final idx = trainers.indexWhere((x) => x.id == id);
        if (idx >= 0) trainers[idx] = t;
        if (current != null && current!.id == id) current = t;
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

  Future<bool> deleteTrainer(int id) async {
    try {
      final ok = await _service.deleteTrainer(id);
      if (ok) {
        trainers.removeWhere((x) => x.id == id);
        if (current != null && current!.id == id) current = null;
        notifyListeners();
      }
      return ok;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignPlayer(int trainerId, int playerId) async {
    try {
      final ok = await _service.assignPlayer(trainerId, playerId);
      if (ok) {
        await fetchTrainerById(trainerId);
      }
      return ok;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<dynamic> planActivity(int trainerId, Map<String, dynamic> activityBody) async {
    try {
      final res = await _service.planActivity(trainerId, activityBody);
      return res;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> getBySpeciality(String speciality) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      trainers = await _service.getTrainersBySpeciality(speciality);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}


