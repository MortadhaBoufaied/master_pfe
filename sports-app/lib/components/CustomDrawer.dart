import 'package:flutter/material.dart';

import '../controllers/AuthState.dart';
import '../l10n/app_strings.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final headerGradient = LinearGradient(
      colors: [
        cs.primary.withValues(alpha: isDark ? 0.62 : 0.24),
        cs.primary.withValues(alpha: isDark ? 0.82 : 0.92),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final tileShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(gradient: headerGradient),
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo_scout.png',
                    width: 110,
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t.tr('welcome'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            shape: tileShape,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            leading: Icon(Icons.home),
            title: Text(
              t.tr('home'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            shape: tileShape,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            leading: Icon(Icons.person),
            title: Text(
              t.tr('profile'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          Divider(
            color: cs.outline.withValues(alpha: 0.35),
            thickness: 1,
            height: 20,
          ),
          ListTile(
            shape: tileShape,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            leading: Icon(Icons.logout),
            title: Text(
              t.tr('logout'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await AuthSession.instance.state.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}


