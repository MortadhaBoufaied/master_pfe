import 'dart:convert';
import '../models/trainer.dart';
import 'ApiService.dart';

class TrainerService {
  final ApiClient _api = ApiClient();

  Future<List<Trainer>> getAllTrainers() async {
    try {
      final response = await _api.get('/trainers')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => Trainer.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching trainers: $e');
    }
  }

  Future<Trainer?> getTrainerById(int id) async {
    try {
      final response = await _api.get('/trainers/$id')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Trainer.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching trainer: $e');
    }
  }

  Future<Trainer?> createTrainer(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(
        '/admin/trainers',
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Trainer.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      throw Exception('Error creating trainer: $e');
    }
  }

  Future<Trainer?> updateTrainer(int id, Map<String, dynamic> data) async {
    try {
      final response = await _api.put(
        '/admin/trainers/$id',
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Trainer.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      throw Exception('Error updating trainer: $e');
    }
  }

  

  /// PUT /trainers/{id}/division
  Future<bool> assignDivision(int trainerId, int? divisionId) async {
    try {
      final res = await _api.put(
        '/trainers/$trainerId/division',
        body: jsonEncode({'divisionId': divisionId}),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      throw Exception('Error assigning division: $e');
    }
  }
Future<bool> deleteTrainer(int id) async {
    try {
      final response = await _api.delete('/admin/trainers/$id')
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting trainer: $e');
    }
  }

  Future<List<Trainer>> getTrainersBySpeciality(String speciality) async {
    try {
      final response = await _api.get(
        '/trainers/speciality/$speciality',
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => Trainer.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching trainers by speciality: $e');
    }
  }

  Future<bool> assignPlayer(int trainerId, int playerId) async {
    try {
      final response = await _api.post(
        '/trainers/$trainerId/players/$playerId',
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error assigning player to trainer: $e');
    }
  }

  Future<dynamic> planActivity(int trainerId, Map<String, dynamic> body) async {
    try {
      final response = await _api.post(
        '/trainers/$trainerId/activities',
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      throw Exception('Error planning activity: $e');
    }
  }
}


