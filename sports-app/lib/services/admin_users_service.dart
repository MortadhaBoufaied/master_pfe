import 'dart:convert';
import 'ApiService.dart';
import '../models/admin_user.dart';

class AdminUsersService {
  final ApiClient _api = ApiClient();

  Future<List<AdminUser>> getAllUsers() async {
    final r = await _api.get('/admin/users');

    final body = utf8.decode(r.bodyBytes);
    if (r.statusCode != 200) {
      // show the real reason (401/403/500...)
      throw Exception('getAllUsers failed: ${r.statusCode} $body');
    }

    final decoded = jsonDecode(body);

    final dynamic rawList = decoded is List
        ? decoded
        : (decoded is Map ? (decoded['data'] ?? decoded['results'] ?? decoded['items'] ?? decoded['users'] ?? []) : []);

    final List<Map<String, dynamic>> list = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          list.add(item);
        } else if (item is Map) {
          list.add(Map<String, dynamic>.from(item));
        }
      }
    }

    return list.map((e) => AdminUser.fromJson(e)).toList();
  }

  Future<AdminUser?> getUser(int id) async {
    // FIX: remove the extra /api prefix
    final r = await _api.get('/admin/users/$id');

    final body = utf8.decode(r.bodyBytes);
    if (r.statusCode != 200) {
      throw Exception('getUser($id) failed: ${r.statusCode} $body');
    }

    final data = jsonDecode(body);
    if (data is Map && data['user'] != null) {
      return AdminUser.fromJson(data['user']);
    }
    return AdminUser.fromJson(data);
  }

  /// Returns created user and uses /auth/signup (ApiClient already targets /api)
  Future<AdminUser?> createUser({
    required String nom,
    required String email,
    required String password,
    required String role,
  }) async {
    final payload = {'nom': nom, 'email': email, 'mdp': password, 'mainRole': role};
    final r = await _api.post('/auth/signup', body: jsonEncode(payload));

    final body = utf8.decode(r.bodyBytes);
    if (r.statusCode == 201 || r.statusCode == 200) {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) return AdminUser.fromJson(data);
    }
    throw Exception('createUser failed: ${r.statusCode} $body');
  }

  Future<bool> updateUser(AdminUser u) async {
    final r = await _api.put('/admin/users/${u.id}', body: jsonEncode(u.toUpdateJson()));
    if (r.statusCode != 200) {
      throw Exception('updateUser failed: ${r.statusCode} ${utf8.decode(r.bodyBytes)}');
    }
    return true;
  }

  Future<bool> deleteUser(int id) async {
    final r = await _api.delete('/admin/users/$id');
    if (r.statusCode != 200 && r.statusCode != 204) {
      throw Exception('deleteUser failed: ${r.statusCode} ${utf8.decode(r.bodyBytes)}');
    }
    return true;
  }
}


