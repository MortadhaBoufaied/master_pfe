import 'package:flutter/material.dart';

import '../../../controllers/dataManagementController.dart';
import '../../../models/division.dart';
import '../../../models/player.dart';
import '../data_management_scope.dart';
import '../../../components/ui_kit.dart';
import 'players/footballer_details_screen.dart';

class DivisionsTab extends StatelessWidget {
  const DivisionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dm = DataManagementScope.of(context);

    if (dm.isLoading && dm.academyDivisions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _HeaderRow(
          loading: dm.isLoading,
          onRefresh: () async {
            await dm.refreshDivisions();
            await dm.refreshPlayers();
            await dm.refreshTrainers();
          },
          onAdd: () => _openAddDivisionModal(context, dm),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: _CountsBar(dm: dm),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await dm.refreshDivisions();
              await dm.refreshPlayers();
              await dm.refreshTrainers();
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const SizedBox(height: 10),
                _sectionTitle('Divisions (Academy)'),

                if (dm.academyDivisions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No academy divisions yet. Click + to add one.',
                    ),
                  )
                else
                  ...dm.academyDivisions.map(
                        (d) => _DivisionTile(
                      division: d,
                      playersCount: dm.allPlayers
                          .where((p) => p.divisionId == d.id)
                          .length,
                      coachesCount: dm.allTrainers
                          .where((t) => t.divisionId == d.id)
                          .length,
                      loading: dm.isLoading,
                      onDelete: () =>
                          _confirmDeleteDivision(context, dm, d),
                    ),
                  ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /* =========================
     Actions
     ========================= */

  Future<void> _openAddDivisionModal(
      BuildContext context,
      DataManagementController dm,
      ) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await dm.refreshDivisions();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to refresh divisions: $e')),
      );
    }

    final available = dm.availableDivisionsToAdd;

    final Division? picked = await showDialog<Division>(
      context: context,
      builder: (_) => _SelectDivisionDialog(divisions: available),
    );

    if (picked == null) return;

    try {
      final ok = await dm.attachDivisionToAcademy(picked.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Division "${picked.nom}" added to academy.'
                : 'Failed to add "${picked.nom}".',
          ),
        ),
      );
      await dm.refreshDivisions();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error adding division: $e')),
      );
    }
  }

  Future<void> _confirmDeleteDivision(
      BuildContext context,
      DataManagementController dm,
      Division division,
      ) async {
    final messenger = ScaffoldMessenger.of(context);

    final affectedPlayers = dm.allPlayers
        .where((p) => p.divisionId == division.id)
        .length;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Division'),
        content: Text(
          'Delete "${division.nom}"?\n\n'
              '$affectedPlayers player(s) will be moved to "Unassigned Players".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final ok =
      await dm.deleteDivisionAndUnassignPlayers(division.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Division "${division.nom}" deleted.'
                : 'Failed to delete "${division.nom}".',
          ),
        ),
      );
      await dm.refreshDivisions();
      await dm.refreshPlayers();
      await dm.refreshTrainers();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error deleting division: $e')),
      );
    }
  }
}

/* =========================
   UI Widgets
   ========================= */

class _HeaderRow extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final bool loading;

  const _HeaderRow({
    required this.onAdd,
    required this.onRefresh,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Divisions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: loading ? null : onRefresh,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Add Division',
              onPressed: loading ? null : onAdd,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountsBar extends StatelessWidget {
  final DataManagementController dm;
  const _CountsBar({required this.dm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Academy: ${dm.academyDivisions.length}   |   '
            'All: ${dm.allDivisions.length}   |   '
            'Available to add: ${dm.availableDivisionsToAdd.length}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

Widget _sectionTitle(String text) => Padding(
  padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
  ),
);

class _DivisionTile extends StatelessWidget {
  final int playersCount;
  final int coachesCount;
  final Division division;
  final bool loading;
  final VoidCallback onDelete;

  const _DivisionTile({
    required this.division,
    required this.playersCount,
    required this.coachesCount,
    required this.loading,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: const Icon(Icons.category, color: Colors.teal),
        ),
        title: Text(
          division.nom,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${division.categorie ?? ''}   '
              'Players: $playersCount   '
              'Coaches: $coachesCount',
        ),
        trailing: IconButton(
          tooltip: 'Delete',
          onPressed: loading ? null : onDelete,
          icon:
          const Icon(Icons.delete_outline, color: Colors.red),
        ),
      ),
    );
  }
}

class _UnassignedPlayerTile extends StatelessWidget {
  final Player player;
  const _UnassignedPlayerTile({required this.player});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.black54),
        ),
        title: Text(player.nom ?? 'Unknown'),
        subtitle: Text(player.position ?? 'No position'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  FootballerDetailsScreen(playerId: player.id),
            ),
          );
        },
      ),
    );
  }
}

/* =========================
   Add dialog
   ========================= */

class _SelectDivisionDialog extends StatefulWidget {
  final List<Division> divisions;
  const _SelectDivisionDialog({required this.divisions});

  @override
  State<_SelectDivisionDialog> createState() =>
      _SelectDivisionDialogState();
}

class _SelectDivisionDialogState
    extends State<_SelectDivisionDialog> {
  final TextEditingController _search = TextEditingController();
  late List<Division> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.of(widget.divisions)
      ..sort((a, b) =>
          a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search.removeListener(_applyFilter);
    _search.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      _filtered = widget.divisions.where((d) {
        return d.nom.toLowerCase().contains(q) ||
            (d.categorie ?? '')
                .toLowerCase()
                .contains(q);
      }).toList()
        ..sort((a, b) =>
            a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Division'),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search by name / category...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                child: Text(
                  'No available divisions to add.',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final d = _filtered[i];
                  return ListTile(
                    title: Text(d.nom),
                    subtitle: Text(d.categorie ?? ''),
                    onTap: () =>
                        Navigator.pop(context, d),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}


