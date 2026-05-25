import 'dart:convert';
import '../models/division.dart';
import 'ApiService.dart';

class DivisionService {
  final ApiClient _api = ApiClient();

  List<Division> _parseList(dynamic data) {
    if (data is List) {
      return data.map((e) => Division.fromJson(e)).toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['divisions'];
      if (list is List) {
        return list.map((e) => Division.fromJson(e)).toList();
      }
    }
    return [];
  }

  Division? _parseOne(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return Division.fromJson(inner);
      return Division.fromJson(data);
    }
    return null;
  }

  Future<List<Division>> getSummaryList() async {
    final resp = await _api.get("/dto/divisions");
    if (resp.statusCode == 200) {
      return _parseList(jsonDecode(resp.body));
    }
    return [];
  }

  Future<Division?> getDetailById(int id) async {
    final resp = await _api.get("/dto/divisions/$id");
    if (resp.statusCode == 200) {
      return _parseOne(jsonDecode(resp.body));
    }
    return null;
  }

  Future<List<Division>> getAllDivisions() async {
    final resp = await _api.get("/dto/divisions");
    if (resp.statusCode == 200) {
      return _parseList(jsonDecode(resp.body));
    }
    return [];
  }

  Future<Division?> getDivisionById(int id) async {
    final resp = await _api.get("/divisions/$id");
    if (resp.statusCode == 200) {
      return _parseOne(jsonDecode(resp.body));
    }
    return null;
  }

  Future<List<Division>> getAcademyDivisions() async {
    final resp = await _api.get("/academy/divisions");
    if (resp.statusCode == 200) {
      return _parseList(jsonDecode(resp.body));
    }
    return [];
  }

  Future<bool> assignDivisionToAcademy(int divisionId) async {
    final resp = await _api.post("/academy/divisions/$divisionId");
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  Future<bool> removeDivisionFromAcademy(int divisionId) async {
    final resp = await _api.delete("/academy/divisions/$divisionId");
    return resp.statusCode == 200 || resp.statusCode == 204;
  }

  Future<Division?> createDivision(Map<String, dynamic> body) async {
    final resp = await _api.post("/divisions", body: body);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return _parseOne(jsonDecode(resp.body));
    }
    return null;
  }

  Future<Division?> updateDivision(int id, Map<String, dynamic> body) async {
    final resp = await _api.put("/divisions/$id", body: body);
    if (resp.statusCode == 200) {
      return _parseOne(jsonDecode(resp.body));
    }
    return null;
  }

  Future<bool> deleteDivision(int id) async {
    final resp = await _api.delete("/divisions/$id");
    return resp.statusCode == 200 || resp.statusCode == 204;
  }

  Future<List<Division>> getDivisionsByCategorie(String c) async {
    final resp = await _api.get("/divisions/categorie/$c");
    if (resp.statusCode == 200) {
      return _parseList(jsonDecode(resp.body));
    }
    return [];
  }

  Future<bool> addPlayerToDivision(int divisionId, int playerId) async {
    final resp = await _api.post("/divisions/$divisionId/players", body: playerId);
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  Future<bool> removePlayerFromDivision(int divisionId, int playerId) async {
    final resp = await _api.delete("/divisions/$divisionId/players/$playerId");
    return resp.statusCode == 200 || resp.statusCode == 204;
    }
}


