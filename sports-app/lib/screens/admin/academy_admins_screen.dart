import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import '../../services/admin_academy_admins_service.dart';

class AcademyAdminsScreen extends StatefulWidget {
  const AcademyAdminsScreen({super.key});

  @override
  State<AcademyAdminsScreen> createState() => _AcademyAdminsScreenState();
}

class _AcademyAdminsScreenState extends State<AcademyAdminsScreen> {
  static const double _radius = 18;
  static const double _cardPad = 14;
  static const Color _accent = Color(0xFF20B2A7);

  final _service = AdminAcademyAdminsService();

  final _searchCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _telCtrl = TextEditingController();

  AdminResponsibility _selectedResponsibility = AdminResponsibility.academyDirector;

  List<AdminUser> _all = [];
  List<AdminUser> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _all = await _service.listAcademyAdmins();
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    _filtered = q.isEmpty
        ? List.of(_all)
        : _all
            .where((u) => u.nom.toLowerCase().contains(q) || u.email.toLowerCase().contains(q))
            .toList();
    if (mounted) setState(() {});
  }

  Future<void> _createAdmin() async {
    final nom = _nomCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final tel = _telCtrl.text.trim();

    if (nom.isEmpty) return _toast('Name is required');
    if (email.isEmpty) return _toast('Email is required');
    if (password.isEmpty) return _toast('Password is required');

    try {
      await _service.createAcademyAdmin(
        nom: nom,
        email: email,
        password: password,
        tel: tel.isEmpty ? null : tel,
        responsibility: _selectedResponsibility,
      );

      _nomCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
      _telCtrl.clear();
      _selectedResponsibility = AdminResponsibility.academyDirector;

      await _load();
      if (mounted) _toast('Admin created');
    } catch (e) {
      _toast(e.toString());
    }
  }

  Future<void> _setResponsibility(AdminUser admin, AdminResponsibility newResp) async {
    try {
      await _service.setAdminResponsibility(
        adminUserId: admin.id,
        responsibility: newResp,
      );
      await _load();
      if (mounted) _toast('Responsibility updated');
    } catch (e) {
      _toast(e.toString());
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Color _getResponsibilityColor(AdminResponsibility r) {
    switch (r) {
      case AdminResponsibility.academyDirector:
        return const Color(0xFFEF4444);
      case AdminResponsibility.operationsManager:
        return const Color(0xFF22C55E);
      case AdminResponsibility.sportsCoordinator:
        return const Color(0xFF06B6D4);
      case AdminResponsibility.playerRegistrar:
        return const Color(0xFFF59E0B);
      case AdminResponsibility.financeManager:
        return const Color(0xFF8B5CF6);
      case AdminResponsibility.communicationsManager:
        return const Color(0xFFEC4899);
      case AdminResponsibility.medicalWelfareManager:
        return const Color(0xFF94A3B8);
    }
  }

  String _responsibilityLabel(AdminResponsibility r) {
    switch (r) {
      case AdminResponsibility.academyDirector:
        return 'ACADEMY_DIRECTOR';
      case AdminResponsibility.operationsManager:
        return 'OPERATIONS_MANAGER';
      case AdminResponsibility.sportsCoordinator:
        return 'SPORTS_COORDINATOR';
      case AdminResponsibility.playerRegistrar:
        return 'PLAYER_REGISTRAR';
      case AdminResponsibility.financeManager:
        return 'FINANCE_MANAGER';
      case AdminResponsibility.communicationsManager:
        return 'COMMUNICATIONS_MANAGER';
      case AdminResponsibility.medicalWelfareManager:
        return 'MEDICAL_WELFARE_MANAGER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        _buildBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: const Text('Manage Academy Admins'),
            centerTitle: false,
            actions: [
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
          body: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _accent))
                : _error != null
                    ? Center(
                        child: _glassCard(
                          padding: const EdgeInsets.all(_cardPad),
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48),
                              const SizedBox(height: 16),
                              Text('Error: $_error', textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildBody(cs),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ColorScheme cs) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: _glassCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search,
                    color: cs.outline.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
                hintText: 'Search by name or email',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        if (_filtered.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 48, color: cs.outline.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    _searchCtrl.text.isEmpty ? 'No academy admins yet' : 'No admins found',
                    style: TextStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _buildAdminCard(_filtered[i]),
            ),
          ),

        const Divider(height: 1),

        // Create admin form
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          child: _glassCard(
            padding: const EdgeInsets.all(_cardPad),
            margin: const EdgeInsets.only(bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add an admin',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _formField(controller: _nomCtrl, label: 'Full name', icon: Icons.person),
                const SizedBox(height: 10),
                _formField(controller: _emailCtrl, label: 'Email', icon: Icons.email_outlined),
                const SizedBox(height: 10),
                _formField(controller: _passwordCtrl, label: 'Password', icon: Icons.lock_outline, obscure: true),
                const SizedBox(height: 10),
                _formField(controller: _telCtrl, label: 'Phone (optional)', icon: Icons.phone_outlined),
                const SizedBox(height: 12),

                Text('Responsibility', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<AdminResponsibility>(
                  value: _selectedResponsibility,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedResponsibility = v);
                  },
                  items: AdminResponsibility.values.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(_responsibilityLabel(r)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _createAdmin,
                        icon: const Icon(Icons.person_add_alt_1, size: 18),
                        label: const Text('Create admin'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildAdminCard(AdminUser u) {
    final cs = Theme.of(context).colorScheme;

    final resp = _responsibilityFromJson(u.responsibility);
    final roleColor = _getResponsibilityColor(resp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(_cardPad),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.nom,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        u.email,
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: roleColor.withValues(alpha: 0.3), width: 0.8),
                  ),
                  child: Text(
                    _responsibilityLabel(resp),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Responsibility update
            Text(
              'Set responsibility',
              style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<AdminResponsibility>(
              value: resp,
              items: AdminResponsibility.values.map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(_responsibilityLabel(r)),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                _setResponsibility(u, v);
              },
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  AdminResponsibility _responsibilityFromJson(String? raw) {
    final normalized = raw?.trim().toUpperCase();
    switch (normalized) {
      case 'ACADEMY_DIRECTOR':
        return AdminResponsibility.academyDirector;
      case 'OPERATIONS_MANAGER':
        return AdminResponsibility.operationsManager;
      case 'SPORTS_COORDINATOR':
        return AdminResponsibility.sportsCoordinator;
      case 'PLAYER_REGISTRAR':
        return AdminResponsibility.playerRegistrar;
      case 'FINANCE_MANAGER':
        return AdminResponsibility.financeManager;
      case 'COMMUNICATIONS_MANAGER':
        return AdminResponsibility.communicationsManager;
      case 'MEDICAL_WELFARE_MANAGER':
        return AdminResponsibility.medicalWelfareManager;
      default:
        return AdminResponsibility.academyDirector;
    }
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFFE7F4ED), Colors.white],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child, EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding}) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            color: Colors.white.withValues(alpha: 0.75),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Helper extension methods (if Colors.withValues isn't already available in this project,
// we keep it consistent by using the same approach used elsewhere in the app.)
extension _ColorWithValues on Color {
  // ignore: unused_element
  Color withValues({required double alpha}) => withOpacity(alpha);
}
