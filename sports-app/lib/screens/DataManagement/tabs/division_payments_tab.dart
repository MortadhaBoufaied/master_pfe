// lib/screens/DataManagement/tabs/division_payments_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:moez_project/components/AnimatedDots.dart';
import 'package:moez_project/components/ui_kit.dart';
import 'package:moez_project/utils/url_resolver.dart';

// ------------------------------
// Models
// ------------------------------

enum PaymentStatus { paid, unpaid }

class DivisionPayment {
  final int id;
  final String playerName;
  final String? playerAvatarPath;
  final String planName;
  final DateTime dueDate;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? receiptPath;
  final String? invoicePath;

  DivisionPayment({
    required this.id,
    required this.playerName,
    this.playerAvatarPath,
    required this.planName,
    required this.dueDate,
    required this.amount,
    required this.currency,
    required this.status,
    this.receiptPath,
    this.invoicePath,
  });
}

// ------------------------------
// Widget
// ------------------------------

class DivisionPaymentsTab extends StatefulWidget {
  final int divisionId;
  final String? divisionTitle;

  const DivisionPaymentsTab({
    Key? key,
    required this.divisionId,
    this.divisionTitle,
  }) : super(key: key);

  @override
  State<DivisionPaymentsTab> createState() => _DivisionPaymentsTabState();
}

class _DivisionPaymentsTabState extends State<DivisionPaymentsTab> {
  PaymentStatus? _statusFilter;
  late int _monthFilter;
  late int _yearFilter;
  String _search = '';

  late Future<List<DivisionPayment>> _future;
  List<DivisionPayment> _cache = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthFilter = now.month;
    _yearFilter = now.year;
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<List<DivisionPayment>> _fetchPayments() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final all = <DivisionPayment>[
      DivisionPayment(
        id: 1,
        playerName: 'Ahmed Ben Ali',
        planName: 'Monthly Plan',
        dueDate: DateTime(_yearFilter, _monthFilter, 5),
        amount: 60,
        currency: 'TND',
        status: PaymentStatus.unpaid,
      ),
      DivisionPayment(
        id: 2,
        playerName: 'Youssef Trabelsi',
        planName: 'Monthly Plan',
        dueDate: DateTime(_yearFilter, _monthFilter, 5),
        amount: 60,
        currency: 'TND',
        status: PaymentStatus.paid,
      ),
    ];

    return all.where((p) {
      if (_statusFilter != null && p.status != _statusFilter) return false;
      if (_search.isNotEmpty &&
          !p.playerName.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  void _load() {
    setState(() {
      _future = _fetchPayments().then((data) {
        _cache = data;
        return data;
      });
    });
  }

  Future<void> _refresh() async {
    _load();
    await _future;
  }

  double _total(PaymentStatus? status) {
    return _cache
        .where((p) => status == null || p.status == status)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // ------------------------------
  // UI
  // ------------------------------

  @override
  Widget build(BuildContext context) {
    final title = widget.divisionTitle ?? 'Division payments';

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SectionTitle(
              title: title,
              subtitle: 'Manage monthly payments',
            ),
          ),
          SliverToBoxAdapter(child: _filters(context)),
          SliverToBoxAdapter(child: _summaryPills()),
          SliverToBoxAdapter(
            child: FutureBuilder<List<DivisionPayment>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: AnimatedDots(size: 10)),
                  );
                }

                if (snap.hasError) {
                  return _errorBox(snap.error);
                }

                final payments = snap.data ?? [];
                if (payments.isEmpty) {
                  return _emptyBox();
                }

                return Column(
                  children:
                  payments.map((p) => _paymentTile(context, p)).toList(),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // ------------------------------
  // Filters
  // ------------------------------

  Widget _filters(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: DropdownButtonFormField<PaymentStatus?>(
              value: _statusFilter,
              decoration: _input(cs, 'Status'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(
                    value: PaymentStatus.unpaid, child: Text('Unpaid')),
                DropdownMenuItem(
                    value: PaymentStatus.paid, child: Text('Paid')),
              ],
              onChanged: (v) {
                setState(() => _statusFilter = v);
                _load();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: _input(cs, 'Search player')
                  .copyWith(prefixIcon: const Icon(Icons.search)),
              onChanged: (v) {
                _search = v;
                _debounce?.cancel();
                _debounce =
                    Timer(const Duration(milliseconds: 300), _load);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryPills() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Row(
        children: [
          MetricPill(
            label: 'All',
            value: _formatAmount(_total(null)),
            color: Colors.blue,
            icon: Icons.receipt_long,
          ),
          const SizedBox(width: 12),
          MetricPill(
            label: 'Paid',
            value: _formatAmount(_total(PaymentStatus.paid)),
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          const SizedBox(width: 12),
          MetricPill(
            label: 'Unpaid',
            value: _formatAmount(_total(PaymentStatus.unpaid)),
            color: Colors.redAccent,
            icon: Icons.warning_amber,
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(BuildContext context, DivisionPayment p) {
    final avatarUrl = resolvePublicUrl(p.playerAvatarPath);
    final isPaid = p.status == PaymentStatus.paid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SoftCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.playerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${p.planName} ${_formatDate(p.dueDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${_formatAmount(p.amount)} ${p.currency}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(isPaid ? 'Paid' : 'Unpaid'),
              backgroundColor: isPaid
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // Helpers
  // ------------------------------

  InputDecoration _input(ColorScheme cs, String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: cs.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatAmount(double a) =>
      a.toStringAsFixed(a.truncateToDouble() == a ? 0 : 2);

  Widget _emptyBox() => const Padding(
    padding: EdgeInsets.all(40),
    child: Center(child: Text('No payments found')),
  );

  Widget _errorBox(Object? error) => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Text(
        'Failed to load payments\n$error',
        textAlign: TextAlign.center,
      ),
    ),
  );
}


