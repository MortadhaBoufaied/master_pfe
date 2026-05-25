import 'package:flutter/material.dart';
import '../../components/app_background.dart';
import '../../components/ui_kit.dart';
import '../../models/global_search_result.dart';
import '../../services/global_search_service.dart';
import '../DataManagement/tabs/players/footballer_details_screen.dart';

class GlobalSearchScreen extends StatefulWidget {
  final bool embedded;

  const GlobalSearchScreen({super.key, this.embedded = false});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _service = GlobalSearchService();
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;
  List<GlobalSearchResult> _results = const [];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  IconData _iconFor(String entity) {
    switch (entity.toUpperCase()) {
      case 'PLAYER':
        return Icons.sports_soccer;
      case 'PARENT':
        return Icons.family_restroom;
      case 'TRAINER':
        return Icons.fitness_center;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      case 'MATCH':
        return Icons.emoji_events;
      case 'TRAINING':
        return Icons.directions_run;
      default:
        return Icons.search;
    }
  }

  Future<void> _doSearch() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _service.search(_ctrl.text);
      setState(() => _results = res);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final mainContent = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SoftCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _doSearch(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search players, parents, trainers, matches...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _doSearch,
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (_loading)
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: const LinearProgressIndicator(),
            ),
          if (_error != null)
            SoftCard(
              margin: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: cs.error)),
            ),
          const SizedBox(height: 10),
          Expanded(
            child:
                _results.isEmpty
                    ? Center(
                      child: Text(
                        _loading
                            ? 'Searching...'
                            : 'Type a name, role, match, or training.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                      ),
                    )
                    : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final r = _results[i];
                        return SoftCard(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.primary.withOpacity(0.12),
                              child: Icon(
                                _iconFor(r.entity),
                                color: cs.primary,
                              ),
                            ),
                            title: Text(
                              r.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle:
                                r.subtitle == null ? null : Text(r.subtitle!),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: cs.onSurfaceVariant,
                            ),
                            onTap: () => _openResult(r),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Text(
                  'Global Search',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _doSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(child: mainContent),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: AppBackground(child: mainContent),
    );
  }

  void _openResult(GlobalSearchResult result) {
    switch (result.entity.toUpperCase()) {
      case 'PLAYER':
        if (result.id <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This player result is missing a valid identifier.'),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FootballerDetailsScreen(playerId: result.id),
          ),
        );
        return;
      case 'TRAINING':
      case 'MATCH':
        Navigator.pushNamed(context, '/my-activities');
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Navigation for ${result.entity.toLowerCase()} is not available yet.',
            ),
          ),
        );
    }
  }
}


