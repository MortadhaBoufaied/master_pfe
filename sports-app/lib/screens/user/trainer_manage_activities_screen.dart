import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/ui_kit.dart';
import '../../components/app_background.dart';
import '../../components/modern_design_system.dart';
import '../../controllers/session_controller.dart';
import '../../l10n/app_strings.dart';
import '../../models/activity.dart';
import '../../services/activity_service.dart';
import '../../theme/app_theme.dart';

class TrainerManageActivitiesScreen extends StatefulWidget {
  const TrainerManageActivitiesScreen({super.key});

  @override
  State<TrainerManageActivitiesScreen> createState() =>
      _TrainerManageActivitiesScreenState();
}

class _TrainerManageActivitiesScreenState
    extends State<TrainerManageActivitiesScreen> {
  final ActivityService _service = ActivityService();
  bool _loading = true;
  String? _error;
  List<Activity> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await _service.getAllActivities();
      final trainerId = AppSession.instance.session.trainerId;
      _items =
          trainerId == null
              ? all
              : all.where((a) => a.trainerId == trainerId).toList();
      _items.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createActivity() async {
    final trainerId = AppSession.instance.session.trainerId;
    final titleController = TextEditingController();
    final placeController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final created = await showModalBottomSheet<Activity?>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottom = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Plan activity',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.edit_calendar),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 30),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: placeController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Place',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Objectives or notes',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;
                      final activity = Activity(
                        id: 0,
                        trainerId: trainerId,
                        titre: title,
                        date: DateFormat('yyyy-MM-dd').format(selectedDate),
                        lieu:
                            placeController.text.trim().isEmpty
                                ? null
                                : placeController.text.trim(),
                        description:
                            descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                      );
                      final saved = await _service.createActivity(activity);
                      if (context.mounted) Navigator.pop(context, saved);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create activity'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    placeController.dispose();
    descriptionController.dispose();

    if (created != null) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Activity created')));
    }
  }

  Future<void> _deleteActivity(Activity activity) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete activity?'),
            content: Text(
              'This will remove "${activity.titre}" from the schedule.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    final deleted = await _service.deleteActivity(activity.id);
    if (!mounted) return;
    if (deleted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Activity deleted')));
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete activity')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final upcomingCount = _items.where(_isUpcoming).length;

    return Scaffold(
      appBar: AppBar(title: Text(t.tr('manage_activities'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createActivity,
        icon: const Icon(Icons.add),
        label: const Text('Plan'),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.teal),
              )
              : _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _metric(
                            'Sessions',
                            _items.length.toString(),
                            Icons.event_available,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _metric(
                            'Upcoming',
                            upcomingCount.toString(),
                            Icons.schedule,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_items.isEmpty)
                      _emptyState()
                    else
                      ..._items.map(_activityCard),
                  ],
                ),
              ),
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return SoftCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: const [
            Icon(Icons.event_busy, color: AppTheme.teal, size: 42),
            SizedBox(height: 10),
            Text(
              'No activities yet',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 4),
            Text('Use Plan to create the next session for your group.'),
          ],
        ),
      ),
    );
  }

  Widget _activityCard(Activity activity) {
    final details = [activity.date, activity.lieu]
        .where((item) => item != null && item.toString().trim().isNotEmpty)
        .join(' - ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.teal.withOpacity(0.14),
          child: const Icon(Icons.sports_soccer, color: AppTheme.teal),
        ),
        title: Text(
          activity.titre,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.isNotEmpty) Text(details),
            if ((activity.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(activity.description!.trim()),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') _deleteActivity(activity);
          },
          itemBuilder:
              (context) => const [
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
        ),
      ),
    );
  }

  bool _isUpcoming(Activity activity) {
    final date = DateTime.tryParse(activity.date);
    if (date == null) return false;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return !date.isBefore(startOfToday);
  }
}


