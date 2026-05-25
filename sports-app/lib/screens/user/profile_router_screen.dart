import 'package:flutter/material.dart';

import '../../controllers/session_controller.dart';
import '../../models/role.dart';
import '../../theme/app_theme.dart';
import '../DataManagement/tabs/players/footballer_details_screen.dart';
import 'staff_profile_screen.dart';

class AccountProfileRouterScreen extends StatefulWidget {
  const AccountProfileRouterScreen({super.key});

  @override
  State<AccountProfileRouterScreen> createState() => _AccountProfileRouterScreenState();
}

class _AccountProfileRouterScreenState extends State<AccountProfileRouterScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AppSession.instance.session.loadFromStorage();
      await AppSession.instance.session.refreshFromServer();
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSession.instance.session;

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: AppTheme.teal)),
      );
    }

    if (_error != null && s.user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 38),
                const SizedBox(height: 12),
                Text('Profile loading failed.\n$_error', textAlign: TextAlign.center),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _bootstrap,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (s.role == Role.player) {
      final playerId = s.playerId ?? s.userId;
      if (playerId != null) {
        return FootballerDetailsScreen(playerId: playerId, isCurrentUser: true);
      }
    }

    return StaffProfileScreen(
      userId: s.userId,
      role: s.role,
      parentId: s.parentId,
      trainerId: s.trainerId,
      displayName: s.displayName,
      email: s.email,
      phone: s.phone,
    );
  }
}

