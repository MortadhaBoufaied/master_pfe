import 'package:flutter/material.dart';

import '../../../controllers/session_controller.dart';
import '../../../models/role.dart';
import '../../../services/dashboard_service.dart';
import '../../../theme/app_theme.dart';
import '../../DataManagement/tabs/players/footballer_details_screen.dart';

class RoleHomeDashboard extends StatefulWidget {
  final VoidCallback onContactPressed;

  const RoleHomeDashboard({
    super.key,
    required this.onContactPressed,
  });

  @override
  State<RoleHomeDashboard> createState() => _RoleHomeDashboardState();
}

class _RoleHomeDashboardState extends State<RoleHomeDashboard> {
  final DashboardService _svc = DashboardService();

  bool loading = true;
  String? error;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final s = AppSession.instance.session;

      if (s.role == Role.parent && s.parentId != null) {
        data = await _svc.getParentDashboard(s.parentId!);
      } else if (s.role == Role.trainer && s.trainerId != null) {
        data = await _svc.getTrainerDashboard(s.trainerId!);
      } else if (s.role == Role.admin || s.role == Role.superAdmin) {
        data = await _svc.getAdminDashboard();
      } else {
        data = null;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSession.instance.session;
    final cs = Theme.of(context).colorScheme;

    if (loading) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.50),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const CircularProgressIndicator(
            color: AppTheme.teal,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        children: [
          _header(context, cs, s.displayName, _roleLabel(s.role)),

          if (error != null) ...[
            const SizedBox(height: 10),
            _errorCard(cs),
          ],

          const SizedBox(height: 10),

          if (s.role == Role.parent) _parentDashboard(context, cs),
          if (s.role == Role.trainer) _trainerDashboard(context, cs),
          if (s.role == Role.admin || s.role == Role.superAdmin)
            _adminDashboard(context, cs),
          if (s.role == Role.player) _playerDashboard(context, cs),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _header(
      BuildContext context,
      ColorScheme cs,
      String name,
      String role,
      ) {
    final displayName = _display(name, fallback: 'Welcome');
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.16),
            cs.tertiary.withOpacity(0.08),
            cs.surfaceContainerHighest.withOpacity(0.48),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.38),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.primary.withOpacity(0.14),
            child: Text(
              initial,
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip(
                      cs,
                      Icons.verified_user_rounded,
                      role,
                    ),
                    _chip(
                      cs,
                      Icons.circle_rounded,
                      'Active',
                      soft: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _parentDashboard(BuildContext context, ColorScheme cs) {
    final d = data ?? {};
    final children =
    d['children'] is List ? d['children'] as List : <dynamic>[];

    final childrenCount = d['childrenCount'] ?? children.length;
    final unpaidTotal = _display(d['unpaidTotal'], fallback: '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _metric(
                cs,
                Icons.family_restroom_rounded,
                'Children',
                '$childrenCount',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                cs,
                Icons.payments_rounded,
                'To pay',
                '$unpaidTotal DT',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _sectionTitle(context, 'Children overview'),

        const SizedBox(height: 8),

        if (children.isEmpty)
          _emptyCard(
            cs,
            Icons.family_restroom_rounded,
            'No children linked',
            'Linked players will appear here.',
          )
        else
          for (final raw in children) _childSummaryCard(context, cs, raw),

        const SizedBox(height: 10),

        _quickActions(cs, [
          _Quick(Icons.payments_rounded, 'Payments', '/my-payments'),
          _Quick(Icons.calendar_month_rounded, 'Activities', '/my-activities'),
          _Quick(Icons.chat_bubble_outline_rounded, 'Messages', '/chat'),
          _Quick(Icons.person_rounded, 'Profile', '/profile'),
        ]),
      ],
    );
  }

  Widget _trainerDashboard(BuildContext context, ColorScheme cs) {
    final d = data ?? {};
    final activities =
    d['activities'] is List ? d['activities'] as List : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _metric(
                cs,
                Icons.groups_rounded,
                'Division',
                _display(d['divisionName'], fallback: '-'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                cs,
                Icons.sports_soccer_rounded,
                'Players',
                '${d['playersCount'] ?? 0}',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _sectionTitle(context, 'This month'),

        const SizedBox(height: 8),

        if (activities.isEmpty)
          _emptyCard(
            cs,
            Icons.event_busy_rounded,
            'No activities yet',
            'Create sessions and keep your team schedule updated.',
          )
        else
          _activityCard(context, cs, activities, d['activitiesThisMonth']),

        const SizedBox(height: 10),

        _quickActions(cs, [
          _Quick(Icons.edit_calendar_rounded, 'Activities', '/trainer-activities'),
          _Quick(Icons.query_stats_rounded, 'Stats', '/trainer-player-stats'),
          _Quick(Icons.chat_bubble_outline_rounded, 'Messages', '/chat'),
          _Quick(Icons.person_rounded, 'Profile', '/profile'),
        ]),
      ],
    );
  }

  Widget _adminDashboard(BuildContext context, ColorScheme cs) {
    final d = data ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _metric(
                cs,
                Icons.people_alt_rounded,
                'Users',
                '${d['users'] ?? 0}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                cs,
                Icons.sports_soccer_rounded,
                'Players',
                '${d['players'] ?? 0}',
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _metric(
                cs,
                Icons.trending_up_rounded,
                'Revenue',
                '${d['monthlyRevenue'] ?? 0} DT',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                cs,
                Icons.warning_amber_rounded,
                'Overdue',
                '${d['overduePayments'] ?? 0}',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _quickActions(cs, [
          _Quick(Icons.storage_rounded, 'Data', '/data-management'),
          _Quick(Icons.bar_chart_rounded, 'Statistics', '/statistics'),
          _Quick(Icons.notifications_rounded, 'Alerts', '/notifications'),
          _Quick(Icons.person_rounded, 'Profile', '/profile'),
        ]),
      ],
    );
  }

  Widget _playerDashboard(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _quickActions(cs, [
          _Quick(Icons.person_rounded, 'Profile', '/profile'),
          _Quick(Icons.event_rounded, 'Activities', '/my-activities'),
          _Quick(Icons.sports_soccer_rounded, 'Matches', '/my-matches'),
          _Quick(Icons.payments_rounded, 'Payments', '/my-payments'),
          _Quick(Icons.chat_bubble_outline_rounded, 'Messages', '/chat'),
        ]),

        const SizedBox(height: 10),

        _infoCard(
          cs,
          Icons.auto_graph_rounded,
          'Your progress hub',
          'Track sessions, matches, payments, and messages.',
          widget.onContactPressed,
        ),
      ],
    );
  }

