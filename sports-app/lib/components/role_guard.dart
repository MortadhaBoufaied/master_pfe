import 'package:flutter/material.dart';

import '../controllers/session_controller.dart';
import '../models/role.dart';
import '../screens/common/forbidden_screen.dart';

class RoleGuard extends StatelessWidget {
  final Set<Role> allow;
  final Widget child;
  final String? deniedMessage;

  const RoleGuard({
    super.key,
    required this.allow,
    required this.child,
    this.deniedMessage,
  });

  @override
  Widget build(BuildContext context) {
    final role = AppSession.instance.session.role;
    if (allow.contains(role)) return child;
    return ForbiddenScreen(message: deniedMessage);
  }
}


