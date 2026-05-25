part of role_home_dashboard;

extension HomeQuickLinksBar on _RoleHomeDashboardState {
  Widget homeQuickLinksBar(BuildContext context, Role role) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final links = quickLinksForRole(role);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: _RoleHomeDashboardState._pageHorizontalPadding,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(isDark ? 0.80 : 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(isDark ? 0.18 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < links.length; i++) ...[
            Expanded(
              child: quickAccessItem(
                icon: links[i].icon,
                label: links[i].label,
                color: links[i].color,
                route: links[i].route,
                onTap: links[i].onTap,
              ),
            ),
            if (i != links.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  List<_HomeQuickLink> quickLinksForRole(Role role) {
    final cs = Theme.of(context).colorScheme;

    switch (role) {
      case Role.parent:
        return [
          _HomeQuickLink(
            icon: Icons.person_rounded,
            label: 'Profile',
            color: cs.primary,
            route: '/profile',
          ),
          _HomeQuickLink(
            icon: Icons.payments_rounded,
            label: 'Payments',
            color: Colors.green.shade600,
            route: '/my-payments',
          ),
          _HomeQuickLink(
            icon: Icons.calendar_month_rounded,
            label: 'Activities',
            color: Colors.blue.shade600,
            route: '/my-activities',
          ),
          _HomeQuickLink(
            icon: Icons.chat_bubble_rounded,
            label: 'Messages',
            color: Colors.orange.shade700,
            route: '',
            onTap: widget.onContactPressed,
          ),
        ];
      case Role.trainer:
        return [
          _HomeQuickLink(
            icon: Icons.person_rounded,
            label: 'Profile',
            color: cs.primary,
            route: '/profile',
          ),
          _HomeQuickLink(
            icon: Icons.edit_calendar_rounded,
            label: 'Sessions',
            color: Colors.orange.shade700,
            route: '/trainer-activities',
          ),
          _HomeQuickLink(
            icon: Icons.query_stats_rounded,
            label: 'Stats',
            color: Colors.blue.shade700,
            route: '/trainer-player-stats',
          ),
          _HomeQuickLink(
            icon: Icons.chat_bubble_rounded,
            label: 'Messages',
            color: Colors.green.shade600,
            route: '',
            onTap: widget.onContactPressed,
          ),
        ];
      case Role.player:
        return [
          _HomeQuickLink(
            icon: Icons.person_rounded,
            label: 'Profile',
            color: cs.primary,
            route: '/profile',
          ),
          _HomeQuickLink(
            icon: Icons.calendar_month_rounded,
            label: 'Activities',
            color: Colors.blue.shade600,
            route: '/my-activities',
          ),
          _HomeQuickLink(
            icon: Icons.sports_soccer_rounded,
            label: 'Matches',
            color: Colors.orange.shade700,
            route: '/my-matches',
          ),
          _HomeQuickLink(
            icon: Icons.payments_rounded,
            label: 'Payments',
            color: Colors.green.shade600,
            route: '/my-payments',
          ),
        ];
      case Role.scouter:
        return [
          _HomeQuickLink(
            icon: Icons.person_rounded,
            label: 'Profile',
            color: cs.primary,
            route: '/profile',
          ),
          _HomeQuickLink(
            icon: Icons.manage_search_rounded,
            label: 'Scouting',
            color: Colors.deepOrange.shade600,
            route: '/scouting',
          ),
          _HomeQuickLink(
            icon: Icons.search_rounded,
            label: 'Search',
            color: Colors.blue.shade700,
            route: '/global-search',
          ),
          _HomeQuickLink(
            icon: Icons.chat_bubble_rounded,
            label: 'Messages',
            color: Colors.green.shade600,
            route: '',
            onTap: widget.onContactPressed,
          ),
        ];
      default:
        return [
          _HomeQuickLink(
            icon: Icons.person_rounded,
            label: 'Profile',
            color: cs.primary,
            route: '/profile',
          ),
          _HomeQuickLink(
            icon: Icons.calendar_month_rounded,
            label: 'Activities',
            color: Colors.blue.shade600,
            route: '/my-activities',
          ),
          _HomeQuickLink(
            icon: Icons.notifications_rounded,
            label: 'Alerts',
            color: Colors.orange.shade700,
            route: '/notifications',
          ),
          _HomeQuickLink(
            icon: Icons.chat_bubble_rounded,
            label: 'Messages',
            color: Colors.green.shade600,
            route: '',
            onTap: widget.onContactPressed,
          ),
        ];
    }
  }

  Widget quickAccessItem({
    required IconData icon,
    required String label,
    required Color color,
    required String route,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap ??
            () {
              if (route.trim().isEmpty) return;
              Navigator.pushNamed(context, route);
            },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.82),
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

