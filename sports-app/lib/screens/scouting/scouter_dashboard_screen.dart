import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/chat_service.dart';
import '../../services/scouter_dashboard_service.dart';
import '../DataManagement/tabs/players/footballer_details_screen.dart';
import '../MainPage/pages/chat/chat_conversations_screen.dart';
import 'academy_detail_screen.dart';

class ScouterDashboardScreen extends StatefulWidget {
  const ScouterDashboardScreen({super.key});

  @override
  State<ScouterDashboardScreen> createState() => _ScouterDashboardScreenState();
}

class _ScouterDashboardScreenState extends State<ScouterDashboardScreen> {
  final ScouterDashboardService _service = ScouterDashboardService();
  final ChatService _chatService = ChatService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _dashboard = {};
  List<Map<String, dynamic>> _sports = const [];
  int? _sportId;
  String? _watchStatus;
  String? _priority;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final sports = await _chatService.getScoutingSports();
      final prefs = await SharedPreferences.getInstance();
      final recent = prefs.getString('recent_scouter_sport_id') ??
          prefs.getString('recent_scouting_ai_sport_id');
      final recentId = int.tryParse(recent ?? '');
      setState(() {
        _sports = sports;
        _sportId = recentId;
      });
    } catch (_) {
      setState(() => _sports = const []);
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getDashboard(
        sportId: _sportId,
        watchStatus: _watchStatus,
        priority: _priority,
      );
      if (mounted) setState(() => _dashboard = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _contactAdmin(int academyId) async {
    try {
      final conversationId = await _chatService.contactAdmin(academyId: academyId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationsScreen(
            initialConversationId: conversationId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to contact admin: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final summary = Map<String, dynamic>.from(_dashboard['summary'] as Map? ?? {});
    final players = (_dashboard['watchedPlayers'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scouter Dashboard'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          children: [
            _filters(cs),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _message(cs, Icons.error_outline_rounded, 'Dashboard unavailable', _error!)
            else ...[
              _summaryGrid(cs, summary),
              const SizedBox(height: 14),
              Text(
                'Watched player progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (players.isEmpty)
                _message(cs, Icons.visibility_off_rounded, 'No watched players yet', 'Mark players from Scouting AI to track their advancement here.')
              else
                for (final player in players) _playerCard(cs, player),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filters(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _sportId,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Sport',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('All sports')),
                    ..._sports.map(
                      (sport) => DropdownMenuItem<int?>(
                        value: _toInt(sport['sportId']),
                        child: Text(_text(sport['sportName'], fallback: 'Sport')),
                      ),
                    ),
                  ],
                  onChanged: (value) async {
                    setState(() => _sportId = value);
                    if (value != null) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('recent_scouter_sport_id', value.toString());
                    }
                    _load();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _watchStatus,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(value: null, child: Text('All statuses')),
                    DropdownMenuItem(value: 'WATCHING', child: Text('Watching')),
                    DropdownMenuItem(value: 'UNDER_OBSERVATION', child: Text('Under observation')),
                    DropdownMenuItem(value: 'SHORTLISTED', child: Text('Shortlisted')),
                    DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                    DropdownMenuItem(value: 'ARCHIVED', child: Text('Archived')),
                  ],
                  onChanged: (value) {
                    setState(() => _watchStatus = value);
                    _load();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: _priority,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Priority',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<String?>(value: null, child: Text('All priorities')),
              DropdownMenuItem(value: 'LOW', child: Text('Low')),
              DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
              DropdownMenuItem(value: 'HIGH', child: Text('High')),
              DropdownMenuItem(value: 'URGENT', child: Text('Urgent')),
            ],
            onChanged: (value) {
              setState(() => _priority = value);
              _load();
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryGrid(ColorScheme cs, Map<String, dynamic> summary) {
    final items = [
      ('Watched', summary['totalWatchedPlayers'], Icons.visibility_rounded),
      ('Improving', summary['playersImproving'], Icons.trending_up_rounded),
      ('Declining', summary['playersDeclining'], Icons.trending_down_rounded),
      ('High potential', summary['highPotentialPlayers'], Icons.auto_awesome_rounded),
      ('Needs review', summary['playersNeedingReview'], Icons.rate_review_rounded),
      ('Missing data', summary['playersWithMissingRecentData'], Icons.dataset_linked_rounded),
    ];
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 78,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.44),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Icon(item.$3, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${item.$2 ?? 0}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _playerCard(ColorScheme cs, Map<String, dynamic> player) {
    final playerId = _toInt(player['playerId']);
    final academyId = _toInt(player['academyId']);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _text(player['playerName'], fallback: 'Player'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
                Chip(
                  label: Text(_text(player['progressionLabel'], fallback: 'Stable')),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Text(
              [
                _text(player['academyName']),
                _text(player['sport']),
                _text(player['division']),
                _text(player['position']),
              ].where((value) => value.isNotEmpty).join(' - '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _mini(cs, 'Talent', _text(player['currentTalentScore'], fallback: '0')),
                const SizedBox(width: 8),
                _mini(cs, 'Change', _text(player['scoreChange'], fallback: '0')),
                const SizedBox(width: 8),
                _mini(cs, 'Priority', _text(player['priority'], fallback: '-')),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _text(player['recommendedAction'], fallback: 'Keep watching and review after new data.'),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: playerId == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FootballerDetailsScreen(
                                playerId: playerId,
                                isCurrentUser: false,
                              ),
                            ),
                          ),
                  icon: const Icon(Icons.person_search_rounded),
                  label: const Text('Player'),
                ),
                TextButton.icon(
                  onPressed: academyId == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AcademyDetailScreen(academyId: academyId),
                            ),
                          ),
                  icon: const Icon(Icons.shield_rounded),
                  label: const Text('Academy'),
                ),
                TextButton.icon(
                  onPressed: academyId == null ? null : () => _contactAdmin(academyId),
                  icon: const Icon(Icons.admin_panel_settings_rounded),
                  label: const Text('Contact Admin'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(ColorScheme cs, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _message(ColorScheme cs, IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.44),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
