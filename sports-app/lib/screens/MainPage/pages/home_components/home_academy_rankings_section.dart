part of role_home_dashboard;

extension HomeAcademyRankingsSection on _RoleHomeDashboardState {
  Widget academyRankingsSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _RoleHomeDashboardState._pageHorizontalPadding,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.82),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.16)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academy ranking',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Best academies from backend performance data',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh rankings',
                  onPressed:
                      _academyRankingsLoading ? null : _loadAcademyRankings,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_academyRankingsLoading)
              const SizedBox(
                height: 142,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_academyRankingsError != null)
              _academyRankingMessage(
                context,
                Icons.error_outline_rounded,
                'Could not load rankings',
                'Pull to refresh and try again.',
              )
            else if (_academyRankings.isEmpty)
              _academyRankingMessage(
                context,
                Icons.domain_disabled_rounded,
                'No academy ranking yet',
                'Rankings will appear after backend data is available.',
              )
            else
              SizedBox(
                height: 142,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _academyRankings.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, index) {
                    return _academyRankingCard(
                      context,
                      _academyRankings[index],
                      index + 1,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _academyRankingMessage(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 142,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.34),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: cs.primary, size: 28),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _academyRankingCard(
    BuildContext context,
    AcademyRanking ranking,
    int fallbackRank,
  ) {
    final cs = Theme.of(context).colorScheme;
    final rank = ranking.rankingPosition > 0
        ? ranking.rankingPosition
        : fallbackRank;
    final location = [
      ranking.sportName,
      ranking.city,
      ranking.country,
    ].where((value) => value.trim().isNotEmpty).join(' - ');

    return SizedBox(
      width: 190,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    ranking.academyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              location.isEmpty ? ranking.tier : location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: _academyMiniStat(
                    context,
                    ranking.mlScore.toStringAsFixed(1),
                    'AI score',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _academyMiniStat(
                    context,
                    ranking.playerProgressionScore > 0
                        ? ranking.playerProgressionScore.toStringAsFixed(0)
                        : '${(ranking.confidence * 100).toStringAsFixed(0)}%',
                    ranking.playerProgressionScore > 0
                        ? 'Progress'
                        : 'Confidence',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _academyMiniStat(BuildContext context, String value, String label) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.48),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 1),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
