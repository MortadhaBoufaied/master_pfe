import 'dart:ui';

import 'package:flutter/material.dart';

import '../../components/app_background.dart';
import '../../controllers/AuthState.dart';
import '../../controllers/session_controller.dart';
import '../../models/role.dart';
import '../../utils/backend_image.dart';

class StaffProfileScreen extends StatefulWidget {
  final int? userId;
  final Role role;
  final int? parentId;
  final int? trainerId;
  final String? displayName;
  final String? email;
  final String? phone;

  const StaffProfileScreen({
    super.key,
    this.userId,
    required this.role,
    this.parentId,
    this.trainerId,
    this.displayName,
    this.email,
    this.phone,
  });

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  bool _loading = false;

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      await AppSession.instance.session.refreshFromServer();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance.session;
    final raw = session.user?.raw ?? const <String, dynamic>{};
    final role = widget.role == Role.unknown ? session.role : widget.role;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = _value(widget.displayName, session.displayName, raw['nom'], raw['name'], raw['fullName']) ?? 'Academy member';
    final email = _value(widget.email, session.email, raw['email']) ?? 'No email available';
    final phone = _value(widget.phone, session.phone, raw['tel'], raw['phone']) ?? 'No phone available';
    final photo = _value(raw['photo'], raw['avatar'], raw['avatarUrl'], raw['imageUrl'], raw['logoUrl']);
    final roleAccent = _roleColor(role, cs);
    final sections = _sectionsFor(role);
    final stats = _statsFor(role, session, raw);
    final actions = _actionsFor(role);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: const Text('Profile'),
          actions: [
            IconButton(
              tooltip: 'Refresh profile',
              onPressed: _loading ? null : _refresh,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
            children: [
              _ProfileHero(
                displayName: displayName,
                email: email,
                roleLabel: _roleLabel(role),
                avatarPath: photo,
                initials: _initials(displayName),
                accent: roleAccent,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              if (stats.isNotEmpty) _StatsStrip(stats: stats),
              const SizedBox(height: 14),
              _GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PanelTitle(
                      icon: Icons.badge_rounded,
                      title: 'Account details',
                      subtitle: 'Your identity and role context from the backend session.',
                      accent: roleAccent,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.person_outline_rounded, label: 'Full name', value: displayName),
                    _InfoTile(icon: Icons.mail_outline_rounded, label: 'Email', value: email),
                    _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: phone),
                    _InfoTile(icon: Icons.verified_user_outlined, label: 'Role', value: _roleLabel(role)),
                    if (session.divisionId != null)
                      _InfoTile(icon: Icons.grid_view_rounded, label: 'Division ID', value: '#${session.divisionId}'),
                    if (widget.trainerId != null || session.trainerId != null)
                      _InfoTile(icon: Icons.sports_rounded, label: 'Trainer profile ID', value: '#${widget.trainerId ?? session.trainerId}'),
                    if (widget.parentId != null || session.parentId != null)
                      _InfoTile(icon: Icons.family_restroom_rounded, label: 'Parent profile ID', value: '#${widget.parentId ?? session.parentId}'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PanelTitle(
                      icon: Icons.auto_awesome_rounded,
                      title: _focusTitle(role),
                      subtitle: _focusSubtitle(role),
                      accent: roleAccent,
                    ),
                    const SizedBox(height: 12),
                    for (final section in sections) _FocusRow(section: section),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PanelTitle(
                      icon: Icons.flash_on_rounded,
                      title: 'Available services',
                      subtitle: 'Shortcuts are generated from the services enabled in your app.',
                      accent: roleAccent,
                    ),
                    const SizedBox(height: 12),
                    _ActionGrid(actions: actions),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _GlassPanel(
                child: Column(
                  children: [
                    _SettingsAction(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      subtitle: 'Review academy updates and alerts.',
                      onTap: () => Navigator.pushNamed(context, '/notifications'),
                    ),
                    _DividerLine(),
                    _SettingsAction(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Messages',
                      subtitle: 'Open your conversations and team chats.',
                      onTap: () => Navigator.pushNamed(context, '/chat'),
                    ),
                    _DividerLine(),
                    _SettingsAction(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out from this device.',
                      danger: true,
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (ok != true) return;
    await AuthSession.instance.state.signOut();
    AppSession.instance.session.clear();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  static String? _value(dynamic a, [dynamic b, dynamic c, dynamic d, dynamic e, String? fallback]) {
    for (final v in [a, b, c, d, e]) {
      final s = v?.toString().trim();
      if (s != null && s.isNotEmpty && s != 'null') return s;
    }
    return fallback;
  }
}

class _ProfileHero extends StatelessWidget {
  final String displayName;
  final String email;
  final String roleLabel;
  final String? avatarPath;
  final String initials;
  final Color accent;
  final bool isDark;

  const _ProfileHero({
    required this.displayName,
    required this.email,
    required this.roleLabel,
    required this.avatarPath,
    required this.initials,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withOpacity(isDark ? 0.34 : 0.18),
                  cs.surface.withOpacity(isDark ? 0.72 : 0.88),
                  cs.tertiary.withOpacity(isDark ? 0.16 : 0.08),
                ],
              ),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.18)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -26,
                  top: -28,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.10),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accent.withOpacity(0.55), width: 2),
                          ),
                          child: BackendAvatar(
                            pathOrUrl: avatarPath,
                            radius: 39,
                            initials: initials,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: cs.onSurface,
                                      height: 0.98,
                                    ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _MiniBadge(icon: Icons.shield_rounded, label: roleLabel, color: accent),
                        const SizedBox(width: 8),
                        _MiniBadge(icon: Icons.workspace_premium_rounded, label: 'Academy workspace', color: cs.tertiary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final List<_ProfileStat> stats;
  const _StatsStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          Expanded(child: _StatCard(stat: stats[i])),
          if (i != stats.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final _ProfileStat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(isDark ? 0.58 : 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(stat.icon, size: 18, color: stat.color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 1),
                Text(stat.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 10.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(isDark ? 0.58 : 0.80),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: cs.outlineVariant.withOpacity(isDark ? 0.28 : 0.20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.22 : 0.06),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _PanelTitle({required this.icon, required this.title, required this.subtitle, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: accent.withOpacity(0.13), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: accent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: cs.onSurface)),
              const SizedBox(height: 2),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, height: 1.25)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusRow extends StatelessWidget {
  final _FocusItem section;
  const _FocusRow({required this.section});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: section.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: section.color.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: section.color.withOpacity(0.14), borderRadius: BorderRadius.circular(14)),
            child: Icon(section.icon, color: section.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: cs.onSurface)),
                const SizedBox(height: 2),
                Text(section.subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final List<_ProfileAction> actions;
  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 520 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return _ActionCard(action: action);
          },
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _ProfileAction action;
  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: action.color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, action.route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: action.color.withOpacity(0.16), borderRadius: BorderRadius.circular(14)),
                child: Icon(action.icon, color: action.color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: cs.onSurface)),
                  Text(action.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, height: 1.2)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _SettingsAction({required this.icon, required this.title, required this.subtitle, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = danger ? cs.error : cs.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(height: 1, color: cs.outlineVariant.withOpacity(0.22));
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MiniBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.13), borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _ProfileStat(this.value, this.label, this.icon, this.color);
}

class _FocusItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _FocusItem(this.icon, this.title, this.subtitle, this.color);
}

class _ProfileAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
  const _ProfileAction(this.icon, this.title, this.subtitle, this.route, this.color);
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
      return 'Member';
  }
}

Color _roleColor(Role role, ColorScheme cs) {
  switch (role) {
    case Role.superAdmin:
      return Colors.deepPurple;
    case Role.admin:
      return cs.primary;
    case Role.trainer:
      return Colors.blue;
    case Role.parent:
      return Colors.orange;
    case Role.player:
      return Colors.green;
    case Role.scouter:
      return Colors.indigo;
    case Role.unknown:
      return cs.primary;
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _focusTitle(Role role) {
  switch (role) {
    case Role.admin:
    case Role.superAdmin:
      return 'Operations focus';
    case Role.trainer:
      return 'Coaching focus';
    case Role.parent:
      return 'Family focus';
    case Role.scouter:
      return 'Scouting focus';
    case Role.player:
      return 'Performance focus';
    case Role.unknown:
      return 'Todayâ€™s focus';
  }
}

String _focusSubtitle(Role role) {
  switch (role) {
    case Role.admin:
    case Role.superAdmin:
      return 'Control academy services, teams, subscriptions, reports, and communications.';
    case Role.trainer:
      return 'Prepare sessions, follow players, and keep your division aligned.';
    case Role.parent:
      return 'Follow children activity, payments, announcements, and academy communication.';
    case Role.scouter:
      return 'Review prospects, compare performance, and manage scouting insights.';
    case Role.player:
      return 'Track training, matches, performance, and progress.';
    case Role.unknown:
      return 'Stay connected to your academy workspace.';
  }
}

List<_ProfileStat> _statsFor(Role role, SessionController session, Map<String, dynamic> raw) {
  String rawValue(List<String> keys, String fallback) {
    for (final k in keys) {
      final v = raw[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return fallback;
  }

  switch (role) {
    case Role.admin:
      return [
        _ProfileStat(rawValue(['totalPlayers', 'playersCount'], '--'), 'Players', Icons.groups_rounded, Colors.teal),
        _ProfileStat(rawValue(['divisionCount', 'divisionsCount'], '--'), 'Divisions', Icons.grid_view_rounded, Colors.orange),
      ];
    case Role.superAdmin:
      return [
        _ProfileStat(rawValue(['academyCount', 'academiesCount'], '--'), 'Academies', Icons.apartment_rounded, Colors.deepPurple),
        _ProfileStat(rawValue(['sportCount', 'sportsCount'], '--'), 'Sports', Icons.sports_soccer_rounded, Colors.teal),
      ];
    case Role.trainer:
      return [
        _ProfileStat(session.divisionId?.toString() ?? rawValue(['divisionId'], '--'), 'Division', Icons.grid_view_rounded, Colors.blue),
        _ProfileStat(rawValue(['playersCount', 'assignedPlayers'], '--'), 'Players', Icons.groups_rounded, Colors.green),
      ];
    case Role.parent:
      return [
        _ProfileStat(rawValue(['childrenCount', 'playersCount'], '--'), 'Children', Icons.family_restroom_rounded, Colors.orange),
        _ProfileStat(rawValue(['unpaidCount', 'pendingPayments'], '--'), 'Pending', Icons.payments_rounded, Colors.redAccent),
      ];
    case Role.scouter:
      return [
        _ProfileStat(rawValue(['shortlistCount'], '--'), 'Shortlist', Icons.star_rounded, Colors.indigo),
        _ProfileStat(rawValue(['insightsCount'], '--'), 'Insights', Icons.psychology_rounded, Colors.teal),
      ];
    case Role.player:
      return [
        _ProfileStat(rawValue(['matches'], '--'), 'Matches', Icons.sports_soccer_rounded, Colors.green),
        _ProfileStat(rawValue(['goals'], '--'), 'Goals', Icons.emoji_events_rounded, Colors.orange),
      ];
    case Role.unknown:
      return [];
  }
}

List<_FocusItem> _sectionsFor(Role role) {
  switch (role) {
    case Role.admin:
      return const [
        _FocusItem(Icons.storage_rounded, 'Data management', 'Manage divisions, players, trainers, parents, activities, and payments.', Colors.teal),
        _FocusItem(Icons.campaign_rounded, 'Communication', 'Send notifications and follow academy conversations.', Colors.orange),
        _FocusItem(Icons.bar_chart_rounded, 'Reports', 'Monitor finance, activity, and performance indicators.', Colors.blue),
      ];
    case Role.superAdmin:
      return const [
        _FocusItem(Icons.apartment_rounded, 'Academies', 'Supervise academies, sports, themes, contacts, and platform payments.', Colors.deepPurple),
        _FocusItem(Icons.webhook_rounded, 'Integrations', 'Review webhooks, global data, and chatbot knowledge.', Colors.teal),
        _FocusItem(Icons.admin_panel_settings_rounded, 'Governance', 'Keep platform services clean, controlled, and consistent.', Colors.orange),
      ];
    case Role.trainer:
      return const [
        _FocusItem(Icons.event_available_rounded, 'Training plan', 'Manage sessions, activities, and preparation work.', Colors.blue),
        _FocusItem(Icons.insights_rounded, 'Player stats', 'Review player development and performance progression.', Colors.green),
        _FocusItem(Icons.chat_bubble_outline_rounded, 'Team chat', 'Stay close to your players and academy staff.', Colors.teal),
      ];
    case Role.parent:
      return const [
        _FocusItem(Icons.family_restroom_rounded, 'Children overview', 'Follow academy updates, activities, and match participation.', Colors.orange),
        _FocusItem(Icons.payments_rounded, 'Payments', 'Review monthly fees, paid status, and pending dues.', Colors.redAccent),
        _FocusItem(Icons.notifications_active_rounded, 'Announcements', 'Receive important academy messages and reminders.', Colors.teal),
      ];
    case Role.scouter:
      return const [
        _FocusItem(Icons.travel_explore_rounded, 'Prospecting', 'Search players and identify strong opportunities.', Colors.indigo),
        _FocusItem(Icons.compare_arrows_rounded, 'Comparison', 'Compare profiles, potential, and performance signals.', Colors.blue),
        _FocusItem(Icons.star_rounded, 'Shortlist', 'Keep promising players organized for follow-up.', Colors.orange),
      ];
    case Role.player:
      return const [
        _FocusItem(Icons.trending_up_rounded, 'Progress', 'Track your sessions, activity, and match performance.', Colors.green),
        _FocusItem(Icons.sports_soccer_rounded, 'Matches', 'Review your football activity and team updates.', Colors.teal),
        _FocusItem(Icons.emoji_events_rounded, 'Goals', 'Stay consistent and improve with every session.', Colors.orange),
      ];
    case Role.unknown:
      return const [
        _FocusItem(Icons.workspace_premium_rounded, 'Workspace', 'Your role-specific tools will appear when the session is available.', Colors.teal),
      ];
  }
}

List<_ProfileAction> _actionsFor(Role role) {
  switch (role) {
    case Role.admin:
      return const [
        _ProfileAction(Icons.dashboard_customize_rounded, 'Admin', 'Portal', '/admin', Colors.teal),
        _ProfileAction(Icons.storage_rounded, 'Data', 'Management', '/data-management', Colors.blue),
        _ProfileAction(Icons.bar_chart_rounded, 'Reports', 'Statistics', '/statistics', Colors.orange),
        _ProfileAction(Icons.campaign_rounded, 'Notify', 'Broadcast', '/send-notification', Colors.purple),
      ];
    case Role.superAdmin:
      return const [
        _ProfileAction(Icons.dashboard_rounded, 'Platform', 'Dashboard', '/super-admin', Colors.deepPurple),
        _ProfileAction(Icons.apartment_rounded, 'Academies', 'Manage', '/super-admin/academies', Colors.teal),
        _ProfileAction(Icons.palette_rounded, 'Themes', 'Branding', '/super-admin/themes', Colors.orange),
        _ProfileAction(Icons.payments_rounded, 'Payments', 'Academy', '/super-admin/academy-payments', Colors.green),
      ];
    case Role.trainer:
      return const [
        _ProfileAction(Icons.event_note_rounded, 'Activities', 'Manage', '/trainer-activities', Colors.blue),
        _ProfileAction(Icons.insights_rounded, 'Stats', 'Players', '/trainer-player-stats', Colors.green),
        _ProfileAction(Icons.chat_rounded, 'Chat', 'Messages', '/chat', Colors.teal),
        _ProfileAction(Icons.search_rounded, 'Search', 'Global', '/global-search', Colors.orange),
      ];
    case Role.parent:
      return const [
        _ProfileAction(Icons.payments_rounded, 'Payments', 'Monthly', '/my-payments', Colors.orange),
        _ProfileAction(Icons.event_available_rounded, 'Activities', 'Calendar', '/my-activities', Colors.blue),
        _ProfileAction(Icons.sports_soccer_rounded, 'Matches', 'Updates', '/my-matches', Colors.green),
        _ProfileAction(Icons.chat_rounded, 'Chat', 'Messages', '/chat', Colors.teal),
      ];
    case Role.scouter:
      return const [
        _ProfileAction(Icons.travel_explore_rounded, 'Scouting', 'Dashboard', '/scouting', Colors.indigo),
        _ProfileAction(Icons.search_rounded, 'Search', 'Players', '/global-search', Colors.teal),
        _ProfileAction(Icons.notifications_rounded, 'Alerts', 'Updates', '/notifications', Colors.orange),
        _ProfileAction(Icons.chat_rounded, 'Chat', 'Messages', '/chat', Colors.blue),
      ];
    case Role.player:
      return const [
        _ProfileAction(Icons.event_available_rounded, 'Activities', 'Plan', '/my-activities', Colors.green),
        _ProfileAction(Icons.sports_soccer_rounded, 'Matches', 'History', '/my-matches', Colors.teal),
        _ProfileAction(Icons.chat_rounded, 'Chat', 'Messages', '/chat', Colors.blue),
        _ProfileAction(Icons.notifications_rounded, 'Alerts', 'Updates', '/notifications', Colors.orange),
      ];
    case Role.unknown:
      return const [
        _ProfileAction(Icons.home_rounded, 'Home', 'Workspace', '/home', Colors.teal),
        _ProfileAction(Icons.notifications_rounded, 'Alerts', 'Updates', '/notifications', Colors.orange),
      ];
  }
}

