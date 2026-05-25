import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/app_background.dart';
import '../../components/ui_kit.dart';
import '../../controllers/session_controller.dart';
import '../../l10n/app_strings.dart';
import '../../models/payment.dart';
import '../../models/role.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';

class UserPaymentsScreen extends StatefulWidget {
  const UserPaymentsScreen({super.key});

  @override
  State<UserPaymentsScreen> createState() => _UserPaymentsScreenState();
}

class _UserPaymentsScreenState extends State<UserPaymentsScreen> {
  final PaymentService _service = PaymentService();

  bool _loading = true;
  String? _error;
  List<Payment> _items = [];

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
      final session = AppSession.instance.session;
      final playerId = session.playerId;
      final parentId = session.parentId;

      if (session.role == Role.parent && parentId != null) {
        _items = await _service.getPaymentsForParent(parentId);
      } else if (playerId != null) {
        _items = await _service.getPaymentsForPlayer(playerId);
      } else if (session.role == Role.admin ||
          session.role == Role.superAdmin) {
        _items = await _service.getAllPayments();
      } else {
        _items = [];
      }
      _items.sort((a, b) => b.mois.compareTo(a.mois));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pay(Payment p) async {
    final t = AppStrings.of(context);
    if (p.id == null) return;
    try {
      await _service.markAsPaid(p.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t.tr('paid')} ')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final locale = Localizations.localeOf(context).toString();
    final money = NumberFormat.currency(
      locale: locale,
      symbol: 'DT',
      decimalDigits: 2,
    );
    final unpaid = _items.where((p) => !p.isPaid).toList();
    final paidCount = _items.length - unpaid.length;
    final unpaidTotal = unpaid.fold<double>(0, (sum, p) => sum + p.montant);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(t.tr('payments')),
        ),

        body:
            _loading
                ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.teal),
                )
                : _error != null
                ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
                : _items.isEmpty
                ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 90),
                    Icon(
                      Icons.payments_outlined,
                      size: 72,
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.92),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        t.tr('empty'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
                : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    itemCount: _items.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return _summaryCard(
                          money.format(unpaidTotal),
                          paidCount,
                          unpaid.length,
                        );
                      }

                      final p = _items[i - 1];
                      final paid = p.isPaid;
                      final monthLabel = DateFormat('yyyy-MM').format(p.mois);

                      return SoftCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: (paid ? Colors.green : Colors.orange)
                                    .withOpacity(0.14),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                paid ? Icons.check_circle : Icons.pending,
                                color: paid ? Colors.green : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${money.format(p.montant)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (paid
                                                  ? Colors.green
                                                  : Colors.orange)
                                              .withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          paid ? t.tr('paid') : t.tr('unpaid'),
                                          style: TextStyle(
                                            color:
                                                paid
                                                    ? Colors.green
                                                    : Colors.orange,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _chip(
                                        '${t.tr('date')}: $monthLabel',
                                        Icons.calendar_today,
                                      ),
                                      if (p.playerId != null)
                                        _chip(
                                          'Child account ${p.playerId}',
                                          Icons.person,
                                        ),
                                      if (p.parentId != null &&
                                          AppSession.instance.session.role !=
                                              Role.parent)
                                        _chip(
                                          'Parent account ${p.parentId}',
                                          Icons.family_restroom,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!paid)
                              ElevatedButton(
                                onPressed: () => _pay(p),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.teal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(t.tr('pay_now')),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }

  Widget _summaryCard(String unpaidTotal, int paidCount, int unpaidCount) {
    final cs = Theme.of(context).colorScheme;
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.teal.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.receipt_long, color: AppTheme.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outstanding balance',
                  style: TextStyle(color: cs.onSurface.withOpacity(0.68)),
                ),
                const SizedBox(height: 3),
                Text(
                  unpaidTotal,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('$unpaidCount unpaid', Icons.pending_actions),
                    _chip('$paidCount paid', Icons.verified),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.92,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.teal),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}