  Widget _activityCard(
      BuildContext context,
      ColorScheme cs,
      List activities,
      dynamic count,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.38),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.11),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: cs.primary,
                size: 20,
              ),
            ),
            title: Text(
              '${count ?? activities.length} activities scheduled',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'Upcoming sessions',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const Divider(height: 1),

          for (final raw in activities.take(4))
            Builder(
              builder: (_) {
                final a = raw is Map
                    ? Map<String, dynamic>.from(raw)
                    : <String, dynamic>{};

                final title = _display(
                  a['titre'] ?? a['title'],
                  fallback: 'Activity',
                );
                final date = _display(a['date']);
                final place = _display(a['lieu'] ?? a['place']);

                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    [date, place].where((e) => e.isNotEmpty).join(' ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _childSummaryCard(BuildContext context, ColorScheme cs, dynamic raw) {
    final c = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    final playerId = _toInt(c['playerId'] ?? c['id']);
    final name = _display(c['name'] ?? c['nom'], fallback: 'Player');
    final division = _display(c['divisionName'] ?? c['division']);
    final position = _display(c['position']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surfaceContainerHighest.withOpacity(0.48),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: playerId == null
              ? null
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FootballerDetailsScreen(
                  playerId: playerId,
                  isCurrentUser: false,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primary.withOpacity(0.12),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),

                      if (division.isNotEmpty || position.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          [division, position]
                              .where((e) => e.isNotEmpty)
                              .join(' ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _smallStat(
                            cs,
                            Icons.sports_soccer_rounded,
                            '${_display(c['goals'], fallback: '0')} goals',
                          ),
                          _smallStat(
                            cs,
                            Icons.handshake_rounded,
                            '${_display(c['assists'], fallback: '0')} assists',
                          ),
                          _smallStat(
                            cs,
                            Icons.event_available_rounded,
                            '${_display(c['matches'], fallback: '0')} matches',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (playerId != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metric(
      ColorScheme cs,
      IconData icon,
      String label,
      String value,
      ) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.38),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: cs.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(ColorScheme cs, List<_Quick> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 170,
              mainAxisExtent: 40,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final q = items[index];

              return OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, q.route),
                icon: Icon(
                  q.icon,
                  size: 17,
                ),
                label: Text(
                  q.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
      ColorScheme cs,
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.48),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.38),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.11),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: cs.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(
      ColorScheme cs,
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.44),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.38),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.11),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: cs.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.error.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: cs.error,
            size: 22,
          ),
          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Dashboard could not be refreshed.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),

          TextButton(
            onPressed: _load,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _chip(
      ColorScheme cs,
      IconData icon,
      String label, {
        bool soft = false,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(soft ? 0.07 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: cs.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStat(ColorScheme cs, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: cs.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: cs.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(Role role) {
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

  String _display(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class _Quick {
  final IconData icon;
  final String label;
  final String route;

  _Quick(this.icon, this.label, this.route);
}


