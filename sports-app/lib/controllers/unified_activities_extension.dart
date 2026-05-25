import '../models/unified_activity.dart';
import 'dataManagementController.dart';

extension UnifiedActivities on DataManagementController {
  List<UnifiedActivity> get unifiedActivities {
    final list = <UnifiedActivity>[];

    for (final a in filteredActivities) {
      list.add(UnifiedActivity(
        type: UnifiedActivityType.training,
        id: a.id,
        date: a.date,
        title: a.titre,
        location: a.lieu,
        trainerId: a.trainerId,
        divisionId: null,
        meta: a.description,
      ));
    }

    for (final m in filteredMatches) {
      final title = (m.opponent != null && m.opponent!.trim().isNotEmpty)
          ? 'vs ${m.opponent}'
          : 'Match';
      final meta = [m.result, m.score]
          .where((e) => e != null && e!.trim().isNotEmpty)
          .join(' ');

      list.add(UnifiedActivity(
        type: UnifiedActivityType.match,
        id: m.id,
        date: m.date,
        title: title,
        location: m.location,
        trainerId: m.trainerId,
        divisionId: m.divisionId,
        meta: meta.isEmpty ? null : meta,
      ));
    }

    list.sort((a, b) => (b.date ?? '').compareTo(a.date ?? ''));
    return list;
  }
}


