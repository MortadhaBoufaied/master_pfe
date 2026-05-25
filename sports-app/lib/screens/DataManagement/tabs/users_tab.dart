import 'package:flutter/material.dart';

import '../../../services/admin_users_service.dart';
import '../../../models/admin_user.dart';
import '../../../utils/role_utils.dart';
import '../../../components/ui_kit.dart';
import '../../admin/admin_user_form_screen.dart';

/// Users tab inside Data Management. ADMIN-only CRUD.
class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final _service = AdminUsersService();
  final _search = TextEditingController();

  List<AdminUser> _all = [];
  List<AdminUser> _filtered = [];
  bool _loading = true;
  String? _error;

  bool get _isAdmin => UserRoleUtil.isAdmin();

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_apply);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _all = await _service.getAllUsers();
      _apply();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _apply() {
    final q = _search.text.trim().toLowerCase();
    _filtered = q.isEmpty
        ? List<AdminUser>.from(_all)
        : _all.where((u) {
            final n = (u.nom ?? '').toLowerCase();
            final e = (u.email ?? '').toLowerCase();
            return n.contains(q) || e.contains(q);
          }).toList();
    if (mounted) setState(() {});
  }

  Future<void> _add() async {
    if (!_isAdmin) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminUserFormScreen()),
    );
    if (changed == true) _load();
  }

  Future<void> _edit(AdminUser u) async {
    if (!_isAdmin) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminUserFormScreen(existing: u)),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(AdminUser u) async {
    if (!_isAdmin) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Delete ${u.nom ?? u.email ?? 'this user'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    if (u.id == null) return;
    final success = await _service.deleteUser(u.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Deleted' : 'Delete failed')),
    );
    if (success) _load();
  }

  @override
  Widget build(BuildContext context) {
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
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search users',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (_isAdmin)
                  IconButton(
                    tooltip: 'Add user',
                    onPressed: _add,
                    icon: const Icon(Icons.person_add_alt_1),
                  ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final u = _filtered[i];
                            return SoftCard(
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                title: Text(u.nom ?? 'User'),
                                subtitle: Text(u.email ?? ''),
                                trailing: _isAdmin
                                    ? Wrap(
                                        spacing: 6,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _edit(u),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                                            onPressed: () => _delete(u),
                                          ),
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


