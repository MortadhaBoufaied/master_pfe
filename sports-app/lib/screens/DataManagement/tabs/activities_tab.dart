import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../controllers/dataManagementController.dart';
import '../../../l10n/app_strings.dart';
import '../data_management_scope.dart';
import '../../../models/unified_activity.dart';
import '../../../controllers/unified_activities_extension.dart';
import '../../../utils/role_utils.dart';
import '../../../components/ui_kit.dart';
import 'monthly_activities/components/ActivityFormDialog.dart';
import '../../../models/activity.dart';

class ActivitiesTab extends StatefulWidget {
  final UnifiedActivityType? initialFilter;

  const ActivitiesTab({super.key, this.initialFilter});

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  final TextEditingController _search = TextEditingController();
  UnifiedActivityType? _filter;
  late final bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = UserRoleUtil.isAdmin();
    _filter = widget.initialFilter;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<UnifiedActivity> _apply(List<UnifiedActivity> list) {
    final q = _search.text.trim().toLowerCase();
    return list.where((a) {
      if (_filter != null && a.type != _filter) return false;
      if (q.isEmpty) return true;
      return a.title.toLowerCase().contains(q) ||
          (a.location ?? '').toLowerCase().contains(q) ||
          (a.meta ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _addTraining(DataManagementController dm) async {
    if (!_isAdmin) return;
    await showDialog(
      context: context,
      builder: (_) => ActivityFormDialog(
        activity: null,
        onSave: (Activity a) async {
          await dm.createActivity(a);
        },
      ),
    );
    await Future.wait([dm.refreshActivities(), dm.refreshMatches()]);
    if (mounted) setState(() {});
  }

  Future<void> _editTraining(DataManagementController dm, Activity existing) async {
    if (!_isAdmin) return;
    await showDialog(
      context: context,
      builder: (_) => ActivityFormDialog(
        activity: existing,
        onSave: (Activity a) async {
          if (existing.id != null) {
            await dm.updateActivity(existing.id!, a);
          }
        },
      ),
    );
    await dm.refreshActivities();
    if (mounted) setState(() {});
  }

  Future<void> _deleteItem(DataManagementController dm, UnifiedActivity item) async {
    if (!_isAdmin) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete ${item.title}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    bool success;
    if (item.type == UnifiedActivityType.training) {
      success = await dm.deleteActivity(item.id);
    } else {
      success = await dm.deleteMatch(item.id);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Deleted' : 'Delete failed')),
    );
    await Future.wait([dm.refreshActivities(), dm.refreshMatches()]);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final dm = DataManagementScope.of(context);
    final list = _apply(dm.unifiedActivities);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([dm.refreshActivities(), dm.refreshMatches()]);
        if (mounted) setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: t.tr('search'),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<UnifiedActivityType?>(
                icon: const Icon(Icons.filter_alt),
                onSelected: (v) => setState(() => _filter = v),
                itemBuilder: (_) => [
                  PopupMenuItem(value: null, child: Text(t.tr('filter_all'))),
                  PopupMenuItem(value: UnifiedActivityType.training, child: Text(t.tr('filter_training'))),
                  PopupMenuItem(value: UnifiedActivityType.match, child: Text(t.tr('filter_matches'))),
                ],
              ),
              if (_isAdmin)
                IconButton(
                  tooltip: 'Add training',
                  onPressed: () => _addTraining(dm),
                  icon: const Icon(Icons.add_circle_outline),
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(child: Text(t.tr('no_items'))),
            )
          else
            ...list.map((a) => _ActivityTile(
                  activity: a,
                  isAdmin: _isAdmin,
                  onDelete: () => _deleteItem(dm, a),
                )),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final UnifiedActivity activity;
  final bool isAdmin;
  final VoidCallback onDelete;

  const _ActivityTile({
    required this.activity,
    required this.isAdmin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTraining = activity.type == UnifiedActivityType.training;
    final color = isTraining ? cs.primary : Colors.deepOrange;
    final icon = isTraining ? Icons.fitness_center : Icons.sports_soccer;

    final dateTxt = activity.date == null ? '' : (activity.date);

    return SoftCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
        title: Text(activity.title),
        subtitle: Text('${activity.meta ?? ''}  $dateTxt'),
        trailing: isAdmin
            ? IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}


