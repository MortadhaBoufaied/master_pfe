import 'dart:convert';

import '../models/training.dart';
import 'ApiService.dart';

class TrainingService {
  final ApiClient _api = ApiClient();

  Future<List<Training>> getAll() async {
    final resp = await _api.get('/trainings');
    if (resp.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(resp.bodyBytes));
      return list.map((e) => Training.fromJson(e)).toList();
    }
    return [];
  }

  Future<Training?> getById(int id) async {
    final resp = await _api.get('/trainings/$id');
    if (resp.statusCode == 200) {
      return Training.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
    }
    return null;
  }

  Future<List<Training>> getByTrainer(int trainerId) async {
    final resp = await _api.get('/trainings/trainer/$trainerId');
    if (resp.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(resp.bodyBytes));
      return list.map((e) => Training.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<Training>> getInDateRange(String start, String end) async {
    final resp = await _api.get(
      '/trainings/date-range',
      query: {'start': start, 'end': end},
    );
    if (resp.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(resp.bodyBytes));
      return list.map((e) => Training.fromJson(e)).toList();
    }
    return [];
  }

  Future<Training?> create(Map<String, dynamic> body) async {
    final resp = await _api.post('/trainings', body: body);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return Training.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
    }
    return null;
  }

  Future<Training?> recordAttendance(
    int trainingId,
    List<int> playerIds,
  ) async {
    final resp = await _api.post(
      '/trainings/$trainingId/record-attendance',
      body: playerIds,
    );
    if (resp.statusCode == 200) {
      return Training.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
    }
    return null;
  }
}


