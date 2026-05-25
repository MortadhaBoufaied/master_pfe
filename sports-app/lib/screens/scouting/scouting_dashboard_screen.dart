import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/modern_design_system.dart';
import '../../components/app_background.dart';
import '../../controllers/scouting_controller.dart';
import '../../models/scouting_models.dart';

class ScoutingDashboardScreen extends StatefulWidget {
  const ScoutingDashboardScreen({super.key});

  @override
  State<ScoutingDashboardScreen> createState() =>
      _ScoutingDashboardScreenState();
}

class _ScoutingDashboardScreenState extends State<ScoutingDashboardScreen> {
  final ScoutingController _controller = ScoutingController();

  final TextEditingController _qCtl = TextEditingController();
  final TextEditingController _positionCtl = TextEditingController();
  final TextEditingController _minPotentialCtl = TextEditingController();
  final TextEditingController _maxChurnCtl = TextEditingController();
  final Map<String, TextEditingController> _templateCtrls =
      <String, TextEditingController>{};

  final Set<int> _selectedForCompare = <int>{};
  final Set<int> _watchlist = <int>{};
  final Map<int, String> _notes = <int, String>{};

  int? _selectedSportId;
  int? _selectedDivisionId;
  String _orderBy = 'potentialScore';
  String _shortlistStrategy = 'balanced';
  bool _showWatchlistOnly = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _loadSavedWorkflow();
    _controller.loadSports();
    _controller.search(limit: 20);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _qCtl.dispose();
    _positionCtl.dispose();
    _minPotentialCtl.dispose();
    _maxChurnCtl.dispose();
    for (final controller in _templateCtrls.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<ScoutingPlayerCard> get _visibleResults {
    if (!_showWatchlistOnly) return _controller.searchResults;
    return _controller.searchResults
        .where((p) => _watchlist.contains(p.playerExternalId))
        .toList();
  }

  Future<void> _loadSavedWorkflow() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList('scouting.watchlist') ?? const [];
    final savedNotes = prefs.getString('scouting.notes');
    if (!mounted) return;
    setState(() {
      _watchlist
        ..clear()
        ..addAll(savedIds.map(int.tryParse).whereType<int>());
      _notes.clear();
      if (savedNotes != null && savedNotes.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedNotes);
          if (decoded is Map) {
            decoded.forEach((key, value) {
              final id = int.tryParse(key.toString());
              final note = value?.toString().trim() ?? '';
              if (id != null && note.isNotEmpty) _notes[id] = note;
            });
          }
        } catch (_) {
          _notes.clear();
        }
      }
    });
  }

  Future<void> _saveWorkflow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'scouting.watchlist',
      _watchlist.map((id) => id.toString()).toList(),
    );
    await prefs.setString(
      'scouting.notes',
      jsonEncode(_notes.map((key, value) => MapEntry(key.toString(), value))),
    );
  }

  Future<void> _search() async {
    if (_selectedSportId != null) {
      await _controller.searchSportPlayers(
        sportId: _selectedSportId!,
        divisionId: _selectedDivisionId,
        q: _qCtl.text.trim().isEmpty ? null : _qCtl.text.trim(),
        filters: _collectTemplateFilters(),
        orderBy: _orderBy,
        size: 30,
      );
      return;
    }

    await _controller.search(
      q: _qCtl.text.trim().isEmpty ? null : _qCtl.text.trim(),
      position:
          _positionCtl.text.trim().isEmpty ? null : _positionCtl.text.trim(),
      minPotential: _parseDouble(_minPotentialCtl.text),
      maxChurn: _parseDouble(_maxChurnCtl.text),
      limit: 30,
    );
  }

  Future<void> _selectSport(int? sportId) async {
    if (_selectedSportId == sportId) return;

    for (final controller in _templateCtrls.values) {
      controller.dispose();
    }
    _templateCtrls.clear();

    setState(() {
      _selectedSportId = sportId;
      _selectedDivisionId = null;
    });

    await _controller.loadSportTemplate(sportId);
    if (_controller.error != null) {
      _showSnack(_controller.error!);
      return;
    }
    await _search();
  }

  Future<void> _compare() async {
    if (_selectedForCompare.length < 2) {
      _showSnack('Select at least 2 players to compare');
      return;
    }

    await _controller.compare(_selectedForCompare.toList());
    if (_controller.error != null) {
      _showSnack(_controller.error!);
      return;
    }

    _showCompareDialog();
  }

  Future<void> _generateShortlist() async {
    await _controller.generateShortlist(
      title: 'Scouter Picks',
      strategy: _shortlistStrategy,
      q: _qCtl.text.trim().isEmpty ? null : _qCtl.text.trim(),
      position:
          _positionCtl.text.trim().isEmpty ? null : _positionCtl.text.trim(),
      minPotential: _parseDouble(_minPotentialCtl.text),
      maxChurn: _parseDouble(_maxChurnCtl.text),
      topN: 10,
    );

    if (_controller.error != null) {
      _showSnack(_controller.error!);
      return;
    }

    _showShortlistDialog();
  }

  Future<void> _toggleWatchlist(ScoutingPlayerCard player) async {
    setState(() {
      if (_watchlist.contains(player.playerExternalId)) {
        _watchlist.remove(player.playerExternalId);
      } else {
        _watchlist.add(player.playerExternalId);
      }
    });
    await _saveWorkflow();
  }

  Future<void> _editNote(ScoutingPlayerCard player) async {
    final controller = TextEditingController(
      text: _notes[player.playerExternalId] ?? '',
    );
    final note = await showDialog<String?>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Scout note: ${player.fullName}'),
            content: TextField(
              controller: controller,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Observation, context, next step...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: const Text('Clear'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    controller.dispose();
    if (note == null) return;

    setState(() {
      if (note.isEmpty) {
        _notes.remove(player.playerExternalId);
      } else {
        _notes[player.playerExternalId] = note;
        _watchlist.add(player.playerExternalId);
      }
    });
    await _saveWorkflow();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Scouting AI Workspace'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _showWatchlistOnly ? 'Show all results' : 'Show watchlist',
            onPressed:
                () => setState(() => _showWatchlistOnly = !_showWatchlistOnly),
            icon: Icon(
              _showWatchlistOnly ? Icons.bookmark : Icons.bookmark_border,
            ),
          ),
          IconButton(
            tooltip: 'Refresh backend data',
            onPressed: _controller.loading ? null : _search,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(cs),
          if (_controller.loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child:
                _visibleResults.isEmpty
                    ? Center(
                      child: Text(
                        _controller.error ??
                            (_showWatchlistOnly
                                ? 'No watched players in this result set'
                                : 'No players found'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                      itemCount: _visibleResults.length,
                      itemBuilder: (_, index) {
                        final p = _visibleResults[index];
                        return _playerCard(cs, p);
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _controller.loading ? null : _compare,
                  icon: const Icon(Icons.compare_arrows),
                  label: Text('Compare (${_selectedForCompare.length})'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _controller.loading ? null : _generateShortlist,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Shortlist'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedSportId,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Sport',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All sports'),
                    ),
                    ..._controller.sports.map(
                      (sport) => DropdownMenuItem<int?>(
                        value: _toNullableInt(sport['sportId']),
                        child: Text(_text(sport['sportName'], 'Sport')),
                      ),
                    ),
                  ],
                  onChanged:
                      _controller.loading ? null : (value) => _selectSport(value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedDivisionId,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Division',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All divisions'),
                    ),
                    ..._controller.sportDivisions.map(
                      (division) => DropdownMenuItem<int?>(
                        value: _toNullableInt(division['divisionId']),
                        child: Text(
                          _text(division['divisionName'], 'Division'),
                        ),
                      ),
                    ),
                  ],
                  onChanged:
                      _selectedSportId == null || _controller.loading
                          ? null
                          : (value) {
                            setState(() => _selectedDivisionId = value);
                            _search();
                          },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qCtl,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Query',
                    hintText: 'Name, academy, position...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _orderBy,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Order by',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'potentialScore',
                      child: Text('Potential'),
                    ),
                    DropdownMenuItem(
                      value: 'scoutingOpportunityScore',
                      child: Text('Opportunity'),
                    ),
                    DropdownMenuItem(
                      value: 'progressionVelocity',
                      child: Text('Progression'),
                    ),
                    DropdownMenuItem(value: 'roleFitScore', child: Text('Role fit')),
                    DropdownMenuItem(value: 'talentScore', child: Text('Talent')),
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                    DropdownMenuItem(value: 'playerName', child: Text('Name')),
                  ],
                  onChanged:
                      _selectedSportId == null
                          ? null
                          : (value) {
                            if (value == null) return;
                            setState(() => _orderBy = value);
                            _search();
                          },
                ),
              ),
            ],
          ),
          if (_selectedSportId == null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _positionCtl,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Position',
                      hintText: 'MID / DEF / FWD',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _minPotentialCtl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Min Potential',
                      hintText: 'e.g. 65',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _maxChurnCtl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Max Churn (0-1)',
                hintText: 'e.g. 0.45',
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            _templateFilterControls(cs),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _shortlistStrategy,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Shortlist Strategy',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'balanced',
                      child: Text('Balanced'),
                    ),
                    DropdownMenuItem(
                      value: 'high_potential',
                      child: Text('High potential'),
                    ),
                    DropdownMenuItem(
                      value: 'low_risk',
                      child: Text('Low risk'),
                    ),
                    DropdownMenuItem(
                      value: 'breakthrough',
                      child: Text('Breakthrough'),
                    ),
                    DropdownMenuItem(
                      value: 'fast_progression',
                      child: Text('Fast progression'),
                    ),
                    DropdownMenuItem(
                      value: 'hidden_potential',
                      child: Text('Hidden potential'),
                    ),
                    DropdownMenuItem(
                      value: 'role_fit',
                      child: Text('Role fit'),
                    ),
                    DropdownMenuItem(
                      value: 'context_adjusted',
                      child: Text('Context adjusted'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _shortlistStrategy = v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _controller.loading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ],
          ),
          if (_watchlist.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                avatar: const Icon(Icons.bookmark, size: 18),
                label: Text('${_watchlist.length} watched players'),
                selected: _showWatchlistOnly,
                onPressed:
                    () => setState(
                      () => _showWatchlistOnly = !_showWatchlistOnly,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _templateFilterControls(ColorScheme cs) {
    final filters = _controller.sportFilters;
    if (_controller.loading && filters.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }

    if (filters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.secondaryContainer.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'No custom filters configured for this sport yet.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          for (var i = 0; i < filters.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: _templateFilterControl(filters[i])),
                  const SizedBox(width: 8),
                  Expanded(
                    child:
                        i + 1 < filters.length
                            ? _templateFilterControl(filters[i + 1])
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _templateFilterControl(Map<String, dynamic> filter) {
    final key = _text(filter['filterKey'], '');
    if (key.isEmpty) return const SizedBox.shrink();

    final label = _text(filter['filterLabel'], key);
    final type = _text(filter['filterType'], '').toLowerCase();
    final allowedValues = (filter['allowedValues'] as List? ?? const [])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();

    if (allowedValues.isNotEmpty ||
        type.contains('select') ||
        type.contains('enum') ||
        key == 'paymentStatus') {
      final values =
          allowedValues.isNotEmpty ? allowedValues : const ['PAID', 'UNPAID'];
      final current = _templateCtrls[key]?.text;

      return DropdownButtonFormField<String>(
        value: values.contains(current) ? current : '',
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text('Any')),
          ...values.map((value) => DropdownMenuItem(
                value: value,
                child: Text(value),
              )),
        ],
        onChanged: (value) {
          _templateCtrl(key).text = value ?? '';
        },
      );
    }

    final numeric = type.contains('number') ||
        type.contains('range') ||
        key.toLowerCase().contains('min') ||
        key.toLowerCase().contains('max') ||
        key.toLowerCase().contains('score') ||
        key.toLowerCase().contains('age') ||
        key.toLowerCase().contains('height') ||
        key.toLowerCase().contains('weight');

    return TextField(
      controller: _templateCtrl(key),
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: _filterHint(filter),
        border: const OutlineInputBorder(),
      ),
    );
  }

  TextEditingController _templateCtrl(String key) {
    return _templateCtrls.putIfAbsent(key, TextEditingController.new);
  }

  Map<String, dynamic> _collectTemplateFilters() {
    final filters = <String, dynamic>{};
    for (final entry in _templateCtrls.entries) {
      final text = entry.value.text.trim();
      if (text.isEmpty) continue;
      filters[entry.key] = double.tryParse(text) ?? text;
    }
    return filters;
  }

  Widget _playerCard(ColorScheme cs, ScoutingPlayerCard p) {
    final selected = _selectedForCompare.contains(p.playerExternalId);
    final watched = _watchlist.contains(p.playerExternalId);
    final note = _notes[p.playerExternalId];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.fullName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.sportName ?? 'Sport'} - ${p.positionGroup ?? p.position ?? '-'} - age ${p.age ?? '-'} - ${p.divisionName ?? 'No division'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip:
                      watched ? 'Remove from watchlist' : 'Add to watchlist',
                  onPressed: () => _toggleWatchlist(p),
                  icon: Icon(watched ? Icons.bookmark : Icons.bookmark_border),
                ),
                Checkbox(
                  value: selected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedForCompare.add(p.playerExternalId);
                      } else {
                        _selectedForCompare.remove(p.playerExternalId);
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _metricChip(
                    cs,
                    'Opportunity',
                    p.scoutingOpportunityScore.toStringAsFixed(1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _metricChip(
                    cs,
                    'Potential',
                    p.potentialScore.toStringAsFixed(1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _metricChip(
                    cs,
                    'Churn',
                    '${(p.churnRisk * 100).toStringAsFixed(1)}%',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _metricChip(cs, 'Trend', p.trendLabel)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _metricChip(
                    cs,
                    'Velocity',
                    p.progressionVelocity.toStringAsFixed(1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _metricChip(
                    cs,
                    'Role',
                    p.roleFitScore.toStringAsFixed(1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _metricChip(
                    cs,
                    'Rating',
                    p.avgRating.toStringAsFixed(2),
                  ),
                ),
              ],
            ),
            if (note != null && note.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  note.trim(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => _editNote(p),
                    icon: const Icon(Icons.note_alt_outlined),
                    label: Text(
                      note == null || note.trim().isEmpty
                          ? 'Add note'
                          : 'Edit note',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await _controller.loadInsights(p.playerExternalId);
                      if (_controller.error != null) {
                        _showSnack(_controller.error!);
                        return;
                      }
                      _showInsightsDialog(p.playerExternalId, p.fullName);
                    },
                    icon: const Icon(Icons.insights),
                    label: const Text('AI insights'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(ColorScheme cs, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _showCompareDialog() {
    showDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Compare Players'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Highlights: ${_controller.compareHighlights}'),
                    const SizedBox(height: 10),
                    for (final p in _controller.comparedPlayers)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(p.fullName),
                        subtitle: Text(
                          'Potential ${p.potentialScore.toStringAsFixed(1)} | Churn ${(p.churnRisk * 100).toStringAsFixed(1)}% | Rating ${p.avgRating.toStringAsFixed(2)}',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showShortlistDialog() {
    showDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Shortlist: ${_controller.shortlistTitle}'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Strategy: ${_controller.shortlistStrategy}'),
                    const SizedBox(height: 8),
                    for (final p in _controller.shortlistPlayers)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(p.fullName),
                        subtitle: Text(
                          'Score ${p.shortlistScore?.toStringAsFixed(2) ?? '-'} | Opportunity ${p.scoutingOpportunityScore.toStringAsFixed(1)} | Velocity ${p.progressionVelocity.toStringAsFixed(1)}',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showInsightsDialog(int playerId, String playerName) {
    final potential = _controller.potentialByPlayer[playerId] ?? const {};
    final evolution = _controller.evolutionByPlayer[playerId] ?? const {};
    final churn = _controller.churnByPlayer[playerId] ?? const {};

    showDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('AI Insights - $playerName'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Potential: ${potential['potential_score'] ?? '-'} (${potential['level'] ?? '-'})',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Evolution: ${evolution['trend_label'] ?? '-'} (confidence ${evolution['confidence'] ?? '-'})',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Churn risk: ${churn['risk_score'] ?? '-'} (${churn['risk_level'] ?? '-'})',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Probable reasons:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    for (final reason
                        in (churn['probable_reasons'] as List? ?? const []))
                      Text('- $reason'),
                    const SizedBox(height: 8),
                    Text(
                      'Recommended actions:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    for (final action
                        in (churn['recommended_actions'] as List? ?? const []))
                      Text('- $action'),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _filterHint(Map<String, dynamic> filter) {
    final minValue = filter['minValue']?.toString().trim() ?? '';
    final maxValue = filter['maxValue']?.toString().trim() ?? '';
    if (minValue.isNotEmpty && maxValue.isNotEmpty) {
      return '$minValue to $maxValue';
    }
    if (minValue.isNotEmpty) return 'Min $minValue';
    if (maxValue.isNotEmpty) return 'Max $maxValue';
    return '';
  }

  String _text(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  int? _toNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _parseDouble(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }
}


