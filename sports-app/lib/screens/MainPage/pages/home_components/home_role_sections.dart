part of role_home_dashboard;

extension HomeRoleSections on _RoleHomeDashboardState {
  Widget parentDashboard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = _dashboardData ?? const <String, dynamic>{};
    final children =
        data['children'] is List ? data['children'] as List : const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeading(context, 'Family overview'),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _RoleHomeDashboardState._pageHorizontalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: summaryMetric(
                  context,
                  value: '${data['childrenCount'] ?? children.length}',
                  label: 'Children',
                  icon: Icons.family_restroom_rounded,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: summaryMetric(
                  context,
                  value: '${displayText(data['unpaidTotal'], fallback: '0')} DT',
                  label: 'Outstanding',
                  icon: Icons.payments_rounded,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _RoleHomeDashboardState._pageHorizontalPadding,
            ),
            child: surfaceCard(
              context,
              child: emptyState(
                context,
                icon: Icons.family_restroom_rounded,
                title: 'No linked children',
                subtitle: 'Linked player profiles will appear here.',
              ),
            ),
          )
        else
          ...children.take(3).map(
                (raw) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: childCard(context, raw),
                ),
              ),
      ],
    );
  }

  Widget trainerDashboard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = _dashboardData ?? const <String, dynamic>{};
    final activities =
        data['activities'] is List ? data['activities'] as List : const [];
    final visibleActivities = activities.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeading(context, 'Training overview'),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _RoleHomeDashboardState._pageHorizontalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: summaryMetric(
                  context,
                  value: displayText(data['divisionName'], fallback: '-'),
                  label: 'Division',
                  icon: Icons.shield_outlined,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: summaryMetric(
                  context,
                  value: '${data['playersCount'] ?? 0}',
                  label: 'Players',
                  icon: Icons.groups_rounded,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        sectionHeading(context, 'Upcoming sessions'),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _RoleHomeDashboardState._pageHorizontalPadding,
          ),
          child: surfaceCard(
            context,
            child: activities.isEmpty
                ? emptyState(
                    context,
                    icon: Icons.event_busy_rounded,
                    title: 'No activities scheduled',
                    subtitle: 'Plan the next session from quick actions.',
                  )
                : Column(
                    children: [
                      for (var i = 0; i < visibleActivities.length; i++) ...[
                        activityRow(context, visibleActivities[i]),
                        if (i != visibleActivities.length - 1)
                          Divider(
                            height: 18,
                            color: cs.outlineVariant.withOpacity(0.3),
                          ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget playerDashboard(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget scouterDashboard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeading(context, 'Scouting workspace'),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _RoleHomeDashboardState._pageHorizontalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: summaryMetric(
                  context,
                  value: '${_divisions.length}',
                  label: 'Teams',
                  icon: Icons.account_tree_rounded,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: summaryMetric(
                  context,
                  value: '${_topPlayers.length}',
                  label: 'Ranked now',
                  icon: Icons.insights_rounded,
                  color: Colors.deepOrange.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _RoleHomeDashboardState._pageHorizontalPadding,
          ),
          child: surfaceCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scouting dashboard',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Review standout talent, compare profiles, and keep shortlists close.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}


