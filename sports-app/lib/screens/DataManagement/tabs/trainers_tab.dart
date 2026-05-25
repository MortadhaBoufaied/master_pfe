import 'package:flutter/material.dart';

import '../../../controllers/dataManagementController.dart';
import '../data_management_scope.dart';
import '../../../utils/role_utils.dart';
import '../../../models/trainer.dart';
import '../../../components/ui_kit.dart';
import 'trainers/trainerDetails.dart';
import 'trainers/TrainerForm/trainer_form_dialog.dart';

class TrainersTab extends StatefulWidget {
  const TrainersTab({super.key});

  @override
  State<TrainersTab> createState() => _TrainersTabState();
}

class _TrainersTabState extends State<TrainersTab> {
  final TextEditingController _search = TextEditingController();
  late final bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = UserRoleUtil.isAdmin();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openForm(DataManagementController dm, {Trainer? trainer}) async {
    if (!_isAdmin) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => TrainerFormDialog(
        trainer: trainer,
        onSubmit: (Map<String, dynamic> form) async {
          // Convert dialog data to backend payload (Admin endpoints create User+Trainer atomically)
          final payload = {
            'user': {
              'nom': form['name'],
              'email': form['email'],
              'tel': form['phone'],
              'mdp': form['password'] ?? 'trainer123',
            },
            'speciality': form['specialty'],
            'experience': form['experience'],
            'license': form['license'],
            'notes': form['notes'],
            'divisionId': dm.selectedDivisionId,
          };

          bool ok;
          if (trainer?.id != null) {
            ok = await dm.updateTrainer(trainer!.id!, payload);
          } else {
            ok = await dm.createTrainer(payload);
          }
          return ok;
        },
      ),
    );

    if (result == true) {
      await dm.refreshTrainers();
      if (mounted) setState(() {});
    }
  }

  Future<void> _delete(DataManagementController dm, Trainer t) async {
    if (!_isAdmin) return;
    if (t.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete trainer'),
        content: Text('Delete ${t.name ?? t.email ?? 'this trainer'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    final ok = await dm.deleteTrainer(t.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Deleted' : 'Delete failed')),
    );
    if (ok) {
      await dm.refreshTrainers();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = DataManagementScope.of(context);
    final q = _search.text.trim().toLowerCase();

    final list = dm.filteredTrainers.where((t) {
      if (q.isEmpty) return true;
      return (t.name ?? '').toLowerCase().contains(q) ||
          (t.email ?? '').toLowerCase().contains(q);
    }).toList();

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
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search trainers',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (_isAdmin)
                  IconButton(
                    tooltip: 'Add trainer',
                    onPressed: () => _openForm(dm),
                    icon: const Icon(Icons.person_add_alt_1),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await dm.refreshTrainers();
                if (mounted) setState(() {});
              },
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final t = list[i];
                  return SoftCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(t.name ?? 'Trainer'),
                      subtitle: Text(t.email ?? ''),
                      onTap: t.id == null
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TrainerDetailsScreen(trainerId: t.id!),
                                ),
                              ),
                      trailing: _isAdmin
                          ? Wrap(
                              spacing: 6,
                              children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(dm, trainer: t)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _delete(dm, t)),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


