import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'ApiService.dart';

class DashboardService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getParentDashboard(int parentId) async {
    final res = await _api.get('/dashboard/parent/$parentId');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Failed to load parent dashboard: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> getTrainerDashboard(int trainerId) async {
    final res = await _api.get('/dashboard/trainer/$trainerId');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Failed to load trainer dashboard: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await _api.get('/dashboard/admin');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Failed to load admin dashboard: ${res.statusCode}');
  }
}


