import 'package:flutter/material.dart';

/// DataManagement app bar that matches the visual style of TopNavigationBar
/// but respects light/dark theme colors.
class DataManagementAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabBar tabBar;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  /// If true: show logo on the left (tap = pop if possible).
  /// If false: show back arrow.
  final bool showLogo;

  const DataManagementAppBar({
    super.key,
    required this.tabBar,
    required this.onSearchTap,
    required this.onNotificationTap,
    this.showLogo = false,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 2 + tabBar.preferredSize.height);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = cs.surface;
    final actionBg = cs.primary.withOpacity(isDark ? 0.22 : 0.11);

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              surface.withOpacity(isDark ? 0.88 : 0.70),
              surface.withOpacity(isDark ? 0.70 : 0.48),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo or back
          showLogo
              ? GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                child: Text(
                  'ACADEMIE',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: cs.tertiary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              )
              : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

          // Search + Notifications
          Row(
            children: [
              _buildCircleIcon(
                context,
                Icons.search,
                'Search',
                onSearchTap,
                actionBg,
              ),
              const SizedBox(width: 12),
              _buildCircleIcon(
                context,
                Icons.notifications,
                'Notifications',
                onNotificationTap,
                actionBg,
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: tabBar.preferredSize,
        child: Container(
          color: surface.withOpacity(isDark ? 0.86 : 0.62),
          child: tabBar,
        ),
      ),
    );
  }

  Widget _buildCircleIcon(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
    Color background,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 21, color: cs.onSurface),
          ),
        ),
      ),
    );
  }
}


