import 'dart:ui';

import 'package:flutter/material.dart';

import '../controllers/session_controller.dart';
import '../models/role.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentSection = 0;
  late AnimationController _appBarAnimationController;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _appBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void _handleSectionSelected(int index) {
    setState(() {
      final shouldShowAppBar = index < 2;
      if (_showAppBar != shouldShowAppBar) {
        _showAppBar = shouldShowAppBar;
        if (_showAppBar) {
          _appBarAnimationController.forward();
        } else {
          _appBarAnimationController.reverse();
        }
      }
      _currentSection = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            children: [
              SizeTransition(
                sizeFactor: _appBarAnimationController,
                axisAlignment: -1.0,
                child: TopNavigationBar(
                  title: '',
                  onSearchTap:
                      () => Navigator.pushNamed(context, '/global-search'),
                  onNotificationTap:
                      () => Navigator.pushNamed(context, '/notifications'),
                ),
              ),
              Expanded(child: _buildCurrentSection()),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SectionNavigation(
              currentSection: _currentSection,
              onSectionSelected: _handleSectionSelected,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSection() {
    return Center(
      child: Text(
        'Workspace',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class TopNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final bool showLogo;
  final String? subtitle;
  final List<Widget> extraActions;

  const TopNavigationBar({
    super.key,
    required this.title,
    required this.onSearchTap,
    required this.onNotificationTap,
    this.showLogo = true,
    this.subtitle,
    this.extraActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = AppSession.instance.session;

    final surface = isDark
        ? cs.surfaceContainerHigh.withOpacity(0.86)
        : Colors.white.withOpacity(0.86);

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 14,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              border: Border(
                bottom: BorderSide(
                  color: cs.outlineVariant.withOpacity(isDark ? 0.28 : 0.48),
                ),
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          if (showLogo) ...[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withOpacity(0.18),
                    cs.tertiary.withOpacity(0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: cs.primary.withOpacity(0.18),
                ),
              ),
              child: Icon(
                Icons.sports_soccer_rounded,
                color: cs.primary,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
          ] else
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? '${_displayName(session.displayName)} ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ ${_roleLabel(session.role)}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          ...extraActions,
          if (extraActions.isNotEmpty) const SizedBox(width: 8),
          _circleIcon(
            context,
            Icons.search_rounded,
            'Search',
            onSearchTap,
          ),
          const SizedBox(width: 8),
          _circleIcon(
            context,
            Icons.notifications_none_rounded,
            'Notifications',
            onNotificationTap,
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(
      BuildContext context,
      IconData icon,
      String tooltip,
      VoidCallback onTap,
      ) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.16),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: cs.primary,
          ),
        ),
      ),
    );
  }

  static String _displayName(String value) {
    final name = value.trim();
    return name.isEmpty ? 'Academy' : name;
  }

  static String _roleLabel(Role role) {
    switch (role) {
      case Role.superAdmin:
        return 'Super Admin';
      case Role.admin:
        return 'Admin';
      case Role.trainer:
        return 'Trainer';
      case Role.parent:
        return 'Parent';
      case Role.player:
        return 'Player';
      case Role.scouter:
        return 'Scouter';
      case Role.unknown:
        return 'Workspace';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

class SectionNavigation extends StatelessWidget {
  final int currentSection;
  final ValueChanged<int> onSectionSelected;
  final List<NavigationItem>? items;

  const SectionNavigation({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navItems = items ?? const [
      NavigationItem(Icons.home_rounded, 'Home'),
      NavigationItem(Icons.chat_bubble_outline_rounded, 'Chat'),
      NavigationItem(Icons.person_rounded, 'Profile'),
      NavigationItem(Icons.settings_rounded, 'Settings'),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.34 : 0.13),
              blurRadius: 30,
              spreadRadius: -6,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          cs.surfaceContainerHigh.withOpacity(0.94),
                          cs.surface.withOpacity(0.86),
                        ]
                      : [
                          Colors.white.withOpacity(0.94),
                          cs.surface.withOpacity(0.84),
                        ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(isDark ? 0.34 : 0.58),
                ),
              ),
              child: Row(
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final selected = currentSection == index;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Semantics(
                        selected: selected,
                        button: true,
                        label: item.label,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => onSectionSelected(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 230),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? cs.primary.withOpacity(isDark ? 0.24 : 0.14)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: selected
                                      ? cs.primary.withOpacity(isDark ? 0.34 : 0.20)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 230),
                                    curve: Curves.easeOutCubic,
                                    width: selected ? 34 : 30,
                                    height: selected ? 30 : 28,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? cs.primary.withOpacity(isDark ? 0.22 : 0.12)
                                          : cs.onSurfaceVariant.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: selected ? 21 : 20,
                                      color: selected ? cs.primary : cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: selected ? cs.primary : cs.onSurfaceVariant,
                                          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                                          fontSize: 10.5,
                                          height: 1.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  const NavigationItem(this.icon, this.label);
}


