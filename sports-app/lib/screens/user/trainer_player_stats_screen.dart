import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/ui_kit.dart';
import '../../controllers/session_controller.dart';
import '../../models/player.dart';
import '../../models/training.dart';
import '../../services/PlayerServices.dart';
import '../../services/player_development_service.dart';
import '../../services/training_service.dart';
import '../../theme/app_theme.dart';

class TrainerPlayerStatsScreen extends StatefulWidget {
  const TrainerPlayerStatsScreen({super.key});

  @override
  State<TrainerPlayerStatsScreen> createState() =>
      _TrainerPlayerStatsScreenState();
}

class _TrainerPlayerStatsScreenState extends State<TrainerPlayerStatsScreen> {
  final PlayerService _playerService = PlayerService();
  final TrainingService _trainingService = TrainingService();
  final PlayerDevelopmentService _developmentService =
      PlayerDevelopmentService();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<Player> _players = [];
  List<Training> _trainings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = AppSession.instance.session;
      final allPlayers = await _playerService.getAllPlayers();
      final trainerId = session.trainerId;
      final divisionId = session.divisionId;

      var scopedPlayers = allPlayers;
      if (trainerId != null) {
        scopedPlayers = allPlayers
            .where(
              (player) =>
                  player.trainerId == trainerId ||
                  (player.trainerId == null &&
                      divisionId != null &&
                      player.divisionId == divisionId),
            )
            .toList();
      } else if (divisionId != null) {
        scopedPlayers = allPlayers
            .where((player) => player.divisionId == divisionId)
            .toList();
      }

      final loadedTrainings = trainerId == null
          ? await _trainingService.getAll()
          : await _trainingService.getByTrainer(trainerId);

      scopedPlayers.sort((first, second) =>
          (first.nom ?? 'Player').compareTo(second.nom ?? 'Player'));
      loadedTrainings.sort((first, second) => second.date.compareTo(first.date));

