import 'dart:convert';
import '../models/payment.dart';
import 'ApiService.dart';

class PaymentService {
  final ApiClient _api = ApiClient();
  Future<List<Payment>> getAllPayments() async {

    try {
      final response = await _api
          .get('/payments')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => Payment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching payments: $e');
    }
  }

  Future<List<Payment>> getPaymentsForPlayer(int playerId) async {
    try {
      final response = await _api
          .get('/payments/player/$playerId')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => Payment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching payments for player: $e');
    }
  }

  Future<List<Payment>> getPaymentsForParent(int parentId) async {
    try {
      final response = await _api
          .get('/payments/parent/$parentId')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => Payment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching payments for parent: $e');
    }
  }

  Future<Payment?> createPayment(Payment payment) async {
    try {
      final response = await _api
          .post('/payments', body: jsonEncode(payment.toJson()))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Payment.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  Future<Payment?> markAsPaid(int id) async {
    try {
      final response = await _api
          .post('/payments/$id/mark-paid')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Payment.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      throw Exception('Error marking payment paid: $e');
    }
  }

  Future<bool> deletePayment(int id) async {
    try {
      final response = await _api
          .delete('/payments/$id')
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting payment: $e');
    }
  }

  Future<List<Payment>> getOverduePayments() async {
    final response = await _api.get('/payments/overdue');
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Payment.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<Payment>> getPendingPayments() async {
    final response = await _api.get('/payments/pending');
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => Payment.fromJson(json)).toList();
    }
    return [];
  }

  Future<double> getMonthlyRevenue() async {
    final response = await _api.get('/payments/revenue/monthly');
    if (response.statusCode == 200) {
      final map = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final v = map['monthlyRevenue'];
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0.0;
    }
    return 0.0;
  }
}


