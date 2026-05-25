import 'package:flutter/material.dart';

import '../../../components/ui_kit.dart';
import '../../../models/admin/admin_module.dart';

class AdminModuleHero extends StatelessWidget {
  final AdminModuleSpec module;
  const AdminModuleHero({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            module.color.withValues(alpha: dark ? 0.28 : 0.16),
            cs.surface.withValues(alpha: 0.86),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: module.color.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(module.icon, color: module.color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(module.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(module.subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(module.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35)),
        ],
      ),
    );
  }
}

class AdminModuleRail extends StatelessWidget {
  final AdminModuleSpec active;
  final List<AdminModuleSpec> modules;
  final ValueChanged<AdminModuleSpec> onSelected;
  final bool vertical;

  const AdminModuleRail({
    super.key,
    required this.active,
    required this.modules,
    required this.onSelected,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = modules.map((module) => _tile(context, module)).toList();
    return SoftCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(10),
      child: vertical
          ? Column(children: children)
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: children),
            ),
    );
  }

  Widget _tile(BuildContext context, AdminModuleSpec module) {
    final selected = active.key == module.key;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(right: vertical ? 0 : 8, bottom: vertical ? 8 : 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: selected ? null : () => onSelected(module),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: vertical ? double.infinity : 168,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: selected ? module.color.withValues(alpha: 0.14) : cs.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: selected ? module.color.withValues(alpha: 0.42) : cs.outlineVariant.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Icon(module.icon, color: selected ? module.color : cs.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  module.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900, color: selected ? module.color : cs.onSurface, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminInfoBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  const AdminInfoBlock({super.key, required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return SoftCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: cs.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w900))]),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
              ),
              child: Text(item, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class AdminActionsBlock extends StatelessWidget {
  final List<AdminModuleAction> actions;
  const AdminActionsBlock({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    return SoftCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Available mobile actions', subtitle: 'Native screens are used where they already exist.'),
          ...actions.map((action) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(action.icon),
            title: Text(action.label, style: const TextStyle(fontWeight: FontWeight.w800)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, action.route),
          )),
        ],
      ),
    );
  }
}


