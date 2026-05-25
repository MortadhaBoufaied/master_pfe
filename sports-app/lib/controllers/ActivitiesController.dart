import 'package:flutter/foundation.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class ActivitiesController {
  final ActivityService _service = ActivityService();

  /// Fetch all activities (no divisionId)
  Future<List<Activity>> getAllActivities() async {
    try {
      return await _service.getAllActivities();
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      rethrow;
    }
  }

  /// Get activities for a month using backend calendar endpoint.
  /// monthKey expected "YYYY-MM"
  Future<List<Activity>> getActivitiesForMonth(String monthKey) async {
    try {
      final parts = monthKey.split('-');
      if (parts.length < 2) {
        // fallback: filter locally from all activities
        final all = await getAllActivities();
        return all.where((a) => a.date.startsWith(monthKey)).toList();
      }
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return await _service.getActivitiesForMonth(year, month);
    } catch (e) {
      debugPrint('Error in getActivitiesForMonth: $e');
      rethrow;
    }
  }

  Future<List<String>> getMonthlyPlanDates() async {
    final activities = await getAllActivities();
    final months = <String>{};
    for (var a in activities) {
      final d = a.date;
      if (d.length >= 7) months.add(d.substring(0, 7));
    }
    final list = months.toList();
    list.sort((a, b) => b.compareTo(a)); // newest first
    return list;
  }

  Future<Activity?> getActivityById(String activityId) async {
    try {
      final int id = int.parse(activityId);
      return await _service.getActivityById(id);
    } catch (e) {
      debugPrint('Error getActivityById: $e');
      rethrow;
    }
  }

  Future<void> addActivity({required Activity activity}) async {
    await _service.createActivity(activity);
  }

  Future<void> updateActivity({required String activityId, required Activity activity}) async {
    final id = int.parse(activityId);
    await _service.updateActivity(id, activity);
  }

  Future<void> deleteActivity({required String activityId}) async {
    final id = int.parse(activityId);
    await _service.deleteActivity(id);
  }

  /// Helper for UI that previously expected a "snapshot"
  Future<List<Activity>> getActivitiesSnapshot() async {
    return getAllActivities();
  }
}


