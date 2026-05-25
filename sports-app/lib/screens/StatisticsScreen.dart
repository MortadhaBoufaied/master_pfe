import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../components/modern_design_system.dart';
import '../components/app_background.dart';
import '../../services/export_service.dart';
import '../controllers/StatisticsController.dart';

class StatisticsScreen extends StatefulWidget {
  final bool embedded;

  const StatisticsScreen({Key? key, this.embedded = false}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  final StatisticsController _controller = StatisticsController();
  final ExportService _exportService = ExportService();
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    await _controller.loadAllStatistics();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --------------------- STATES ---------------------

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading statistics...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final msg = _controller.error ?? 'Unknown error';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $msg',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------- OVERVIEW ---------------------

  Widget _buildSummaryCard() {
    final summary = _controller.getSummary();

    final totalPlayers =
    (summary['players']?['total'] ?? 0).toString();
    final totalDivisions =
    (summary['divisions']?['total'] ?? 0).toString();
    final totalActivities =
    (summary['activities']?['total'] ?? 0).toString();

    final topScorer =
    (summary['players']?['top_scorer'] ?? 'N/A').toString();
    final topScorerGoals =
    (summary['players']?['top_scorer_goals'] ?? 0).toString();
    final winRate =
    (summary['activities']?['win_rate'] ?? '0').toString();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Academy Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _summaryItem('Total Players', totalPlayers, Icons.people),
                _summaryItem('Divisions', totalDivisions, Icons.category),
                _summaryItem('Activities', totalActivities, Icons.event),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _summaryItem('Top Scorer', topScorer, Icons.emoji_events),
                _summaryItem('Goals', topScorerGoals, Icons.sports_soccer),
                _summaryItem('Win Rate', '$winRate%', Icons.trending_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.teal, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // --------------------- PLAYERS TAB ---------------------

  Widget _buildPlayersTab() {
    final ageDistribution = _controller.getPlayerAgeDistribution();
    final positionDistribution = _controller.getPositionDistribution();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Key metrics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _metricCard('Total Players',
                    (_controller.playerStats['total_players'] ?? 0).toString()),
                _metricCard('Total Goals',
                    (_controller.playerStats['total_goals'] ?? 0).toString()),
                _metricCard('Total Assists',
                    (_controller.playerStats['total_assists'] ?? 0).toString()),
              ],
            ),
          ),

          // Age Distribution
          _buildBarChartCard(
            title: 'Age Distribution',
            data: ageDistribution,
            xKey: 'ageGroup',
            yKey: 'count',
            color: Colors.blue,
          ),

          // Position Distribution
          _buildPieChartCard(
            title: 'Position Distribution',
            data: positionDistribution,
            xKey: 'position',
            yKey: 'count',
          ),

          // Top Scorers
          if ((_controller.playerStats['top_scorers'] as List?)?.isNotEmpty == true)
            _buildTopScorers(),
        ],
      ),
    );
  }

  Widget _buildTopScorers() {
    final top = (_controller.playerStats['top_scorers'] as List)
        .cast<Map<String, dynamic>>();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Scorers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...top.map((scorer) {
              final name = scorer['name']?.toString() ?? 'Unknown';
              final goals = (scorer['goals'] ?? 0).toString();
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber.shade100,
                  child: const Icon(Icons.emoji_events, color: Colors.amber),
                ),
                title: Text(name),
                trailing: Chip(
                  label: Text('$goals goals'),
                  backgroundColor: Colors.green.shade100,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --------------------- FINANCE TAB ---------------------

  Widget _buildFinanceTab() {
    final revenueByMonth = _controller.getRevenueByMonth();

    final totalRevenue =
    (_controller.financialStats['total_revenue'] ?? 0.0).toStringAsFixed(2);
    final paidRevenue =
    (_controller.financialStats['paid_revenue'] ?? 0.0).toStringAsFixed(2);
    final paymentRate =
    (_controller.financialStats['payment_rate'] ?? '0').toString();

    final paidCount =
        _controller.financialStats['paid_payments_count'] ?? 0;
    final pendingCount =
        _controller.financialStats['pending_payments_count'] ?? 0;
    final totalCount =
        _controller.financialStats['total_payments_count'] ?? 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Financial Metrics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _metricCard('Total Revenue', '$totalRevenue DT'),
                _metricCard('Paid Revenue', '$paidRevenue DT'),
                _metricCard('Payment Rate', '$paymentRate%'),
              ],
            ),
          ),

          // Revenue Chart
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Revenue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        numberFormat: NumberFormat.compactCurrency(symbol: 'DT '),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        LineSeries<Map<String, dynamic>, String>(
                          dataSource: revenueByMonth,
                          xValueMapper: (data, _) => data['month']?.toString() ?? '',
                          yValueMapper: (data, _) => (data['revenue'] ?? 0.0) as double,
                          color: Colors.green,
                          markerSettings: const MarkerSettings(isVisible: true),
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Payment Status
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _statusCard('Paid', paidCount, Colors.green, Icons.check_circle),
                      ),
                      Expanded(
                        child: _statusCard('Pending', pendingCount, Colors.orange, Icons.pending),
                      ),
                      Expanded(
                        child: _statusCard('Total', totalCount, Colors.blue, Icons.payments),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------- ACTIVITIES TAB ---------------------

  Widget _buildActivitiesTab() {
    final matchResults = _controller.getMatchResults();

    final totalActivities =
    (_controller.activityStats['total_activities'] ?? 0).toString();
    final totalMatches =
    (_controller.activityStats['total_matches'] ?? 0).toString();
    final winRate =
    (_controller.activityStats['win_rate'] ?? '0').toString();

    final activitiesByMonth =
        (_controller.activityStats['activities_by_month'] as Map<String, int>?) ??
            const {};

    return SingleChildScrollView(
      child: Column(
        children: [
          // Activity Metrics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _metricCard('Total Activities', totalActivities),
                _metricCard('Total Matches', totalMatches),
                _metricCard('Win Rate', '$winRate%'),
              ],
            ),
          ),

          // Match Results chart

          // Activities by Month
          if (activitiesByMonth.isNotEmpty)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activities by Month',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...activitiesByMonth.entries.map((entry) {
                      final month = entry.key;
                      final count = entry.value;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              count.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        title: Text(month),
                        subtitle: LinearProgressIndicator(
                          value: (count / 20.0).clamp(0.0, 1.0), // normalized
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.teal,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --------------------- SMALL BUILDERS ---------------------

  Widget _metricCard(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard(String label, int value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard({
    required String title,
    required List<Map<String, dynamic>> data,
    required String xKey,
    required String yKey,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<Map<String, dynamic>, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d[xKey]?.toString() ?? '',
                    yValueMapper: (d, _) => (d[yKey] ?? 0) as num,
                    color: color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard({
    required String title,
    required List<Map<String, dynamic>> data,
    required String xKey,
    required String yKey,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d[xKey]?.toString() ?? '',
                    yValueMapper: (d, _) => (d[yKey] ?? 0) as num,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------- BUILD ---------------------

  @override
  Widget build(BuildContext context) {
    final bodyContent = _isLoading
        ? _buildLoadingState()
        : _controller.error != null
        ? _buildErrorState()
        : TabBarView(
      controller: _tabController,
      children: [
        // Overview
        SingleChildScrollView(
          child: Column(
            children: [
              _buildSummaryCard(),
              _buildPlayersTab(),
            ],
          ),
        ),
        // Players
        _buildPlayersTab(),
        // Finance
        _buildFinanceTab(),
        // Activities
        _buildActivitiesTab(),
      ],
    );

    if (widget.embedded) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Statistics Dashboard',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStatistics,
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                Tab(icon: Icon(Icons.people), text: 'Players'),
                Tab(icon: Icon(Icons.payments), text: 'Finance'),
                Tab(icon: Icon(Icons.sports_soccer), text: 'Activities'),
              ],
            ),
          ),
          Expanded(child: bodyContent),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Statistics Dashboard'),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Players'),
            Tab(icon: Icon(Icons.payments), text: 'Finance'),
            Tab(icon: Icon(Icons.sports_soccer), text: 'Activities'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStatistics),
        ],
      ),
      body: bodyContent,
    );
  }
}


