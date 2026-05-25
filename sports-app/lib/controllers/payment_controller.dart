import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentController extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  List<Payment> payments = [];
  bool isLoading = false;
  String? error;
  double monthlyRevenue = 0.0;

  Future<void> fetchAllPayments() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      payments = await _service.getAllPayments();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Compatibility alias for older UI code (calls the new method).
  Future<void> getAllPayments() => fetchAllPayments();

  Future<void> fetchPaymentsForPlayer(int playerId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      payments = await _service.getPaymentsForPlayer(playerId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPayment({
    required double montant,
    required String mois, // expects 'YYYY-MM'
    int? playerId,
    int? parentId,
  }) async {
    try {
      final payment = Payment(
        montant: montant,
        mois: DateTime.parse('$mois-01'),
        playerId: playerId,
        parentId: parentId,
        isPaid: false,
      );

      final created = await _service.createPayment(payment);
      if (created != null) {
        payments.add(created);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  ///  Single "mark paid" method (updates local list)
  Future<bool> markPaymentAsPaid(int id) async {
    try {
      final updated = await _service.markAsPaid(id);
      if (updated != null) {
        final idx = payments.indexWhere((p) => p.id == id);
        if (idx >= 0) {
          payments[idx] = updated;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchOverduePayments() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      payments = await _service.getOverduePayments();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyRevenue() async {
    try {
      monthlyRevenue = await _service.getMonthlyRevenue();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      final allPayments = await _service.getAllPayments();

      final totalRevenue = allPayments
          .where((p) => p.isPaid)
          .fold(0.0, (sum, p) => sum + p.montant);

      final pendingRevenue = allPayments
          .where((p) => !p.isPaid)
          .fold(0.0, (sum, p) => sum + p.montant);

      final paidCount = allPayments
          .where((p) => p.isPaid)
          .length;
      final unpaidCount = allPayments
          .where((p) => !p.isPaid)
          .length;

      final totalCount = allPayments.length;
      final paymentRate =
      totalCount == 0 ? 0 : ((paidCount / totalCount) * 100).round();

      return {
        'totalRevenue': totalRevenue,
        'pendingRevenue': pendingRevenue,
        'paidCount': paidCount,
        'unpaidCount': unpaidCount,
        'totalCount': totalCount,
        'payment_rate': paymentRate,
      };
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return {};
    }
  }

  Future<bool> deletePayment(int id) async {
    try {
      final ok = await _service.deletePayment(id);
      if (ok) {
        payments.removeWhere((p) => p.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}


