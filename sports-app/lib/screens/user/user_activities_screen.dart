import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/dataManagementController.dart';
import '../../controllers/session_controller.dart';
import '../../l10n/app_strings.dart';
import '../../models/role.dart';
import '../../models/unified_activity.dart';
import '../../controllers/unified_activities_extension.dart';

/// Filter shown to the user.
enum ActivityFilter { all, trainings, matches }

/// Calendar-based activities screen (Trainings + Matches).
/// - Click day => details below
/// - Players: current week only
class UserActivitiesScreen extends StatefulWidget {
  final ActivityFilter initialFilter;
  const UserActivitiesScreen({super.key, this.initialFilter = ActivityFilter.all});

  @override
  State<UserActivitiesScreen> createState() => _UserActivitiesScreenState();
}

class _UserActivitiesScreenState extends State<UserActivitiesScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  ActivityFilter _filter = ActivityFilter.all;

  final DataManagementController _dm = DataManagementController();

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _dm.bootstrap();
  }

  bool get _isPlayer => AppSession.instance.session.role == Role.player;

  List<DateTime> _daysToShow() {
    if (!_isPlayer) {
      final first = DateTime(_focused.year, _focused.month, 1);
      final startOffset = (first.weekday + 6) % 7; // Monday=0
      final start = first.subtract(Duration(days: startOffset));
      return List.generate(42, (i) => start.add(Duration(days: i)));
    }
    final now = DateTime.now();
    final start = now.subtract(Duration(days: (now.weekday + 6) % 7));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  List<UnifiedActivity> _activitiesForDay(DateTime day) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    final list = _dm.unifiedActivities.where((a) => a.date == key).toList();
    return list.where((a) {
      if (_filter == ActivityFilter.all) return true;
      if (_filter == ActivityFilter.trainings) {
        return a.type == UnifiedActivityType.training;
      }
      return a.type == UnifiedActivityType.match;
    }).toList();
  }

  Color _typeColor(UnifiedActivityType type) {
    return type == UnifiedActivityType.training ? Colors.teal : Colors.deepOrange;
  }

  IconData _typeIcon(UnifiedActivityType type) {
    return type == UnifiedActivityType.training ? Icons.fitness_center : Icons.sports_soccer;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final cs = Theme.of(context).colorScheme;

    final days = _daysToShow();
    final selectedActivities = _activitiesForDay(_selected);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(t.tr('activities')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _dm.bootstrap();
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
          children: [
            _FilterRow(
              value: _filter,
              onChanged: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outline.withOpacity(0.18)),
              ),
              child: Column(
                children: [
                  if (!_isPlayer)
                    _MonthHeader(
                      focused: _focused,
                      onPrev: () => setState(() =>
                      _focused = DateTime(_focused.year, _focused.month - 1, 1)),
                      onNext: () => setState(() =>
                      _focused = DateTime(_focused.year, _focused.month + 1, 1)),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month,
                              color: cs.onSurface.withOpacity(0.7)),
                          const SizedBox(width: 8),
                          Text(t.tr('current_week'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),

                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                    child: _CalendarGrid(
                      days: days,
                      focusedMonth: _focused.month,
                      selected: _selected,
                      onSelect: (d) => setState(() => _selected = d),
                      eventsForDay: _activitiesForDay,
                      typeColor: _typeColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Text(
              t.tr('day_details'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),

            if (selectedActivities.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Center(child: Text(t.tr('no_activities_day'))),
              )
            else
              ...selectedActivities.map((a) {
                final c = _typeColor(a.type);
                return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_typeIcon(a.type), color: c),
                      ),
                      title: Text(a.title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text([
                        if ((a.location ?? '').isNotEmpty) a.location!,
                        if ((a.meta ?? '').isNotEmpty) a.meta!,
                      ].join(' '),
                      ),
                    ));
              }),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final ActivityFilter value;
  final ValueChanged<ActivityFilter> onChanged;
  const _FilterRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<ActivityFilter>(
            segments: [
              ButtonSegment(value: ActivityFilter.all, label: Text(t.tr('filter_all'))),
              ButtonSegment(
                  value: ActivityFilter.trainings,
                  label: Text(t.tr('filter_training'))),
              ButtonSegment(
                  value: ActivityFilter.matches,
                  label: Text(t.tr('filter_matches'))),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime focused;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthHeader({required this.focused, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMMM yyyy').format(focused);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Center(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900)),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

typedef EventProvider = List<UnifiedActivity> Function(DateTime day);

class _CalendarGrid extends StatelessWidget {
  final List<DateTime> days;
  final int focusedMonth;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final EventProvider eventsForDay;
  final Color Function(UnifiedActivityType type) typeColor;

  const _CalendarGrid({
    required this.days,
    required this.focusedMonth,
    required this.selected,
    required this.onSelect,
    required this.eventsForDay,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWeek = days.length == 7;
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Row(
          children: List.generate(7, (i) {
            return Expanded(
              child: Center(
                child: Text(labels[i],
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w700)),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 54,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: days.length,
          itemBuilder: (context, i) {
            final d = days[i];
            final inMonth = isWeek ? true : d.month == focusedMonth;
            final isSelected = DateUtils.isSameDay(d, selected);
            final events = eventsForDay(d);
            final hasTraining =
            events.any((e) => e.type == UnifiedActivityType.training);
            final hasMatch =
            events.any((e) => e.type == UnifiedActivityType.match);

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSelect(d),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary.withOpacity(0.18)
                      : cs.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outline.withOpacity(0.12)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Text(
                        '${d.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: inMonth
                              ? cs.onSurface
                              : cs.onSurface.withOpacity(0.35),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          if (hasTraining)
                            _Dot(color: typeColor(UnifiedActivityType.training)),
                          if (hasMatch) ...[
                            if (hasTraining) const SizedBox(width: 6),
                            _Dot(color: typeColor(UnifiedActivityType.match)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}


