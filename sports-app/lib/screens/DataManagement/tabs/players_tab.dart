import 'package:flutter/material.dart';

import '../../../controllers/dataManagementController.dart';
import '../data_management_scope.dart';
import 'players/footballer_details_screen.dart';
import 'players/PlayerForm/player_form.dart';
import '../../../models/player.dart';
import '../../../utils/role_utils.dart';
import '../../../components/ui_kit.dart';

class PlayersTab extends StatefulWidget {
  const PlayersTab({Key? key}) : super(key: key);

  @override
  State<PlayersTab> createState() => _PlayersTabState();
}

class _PlayersTabState extends State<PlayersTab> {
  final TextEditingController _searchController = TextEditingController();
  late final bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = UserRoleUtil.isAdmin();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Player> _filter(List<Player> list) {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return list;
    return list.where((p) {
      return (p.nom ?? '').toLowerCase().contains(q) ||
          (p.email ?? '').toLowerCase().contains(q) ||
          (p.position ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<int?> _pickDivision(DataManagementController dm) async {
    final divisions = dm.academyDivisions;
    if (divisions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No divisions in academy yet')),
      );
      return null;
    }
    return showModalBottomSheet<int>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          children: [
            const ListTile(title: Text('Select a division')),
            for (final d in divisions)
              ListTile(
                leading: const Icon(Icons.group),
                title: Text(d.nom),
                onTap: () => Navigator.pop(context, d.id),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPlayer(DataManagementController dm) async {
    if (!_isAdmin) return;

    int? divId = dm.selectedDivisionId;
    if (divId == null || divId == DataManagementController.unassignedDivisionKey) {
      divId = await _pickDivision(dm);
      if (divId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a division first to add a player')),
        );
        return;
      }
      dm.setSelectedDivision(divId);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerForm(divisionId: divId!.toString())),
    );
    await dm.refreshPlayers();
    await dm.refreshUnassignedPlayers();
    if (mounted) setState(() {});
  }

  Future<void> _editPlayer(DataManagementController dm, Player p) async {
    if (!_isAdmin) return;
    final divId = p.divisionId;
    if (divId == null || p.id == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerForm(
          divisionId: divId.toString(),
          playerId: p.id!.toString(),
        ),
      ),
    );
    await dm.refreshPlayers();
    await dm.refreshUnassignedPlayers();
    if (mounted) setState(() {});
  }

  Future<void> _deletePlayer(DataManagementController dm, Player p) async {
    if (!_isAdmin) return;
    if (p.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete player'),
        content: Text('Delete ${p.nom ?? 'this player'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    final ok = await dm.deletePlayer(p.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Deleted' : 'Delete failed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dm = DataManagementScope.of(context);
    final players = _filter(dm.filteredPlayers);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search players',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                if (_isAdmin)
                  IconButton(
                    tooltip: 'Add player',
                    onPressed: () => _addPlayer(dm),
                    icon: const Icon(Icons.person_add_alt_1),
                  ),
              ],
            ),
          ),
          Expanded(
            child: players.isEmpty
                ? const Center(child: Text('No players found'))
                : RefreshIndicator(
              onRefresh: () async {
                await dm.refreshPlayers();
                await dm.refreshUnassignedPlayers();
                if (mounted) setState(() {});
              },
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (_, i) => _playerCard(dm, players[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerCard(DataManagementController dm, Player p) {
    return SoftCard(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(p.nom ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(p.position ?? ''),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FootballerDetailsScreen(playerId: p.id)),
          );
        },
        trailing: _isAdmin
            ? Wrap(
          spacing: 6,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () => _editPlayer(dm, p)),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deletePlayer(dm, p),
            ),
          ],
        )
            : null,
      ),
    );
  }
}


