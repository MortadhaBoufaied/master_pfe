import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/app_background.dart';
import '../../components/ui_kit.dart';
import '../../components/modern_design_system.dart';
import '../../controllers/notificationsController.dart';
import '../../controllers/session_controller.dart';
import '../../l10n/app_strings.dart';
import '../../models/notification_data.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  final bool embedded;

  const NotificationsScreen({Key? key, this.embedded = false})
    : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _controller = NotificationController();
  String _filter = 'all'; // all, unread, payment, activity

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _load();
    final userId = AppSession.instance.session.userId;
    if (userId != null) {
      _controller.startRealtime(userId: userId);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _controller.loadNotifications();
  }

  List<NotificationData> get _filtered {
    var list = List<NotificationData>.from(_controller.notifications);
    final norm = (String s) => s.toLowerCase();

    bool isPayment(NotificationData n) {
      final c = norm(n.content);
      return c.contains('payment') || c.contains('paiement');
    }

    bool isActivity(NotificationData n) {
      final c = norm(n.content);
      return c.contains('activity') ||
          c.contains('activite') ||
          c.contains('activit') ||
          c.contains('match') ||
          c.contains('training') ||
          c.contains('entrainement') ||
          c.contains('entranement');
    }

    switch (_filter) {
      case 'unread':
        list = list.where((n) => !n.readStatus).toList();
        break;
      case 'payment':
        list = list.where(isPayment).toList();
        break;
      case 'activity':
        list = list.where(isActivity).toList();
        break;
      default:
        break;
    }

    // Sort newest first when possible
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    final pageBody = Column(
      children: [
        _buildFilterBar(context),
        _buildStats(context),
        Expanded(
          child:
              _controller.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.teal),
                  )
                  : RefreshIndicator(
                    onRefresh: _load,
                    child: _buildList(context),
                  ),
        ),
      ],
    );

    if (widget.embedded) {
      return pageBody;
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(t.tr('notifications')),
          actions: [
            TextButton(
              onPressed:
                  _controller.unreadCount > 0 ? _controller.markAllAsRead : null,
              child: const Text('Mark all read'),
            ),
          ],
        ),
        body: pageBody,
        floatingActionButton:
            kDebugMode
                ? FloatingActionButton(
                  onPressed: _sendTest,
                  child: const Icon(Icons.add_alert),
                )
                : null,
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final t = AppStrings.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(t.tr('all'), 'all'),
            _chip(t.tr('unread'), 'unread'),
            _chip(t.tr('payments'), 'payment'),
            _chip(t.tr('activities'), 'activity'),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) => setState(() => _filter = value),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Colors.teal.shade100,
        checkmarkColor: Colors.teal,
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final t = AppStrings.of(context);
    final unread = _controller.unreadCount;
    final total = _controller.notifications.length;
    final filtered = _filtered.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _stat(t.tr('unread'), unread.toString(), Colors.red)),
          Expanded(child: _stat(t.tr('total'), total.toString(), Colors.teal)),
          Expanded(
            child: _stat(t.tr('filtered'), filtered.toString(), Colors.indigo),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    final t = AppStrings.of(context);
    final list = _filtered;

    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.notifications_none,
            size: 72,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              t.tr('empty'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: Text(t.tr('retry')),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _notificationCard(context, list[i]),
    );
  }

  Widget _notificationCard(BuildContext context, NotificationData n) {
    final t = AppStrings.of(context);
    final isUnread = !n.readStatus;

    final content = n.preview;
    final icon = _detectIcon(content);
    final color = _detectColor(content);

    return Dismissible(
      key: ValueKey('notif_${n.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: Text(t.tr('confirm_delete')),
                    content: Text(t.tr('delete') + '?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(t.tr('cancel')),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(t.tr('delete')),
                      ),
                    ],
                  ),
            ) ??
            false;
      },
      onDismissed: (_) => _controller.deleteNotification(n.id),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openNotificationDetails(n),
        child: SoftCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (n.title.trim().isNotEmpty)
                                Text(
                                  n.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight:
                                        isUnread ? FontWeight.w900 : FontWeight.w800,
                                  ),
                                ),
                              if (n.title.trim().isNotEmpty)
                                const SizedBox(height: 4),
                              Text(
                                n.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight:
                                      isUnread ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8, top: 6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if ((n.senderName ?? '').trim().isNotEmpty)
                          Text(
                            'From ${n.senderName}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Text(
                          _timeAgo(n.createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                        if ((n.category ?? '').trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              n.category!.replaceAll('_', ' '),
                              style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (isUnread)
                          TextButton.icon(
                            onPressed: () => _controller.markAsRead(n.id),
                            icon: const Icon(Icons.done, size: 18),
                            label: Text(t.tr('mark_read')),
                          ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'open') _openNotificationDetails(n);
                            if (v == 'read') _controller.markAsRead(n.id);
                            if (v == 'delete') {
                              _controller.deleteNotification(n.id);
                            }
                          },
                          itemBuilder:
                              (_) => [
                                const PopupMenuItem(
                                  value: 'open',
                                  child: Text('Open'),
                                ),
                                PopupMenuItem(
                                  value: 'read',
                                  child: Text(t.tr('mark_read')),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(t.tr('delete')),
                                ),
                              ],
                        ),
                      ],
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

  IconData _detectIcon(String content) {
    final c = content.toLowerCase();
    if (c.contains('payment') || c.contains('paiement')) return Icons.payments;
    if (c.contains('match')) return Icons.sports_soccer;
    if (c.contains('activity') ||
        c.contains('activite') ||
        c.contains('activit') ||
        c.contains('training') ||
        c.contains('entrainement') ||
        c.contains('entranement')) {
      return Icons.event;
    }
    return Icons.notifications;
  }

  Color _detectColor(String content) {
    final c = content.toLowerCase();
    if (c.contains('payment') || c.contains('paiement')) return Colors.orange;
    if (c.contains('match')) return Colors.blue;
    if (c.contains('activity') ||
        c.contains('activite') ||
        c.contains('activit') ||
        c.contains('training') ||
        c.contains('entrainement') ||
        c.contains('entranement')) {
      return Colors.teal;
    }
    return Colors.grey;
  }

  String _timeAgo(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min';
      if (diff.inHours < 24) return '${diff.inHours} h';
      if (diff.inDays < 7) return '${diff.inDays} d';
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return createdAt;
    }
  }

  void _sendTest() {
    final now = DateTime.now().toIso8601String();
    _controller.addNotification(
      NotificationData(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 0,
        title: 'Test notification',
        content:
            'Test notification (${DateFormat('HH:mm').format(DateTime.now())})',
        createdAt: now,
        readStatus: false,
      ),
    );
  }

  Future<void> _openNotificationDetails(NotificationData notification) async {
    final opened = await _controller.openNotification(notification) ?? notification;
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        opened.title.trim().isEmpty ? 'Notification' : opened.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if ((opened.category ?? '').trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.teal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          opened.category!.replaceAll('_', ' '),
                          style: const TextStyle(
                            color: AppTheme.teal,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  [
                    if ((opened.senderName ?? '').trim().isNotEmpty)
                      'From ${opened.senderName}',
                    _timeAgo(opened.createdAt),
                  ].join(' ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· '),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  opened.content.trim().isEmpty ? opened.preview : opened.content,
                  style: const TextStyle(height: 1.5, fontSize: 15),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


