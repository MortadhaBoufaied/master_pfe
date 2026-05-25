import 'dart:ui';

import 'package:flutter/material.dart';
import 'admin_users_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../components/app_background.dart';
import '../../components/ui_kit.dart';
import '../../controllers/StatisticsController.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final StatisticsController _stats = StatisticsController();
  bool _loading = true;

  // ===================== UI CONSTANTS =====================
  double get _radius => 18;
  double get _cardPad => 14;
  
  ColorScheme get cs => Theme.of(context).colorScheme;
  TextTheme get tt => Theme.of(context).textTheme;
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _cardColor =>
      isDark ? const Color(0xFF141A20) : Colors.white.withOpacity(0.92);

  Color get _strokeColor => cs.outlineVariant.withOpacity(isDark ? 0.28 : 0.16);

  Color get _accent => const Color(0xFF20B2A7);

  List<BoxShadow> get _softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];

  TextStyle get _sectionTitleStyle => (tt.titleMedium ?? const TextStyle()).copyWith(
    fontWeight: FontWeight.w900,
    letterSpacing: -0.2,
    color: cs.onSurface.withOpacity(isDark ? 0.92 : 0.88),
  );

  TextStyle get _mutedStyle => (tt.bodySmall ?? const TextStyle()).copyWith(
    height: 1.25,
    color: cs.onSurface.withOpacity(isDark ? 0.72 : 0.62),
    fontWeight: FontWeight.w500,
  );

  Color _pastel(Color base, {double amount = 0.82}) {
    return Color.lerp(base, Colors.white, amount) ?? base;
  }

  // ===================== SOFT CARD =====================
  Widget _softCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(12),
      padding: padding ?? EdgeInsets.all(_cardPad),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _strokeColor),
        boxShadow: _softShadow,
      ),
      child: child,
    );
  }

  // ===================== GLASS CARD =====================
  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? EdgeInsets.all(_cardPad),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF121821).withOpacity(0.68)
                  : Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: _strokeColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _stats.loadAllStatistics();
    if (mounted) setState(() => _loading = false);
  }

  // ===================== BACKGROUND =====================
  Widget _buildBackground() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage("assets/background-image.png"),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(isDark ? 0.10 : 0.75),
                    cs.surface.withOpacity(isDark ? 0.70 : 0.55),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _stats.getSummary();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Header Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Panel',
                                style: _sectionTitleStyle,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Live KPIs from your academy database',
                                style: _mutedStyle,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _load,
                          icon: Icon(Icons.refresh, color: _accent),
                          style: IconButton.styleFrom(
                            backgroundColor: _pastel(_accent, amount: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  _loading
                      ? _glassCard(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(18),
                          child: Center(
                            child: CircularProgressIndicator(color: _accent),
                          ),
                        )
                      : Column(
                          children: [
                            // KPI Metrics Row
                            _buildMetricsRow(summary),
                            const SizedBox(height: 6),

                            // Quick Stats
                            _buildQuickStatsCard(summary),
                            const SizedBox(height: 6),

                            // Revenue Chart
                            _buildRevenueCard(),
                            const SizedBox(height: 6),

                            // Action Buttons
                            _buildActionButtons(context),
                            const SizedBox(height: 20),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== KPI GRID =====================
  Widget _buildMetricsGrid(Map<String, dynamic> summary) {
    final metrics = [
      (Icons.people, 'Players', summary['players']?['total'] ?? 0, Color(0xFF14B8A6)),
      (Icons.category, 'Divisions', summary['divisions']?['total'] ?? 0, Color(0xFFF59E0B)),
      (Icons.event, 'Activities', summary['activities']?['total'] ?? 0, Color(0xFF3B82F6)),
      (Icons.payments, 'Payment Rate', '${summary['finance']?['payment_rate'] ?? 0}%', Color(0xFF22C55E)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: metrics.map((m) => _buildMetricCard(m.$2, m.$3, m.$1, m.$4)).toList(),
      ),
    );
  }

  Widget _buildMetricCard(String label, dynamic value, IconData icon, Color color) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== KPI METRICS ROW (GLASS CARD) =====================
  Widget _buildMetricsRow(Map<String, dynamic> summary) {
    final accents = <Color>[
      const Color(0xFF14B8A6), // teal
      const Color(0xFFF59E0B), // amber
      const Color(0xFF3B82F6), // blue
      const Color(0xFF22C55E), // green
    ];

    final metrics = [
      ('Players', summary['players']?['total'] ?? 0, Icons.people, accents[0]),
      ('Divisions', summary['divisions']?['total'] ?? 0, Icons.category, accents[1]),
      ('Activities', summary['activities']?['total'] ?? 0, Icons.event, accents[2]),
      ('Payment', '${summary['finance']?['payment_rate'] ?? 0}%', Icons.payments, accents[3]),
    ];

    return _glassCard(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: List.generate(metrics.length, (i) {
          final m = metrics[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == metrics.length - 1 ? 0 : 8),
              child: _metricPill(m.$1, m.$2, m.$3, m.$4),
            ),
          );
        }),
      ),
    );
  }

  Widget _metricPill(String label, dynamic value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: (tt.labelLarge ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: cs.onSurface.withOpacity(isDark ? 0.92 : 0.88),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: (tt.labelSmall ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withOpacity(isDark ? 0.72 : 0.62),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ===================== QUICK STATS (SOFT CARD) =====================
  Widget _buildQuickStatsCard(Map<String, dynamic> summary) {
    return _softCard(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Stats', style: _sectionTitleStyle),
          const SizedBox(height: 8),
          _statRow(
            'Active Players',
            '${summary['players']?['active'] ?? 0} / ${summary['players']?['total'] ?? 0}',
            Icons.verified,
            const Color(0xFF14B8A6),
          ),
          const SizedBox(height: 10),
          _statRow(
            'Upcoming Activities',
            '${summary['activities']?['upcoming'] ?? 0}',
            Icons.calendar_today,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 10),
          _statRow(
            'Pending Payments',
            '${summary['finance']?['pending'] ?? 0}',
            Icons.receipt_long,
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _pastel(color, amount: 0.86),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: (tt.labelMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w700)),
              Text(
                value,
                style: (tt.labelSmall ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================== REVENUE CHART (GLASS CARD) =====================
  Widget _buildRevenueCard() {
    return _glassCard(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Trends',
            subtitle: 'Live KPIs from your academy database',
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: AxisLine(
                  color: cs.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
                labelStyle: _mutedStyle,
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: cs.outlineVariant.withOpacity(isDark ? 0.22 : 0.18),
                  dashArray: const <double>[4, 4],
                ),
                axisLine: const AxisLine(width: 0),
                labelStyle: _mutedStyle,
              ),
              series: <CartesianSeries<_Point, String>>[
                LineSeries<_Point, String>(
                  dataSource: _stats
                      .getRevenueByMonth()
                      .map((e) => _Point(
                        e['month'],
                        (e['revenue'] as num).toDouble(),
                      ))
                      .toList(),
                  xValueMapper: (p, _) => p.x,
                  yValueMapper: (p, _) => p.y,
                  color: cs.tertiary,
                  width: 3,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 7,
                    width: 7,
                    borderWidth: 2,
                    borderColor: cs.tertiary,
                    color: _pastel(cs.tertiary, amount: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== ACTION BUTTONS =====================
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _softCard(
          margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: _actionButton(
                  'Data Management',
                  Icons.storage,
                  _accent,
                  () => Navigator.pushNamed(context, '/data-management'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(
                  'Statistics',
                  Icons.bar_chart,
                  const Color(0xFF3B82F6),
                  () => Navigator.pushNamed(context, '/statistics'),
                ),
              ),
            ],
          ),
        ),
        _softCard(
          margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          padding: const EdgeInsets.all(12),
          child: _actionButton(
            'Manage Users',
            Icons.manage_accounts,
            const Color(0xFFF59E0B),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _pastel(color, amount: 0.86),
                _pastel(color, amount: 0.90),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: (tt.labelMedium ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Point {
  final String x;
  final double y;
  _Point(this.x, this.y);
}


