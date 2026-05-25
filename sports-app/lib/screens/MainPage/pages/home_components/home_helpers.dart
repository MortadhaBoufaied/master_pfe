part of role_home_dashboard;

extension HomeHelpers on _RoleHomeDashboardState {
  Future<void> openRoute(String route) async {
    if (!mounted) return;
    await Navigator.of(context).pushNamed(route);
  }

  String displayText(
    dynamic value, {
    String fallback = '',
  }) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String roleLabel(Role role) {
    switch (role) {
      case Role.parent:
        return 'Parent';
      case Role.trainer:
        return 'Trainer';
      case Role.player:
        return 'Player';
      case Role.scouter:
        return 'Scouter';
      case Role.admin:
        return 'Admin';
      case Role.superAdmin:
        return 'Super Admin';
      case Role.unknown:
        return 'Workspace';
    }
  }


  List<_HeaderStat> headerStats(Role role) {
    final cs = Theme.of(context).colorScheme;
    final data = _dashboardData ?? const <String, dynamic>{};

    switch (role) {
      case Role.parent:
        final children =
            data['children'] is List ? data['children'] as List : const [];

        return [
          _HeaderStat(
            value: '${data['childrenCount'] ?? children.length}',
            label: 'Children',
            icon: Icons.family_restroom_rounded,
            color: cs.primary,
          ),
          _HeaderStat(
            value: '${displayText(data['unpaidTotal'], fallback: '0')} DT',
            label: 'Outstanding',
            icon: Icons.payments_rounded,
            color: Colors.orange.shade700,
          ),
        ];

      case Role.trainer:
        return [
          _HeaderStat(
            value: displayText(data['divisionName'], fallback: '-'),
            label: 'Division',
            icon: Icons.shield_outlined,
            color: cs.primary,
          ),
          _HeaderStat(
            value: '${data['playersCount'] ?? 0}',
            label: 'Players',
            icon: Icons.groups_rounded,
            color: Colors.blue.shade700,
          ),
        ];

      case Role.player:
        return [
          _HeaderStat(
            value: '${_divisions.length}',
            label: 'Divisions',
            icon: Icons.grid_view_rounded,
            color: cs.primary,
          ),
          _HeaderStat(
            value: '${_topPlayers.length}',
            label: 'Top picks',
            icon: Icons.star_rounded,
            color: Colors.amber.shade700,
          ),
        ];

      case Role.scouter:
        return [
          _HeaderStat(
            value: '${_divisions.length}',
            label: 'Teams',
            icon: Icons.account_tree_rounded,
            color: cs.primary,
          ),
          _HeaderStat(
            value: '${_topPlayers.length}',
            label: 'Ranked now',
            icon: Icons.insights_rounded,
            color: Colors.deepOrange.shade600,
          ),
        ];

      default:
        return const [];
    }
  }

  String? get _selectedDivisionName {
    if (_selectedDivisionId == null) return null;

    for (final division in _divisions) {
      if (division.id == _selectedDivisionId) {
        return division.nom;
      }
    }

    return null;
  }
}


