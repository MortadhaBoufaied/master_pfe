part of role_home_dashboard;

class _HomeQuickLink {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final VoidCallback? onTap;

  const _HomeQuickLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
    this.onTap,
  });
}

class _TopPlayerCardData {
  final PlayerRanking ranking;
  final Player? player;
  final String? divisionName;

  const _TopPlayerCardData({
    required this.ranking,
    required this.player,
    required this.divisionName,
  });
}

class _HeaderStat {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}


