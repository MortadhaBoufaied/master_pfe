part of role_home_dashboard;

extension HomeTopPlayersSection on _RoleHomeDashboardState {
  Widget topPlayersSection(BuildContext context) {
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
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.16),
          ),
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
            topPlayersHeader(context),
            const SizedBox(height: 14),
            divisionSelector(context),
            const SizedBox(height: 14),
            if (_topPlayersLoading)
              const SizedBox(
                height: _RoleHomeDashboardState._topPlayerListHeight,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_topPlayersError != null)
              topPlayersMessage(
                context,
                icon: Icons.error_outline_rounded,
                title: 'Could not load players',
                subtitle: 'Pull to refresh and try again.',
              )
            else if (_topPlayers.isEmpty)
              topPlayersMessage(
                context,
                icon: Icons.groups_rounded,
                title: 'No ranked players yet',
                subtitle:
                    'Player cards will appear here when ranking data is available.',
              )
            else
              SizedBox(
                height: _RoleHomeDashboardState._topPlayerListHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _topPlayers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final player = _topPlayers[index];
                    return playerCard(context, player);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget topPlayersHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top players',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedDivisionName ?? 'Best academy performers right now',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: cs.primary,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget divisionSelector(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          divisionChip(
            context,
            label: 'All',
            selected: _selectedDivisionId == null,
            onTap: () => _selectDivision(null),
          ),
          ..._divisions.map(
            (division) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: divisionChip(
                context,
                label: division.nom,
                selected: _selectedDivisionId == division.id,
                onTap: () => _selectDivision(division.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget divisionChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(maxWidth: 140),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary
                : cs.surfaceContainerHighest.withOpacity(0.38),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? cs.primary
                  : cs.outlineVariant.withOpacity(0.18),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ),
    );
  }

  Widget topPlayersMessage(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: _RoleHomeDashboardState._topPlayerListHeight,
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

  Widget playerCard(
    BuildContext context,
    _TopPlayerCardData playerData,
  ) {
    final cs = Theme.of(context).colorScheme;
    final ranking = playerData.ranking;
    final player = playerData.player;

    final playerName = displayText(
      player?.nom,
      fallback: ranking.playerName,
    );

    final position = displayText(
      player?.position,
      fallback: 'Player',
    );

    final divisionName = displayText(
      playerData.divisionName,
      fallback: 'Academy',
    );

    final matches = player?.matches ?? ranking.matchesPlayed;
    final goals = player?.goals ?? ranking.goals;
    final assists = player?.assists ?? ranking.assists;

    return SizedBox(
      width: _RoleHomeDashboardState._topPlayerCardWidth,
      height: _RoleHomeDashboardState._topPlayerListHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FootballerDetailsScreen(
                  playerId: ranking.playerId,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(0.18),
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BackendAvatar(
                      pathOrUrl: player?.imageUrl,
                      radius: 18,
                      initials: initials(playerName),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        playerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: cs.onSurface,
                                ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '#${ranking.rank}',
                        maxLines: 1,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  '$position | $divisionName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        ranking.playerRating.toStringAsFixed(1),
                        maxLines: 1,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          ranking.tier,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: miniStat(context, '$goals', 'Goals')),
                    const SizedBox(width: 5),
                    Expanded(child: miniStat(context, '$assists', 'Assists')),
                    const SizedBox(width: 5),
                    Expanded(child: miniStat(context, '$matches', 'Games')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget miniStat(
    BuildContext context,
    String value,
    String label,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(
        horizontal: 3,
        vertical: 4,
      ),
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


