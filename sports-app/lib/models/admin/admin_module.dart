import 'package:flutter/material.dart';

enum AdminWebRole { admin, superAdmin }

class AdminModuleAction {
  final String label;
  final String route;
  final IconData icon;

  const AdminModuleAction({
    required this.label,
    required this.route,
    required this.icon,
  });
}

class AdminModuleSpec {
  final String key;
  final AdminWebRole role;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> sections;
  final List<String> capabilities;
  final List<String> webPages;
  final List<AdminModuleAction> actions;

  const AdminModuleSpec({
    required this.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    this.sections = const [],
    this.capabilities = const [],
    this.webPages = const [],
    this.actions = const [],
  });

  bool get isSuperAdmin => role == AdminWebRole.superAdmin;
}


