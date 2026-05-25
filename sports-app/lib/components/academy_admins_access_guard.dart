import 'package:flutter/material.dart';

import '../services/admin_academy_admins_service.dart';
import '../screens/admin/academy_admins_screen.dart';
import '../screens/common/forbidden_screen.dart';

class AcademyAdminsAccessGuard extends StatelessWidget {
  const AcademyAdminsAccessGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminResponsibility>(
      future: AdminAcademyAdminsService().getMyResponsibility(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return ForbiddenScreen(message: 'Not allowed to manage academy admins.');
        }

        final r = snapshot.data!;
        final allowed = AdminAcademyAdminsService().isFullAccess(r);

        if (!allowed) {
          return ForbiddenScreen(
            message: 'Your admin responsibility cannot manage academy admins.',
          );
        }

        return const AcademyAdminsScreen();
      },
    );
  }
}
