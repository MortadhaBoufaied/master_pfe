import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:moez_project/components/NavigationLink.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../controllers/PlayerController.dart';
import '../../models/player.dart';
import '../../models/division.dart';
import '../controllers/divisionsController.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  _AdvancedSearchScreenState createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final PlayerController _playerController = PlayerController();
  final DivisionController _divisionController = DivisionController();

  // Filtres
  String _searchQuery = '';
  String? _selectedDivision;
  String? _selectedPosition;
  SfRangeValues _ageRange = const SfRangeValues(15.0, 35.0);
  SfRangeValues _goalsRange = const SfRangeValues(0.0, 50.0);
  SfRangeValues _ratingRange = const SfRangeValues(0.0, 10.0);
  bool _showFilters = false;
  bool _showStats = false;

  List<Player> _allPlayers = [];
  List<Player> _filteredPlayers = [];
  bool _isLoading = false;

  // Options pour les dropdowns
  final List<String> _positions = [
    'Goalkeeper',
    'Defender',
    'Midfielder',
    'Forward',
    'Winger',
  ];

  List<String> _divisions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await _playerController.loadPlayers();
      await _divisionController.fetchAll();

      _allPlayers = _playerController.players;
      _divisions = _divisionController.allDivisions.map((d) => d.nom).toList();
      _applyFilters();
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Player> filtered = _allPlayers;

    // Filtre par recherche textuelle
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered.where((player) {
            return (player.nom ?? '').toLowerCase().contains(query) ||
                (player.email ?? '').toLowerCase().contains(query) ||
                (player.position ?? '').toLowerCase().contains(query);
          }).toList();
    }

    // Filtre par division
    if (_selectedDivision != null) {
      final matchingDivision = _divisionController.allDivisions
          .cast<Division?>()
          .firstWhere(
            (d) => d != null && d.nom == _selectedDivision,
            orElse: () => null,
          );
      final divisionId = matchingDivision?.id;
      if (divisionId != null) {
        filtered =
            filtered
                .where((player) => player.divisionId == divisionId)
                .toList();
      }
    }

    // Filtre par position
    if (_selectedPosition != null) {
      filtered =
          filtered
              .where((player) => player.position == _selectedPosition)
              .toList();
    }

    // Filtre par
    filtered =
        filtered.where((player) {
          final age = player.age ?? 0;
          return age >= _ageRange.start && age <= _ageRange.end;
        }).toList();

    // Filtre par buts
    filtered =
        filtered.where((player) {
          final goals = player.goals ?? 0;
          return goals >= _goalsRange.start && goals <= _goalsRange.end;
        }).toList();

    // Filtre par rating
    filtered =
        filtered.where((player) {
          final rating = player.rating ?? 0;
          return rating >= _ratingRange.start && rating <= _ratingRange.end;
        }).toList();

    setState(() => _filteredPlayers = filtered);
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedDivision = null;
      _selectedPosition = null;
      _ageRange = const SfRangeValues(15.0, 35.0);
      _goalsRange = const SfRangeValues(0.0, 50.0);
      _ratingRange = const SfRangeValues(0.0, 10.0);
    });
    _applyFilters();
  }

  void _saveSearch() {
    // Impl la sauvegarde de la recherche
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Search saved successfully')));
  }

  // Statistiques des joueurs filtr
  Map<String, dynamic> get _filteredStats {
    if (_filteredPlayers.isEmpty) {
      return {
        'averageAge': 0,
        'averageGoals': 0,
        'averageRating': 0,
        'totalGoals': 0,
        'totalAssists': 0,
      };
    }

    final totalPlayers = _filteredPlayers.length;
    final totalAge = _filteredPlayers.fold(0, (sum, p) => sum + (p.age ?? 0));
    final totalGoals = _filteredPlayers.fold(
      0,
      (sum, p) => sum + (p.goals ?? 0),
    );
    final totalAssists = _filteredPlayers.fold(
      0,
      (sum, p) => sum + (p.assists ?? 0),
    );
    final totalRating = _filteredPlayers.fold(
      0.0,
      (sum, p) => sum + (p.rating ?? 0),
    );

    return {
      'averageAge': (totalAge / totalPlayers).toStringAsFixed(1),
      'averageGoals': (totalGoals / totalPlayers).toStringAsFixed(1),
      'averageRating': (totalRating / totalPlayers).toStringAsFixed(2),
      'totalGoals': totalGoals,
      'totalAssists': totalAssists,
    };
  }

  Widget _buildPlayerCard(Player player) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage:
              player.imageUrl != null && player.imageUrl!.isNotEmpty
                  ? NetworkImage(player.imageUrl!)
                  : const AssetImage('assets/default_player.png')
                      as ImageProvider,
        ),
        title: Text(
          player.nom ?? 'Unknown Player',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${player.position ?? "No position"}  ${player.age ?? "??"} years',
            ),
            Text(
              'Goals: ${player.goals ?? 0}  Assists: ${player.assists ?? 0}',
            ),
            if (player.divisionName != null)
              Text('Division: ${player.divisionName}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Rating: ${player.rating?.toStringAsFixed(1) ?? "N/A"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        onTap: () {
          // Naviguer vers les d du joueur
          // Navigator.push(...)
        },
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced Filters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Division filter
          DropdownButtonFormField<String>(
            value: _selectedDivision,
            decoration: const InputDecoration(
              labelText: 'Division',
              border: OutlineInputBorder(),
            ),
            items:
                _divisions.map((division) {
                  return DropdownMenuItem(
                    value: division,
                    child: Text(division),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedDivision = value);
              _applyFilters();
            },
          ),

          const SizedBox(height: 12),

          // Position filter
          DropdownButtonFormField<String>(
            value: _selectedPosition,
            decoration: const InputDecoration(
              labelText: 'Position',
              border: OutlineInputBorder(),
            ),
            items:
                _positions.map((position) {
                  return DropdownMenuItem(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() => _selectedPosition = value);
              _applyFilters();
            },
          ),

          const SizedBox(height: 16),

          // Age range slider
          const Text(
            'Age Range:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SfRangeSlider(
            min: 15,
            max: 40,
            values: _ageRange,
            interval: 5,
            showTicks: true,
            showLabels: true,
            onChanged: (SfRangeValues values) {
              setState(() => _ageRange = values);
              _applyFilters();
            },
          ),

          const SizedBox(height: 16),

          // Goals range slider
          const Text(
            'Goals Range:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SfRangeSlider(
            min: 0,
            max: 100,
            values: _goalsRange,
            interval: 20,
            showTicks: true,
            showLabels: true,
            onChanged: (SfRangeValues values) {
              setState(() => _goalsRange = values);
              _applyFilters();
            },
          ),

          const SizedBox(height: 16),

          // Rating range slider
          const Text(
            'Rating Range:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SfRangeSlider(
            min: 0,
            max: 10,
            values: _ratingRange,
            interval: 2,
            showTicks: true,
            showLabels: true,
            onChanged: (SfRangeValues values) {
              setState(() => _ratingRange = values);
              _applyFilters();
            },
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveSearch,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Search'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsPanel() {
    final stats = _filteredStats;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Search Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(_showStats ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _showStats = !_showStats),
              ),
            ],
          ),

          if (_showStats) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard('Players', _filteredPlayers.length.toString()),
                _statCard('Avg Age', stats['averageAge'].toString()),
                _statCard('Avg Goals', stats['averageGoals'].toString()),
                _statCard('Avg Rating', stats['averageRating'].toString()),
              ],
            ),
            const SizedBox(height: 12),
            if (_filteredPlayers.isNotEmpty) _buildPositionChart(),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionChart() {
    final positionCounts = <String, int>{};
    for (final player in _filteredPlayers) {
      if (player.position != null) {
        positionCounts[player.position!] =
            (positionCounts[player.position!] ?? 0) + 1;
      }
    }

    final chartData =
        positionCounts.entries.map((entry) {
          return {'position': entry.key, 'count': entry.value};
        }).toList();

    return SizedBox(
      height: 200,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries>[
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: chartData,
            xValueMapper: (data, _) => data['position'],
            yValueMapper: (data, _) => data['count'],
            color: Colors.teal,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TopNavigationBar(
        title: '',
        onSearchTap: () => Navigator.pushNamed(context, '/global-search'),
        showLogo: true,
        onNotificationTap:
            () =>
                Navigator.pushNamed(context, '/notifications'), // <-- add this
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, position...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showFilters
                                ? Icons.filter_alt
                                : Icons.filter_alt_outlined,
                          ),
                          onPressed:
                              () =>
                                  setState(() => _showFilters = !_showFilters),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Filters panel
                  if (_showFilters)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildFiltersPanel(),
                    ),

                  const SizedBox(height: 12),

                  // Statistics panel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStatisticsPanel(),
                  ),

                  const SizedBox(height: 12),

                  // Results header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Results: ${_filteredPlayers.length} players found',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_filteredPlayers.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => _exportResults(),
                            icon: const Icon(Icons.download),
                            label: const Text('Export'),
                          ),
                      ],
                    ),
                  ),

                  // Results list
                  Expanded(
                    child:
                        _filteredPlayers.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No players found',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _resetFilters,
                                    child: const Text('Reset filters'),
                                  ),
                                ],
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                itemCount: _filteredPlayers.length,
                                itemBuilder: (context, index) {
                                  return _buildPlayerCard(
                                    _filteredPlayers[index],
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }

  Future<void> _exportResults() async {
    // Impl l'export des r
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature will be implemented in ExportService'),
      ),
    );
  }
}


