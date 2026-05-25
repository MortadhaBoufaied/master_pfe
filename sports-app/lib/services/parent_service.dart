import 'dart:convert';
import 'ApiService.dart';
import '../models/parent.dart';
import '../models/player.dart';

class ParentService {
  final ApiClient _api = ApiClient();
  Future<List<Parent>> getAllParents() async {
    final r = await _api.get('/parents');
    if (r.statusCode == 200) {
      final List data = jsonDecode(r.body);
      return data.map((e) => Parent.fromJson(e)).toList();
    }
    return [];
  }
  Future<Parent?> getParentById(int id) async {
    final r = await _api.get('/parents/$id');
    if (r.statusCode == 200) {
      return Parent.fromJson(jsonDecode(r.body));
    }
    return null;
  }
  Future<Parent?> createParent(Map<String, dynamic> body) async {
    final r = await _api.post('/admin/parents', body: jsonEncode(body));
    if (r.statusCode == 200 || r.statusCode == 201) {
      return Parent.fromJson(jsonDecode(r.body));
    }
    return null;
  }
  Future<Parent?> updateParent(int id, Map<String, dynamic> body) async {
    final r = await _api.put('/admin/parents/$id', body: jsonEncode(body));
    if (r.statusCode == 200) {
      return Parent.fromJson(jsonDecode(r.body));
    }
    return null;
  }
  Future<bool> deleteParent(int id) async {
    final r = await _api.delete('/admin/parents/$id');
    return r.statusCode == 200 || r.statusCode == 204;
  }


  /// GET /parents/{id}/children
  Future<List<Player>> getChildren(int parentId) async {
    final r = await _api.get('/parents/$parentId/children');
    if (r.statusCode == 200) {
      final List data = jsonDecode(r.body);
      return data.map((e) => Player.fromJson(e)).toList();
    }
    return [];
  }



  /// POST /parents/{parentId}/children/{playerId}
  Future<bool> addChild({required int parentId, required int playerId}) async {
    final r = await _api.post('/parents/$parentId/children/$playerId');
    return r.statusCode == 200 || r.statusCode == 201 || r.statusCode == 204;
  }

  /// DELETE /parents/{parentId}/children/{playerId}
  Future<bool> removeChild({required int parentId, required int playerId}) async {
    final r = await _api.delete('/parents/$parentId/children/$playerId');
    return r.statusCode == 200 || r.statusCode == 204;
  }

}


