part of role_home_dashboard;

extension HomeHeader on _RoleHomeDashboardState {
  Widget homeHeader(BuildContext context, dynamic session) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = headerStats(session.role);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _RoleHomeDashboardState._pageHorizontalPadding,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(isDark ? 0.82 : 0.88),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.14)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(isDark ? 0.16 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/icons/kick-ball.png',
                    width: 30,
                    height: 30,
                    color: cs.primary,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.sports_soccer_rounded,
                      color: cs.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sports Academy Pro',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome back, ${displayText(session.displayName, fallback: 'Academy')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    roleLabel(session.role),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ],
            ),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 16),
              responsiveHeaderStats(context, stats),
            ],
            const SizedBox(height: 16),
            CustomPaint(
              painter: CornerBorderPainter(
                color: cs.primary.withOpacity(0.78),
                strokeWidth: 2,
                length: 22,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(isDark ? 0.26 : 0.42),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.14)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.trending_up_rounded, color: cs.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's focus",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _homeHeaderSubtitle(session.role),
                            maxLines: _isIntroExpanded ? null : 2,
                            overflow: _isIntroExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => setState(() => _isIntroExpanded = !_isIntroExpanded),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isIntroExpanded ? 'Show less' : 'Show more',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                    _isIntroExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                    color: cs.primary,
                                    size: 19,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _homeHeaderSubtitle(dynamic role) {
    final normalizedRole = role.toString().toLowerCase();

    if (normalizedRole.contains('admin')) {
      return 'Monitor academy activity, manage divisions, and keep track of key updates from one place.';
    }

    if (normalizedRole.contains('coach') || normalizedRole.contains('trainer')) {
      return 'Follow your teams, review training progress, and stay updated on match preparation.';
    }

    if (normalizedRole.contains('player')) {
      return 'Follow your academy activity, training progress, match updates, and key performance insights.';
    }

    if (normalizedRole.contains('parent')) {
      return 'Follow your childrenâ€™s academy activity, payments, schedules, and important updates.';
    }

    return 'Follow your academy activity, performance, and key team updates.';
  }

  Widget responsiveHeaderStats(BuildContext context, List<_HeaderStat> stats) {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          Expanded(child: headerStatCard(context, stats[i])),
          if (i != stats.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget headerStatCard(BuildContext context, _HeaderStat stat) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(isDark ? 0.42 : 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, size: 17, color: stat.color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

