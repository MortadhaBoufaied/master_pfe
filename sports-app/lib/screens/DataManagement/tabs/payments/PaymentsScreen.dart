import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/payment.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/payment_service.dart';
import '../../../../components/ui_kit.dart';

class PaymentsScreen extends StatefulWidget {
  final int playerId;
  final bool allowCreate;

  const PaymentsScreen({
    Key? key,
    required this.playerId,
    this.allowCreate = true,
  }) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentService _paymentService = PaymentService();
  final AuthService _authService = AuthService();

  List<Payment> _payments = [];
  bool _loading = true;
  String? _error;
  double _monthlyRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _ensureLoggedInOrRedirect() async {
    final loggedIn = await _authService.checkAuthentication();
    if (!loggedIn) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Not authenticated'),
            content: const Text('You must be logged in to view payments.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _ensureLoggedInOrRedirect();
      final list = await _paymentService.getPaymentsForPlayer(widget.playerId);
      final revenue = await _paymentService.getMonthlyRevenue();

      setState(() {
        _payments = list;
        _monthlyRevenue = revenue;
      });
    } catch (e, st) {
      debugPrint('Error loading payments: $e\n$st');
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime d) {
    try {
      return DateFormat('yyyy-MM-dd').format(d);
    } catch (_) {
      return d.toIso8601String();
    }
  }

  Widget _buildItem(Payment p) {
    final overdue = (!p.isPaid) &&
        p.mois.isBefore(DateTime(DateTime.now().year, DateTime.now().month, 1));

    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: EdgeInsets.zero,
      child: ListTile(
        title: Text('Amount: ${p.montant.toStringAsFixed(2)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Month: ${_formatDate(p.mois)}'),
            if (p.playerId != null) Text('Player ID: ${p.playerId}'),
            if (p.parentId != null) Text('Parent ID: ${p.parentId}'),
            if (overdue)
              const Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Text(
                  'OVERDUE',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            if (!p.isPaid)
              ElevatedButton(
                onPressed: () => _handleMarkAsPaid(p),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Mark Paid'),
              ),
            Text(
              p.isPaid ? 'Paid' : 'Pending',
              style: TextStyle(
                  color: p.isPaid ? Colors.green : Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMarkAsPaid(Payment payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Mark payment ${payment.id ?? ''} of ${payment.montant} as paid?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final updated = await _paymentService.markAsPaid(payment.id!);

      if (updated == null) {
        throw Exception("Server returned null payment.");
      }

      /// ---------------- FIXED LOGIC ----------------
      setState(() {
        _payments = _payments.map((p) {
          return p.id == updated.id ? updated : p;
        }).toList();
      });
      /// ----------------------------------------------

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment marked as paid')));
    } catch (e) {
      debugPrint('markAsPaid error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to mark payment: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _showCreatePaymentDialog() async {
    final montantController = TextEditingController();
    DateTime selectedMonth =
    DateTime(DateTime.now().year, DateTime.now().month, 1);
    final parentIdController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Payment'),
        content: StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: montantController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                TextField(
                  controller: parentIdController,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: 'Parent ID (optional)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Month: '),
                    Text(_formatDate(selectedMonth)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showMonthPicker(
                            context: context, initialDate: selectedMonth);
                        if (picked != null) {
                          setState(() {
                            selectedMonth =
                                DateTime(picked.year, picked.month, 1);
                          });
                        }
                      },
                      child: const Text('Choose'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create')),
        ],
      ),
    );

    if (result != true) return;

    final montantText = montantController.text.trim();
    if (montantText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Amount is required')));
      return;
    }

    final montant = double.tryParse(montantText);
    if (montant == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }

    final parentId = int.tryParse(parentIdController.text.trim());

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final newPayment = Payment(
        montant: montant,
        mois: selectedMonth,
        playerId: widget.playerId,
        parentId: parentId,
      );

      final created = await _paymentService.createPayment(newPayment);

      if (created != null) {
        setState(() {
          _payments.insert(0, created);
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment created')));
    } catch (e) {
      debugPrint('createPayment error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Create payment failed: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<DateTime?> showMonthPicker({
    required BuildContext context,
    required DateTime initialDate,
  }) async {
    DateTime chosen = initialDate;
    int selectedYear = initialDate.year;
    int selectedMonth = initialDate.month;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select month'),
        content: StatefulBuilder(builder: (c, setState) {
          return SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(
                      10, (i) => DateTime.now().year - 5 + i)
                      .map((y) =>
                      DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => selectedYear = v ?? selectedYear),
                ),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(12, (i) => i + 1)
                      .map((m) =>
                      DropdownMenuItem(value: m, child: Text('$m')))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => selectedMonth = v ?? selectedMonth),
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                chosen = DateTime(selectedYear, selectedMonth, 1);
                Navigator.of(context).pop(true);
              },
              child: const Text('OK')),
        ],
      ),
    );

    if (ok == true) return chosen;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.transparent,
      appBar: AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
        title: Text('Payments for player ${widget.playerId}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
        ],
      ),
      floatingActionButton: widget.allowCreate
          ? FloatingActionButton(
        onPressed: _showCreatePaymentDialog,
        child: const Icon(Icons.add),
        tooltip: 'Create Payment',
      )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
              child: SoftCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: Text(
                      'Monthly Revenue: ${_monthlyRevenue.toStringAsFixed(2)}'),
                  subtitle:
                  const Text('From backend /payments/revenue/monthly'),
                ),
              ),
            ),
            if (_payments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('No payments found',
                    textAlign: TextAlign.center),
              )
            else
              ..._payments.map(_buildItem).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}


