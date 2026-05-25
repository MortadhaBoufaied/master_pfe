import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/ui_kit.dart';
import '../../../controllers/notificationsController.dart';
import '../../../controllers/session_controller.dart';
import '../../../models/notification_data.dart';
import '../../../models/role.dart';
import '../../../theme/app_theme.dart';

class MatchHistorySection extends StatefulWidget {
  final bool embedded;

  const MatchHistorySection({super.key, this.embedded = false});

  @override
  State<MatchHistorySection> createState() => _MatchHistorySectionState();
}

class _MatchHistorySectionState extends State<MatchHistorySection> {
  final NotificationController _notifications = NotificationController();

  @override
  void initState() {
    super.initState();
    _notifications.addListener(_refresh);
    _notifications.loadNotifications();
  }

  @override
  void dispose() {
    _notifications.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance.session;
    final actions = _operationsForRole(session.role);
    final notifications = _notifications.notifications.take(5).toList();

    final content = <Widget>[
          SectionTitle(
            title: 'Operations Center',
            subtitle: _subtitleForRole(session.role),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                MetricPill(
                  label: 'Unread alerts',
                  value: '${_notifications.unreadCount}',
                  color: Colors.redAccent,
                  icon: Icons.notifications_active_rounded,
                ),
                MetricPill(
                  label: 'Inbox items',
                  value: '${_notifications.notifications.length}',
                  color: AppTheme.teal,
                  icon: Icons.mark_email_unread_rounded,
                ),
                MetricPill(
                  label: 'Role',
                  value: _roleShortLabel(session.role),
                  color: Colors.indigo,
                  icon: Icons.badge_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
      SoftCard(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 10) / 2;

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final action in actions)
                      SizedBox(
                        width: itemWidth,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, action.route),
                          icon: Icon(action.icon, color: action.color),
                          label: Text(
                            action.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
          SoftCard(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent alerts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (_notifications.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(color: AppTheme.teal),
                    ),
                  )
                else if (notifications.isEmpty)
                  _emptyHint(context)
                else
                  ...notifications.map((item) => _notificationTile(context, item)),
              ],
            ),
          ),
    ];

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      );
    }

    return RefreshIndicator(
      onRefresh: _notifications.loadNotifications,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 24),
        children: content,
      ),
    );
  }

  Widget _emptyHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.inbox_outlined, color: AppTheme.teal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No recent alerts yet. Your next messages, reminders, and payment notices will appear here.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationTile(BuildContext context, NotificationData item) {
    final parsed = DateTime.tryParse(item.createdAt);
    final date =
        parsed == null ? item.createdAt : DateFormat('dd MMM, HH:mm').format(parsed);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: (item.readStatus ? Colors.grey : AppTheme.teal)
                .withOpacity(0.14),
            child: Icon(
              item.readStatus
                  ? Icons.mark_email_read_rounded
                  : Icons.notification_important_rounded,
              size: 18,
              color: item.readStatus ? Colors.grey : AppTheme.teal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: item.readStatus ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitleForRole(Role role) {
    switch (role) {
      case Role.superAdmin:
        return 'Academy oversight, communications, and governance shortcuts';
      case Role.admin:
        return 'Daily academy operations, users, and communication tools';
      case Role.trainer:
        return 'Training workload, attendance, and performance follow-up';
      case Role.parent:
        return 'Family coordination, payment follow-up, and academy updates';
      case Role.player:
        return 'Your activities, payments, and academy updates in one place';
      case Role.scouter:
        return 'Scouting watchlist, search flows, and club communication';
      case Role.unknown:
        return 'Alerts and shortcuts tailored to your session';
    }
  }

  String _roleShortLabel(Role role) {
    switch (role) {
      case Role.superAdmin:
        return 'SUPER';
      case Role.admin:
        return 'ADMIN';
      case Role.trainer:
        return 'TRAINER';
      case Role.parent:
        return 'PARENT';
      case Role.player:
        return 'PLAYER';
      case Role.scouter:
        return 'SCOUTER';
      case Role.unknown:
        return 'USER';
    }
  }

  List<_OperationAction> _operationsForRole(Role role) {
    switch (role) {
      case Role.superAdmin:
        return const [
          _OperationAction('Academies', '/super-admin/academies', Icons.domain_rounded, Colors.redAccent),
          _OperationAction('App data', '/super-admin/app-data', Icons.dataset_rounded, AppTheme.teal),
          _OperationAction('Contact admins', '/super-admin/contact-admins', Icons.contact_mail_rounded, Colors.indigo),
          _OperationAction('Platform settings', '/super-admin/settings', Icons.tune_rounded, Colors.orange),
        ];
      case Role.admin:
        return const [
          _OperationAction('Manage users', '/admin-users', Icons.groups_rounded, Colors.redAccent),
          _OperationAction('Send notice', '/send-notification', Icons.notifications_active_rounded, Colors.indigo),
          _OperationAction('Data hub', '/data-management', Icons.storage_rounded, AppTheme.teal),
          _OperationAction('Statistics', '/statistics', Icons.query_stats_rounded, Colors.orange),
        ];
      case Role.trainer:
        return const [
          _OperationAction('Manage activities', '/trainer-activities', Icons.edit_calendar_rounded, AppTheme.teal),
          _OperationAction('Update player stats', '/trainer-player-stats', Icons.insights_rounded, Colors.indigo),
          _OperationAction('Notifications', '/notifications', Icons.notifications_rounded, Colors.orange),
          _OperationAction('Academy details', '/academy-info', Icons.shield_rounded, Colors.green),
        ];
      case Role.parent:
        return const [
          _OperationAction('Payments', '/my-payments', Icons.payments_rounded, Colors.orange),
          _OperationAction('Activities', '/my-activities', Icons.event_available_rounded, AppTheme.teal),
          _OperationAction('Notifications', '/notifications', Icons.notifications_rounded, Colors.indigo),
          _OperationAction('Profile', '/profile', Icons.person_rounded, Colors.green),
        ];
      case Role.player:
        return const [
          _OperationAction('Matches', '/my-matches', Icons.sports_soccer_rounded, Colors.orange),
          _OperationAction('Activities', '/my-activities', Icons.event_rounded, AppTheme.teal),
          _OperationAction('Payments', '/my-payments', Icons.account_balance_wallet_rounded, Colors.indigo),
          _OperationAction('Profile', '/profile', Icons.person_rounded, Colors.green),
        ];
      case Role.scouter:
        return const [
          _OperationAction('Scouter dashboard', '/scouter-dashboard', Icons.space_dashboard_rounded, Colors.green),
          _OperationAction('Scouting AI', '/scouting', Icons.travel_explore_rounded, AppTheme.teal),
          _OperationAction('Global search', '/global-search', Icons.search_rounded, Colors.indigo),
          _OperationAction('Notifications', '/notifications', Icons.notifications_rounded, Colors.orange),
        ];
      case Role.unknown:
        return const [
          _OperationAction('Notifications', '/notifications', Icons.notifications_rounded, AppTheme.teal),
          _OperationAction('Profile', '/profile', Icons.person_rounded, Colors.indigo),
        ];
    }
  }
}

class _OperationAction {
  final String label;
  final String route;
  final IconData icon;
  final Color color;

  const _OperationAction(this.label, this.route, this.icon, this.color);
}

