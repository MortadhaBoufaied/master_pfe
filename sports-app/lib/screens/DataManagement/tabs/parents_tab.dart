import 'package:flutter/material.dart';

import '../../../controllers/dataManagementController.dart';
import '../data_management_scope.dart';
import '../../../utils/role_utils.dart';
import '../../../models/parent.dart';
import '../../../components/ui_kit.dart';

class ParentsTab extends StatefulWidget {
  const ParentsTab({super.key});

  @override
  State<ParentsTab> createState() => _ParentsTabState();
}

class _ParentsTabState extends State<ParentsTab> {
  final _search = TextEditingController();
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

  Future<void> _openForm(DataManagementController dm, {Parent? parent}) async {
    if (!_isAdmin) return;

    final nameCtrl = TextEditingController(text: parent?.nom ?? '');
    final emailCtrl = TextEditingController(text: parent?.email ?? '');
    final telCtrl = TextEditingController(text: parent?.tel ?? '');
    final passCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(parent == null ? 'Add parent' : 'Edit parent'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Phone')),
              if (parent == null)
                TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok != true) return;

    final payload = {
      'user': {
        'nom': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'tel': telCtrl.text.trim(),
        if (parent == null) 'mdp': passCtrl.text.trim(),
      }
    };

    bool success;
    if (parent?.id != null) {
      success = await dm.updateParent(parent!.id!, payload);
    } else {
      success = await dm.createParent(payload);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Saved' : 'Save failed')),
    );
    if (success) {
      await dm.refreshParents();
      if (mounted) setState(() {});
    }
  }

  Future<void> _delete(DataManagementController dm, Parent p) async {
    if (!_isAdmin) return;
    if (p.id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete parent'),
        content: Text('Delete ${p.nom ?? p.email ?? 'this parent'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    final success = await dm.deleteParent(p.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Deleted' : 'Delete failed')),
    );
    if (success) {
      await dm.refreshParents();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final dm = DataManagementScope.of(context);
    final q = _search.text.trim().toLowerCase();

    final list = dm.filteredParents.where((p) {
      if (q.isEmpty) return true;
      return (p.nom ?? '').toLowerCase().contains(q) || (p.email ?? '').toLowerCase().contains(q);
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
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search parents'),
                  ),
                ),
                const SizedBox(width: 10),
                if (_isAdmin)
                  IconButton(
                    tooltip: 'Add parent',
                    onPressed: () => _openForm(dm),
                    icon: const Icon(Icons.person_add_alt_1),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await dm.refreshParents();
                if (mounted) setState(() {});
              },
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  return SoftCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(p.nom ?? 'Parent'),
                      subtitle: Text(p.email ?? ''),
                      trailing: _isAdmin
                          ? Wrap(
                              spacing: 6,
                              children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(dm, parent: p)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _delete(dm, p)),
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