      _players = scopedPlayers;
      _trainings = loadedTrainings;
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Player development'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'Players'),
              Tab(icon: Icon(Icons.fact_check_rounded), text: 'Presence'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createTraining,
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Training'),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.teal),
              )
            : _error != null
                ? _errorState()
                : TabBarView(
                    children: [
                      _playersTab(),
                      _attendanceTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 42),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playersTab() {
    final query = _searchController.text.trim().toLowerCase();
    final visiblePlayers = query.isEmpty
        ? _players
        : _players
            .where(
              (player) =>
                  (player.nom ?? '').toLowerCase().contains(query) ||
                  (player.position ?? '').toLowerCase().contains(query) ||
                  (player.sportName ?? '').toLowerCase().contains(query),
            )
            .toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        children: [
          _summaryCards(),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Search player, role, or sport',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          if (visiblePlayers.isEmpty)
            _emptyState(
              icon: Icons.person_search_rounded,
              title: 'No players found',
              message: 'Assign players to this trainer or division first.',
            )
          else
            ...visiblePlayers.map(_playerCard),
        ],
      ),
    );
  }

  Widget _attendanceTab() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        children: [
          _attendanceHeader(),
          const SizedBox(height: 12),
          if (_trainings.isEmpty)
            _emptyState(
              icon: Icons.event_busy_rounded,
              title: 'No trainings yet',
              message:
                  'Create training sessions, then record who was present.',
            )
          else
            ..._trainings.map(_trainingCard),
        ],
      ),
    );
  }

  Widget _summaryCards() {
    final ratedCount = _players.where((player) => player.rating != null).length;
    final sportCount = _players
        .map((player) => player.sportName ?? '')
        .where((sport) => sport.trim().isNotEmpty)
        .toSet()
        .length;

    return Row(
      children: [
        Expanded(
          child: _metric('Players', _players.length.toString(),
              Icons.groups_rounded, AppTheme.teal),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metric('Rated', ratedCount.toString(),
              Icons.star_rate_rounded, Colors.amber.shade700),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metric('Sports', sportCount.toString(),
              Icons.sports_rounded, Colors.blue.shade700),
        ),
      ],
    );
  }

  Widget _attendanceHeader() {
    final recordedCount =
        _trainings.where((training) => training.attendeeIds.isNotEmpty).length;
    return Row(
      children: [
        Expanded(
          child: _metric('Sessions', _trainings.length.toString(),
              Icons.event_available_rounded, AppTheme.teal),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metric('Presence', recordedCount.toString(),
              Icons.fact_check_rounded, Colors.green.shade700),
        ),
      ],
    );
  }

  Widget _metric(String label, String value, IconData icon, Color color) {
    return SoftCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.14),
            child: Icon(icon, color: color),
          ),
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
                Text(label, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerCard(Player player) {
    final subtitle = [
      player.sportName,
      player.sportPositionName ?? player.position,
      player.divisionName,
    ].where((item) => item != null && item.trim().isNotEmpty).join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.teal.withOpacity(0.14),
                  child: Text(
                    _initials(player.nom),
                    style: const TextStyle(
                      color: AppTheme.teal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.nom ?? 'Player ${player.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'History',
                  onPressed: () => _openHistorySheet(player),
                  icon: const Icon(Icons.history_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Rating', _formatDouble(player.rating), Icons.star),
                _chip('Matches', '${player.matches ?? 0}',
                    Icons.sports_score_rounded),
                _chip('Goals', '${player.goals ?? 0}',
                    Icons.track_changes_rounded),
                _chip('Assists', '${player.assists ?? 0}',
                    Icons.handshake_rounded),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _openObservationSheet(player),
                  icon: const Icon(Icons.rate_review_rounded),
                  label: const Text('Report'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openInjurySheet(player),
                  icon: const Icon(Icons.healing_rounded),
                  label: const Text('Injury'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _openLegacyStatsSheet(player),
                  icon: const Icon(Icons.query_stats_rounded),
                  label: const Text('Stats'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _trainingCard(Training training) {
    final presentCount = training.attendeeIds.length;
    final details = [
      training.date,
      training.sessionType,
    ].where((item) => item != null && item.trim().isNotEmpty).join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.teal.withOpacity(0.14),
          child: const Icon(Icons.fitness_center_rounded, color: AppTheme.teal),
        ),
        title: Text(
          training.sessionType?.trim().isNotEmpty == true
              ? training.sessionType!
              : 'Training session',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.isNotEmpty) Text(details),
            if ((training.objectives ?? '').trim().isNotEmpty)
              Text(training.objectives!.trim()),
            const SizedBox(height: 6),
            Text(
              presentCount == 0
                  ? 'Presence not recorded'
                  : '$presentCount present • ${_players.length - presentCount} absent',
              style: TextStyle(
                color: presentCount == 0 ? Colors.orange.shade700 : AppTheme.teal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'presence') _openAttendanceSheet(training);
            if (value == 'report') _choosePlayerForTraining(training);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'presence', child: Text('Record presence')),
            PopupMenuItem(value: 'report', child: Text('Add player report')),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text('$label: $value'),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return SoftCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.teal, size: 44),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _openObservationSheet(Player player, {Training? training}) async {
    final notesController = TextEditingController();
    final sourceIdController =
        TextEditingController(text: training == null ? '' : '${training.id}');
    String sourceType = training == null ? 'MANUAL' : 'TRAINING';
    double summaryRating = (player.rating ?? 6).clamp(0, 10).toDouble();
    double rolePerformance = 65;
    double confidence = 0.7;
    bool saving = false;

    final metricDefinitions =
        player.sportId == null ? <Map<String, dynamic>>[] : await _loadMetricDefinitions(player.sportId!);
    final metricControllers = <String, TextEditingController>{};
    for (final metric in metricDefinitions.take(8)) {
      final code = metric['code']?.toString();
      if (code == null || code.trim().isEmpty) continue;
      metricControllers[code] = TextEditingController();
    }
    for (final code in const [
      'EFFORT',
      'TECHNIQUE',
      'TACTICAL',
      'PHYSICAL',
      'MENTAL',
      'DISCIPLINE',
    ]) {
      metricControllers.putIfAbsent(code, () => TextEditingController());
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottom = MediaQuery.of(context).viewInsets.bottom;
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AI report • ${player.nom ?? 'Player'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: sourceType,
                      decoration: const InputDecoration(
                        labelText: 'Source',
                        prefixIcon: Icon(Icons.source_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'MANUAL', child: Text('Manual observation')),
                        DropdownMenuItem(value: 'TRAINING', child: Text('Training')),
                        DropdownMenuItem(value: 'MATCH', child: Text('Match')),
                        DropdownMenuItem(value: 'SCOUTING', child: Text('Scouting')),
                      ],
                      onChanged: (value) {
                        if (value != null) setSheetState(() => sourceType = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sourceIdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Source ID (optional)',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _sliderRow(
                      label: 'Current rating',
                      value: summaryRating,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      suffix: '/10',
                      onChanged: (value) =>
                          setSheetState(() => summaryRating = value),
                    ),
                    _sliderRow(
                      label: 'Role fit',
                      value: rolePerformance,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      suffix: '%',
                      onChanged: (value) =>
                          setSheetState(() => rolePerformance = value),
                    ),
                    _sliderRow(
                      label: 'Confidence',
                      value: confidence,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      suffix: '',
                      onChanged: (value) =>
                          setSheetState(() => confidence = value),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Metric values',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...metricControllers.entries.map((entry) {
                      final label = _metricLabel(metricDefinitions, entry.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: entry.value,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: label,
                            helperText:
                                'Optional. Saved when this metric code exists for the sport.',
                            prefixIcon: const Icon(Icons.analytics_rounded),
                          ),
                        ),
                      );
                    }),
                    TextField(
                      controller: notesController,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Coach notes / scouting report',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              setSheetState(() => saving = true);
                              final metrics = <String, num>{};
                              metricControllers.forEach((code, controller) {
                                final value = num.tryParse(
                                  controller.text.trim().replaceAll(',', '.'),
                                );
                                if (value != null) metrics[code] = value;
                              });
                              await _developmentService.createObservation(
                                playerId: player.id,
                                sourceType: sourceType,
                                sourceId: int.tryParse(
                                  sourceIdController.text.trim(),
                                ),
                                summaryRating: summaryRating,
                                rolePerformanceIndex: rolePerformance,
                                confidence: confidence,
                                notes: notesController.text.trim(),
                                metrics: metrics,
                              );
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext, true);
                              }
                            },
                      icon: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(saving ? 'Saving...' : 'Save AI report'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    for (final controller in metricControllers.values) {
      controller.dispose();
    }
    notesController.dispose();
    sourceIdController.dispose();

    if (saved == true) {
      await _load();
      _showSnack('Player report saved for AI history');
    }
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    final shown = max <= 1 ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $shown$suffix',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: '$shown$suffix',
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _loadMetricDefinitions(int sportId) async {
    try {
      final metrics = await _developmentService.getSportMetrics(sportId);
      metrics.sort((first, second) {
        final firstOrder = int.tryParse('${first['displayOrder']}') ?? 0;
        final secondOrder = int.tryParse('${second['displayOrder']}') ?? 0;
        return firstOrder.compareTo(secondOrder);
      });
      return metrics
          .where((metric) => metric['active'] == null || metric['active'] == true)
          .toList();
    } catch (_) {
      return [];
    }
  }

  String _metricLabel(List<Map<String, dynamic>> definitions, String code) {
    final match = definitions.where((metric) => metric['code'] == code).toList();
    if (match.isNotEmpty) {
      final name = match.first['name']?.toString();
      if (name != null && name.trim().isNotEmpty) return '$name ($code)';
    }
    return code
        .toLowerCase()
        .split('_')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Future<void> _openInjurySheet(Player player) async {
    final typeController = TextEditingController();
    final notesController = TextEditingController();
    String severity = 'MEDIUM';
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    bool saving = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottom = MediaQuery.of(context).viewInsets.bottom;
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Injury • ${player.nom ?? 'Player'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: 'Injury type',
                        hintText: 'Hamstring, ankle, shoulder...',
                        prefixIcon: Icon(Icons.healing_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: severity,
                      decoration: const InputDecoration(
                        labelText: 'Severity',
                        prefixIcon: Icon(Icons.speed_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'LOW', child: Text('Low')),
                        DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                        DropdownMenuItem(value: 'HIGH', child: Text('High')),
                        DropdownMenuItem(value: 'CRITICAL', child: Text('Critical')),
                      ],
                      onChanged: (value) {
                        if (value != null) setSheetState(() => severity = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setSheetState(() => startDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text('Start: ${_date(startDate)}'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              endDate ?? DateTime.now().add(const Duration(days: 7)),
                          firstDate: startDate,
                          lastDate: DateTime.now().add(
                            const Duration(days: 730),
                          ),
                        );
                        setSheetState(() => endDate = picked);
                      },
                      icon: const Icon(Icons.event_available_rounded),
                      label: Text(endDate == null
                          ? 'Expected recovery: optional'
                          : 'Expected recovery: ${_date(endDate!)}'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Medical notes',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              final injuryType = typeController.text.trim();
                              if (injuryType.isEmpty) {
                                _showSnack('Add the injury type first');
                                return;
                              }
                              setSheetState(() => saving = true);
                              await _developmentService.recordInjury(
                                playerId: player.id,
                                injuryType: injuryType,
                                severity: severity,
                                startDate: _date(startDate),
                                endDate: endDate == null ? null : _date(endDate!),
                                notes: notesController.text.trim(),
                              );
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext, true);
                              }
                            },
                      icon: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(saving ? 'Saving...' : 'Save injury'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    typeController.dispose();
    notesController.dispose();

    if (saved == true) {
      _showSnack('Injury saved and available for AI availability signals');
    }
  }

  Future<void> _openLegacyStatsSheet(Player player) async {
    final goalsController =
        TextEditingController(text: (player.goals ?? 0).toString());
    final assistsController =
        TextEditingController(text: (player.assists ?? 0).toString());
    final matchesController =
        TextEditingController(text: (player.matches ?? 0).toString());
    final ratingController =
        TextEditingController(text: (player.rating ?? 0).toString());
    bool saving = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottom = MediaQuery.of(context).viewInsets.bottom;
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Legacy stats • ${player.nom ?? 'Player'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _numberField(goalsController, 'Goals'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _numberField(assistsController, 'Assists'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _numberField(matchesController, 'Matches'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _numberField(ratingController, 'Rating'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              setSheetState(() => saving = true);
                              final success =
                                  await _playerService.updatePlayerStats(
                                playerId: player.id,
                                goals: int.tryParse(goalsController.text.trim()),
                                assists:
                                    int.tryParse(assistsController.text.trim()),
                                matches:
                                    int.tryParse(matchesController.text.trim()),
                                rating: double.tryParse(
                                  ratingController.text
                                      .trim()
                                      .replaceAll(',', '.'),
                                ),
                                played: true,
                              );
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext, success);
                              }
                            },
                      icon: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(saving ? 'Saving...' : 'Update stats'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    goalsController.dispose();
    assistsController.dispose();
    matchesController.dispose();
    ratingController.dispose();

    if (saved == true) {
      await _load();
      _showSnack('Player stats updated');
    }
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _openHistorySheet(Player player) async {
    try {
      final history = await _developmentService.getPlayerHistory(player.id);
      final injuries = await _developmentService.getPlayerInjuries(player.id);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.72,
              minChildSize: 0.35,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'History • ${player.nom ?? 'Player'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (injuries.isNotEmpty) ...[
                      const Text(
                        'Injuries',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      ...injuries.map((injury) => _historyTile(
                            icon: Icons.healing_rounded,
                            title:
                                '${injury['injuryType'] ?? 'Injury'} • ${injury['severity'] ?? ''}',
                            subtitle:
                                '${injury['startDate'] ?? ''} → ${injury['endDate'] ?? 'active'}',
                            trailing: injury['recovered'] == true
                                ? 'Recovered'
                                : 'Active',
                          )),
                      const SizedBox(height: 12),
                    ],
                    const Text(
                      'Performance observations',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    if (history.isEmpty)
                      const Text('No reports saved yet.')
                    else
                      ...history.map((entry) => _historyTile(
                            icon: Icons.rate_review_rounded,
                            title:
                                '${entry['sourceType'] ?? 'MANUAL'} • ${_formatAny(entry['summaryRating'])}/10',
                            subtitle: entry['notes']?.toString() ??
                                'Role fit: ${_formatAny(entry['rolePerformanceIndex'])}',
                            trailing: _formatDateTime(entry['observedAt']),
                          )),
                  ],
                );
              },
            ),
          );
        },
      );
    } catch (error) {
      _showSnack('Could not load history: $error');
    }
  }

  Widget _historyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: Text(
          trailing,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Future<void> _openAttendanceSheet(Training training) async {
    final selectedIds = training.attendeeIds.toSet();
    bool saving = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.78,
                minChildSize: 0.45,
                maxChildSize: 0.96,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Presence • ${training.date}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Text('${selectedIds.length}/${_players.length}'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _players.length,
                          itemBuilder: (context, index) {
                            final player = _players[index];
                            final selected = selectedIds.contains(player.id);
                            return CheckboxListTile(
                              value: selected,
                              title: Text(player.nom ?? 'Player ${player.id}'),
                              subtitle: Text(
                                player.position ?? player.sportName ?? '',
                              ),
                              onChanged: (value) {
                                setSheetState(() {
                                  if (value == true) {
                                    selectedIds.add(player.id);
                                  } else {
                                    selectedIds.remove(player.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: FilledButton.icon(
                          onPressed: saving
                              ? null
                              : () async {
                                  if (selectedIds.isEmpty) {
                                    _showSnack(
                                      'Select at least one present player',
                                    );
                                    return;
                                  }
                                  setSheetState(() => saving = true);
                                  final updated =
                                      await _trainingService.recordAttendance(
                                    training.id,
                                    selectedIds.toList(),
                                  );
                                  if (sheetContext.mounted) {
                                    Navigator.pop(
                                      sheetContext,
                                      updated != null,
                                    );
                                  }
                                },
                          icon: saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_rounded),
                          label:
                              Text(saving ? 'Saving...' : 'Save presence list'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );

    if (saved == true) {
      await _load();
      _showSnack('Presence saved. Absences are inferred from missing players.');
    }
  }

  Future<void> _choosePlayerForTraining(Training training) async {
    if (_players.isEmpty) {
      _showSnack('No players available for this training');
      return;
    }
    final selectedPlayer = await showDialog<Player>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Add report for player'),
          children: [
            for (final player in _players)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, player),
                child: Text(player.nom ?? 'Player ${player.id}'),
              ),
          ],
        );
      },
    );
    if (selectedPlayer != null) {
      await _openObservationSheet(selectedPlayer, training: training);
    }
  }

  Future<void> _createTraining() async {
    final trainerId = AppSession.instance.session.trainerId;
    final sessionTypeController = TextEditingController(text: 'Development');
    final placeController = TextEditingController();
    final objectivesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool saving = false;

    final created = await showModalBottomSheet<Training?>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottom = MediaQuery.of(context).viewInsets.bottom;
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create training session',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sessionTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Session type',
                        prefixIcon: Icon(Icons.fitness_center_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 60),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(_date(selectedDate)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: placeController,
                      decoration: const InputDecoration(
                        labelText: 'Place',
                        prefixIcon: Icon(Icons.place_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: objectivesController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Objectives',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.flag_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              final sessionType =
                                  sessionTypeController.text.trim();
                              if (sessionType.isEmpty) {
                                _showSnack('Add the session type first');
                                return;
                              }
                              setSheetState(() => saving = true);
                              final training = await _trainingService.create({
                                'trainerId': trainerId,
                                'titre': sessionType,
                                'date': _date(selectedDate),
                                'lieu': placeController.text.trim(),
                                'description':
                                    objectivesController.text.trim(),
                                'sessionType': sessionType,
                                'objectives':
                                    objectivesController.text.trim(),
                              });
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext, training);
                              }
                            },
                      icon: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded),
                      label: Text(saving ? 'Creating...' : 'Create training'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    sessionTypeController.dispose();
    placeController.dispose();
    objectivesController.dispose();

    if (created != null) {
      await _load();
      _showSnack('Training created. You can now record presence.');
    }
  }

  String _initials(String? name) {
    final parts = (name ?? 'P')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return _firstInitial(parts.first);
    return '${_firstInitial(parts.first)}${_firstInitial(parts.last)}';
  }

  String _firstInitial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'P';
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _formatDouble(double? value) {
    if (value == null) return '0';
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }

  String _formatAny(dynamic value) {
    final number = double.tryParse(value?.toString() ?? '');
    if (number == null) return value?.toString() ?? '-';
    return _formatDouble(number);
  }

  String _formatDateTime(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.length >= 10) return text.substring(0, 10);
    return text;
  }

  String _date(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
