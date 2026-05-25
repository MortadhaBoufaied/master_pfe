      import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/activity.dart';
import 'ApiService.dart';

class ActivityService {
  final ApiClient _api = ApiClient();

  /* ============================================================
     GET ALL ACTIVITIES
  ============================================================ */
  Future<List<Activity>> getAllActivities() async {
    try {
      final http.Response resp = await _api.get("/activities");

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);

        if (decoded is List) {
          return decoded
              .map((json) => Activity.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }

        // some backends wrap results {data:[...]}
        if (decoded is Map && decoded['data'] is List) {
          final List list = decoded['data'];
          return list
              .map((json) => Activity.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }
      }

      return [];
    } catch (e) {
      throw Exception("Error fetching activities: $e");
    }
  }

  /* ============================================================
     GET ACTIVITIES FOR MONTH
  ============================================================ */
  Future<List<Activity>> getActivitiesForMonth(int year, int month) async {
    try {
      final http.Response resp = await _api.get("/calendar/month/$year/$month");

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);

        if (decoded is List) {
          return decoded
              .map((json) => Activity.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }

        if (decoded is Map && decoded['data'] is List) {
          final List list = decoded['data'];
          return list
              .map((json) => Activity.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }
      }

      return [];
    } catch (e) {
      throw Exception("Error fetching activities for month: $e");
    }
  }

  /* ============================================================
     GET ACTIVITY BY ID
  ============================================================ */
  Future<Activity?> getActivityById(int id) async {
    try {
      final http.Response resp = await _api.get("/activities/$id");

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);

        if (decoded is Map<String, dynamic>) {
          return Activity.fromJson(decoded);
        }

        if (decoded is Map && decoded['data'] is Map) {
          return Activity.fromJson(Map<String, dynamic>.from(decoded['data']));
        }
      }

      return null;
    } catch (e) {
      throw Exception("Error fetching activity: $e");
    }
  }

  /* ============================================================
     CREATE ACTIVITY
  ============================================================ */
  Future<Activity?> createActivity(Activity activity) async {
    try {
      final http.Response resp = await _api.post(
        "/activities",
        body: activity.toJson(),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);

        if (decoded is Map<String, dynamic>) {
          return Activity.fromJson(decoded);
        }

        if (decoded is Map && decoded['data'] is Map) {
          return Activity.fromJson(Map<String, dynamic>.from(decoded['data']));
        }
      }

      return null;
    } catch (e) {
      throw Exception("Error creating activity: $e");
    }
  }

  /* ============================================================
     UPDATE ACTIVITY
  ============================================================ */
  Future<Activity?> updateActivity(int id, Activity activity) async {
    try {
      final http.Response resp = await _api.put(
        "/activities/$id",
        body: activity.toJson(),
      );

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);

        if (decoded is Map<String, dynamic>) {
          return Activity.fromJson(decoded);
        }

        if (decoded is Map && decoded['data'] is Map) {
          return Activity.fromJson(Map<String, dynamic>.from(decoded['data']));
        }
      }

      return null;
    } catch (e) {
      throw Exception("Error updating activity: $e");
    }
  }

  /* ============================================================
     DELETE ACTIVITY
  ============================================================ */
  Future<bool> deleteActivity(int id) async {
    try {
      final http.Response resp = await _api.delete("/activities/$id");
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}


