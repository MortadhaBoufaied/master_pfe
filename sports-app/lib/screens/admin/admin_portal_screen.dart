import 'package:flutter/material.dart';

import '../../components/app_background.dart';
import '../../controllers/session_controller.dart';
import '../../data/admin/admin_module_catalog.dart';
import '../../models/admin/admin_module.dart';
import '../../models/role.dart';
import '../../services/dashboard_service.dart';
import '../../services/super_admin_service.dart';
import 'admin_module_screen.dart';

class AdminPortalScreen extends StatefulWidget {
  final bool embedded;

  const AdminPortalScreen({super.key, this.embedded = false});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  final DashboardService _dashboardService = DashboardService();
  final SuperAdminService _superAdminService = SuperAdminService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _data = {};

  bool get _isSuperAdmin => AppSession.instance.session.role == Role.superAdmin;

  List<AdminModuleSpec> get _modules =>
      _isSuperAdmin ? superAdminModuleCatalog : adminModuleCatalog;

  AdminWebRole get _moduleRole =>
      _isSuperAdmin ? AdminWebRole.superAdmin : AdminWebRole.admin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _data =
          _isSuperAdmin
              ? await _superAdminService.getDashboard()
              : await _dashboardService.getAdminDashboard();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _buildHero(context),
          const SizedBox(height: 14),
          if (_error != null) _buildErrorCard(context),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _buildMetrics(context),
            const SizedBox(height: 14),
            _buildQuickAccess(context),
            const SizedBox(height: 14),
            _buildFeaturedModules(context),
            const SizedBox(height: 14),
            _buildOperationalModules(context),
            const SizedBox(height: 14),
            _buildStatusBoard(context),
          ],
        ],
      ),
    );

    if (widget.embedded) {
      return body;
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_isSuperAdmin ? 'Super Admin Portal' : 'Admin Portal'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: body,
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final session = AppSession.instance.session;
    final name =
        session.displayName.trim().isEmpty
            ? (_isSuperAdmin ? 'Platform Owner' : 'Administrator')
            : session.displayName.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF171717),
            _isSuperAdmin ? const Color(0xFF7C3AED) : const Color(0xFFDC2626),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isSuperAdmin
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFFDC2626))
                .withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -16,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _isSuperAdmin
                          ? Icons.admin_panel_settings_rounded
                          : Icons.dashboard_customize_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSuperAdmin ? 'Platform control' : 'Academy operations',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.76),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back, $name',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _isSuperAdmin
                    ? 'Academies, sports, categories, chatbot, payments, webhooks, and platform settings are all reachable from this mobile workspace.'
                    : 'Users, divisions, players, forms, reports, notifications, chatbot, and settings are exposed here as real module entry points.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _heroAction(
                    icon: Icons.folder_open_rounded,
                    label: _isSuperAdmin ? 'Academies' : 'Data hub',
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          _isSuperAdmin ? '/super-admin/academies' : '/data-management',
                        ),
                  ),
                  _heroAction(
                    icon: Icons.analytics_rounded,
                    label: 'Reports',
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          _isSuperAdmin
                              ? '/super-admin/app-data'
                              : '/admin/reports',
                        ),
                  ),
                  _heroAction(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetrics(BuildContext context) {
    final metrics =
        _isSuperAdmin
            ? [
              _PortalMetric(
                'Academies',
                _number('academiesCount'),
                Icons.domain_rounded,
                const Color(0xFF16A34A),
              ),
              _PortalMetric(
                'Sports',
                _number('sportsCount'),
                Icons.sports_rounded,
                const Color(0xFF2563EB),
              ),
              _PortalMetric(
                'Contacts',
                _number('adminContactsCount'),
                Icons.contact_mail_rounded,
                const Color(0xFFF59E0B),
              ),
              _PortalMetric(
                'Webhooks',
                _number('webhooksCount'),
                Icons.webhook_rounded,
                const Color(0xFF7C3AED),
              ),
            ]
            : [
              _PortalMetric(
                'Users',
                _number('users'),
                Icons.group_rounded,
                const Color(0xFF16A34A),
              ),
              _PortalMetric(
                'Players',
                _number('players'),
                Icons.groups_rounded,
                const Color(0xFF2563EB),
              ),
              _PortalMetric(
                'Revenue',
                _money(_data['monthlyRevenue']),
                Icons.payments_rounded,
                const Color(0xFFF59E0B),
              ),
              _PortalMetric(
                'Overdue',
                _number('overduePayments'),
                Icons.warning_amber_rounded,
                const Color(0xFFDC2626),
              ),
            ];

    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(metric.icon, color: metric.color),
              ),
              const Spacer(),
              Text(
                metric.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
              ),
              const SizedBox(height: 4),
              Text(
                metric.label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final shortcuts = _isSuperAdmin
        ? [
            _PortalShortcut(
              'Academies',
              'Create and manage academy accounts',
              Icons.domain_add_rounded,
              '/super-admin/academies',
            ),
            _PortalShortcut(
              'Sports',
              'Sport and category setup',
              Icons.sports_soccer_rounded,
              '/super-admin/sports',
            ),
            _PortalShortcut(
              'Global chatbot',
              'Knowledge and assistant controls',
              Icons.smart_toy_rounded,
              '/super-admin/chatbot-global',
            ),
          ]
        : [
            _PortalShortcut(
              'Data management',
              'Users, divisions, players, trainers, parents, activities, payments',
              Icons.dataset_rounded,
              '/data-management',
            ),
            _PortalShortcut(
              'Player development',
              'Presence, injuries, reports, ratings',
              Icons.insights_rounded,
              '/admin/player-development',
            ),
            _PortalShortcut(
              'Notifications',
              'Broadcast alerts and updates',
              Icons.campaign_rounded,
              '/admin/notifications',
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            context,
            title: 'Quick access',
            subtitle: 'Jump straight into the busiest mobile operations.',
          ),
          const SizedBox(height: 12),
          ...shortcuts.map(
            (shortcut) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, shortcut.route),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(shortcut.icon, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shortcut.title,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shortcut.subtitle,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedModules(BuildContext context) {
    final featured = _modules.take(4).toList(growable: false);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            context,
            title: 'Featured modules',
            subtitle: 'The same service families that exist in `resources/pages`, now surfaced for mobile work.',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 166,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder:
                  (context, index) => _featuredModuleCard(context, featured[index]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: featured.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalModules(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            context,
            title: 'All services',
            subtitle: 'Manage, add, edit, and inspect each module from mobile or open its mapped web-resource overview.',
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: _modules.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder:
                (context, index) => _moduleCard(context, _modules[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBoard(BuildContext context) {
    final rows =
        _isSuperAdmin
            ? [
              ('Knowledge entries', '${_number('chatbotCount')} items'),
              ('Categories', '${_number('categoriesCount')} mapped'),
              ('Themes', '${_number('themesCount')} active'),
            ]
            : [
              ('Academy workspace', 'Verified'),
              ('Finance queue', '${_number('overduePayments')} overdue'),
              ('Reports and stats', 'Ready'),
            ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            context,
            title: _isSuperAdmin ? 'Platform status' : 'Operations status',
            subtitle: 'A compact snapshot of live operational health.',
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.$1,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      row.$2,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredModuleCard(BuildContext context, AdminModuleSpec module) {
    return Container(
      width: 228,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            module.color.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: module.color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: module.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(module.icon, color: module.color),
          ),
          const Spacer(),
          Text(
            module.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            module.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _compactAction(
                  context,
                  label: 'Open',
                  filled: true,
                  onTap: () => _openPrimaryAction(module),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _compactAction(
                  context,
                  label: 'Guide',
                  onTap: () => _openModuleOverview(module),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(BuildContext context, AdminModuleSpec module) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: module.color.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(module.icon, color: module.color, size: 20),
              ),
              const Spacer(),
              Text(
                '${module.actions.length} action${module.actions.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: module.color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            module.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            module.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Text(
            '${module.capabilities.length} capabilities, ${module.webPages.length} page groups',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _compactAction(
                  context,
                  label: 'Manage',
                  filled: true,
                  onTap: () => _openPrimaryAction(module),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _compactAction(
                  context,
                  label: 'Pages',
                  onTap: () => _openModuleOverview(module),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactAction(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? cs.primary : cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? cs.primary : cs.primary.withValues(alpha: 0.14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? cs.onPrimary : cs.primary,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  void _openPrimaryAction(AdminModuleSpec module) {
    if (module.actions.isEmpty) {
      _openModuleOverview(module);
      return;
    }
    Navigator.pushNamed(context, module.actions.first.route);
  }

  void _openModuleOverview(AdminModuleSpec module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminModuleScreen(moduleKey: module.key, role: _moduleRole),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.errorContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(
                  color: cs.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.45),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  String _number(String key) {
    return (_data[key] ?? 0).toString();
  }

  String _money(dynamic value) {
    if (value is num) {
      return '${value.toStringAsFixed(0)} TND';
    }
    return '${value ?? 0} TND';
  }
}

class _PortalMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _PortalMetric(this.label, this.value, this.icon, this.color);
}

class _PortalShortcut {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const _PortalShortcut(this.title, this.subtitle, this.icon, this.route);
}


