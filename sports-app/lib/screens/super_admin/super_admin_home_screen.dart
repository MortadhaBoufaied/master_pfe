import 'dart:ui';

import 'package:flutter/material.dart';

import '../../components/app_background.dart';
import '../../components/ui_kit.dart';
import 'super_admin_module_screens.dart';

class SuperAdminHomeScreen extends StatefulWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  State<SuperAdminHomeScreen> createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final List<_SuperAdminModuleGroup> _groups = [
    _SuperAdminModuleGroup(
      title: 'Platform operations',
      subtitle: 'Global system data and health',
      entries: [
        _SuperAdminModuleEntry(
          key: 'app-data',
          title: 'App Data',
          subtitle: 'Platform counters and chatbot knowledge status',
          icon: Icons.dataset_rounded,
          color: const Color(0xFF2563EB),
          builder: (_) => const SuperAdminAppDataScreen(),
        ),
        _SuperAdminModuleEntry(
          key: 'contact',
          title: 'Contact Admins',
          subtitle: 'Academy owners and linked admin contacts',
          icon: Icons.contact_mail_rounded,
          color: const Color(0xFF0891B2),
          builder: (_) => const SuperAdminContactsScreen(),
        ),
      ],
    ),
    _SuperAdminModuleGroup(
      title: 'Sports & configuration',
      subtitle: 'Multi-sport catalog, themes and assistant settings',
      entries: [
        _SuperAdminModuleEntry(
          key: 'sports',
          title: 'Sports & Categories',
          subtitle: 'Manage sports and sport categories',
          icon: Icons.sports_rounded,
          color: const Color(0xFF115CB9),
          builder: (_) => const SuperAdminSportsScreen(),
        ),
        _SuperAdminModuleEntry(
          key: 'themes',
          title: 'Themes',
          subtitle: 'Platform, sport and academy visual identity',
          icon: Icons.palette_rounded,
          color: const Color(0xFFDB2777),
          builder: (_) => const SuperAdminThemesScreen(),
        ),
        _SuperAdminModuleEntry(
          key: 'chatbot-global',
          title: 'Global Chatbot',
          subtitle: 'Teach and manage platform assistant knowledge',
          icon: Icons.smart_toy_rounded,
          color: const Color(0xFF9333EA),
          builder: (_) => const SuperAdminChatbotScreen(),
        ),
      ],
    ),
  ];

  List<_SuperAdminModuleEntry> get _allEntries {
    return _groups.expand((group) => group.entries).toList(growable: false);
  }

  List<_SuperAdminModuleGroup> get _filteredGroups {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return _groups;

    return _groups
        .map(
          (group) => _SuperAdminModuleGroup(
        title: group.title,
        subtitle: group.subtitle,
        entries: group.entries.where((entry) {
          return entry.title.toLowerCase().contains(query) ||
              entry.subtitle.toLowerCase().contains(query) ||
              entry.key.toLowerCase().contains(query);
        }).toList(),
      ),
    )
        .where((group) => group.entries.isNotEmpty)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = _filteredGroups;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroHeader(
                    totalModules: _allEntries.length,
                    quickModules: _groups.first.entries.length,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: _SearchBox(controller: _searchController),
                  ),
                ),

                if (_searchController.text.trim().isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      child: _QuickActionsRow(
                        entries: _groups.first.entries,
                        onOpen: _openModule,
                      ),
                    ),
                  ),

                if (filteredGroups.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptySearchState(
                      query: _searchController.text.trim(),
                      onClear: () => _searchController.clear(),
                    ),
                  )
                else
                  for (final group in filteredGroups) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                        child: SectionTitle(
                          title: group.title,
                          subtitle: group.subtitle,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.crossAxisExtent;
                          final crossAxisCount = width >= 850
                              ? 4
                              : width >= 620
                              ? 3
                              : 2;

                          return SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final entry = group.entries[index];
                                return _ModuleCard(
                                  entry: entry,
                                  onTap: () => _openModule(entry),
                                );
                              },
                              childCount: group.entries.length,
                            ),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.95,
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                const SliverToBoxAdapter(
                  child: SizedBox(height: 105),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openModule(_SuperAdminModuleEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: entry.builder,
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final int totalModules;
  final int quickModules;

  const _HeroHeader({
    required this.totalModules,
    required this.quickModules,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  cs.primary.withOpacity(0.34),
                  cs.surface.withOpacity(0.72),
                  cs.tertiary.withOpacity(0.18),
                ]
                    : [
                  cs.primary.withOpacity(0.15),
                  Colors.white.withOpacity(0.82),
                  cs.tertiary.withOpacity(0.12),
                ],
              ),
              border: Border.all(
                color: cs.outlineVariant.withOpacity(isDark ? 0.30 : 0.20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.28 : 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -42,
                  top: -48,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withOpacity(0.10),
                    ),
                  ),
                ),
                Positioned(
                  right: 28,
                  bottom: -48,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.tertiary.withOpacity(0.10),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: cs.primary.withOpacity(0.18),
                            ),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: cs.primary,
                            size: 29,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Super Admin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: cs.onSurface,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Platform command center',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Manage academies, sports, automation, payments, themes, chatbot knowledge, and platform settings from one clean workspace.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.42,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroMetric(
                            icon: Icons.apps_rounded,
                            value: '$totalModules',
                            label: 'Modules',
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeroMetric(
                            icon: Icons.flash_on_rounded,
                            value: '$quickModules',
                            label: 'Quick tools',
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _HeroMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBox({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search platform modules',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
              tooltip: 'Clear',
              onPressed: controller.clear,
              icon: const Icon(Icons.close_rounded),
            ),
            filled: true,
            fillColor: isDark
                ? cs.surface.withOpacity(0.58)
                : Colors.white.withOpacity(0.78),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: cs.outlineVariant.withOpacity(0.18),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: cs.outlineVariant.withOpacity(0.18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final List<_SuperAdminModuleEntry> entries;
  final ValueChanged<_SuperAdminModuleEntry> onOpen;

  const _QuickActionsRow({
    required this.entries,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final entry = entries[index];

          return _QuickActionChip(
            entry: entry,
            onTap: () => onOpen(entry),
          );
        },
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final _SuperAdminModuleEntry entry;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 188,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isDark
                ? cs.surface.withOpacity(0.58)
                : Colors.white.withOpacity(0.80),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: entry.color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  entry.icon,
                  color: entry.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Open module',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final _SuperAdminModuleEntry entry;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surface.withOpacity(0.58)
                    : Colors.white.withOpacity(0.82),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(isDark ? 0.28 : 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.22 : 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: entry.color.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Icon(
                          entry.icon,
                          color: entry.color,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 19,
                        color: cs.onSurfaceVariant.withOpacity(0.55),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    entry.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _EmptySearchState({
    required this.query,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SoftCard(
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 46,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'No module found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No Super Admin module matches "$query".',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Clear search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuperAdminModuleGroup {
  final String title;
  final String subtitle;
  final List<_SuperAdminModuleEntry> entries;

  const _SuperAdminModuleGroup({
    required this.title,
    required this.subtitle,
    required this.entries,
  });
}

class _SuperAdminModuleEntry {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;

  const _SuperAdminModuleEntry({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });
}