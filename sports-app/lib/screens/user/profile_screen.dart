import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../models/role.dart';
import 'staff_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    await AppSession.instance.session.loadFromStorage();
    try {
      await AppSession.instance.session.refreshFromServer();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSession.instance.session;

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StaffProfileScreen(
      userId: s.userId,
      role: s.role == Role.unknown ? Role.unknown : s.role,
      parentId: s.parentId,
      trainerId: s.trainerId,
      displayName: s.displayName,
      email: s.email,
      phone: s.phone,
    );
  }
}

