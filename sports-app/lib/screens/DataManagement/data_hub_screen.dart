import 'package:flutter/material.dart';

import '../../components/DataManagementAppbar.dart';
import '../../components/app_background.dart';
import '../../components/modern_design_system.dart';
import '../../controllers/dataManagementController.dart';
import '../../models/unified_activity.dart';
import 'data_management_scope.dart';
import '../../l10n/app_strings.dart';

import 'tabs/activities_tab.dart';
import 'tabs/division_tab.dart';
import 'tabs/parents_tab.dart';
import 'tabs/payments_tab.dart';
import 'tabs/players_tab.dart';
import 'tabs/trainers_tab.dart';
import 'tabs/unassigned_tab.dart';
import 'tabs/users_tab.dart';

/// Data management hub.
/// CRUD buttons are shown inside each tab only for ADMIN users.
class DataHubScreen extends StatefulWidget {
  final bool embedded;
  final int initialIndex;
  final UnifiedActivityType? initialActivityFilter;

  const DataHubScreen({
    super.key,
    this.embedded = false,
    this.initialIndex = 0,
    this.initialActivityFilter,
  });

  @override
  State<DataHubScreen> createState() => _DataHubScreenState();
}

class _DataHubScreenState extends State<DataHubScreen> {
  late final DataManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DataManagementController();
    _controller.bootstrap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    final tabBar = TabBar(
      isScrollable: true,
      indicatorColor: Theme.of(context).colorScheme.primary,
      labelColor: Theme.of(context).colorScheme.onSurface,
      unselectedLabelColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.65),
      tabs: [
        Tab(text: t.tr('Users')),
        Tab(text: t.tr('Divisions')),
        Tab(text: t.tr('Unassigned')),
        Tab(text: t.tr('Players')),
        Tab(text: t.tr('Trainers')),
        Tab(text: t.tr('Parents')),
        Tab(text: t.tr('Activities')),
        Tab(text: t.tr('Payments')),
      ],
    );

    final tabView = TabBarView(
      children: [
        const UsersTab(),
        const DivisionsTab(),
        const UnassignedTab(),
        const PlayersTab(),
        const TrainersTab(),
        const ParentsTab(),
        ActivitiesTab(initialFilter: widget.initialActivityFilter),
        const PaymentsTab(),
      ],
    );

    final desktopContent = DefaultTabController(
      length: 8,
      initialIndex: widget.initialIndex.clamp(0, 7),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
            ),
            child: Material(color: Colors.transparent, child: tabBar),
          ),
          Expanded(child: tabView),
        ],
      ),
    );

    final mobileContent = DefaultTabController(
      length: 8,
      initialIndex: widget.initialIndex.clamp(0, 7),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: DataManagementAppBar(
          showLogo: false,
          onSearchTap: () {
            Navigator.pushNamed(context, '/global-search');
          },
          onNotificationTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
          tabBar: tabBar,
        ),
        body: tabView,
      ),
    );

    return DataManagementScope(
      controller: _controller,
      child:
          widget.embedded
              ? desktopContent
              : AppBackground(child: mobileContent),
    );
  }
}


