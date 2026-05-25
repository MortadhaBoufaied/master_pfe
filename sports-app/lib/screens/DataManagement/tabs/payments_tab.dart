import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../controllers/payment_controller.dart';
import '../../../models/payment.dart';
import '../../../utils/role_utils.dart';
import '../../../components/ui_kit.dart';
import 'common/ui_helpers.dart';

class PaymentsTab extends StatefulWidget {
  const PaymentsTab({Key? key}) : super(key: key);

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  final PaymentController _controller = PaymentController();
  final TextEditingController _searchController = TextEditingController();

  bool _isAdmin = false;

  // Archive filters
  String _archiveMonth = 'all'; // all or YYYY-MM
  String _archiveStatus = 'all'; // all, paid, unpaid

  @override
  void initState() {
    super.initState();
    _isAdmin = UserRoleUtil.isAdmin();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPayments());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    await _controller.getAllPayments(); // fills controller.payments
    if (mounted) setState(() {});
  }

  String get _currentMonthKey => DateFormat('yyyy-MM').format(DateTime.now());

  bool _inMonth(Payment p, String monthKey) {
    final k = DateFormat('yyyy-MM').format(p.mois);
    return k == monthKey;
  }

  List<Payment> get _thisMonthPayments =>
      _controller.payments.where((p) => _inMonth(p, _currentMonthKey)).toList();

  List<Payment> get _unpaidThisMonth =>
      _thisMonthPayments.where((p) => !p.isPaid).toList();

  List<Payment> get _paidThisMonth =>
      _thisMonthPayments.where((p) => p.isPaid).toList();

  List<Payment> get _archivePaymentsFiltered {
    final q = _searchController.text.toLowerCase();

    return _controller.payments.where((p) {
      final okMonth = _archiveMonth == 'all'
          ? true
          : DateFormat('yyyy-MM').format(p.mois) == _archiveMonth;

      final okStatus = _archiveStatus == 'all'
          ? true
          : (_archiveStatus == 'paid' ? p.isPaid : !p.isPaid);

      final okText = q.isEmpty
          ? true
          : (p.id?.toString().contains(q) ?? false) ||
              DateFormat('yyyy-MM').format(p.mois).contains(q);

      return okMonth && okStatus && okText;
    }).toList();
  }

  List<String> _recentMonthKeys({int count = 18}) {
    final now = DateTime.now();
    final list = <String>[];
    for (int i = 0; i < count; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      list.add(DateFormat('yyyy-MM').format(d));
    }
    return list;
  }

  Future<void> _openCreatePaymentDialog() async {
    if (!_isAdmin) return;

    final amountCtrl = TextEditingController();
    final monthCtrl = TextEditingController(text: DateFormat('yyyy-MM').format(DateTime.now()));
    final playerCtrl = TextEditingController();
    final parentCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create payment'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount')),
              TextField(controller: monthCtrl, decoration: const InputDecoration(labelText: 'Month (YYYY-MM)')),
              TextField(controller: playerCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Player ID (optional)')),
              TextField(controller: parentCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Parent ID (optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );

    if (ok != true) return;

    final montant = double.tryParse(amountCtrl.text.trim()) ?? 0;
    final mois = monthCtrl.text.trim();
    final pid = int.tryParse(playerCtrl.text.trim());
    final paid = int.tryParse(parentCtrl.text.trim());

    final created = await _controller.createPayment(
      montant: montant,
      mois: mois,
      playerId: pid,
      parentId: paid,
    );

    if (!mounted) return;
    showSnack(context, created ? 'Payment created' : 'Create failed');
    if (created) await _loadPayments();
  }

  Future<void> _markAsPaid(Payment payment) async {
    if (!_isAdmin) return;
    if (payment.id == null) return;

    final ok = await _controller.markPaymentAsPaid(payment.id!);
    if (!mounted) return;

    if (ok) {
      showSnack(context, 'Marked as paid.');
      await _loadPayments();
    } else {
      showSnack(context, 'Failed to mark as paid.');
    }
  }

  Future<void> _deletePayment(Payment payment) async {
    if (!_isAdmin) return;
    if (payment.id == null) return;

    final confirmed = await confirmDelete(
      context,
      title: 'Delete Payment',
      message: 'Are you sure you want to delete this payment?',
    );

    if (!confirmed) return;

    final ok = await _controller.deletePayment(payment.id!);
    if (!mounted) return;

    if (ok) {
      showSnack(context, 'Payment deleted');
      await _loadPayments();
    } else {
      showSnack(context, 'Failed to delete payment');
    }
  }

  Widget _buildPaymentTile(Payment p) {
    final fmt = NumberFormat.currency(locale: 'fr', symbol: 'DT ');
    final month = DateFormat('yyyy-MM').format(p.mois);

    return SoftCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: p.isPaid ? Colors.green : Colors.orange,
          child: Icon(p.isPaid ? Icons.check : Icons.pending, color: Colors.white),
        ),
        title: Text('${fmt.format(p.montant)}    $month'),
        subtitle: Text('Player: ${p.playerId ?? '-'}  Parent: ${p.parentId ?? '-'}'),
        trailing: _isAdmin
            ? Wrap(
                spacing: 8,
                children: [
                  if (!p.isPaid)
                    IconButton(
                      tooltip: 'Mark paid',
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                      onPressed: () => _markAsPaid(p),
                    ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _deletePayment(p),
                  ),
                ],
              )
            : Text(p.isPaid ? 'Paid' : 'Pending'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final archiveList = _archivePaymentsFiltered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _openCreatePaymentDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          children: [
            // Search + filters
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search payments',
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _archiveMonth,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All')),
                      ..._recentMonthKeys().map((k) => DropdownMenuItem(value: k, child: Text(k))),
                    ],
                    onChanged: (v) => setState(() => _archiveMonth = v ?? 'all'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _archiveStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                    ],
                    onChanged: (v) => setState(() => _archiveStatus = v ?? 'all'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary
            Text('This month: ${_thisMonthPayments.length}  Paid: ${_paidThisMonth.length}  Unpaid: ${_unpaidThisMonth.length}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            if (archiveList.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: Text('No payments found')),
              )
            else
              ...archiveList.map(_buildPaymentTile),
          ],
        ),
      ),
    );
  }
}


