import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../components/app_background.dart';
import '../../controllers/session_controller.dart';
import '../../services/super_admin_service.dart';

class SuperAdminDashboard extends StatefulWidget {
  final bool embedded;

  const SuperAdminDashboard({super.key, this.embedded = false});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final SuperAdminService _service = SuperAdminService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _dashboard = {};
  Map<String, dynamic> _summary = {};
  Map<String, dynamic> _payments = {};
  Map<String, dynamic> _appData = {};
  List<dynamic> _failedLogs = [];

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
      final dashboard = await _service.getDashboard();
      final summary = await _service.getDashboardSummary();
      final payments = await _service.getAcademyPayments();
      final appData = await _service.getAppData();
      final failedLogs = await _service.getFailedWebhookLogs();

      if (mounted) {
        setState(() {
          _dashboard = dashboard;
          _summary = summary;
          _payments = payments;
          _appData = appData;
          _failedLogs = failedLogs.map((e) => e as dynamic).toList();
        });
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AppSession.instance.session;
    final name = session.displayName.trim().isEmpty
        ? 'Platform Owner'
        : session.displayName.trim();

    final cs = Theme.of(context).colorScheme;

    final body = RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: cs.primary.withOpacity(0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PLATFORM OVERVIEW',
                            style: TextStyle(
                              color: cs.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Welcome, $name',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Compact KPIs, academy performance, payments, alerts, and quick platform actions.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Refresh',
                      onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _quickAction('Create Academy', Icons.add_business_rounded, '/super-admin/academies'),
                    _quickAction('Manage Sports', Icons.sports_rounded, '/super-admin/sports'),
                    _quickAction('Manage Users', Icons.people_rounded, '/admin-users'),
                    _quickAction('Payments', Icons.payments_rounded, '/super-admin/academy-payments'),
                    ActionChip(
                      avatar: const Icon(Icons.auto_awesome_rounded, size: 17),
                      label: const Text('Recompute Rankings'),
                      onPressed: () async {
                        await _service.recomputeAcademyRankings();
                        await _load();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Card(
              color: cs.errorContainer.withOpacity(0.25),
              child: ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: const Text('Error loading dashboard'),
                subtitle: Text(_error ?? 'Unknown error'),
              ),
            )
          else ...[
            // Platform Statistics Grid
            _buildStatsGrid(cs),
            const SizedBox(height: 20),

            // Payment Status Card
            if (_payments.containsKey('totalCollected') && _payments.containsKey('pendingPaymentsCount'))
              _buildPaymentSection(cs),

            const SizedBox(height: 20),

            // Academy Performance Overview
            if (_dashboard.isNotEmpty)
              _buildPerformanceSection(cs),

            const SizedBox(height: 20),

            // Webhook Health
            if (_failedLogs.isNotEmpty || _dashboard.containsKey('recentWebhookLogs'))
              _buildWebhookHealthSection(cs),

            const SizedBox(height: 20),

            // Recent Webhook Logs
            if (_dashboard.containsKey('recentWebhookLogs'))
              _buildRecentLogsSection(cs),
          ],
        ],
      ),
    );

    if (widget.embedded) return body;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Super Admin Dashboard'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: body,
      ),
    );
  }

  Widget _buildStatsGrid(ColorScheme cs) {
    final source = _summary.isNotEmpty ? _summary : _dashboard;
    final cards = [
      ('Total Academies', source['totalAcademies'] ?? source['academiesCount'] ?? 0, Icons.business_rounded),
      ('Active Academies', source['activeAcademies'] ?? 0, Icons.verified_rounded),
      ('Suspended', source['suspendedAcademies'] ?? 0, Icons.pause_circle_rounded),
      ('Sports', source['totalSports'] ?? source['sportsCount'] ?? 0, Icons.sports_soccer_rounded),
      ('Users', source['totalUsers'] ?? source['usersCount'] ?? 0, Icons.people_rounded),
      ('Admins', source['totalAdmins'] ?? source['adminContactsCount'] ?? 0, Icons.admin_panel_settings_rounded),
      ('Players', source['totalPlayers'] ?? 0, Icons.directions_run_rounded),
      ('Trainers', source['totalTrainers'] ?? 0, Icons.sports_rounded),
      ('Parents', source['totalParents'] ?? 0, Icons.family_restroom_rounded),
      ('Scouters', source['totalScouters'] ?? 0, Icons.travel_explore_rounded),
      ('Pending Payments', source['pendingPayments'] ?? 0, Icons.pending_actions_rounded),
      ('System Alerts', source['unreadSystemAlerts'] ?? 0, Icons.notifications_active_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Platform Overview',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 82,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (_, index) {
            final card = cards[index];
            return _statCard(cs, card.$1, '${card.$2}', card.$3, cs.primary);
          },
        ),
      ],
    );
  }

  Widget _statCard(
    ColorScheme cs,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.34)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                  ),
                  const SizedBox(height: 2),
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
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, String route) {
    return ActionChip(
      avatar: Icon(icon, size: 17),
      label: Text(label),
      onPressed: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildPaymentSection(ColorScheme cs) {
    final totalCollected = _payments['totalCollected'] ?? 0;
    final pendingCount = _payments['pendingPaymentsCount'] ?? 0;
    final currency = _payments['currency'] ?? '\$';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Revenue & Payments',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Collected',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currency$totalCollected',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF52C41A),
                              ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52C41A).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Color(0xFF52C41A),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _paymentStatusChip(
                        'Pending',
                        pendingCount.toString(),
                        const Color(0xFFFFA500),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _paymentStatusChip(
                        'Paid',
                        ((_payments['payments'] as List?)?.length ?? 0 - pendingCount).toString(),
                        const Color(0xFF52C41A),
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

  Widget _paymentStatusChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(ColorScheme cs) {
    final academies = _dashboard['academiesCount'] ?? 0;
    final sports = _dashboard['sportsCount'] ?? 0;
    final themes = _dashboard['themesCount'] ?? 0;

    final performanceData = [
      ('Academies', academies.toDouble()),
      ('Sports', sports.toDouble()),
      ('Themes', themes.toDouble()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Catalog Status',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 220,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: Theme.of(context).textTheme.labelSmall,
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: Theme.of(context).textTheme.labelSmall,
                ),
                series: <CartesianSeries>[
                  BarSeries<MapEntry<String, double>, String>(
                    dataSource: performanceData
                        .map<MapEntry<String, double>>((e) => MapEntry<String, double>(e.$1, e.$2))
                        .toList(),
                    xValueMapper: (MapEntry<String, double> sales, _) => sales.key,
                    yValueMapper: (MapEntry<String, double> sales, _) => sales.value,
                    pointColorMapper: (MapEntry<String, double> sales, _) =>
                        const Color(0xFF20B2A7),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebhookHealthSection(ColorScheme cs) {
    final totalLogs = _dashboard['recentWebhookLogs'] as List?;
    final failedCount = _failedLogs.length;
    final successRate = totalLogs != null && totalLogs.isNotEmpty
        ? ((totalLogs.length - failedCount) / totalLogs.length * 100).toStringAsFixed(1)
        : '100';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Webhook Health',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _healthIndicator('Success Rate', '$successRate%', 
                        const Color(0xFF52C41A)),
                    _healthIndicator('Failed', failedCount.toString(), 
                        const Color(0xFFFF6B6B)),
                    _healthIndicator('Total', (totalLogs?.length ?? 0).toString(), 
                        const Color(0xFF4A90E2)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: double.parse(successRate) / 100,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF52C41A)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _healthIndicator(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogsSection(ColorScheme cs) {
    final logs = _dashboard['recentWebhookLogs'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: logs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No recent webhook activity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final log = logs[index] as Map<String, dynamic>;
                      final success = log['success'] ?? false;
                      final webhookName = log['webhookName'] ?? 'Unknown';
                      final eventType = log['eventType'] ?? 'Unknown';
                      final statusCode = log['statusCode'] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (success
                                        ? const Color(0xFF52C41A)
                                        : const Color(0xFFFF6B6B))
                                    .withOpacity(0.12),
                              ),
                              child: Icon(
                                success ? Icons.check_rounded : Icons.close_rounded,
                                color: success
                                    ? const Color(0xFF52C41A)
                                    : const Color(0xFFFF6B6B),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    webhookName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$eventType ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Status: $statusCode',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: cs.onSurface.withOpacity(0.6),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
