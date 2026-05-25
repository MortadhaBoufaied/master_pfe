import 'role.dart';

class CurrentUser {
  final int? id;
  final String? nom;
  final String? email;
  final Role role;
  final Map<String, dynamic>? raw;

  CurrentUser({
    this.id,
    this.nom,
    this.email,
    required this.role,
    this.raw,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    Role detected = Role.unknown;

    // -------------------------------------
    // 1 PRIORITY: mainRole (backend field)
    // -------------------------------------
    final rawRole = json['mainRole'] ?? json['main_role'];

    if (rawRole != null) {
      detected = RoleParsing.fromString(rawRole.toString());
    }

    // -------------------------------------------------
    // 2 FALLBACK: roles: [ { "name": "ADMIN" } ]
    // -------------------------------------------------
    if (detected == Role.unknown && json['roles'] is List) {
      final rolesList = json['roles'] as List;

      if (rolesList.isNotEmpty) {
        final r = rolesList.first;
        final name = r is Map ? r['name'] : r.toString();
        detected = RoleParsing.fromString(name.toString());
      }
    }

    // -------------------------------------
    // 3 FINAL fallback: raw "role" string
    // -------------------------------------
    if (detected == Role.unknown && json['role'] != null) {
      detected = RoleParsing.fromString(json['role'].toString());
    }

    // -------------------------------------
    // Numeric ID safe parsing
    // -------------------------------------
    final parsedId = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? "");

    return CurrentUser(
      id: parsedId,
      nom: json['nom'] ?? json['name'] ?? json['fullName'],
      email: json['email']?.toString(),
      role: detected,
      raw: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => raw ?? {};
}


