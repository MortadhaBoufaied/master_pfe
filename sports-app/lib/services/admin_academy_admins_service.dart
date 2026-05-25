import 'dart:convert';
import 'admin_users_service.dart';
import '../models/admin_user.dart';
import '../models/admin.dart';

import 'ApiService.dart';

enum AdminResponsibility {
  academyDirector,
  operationsManager,
  sportsCoordinator,
  playerRegistrar,
  financeManager,
  communicationsManager,
  medicalWelfareManager,
}

class AdminAcademyAdminsService {
  final ApiClient _api = ApiClient();

  Future<AdminResponsibility> getMyResponsibility() async {
    final r = await _api.get('/admin/academy-admins/me');
    final body = utf8.decode(r.bodyBytes);

    if (r.statusCode != 200) {
      throw Exception('getMyResponsibility failed: ${r.statusCode} $body');
    }

    final decoded = jsonDecode(body);
    final raw = decoded is Map ? decoded['responsibility']?.toString() : null;
    if (raw == null || raw.trim().isEmpty) {
      throw Exception('getMyResponsibility failed: missing responsibility');
    }

    return _parseResponsibility(raw);
  }

  Future<List<AdminUser>> listAcademyAdmins() async {
    final r = await _api.get('/admin/academy-admins');
    final body = utf8.decode(r.bodyBytes);

    if (r.statusCode != 200) {
      throw Exception('listAcademyAdmins failed: ${r.statusCode} $body');
    }

    final decoded = jsonDecode(body);
    final rawList = decoded is List ? decoded : (decoded is Map ? decoded['data'] ?? [] : []);
    if (rawList is! List) return [];

    final List<AdminUser> result = [];
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        result.add(AdminUser.fromJson(item));
      } else if (item is Map) {
        result.add(AdminUser.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return result;
  }

  Future<bool> createAcademyAdmin({
    required String nom,
    required String email,
    required String password,
    required AdminResponsibility responsibility,
    String? tel,
  }) async {
    final payload = {
      'nom': nom,
      'email': email,
      'password': password,
      'tel': tel ?? '',
      'responsibility': responsibility.name,
    };

    final r = await _api.post('/admin/academy-admins', body: jsonEncode(payload));
    final body = utf8.decode(r.bodyBytes);

    if (r.statusCode != 201 && r.statusCode != 200) {
      throw Exception('createAcademyAdmin failed: ${r.statusCode} $body');
    }
    return true;
  }

  Future<bool> setAdminResponsibility({
    required int adminUserId,
    required AdminResponsibility responsibility,
  }) async {
    final payload = {'responsibility': responsibility.name};

    final r = await _api.put(
      '/admin/academy-admins/$adminUserId/responsibility',
      body: jsonEncode(payload),
    );
    final body = utf8.decode(r.bodyBytes);

    if (r.statusCode != 200) {
      throw Exception('setAdminResponsibility failed: ${r.statusCode} $body');
    }
    return true;
  }

  bool isFullAccess(AdminResponsibility r) {
    return r == AdminResponsibility.academyDirector ||
        r == AdminResponsibility.operationsManager ||
        r == AdminResponsibility.sportsCoordinator;
  }

  AdminResponsibility _parseResponsibility(String raw) {
    final normalized = raw.trim().toUpperCase();
    switch (normalized) {
      case 'ACADEMY_DIRECTOR':
        return AdminResponsibility.academyDirector;
      case 'OPERATIONS_MANAGER':
        return AdminResponsibility.operationsManager;
      case 'SPORTS_COORDINATOR':
        return AdminResponsibility.sportsCoordinator;
      case 'PLAYER_REGISTRAR':
        return AdminResponsibility.playerRegistrar;
      case 'FINANCE_MANAGER':
        return AdminResponsibility.financeManager;
      case 'COMMUNICATIONS_MANAGER':
        return AdminResponsibility.communicationsManager;
      case 'MEDICAL_WELFARE_MANAGER':
        return AdminResponsibility.medicalWelfareManager;
      default:
        throw Exception('Unknown responsibility: $raw');
    }
  }
}
