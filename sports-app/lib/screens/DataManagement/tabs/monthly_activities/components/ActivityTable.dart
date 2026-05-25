import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../controllers/ActivitiesController.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../../../models/activity.dart';
import '../../../../../components/ui_kit.dart';
import '../ActivityDetailsPage.dart';
import 'ActivityFormDialog.dart';

class ActivityTable extends StatelessWidget {
  final ActivitiesController controller;
  final List<Activity> activities;
  final Future<void> Function(String activityId) deleteActivity;
  final String monthYear;

  const ActivityTable({
    Key? key,
    required this.controller,
    required this.activities,
    required this.deleteActivity,
    required this.monthYear,
  }) : super(key: key);

  void _editActivity(BuildContext context, Activity a) {
    showDialog(
      context: context,
      builder: (dialogContext) => ActivityFormDialog(
        activity: a,
        onSave: (updated) async {
          await controller.updateActivity(
            activityId: a.id.toString(),
            activity: updated,
          );
        },
      ),
    );
  }

  void _viewDetails(BuildContext context, Activity a) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActivityDetailsPage(activity: a)),
    );
  }

  DateTime? _parseDate(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final a = activities[i];
        final dt = _parseDate(a.date);
        final dateLabel = dt == null ? a.date : DateFormat('yyyy-MM-dd').format(dt);

        return SoftCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            title: Text(a.titre),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t.tr('date')}: $dateLabel'),
                if (a.lieu != null && a.lieu!.isNotEmpty) Text('${t.tr('location')}: ${a.lieu}'),
                if (a.description != null && a.description!.trim().isNotEmpty)
                  Text(
                    a.description!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            onTap: () => _viewDetails(context, a),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editActivity(context, a),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(t.tr('confirm_delete')),
                        content: Text('${t.tr('delete')}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: Text(t.tr('cancel')),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: Text(t.tr('delete')),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await deleteActivity(a.id.toString());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


