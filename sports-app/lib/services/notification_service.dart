import 'dart:convert';

import '../models/notification_campaign_stats.dart';
import '../models/notification_data.dart';
import 'ApiService.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  Future<List<NotificationData>> getNotifications() async {
    try {
      final response = await _api.get('/notifications');
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((item) => NotificationData.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
        if (decoded is Map && decoded['data'] is List) {
          final list = (decoded['data'] as List)
              .whereType<Map>()
              .map((item) => NotificationData.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          return list;
        }
        return [];
      }
      if (response.statusCode == 404) return [];
      throw Exception('Failed to load notifications: ${response.statusCode}');
    } catch (_) {
      return _getMockNotifications();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _api.put('/notifications/$notificationId/read');
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.put('/notifications/read-all');
    } catch (_) {}
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _api.delete('/notifications/$notificationId');
    } catch (_) {}
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get('/notifications/count');
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map) {
          final raw = decoded['unreadCount'];
          if (raw is int) return raw;
          return int.tryParse(raw?.toString() ?? '') ?? 0;
        }
      }
    } catch (_) {}
    return 0;
  }

  Future<List<NotificationCampaignStats>> getCampaigns({bool mineOnly = false}) async {
    final response = await _api.get('/admin/notifications/campaigns', query: {
      'mineOnly': mineOnly,
    });
    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => NotificationCampaignStats.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      if (decoded is Map && decoded['data'] is List) {
        return (decoded['data'] as List)
            .whereType<Map>()
            .map((item) => NotificationCampaignStats.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    throw Exception('Failed to load notification campaigns: ${response.statusCode}');
  }

  Future<NotificationCampaignStats> getCampaignStats(int campaignId) async {
    final response = await _api.get('/admin/notifications/campaigns/$campaignId');
    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is Map) {
        return NotificationCampaignStats.fromJson(Map<String, dynamic>.from(decoded));
      }
    }
    throw Exception('Failed to load campaign stats: ${response.statusCode}');
  }

  /// Backward compatible: some UI passes a free-form message.
  Future<void> sendPaymentReminder(int userId, String messageOrMonth) async {
    try {
      await _api.post('/notifications/payment-reminder', body: {
        'userId': userId,
        'message': messageOrMonth,
        'paymentMonth': messageOrMonth,
      });
    } catch (_) {}
  }

  /// Backward compatible:
  /// - old UI: (userId, activityTitle, date)
  /// - other flows: (userId, activityTitle)
  Future<void> sendActivityReminder(int userId, String activityTitle, [DateTime? date]) async {
    try {
      await _api.post('/notifications/activity-reminder', body: {
        'userId': userId,
        'activityTitle': activityTitle,
        if (date != null) 'date': date.toIso8601String(),
      });
    } catch (_) {}
  }

  List<NotificationData> _getMockNotifications() {
    return [
      NotificationData(
        id: 1,
        userId: 1,
        content: 'Welcome to Sports Academy Pro!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        readStatus: true,
      ),
      NotificationData(
        id: 2,
        userId: 1,
        content: 'Your payment for October is due',
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        readStatus: false,
      ),
      NotificationData(
        id: 3,
        userId: 1,
        content: 'Training session scheduled for tomorrow',
        createdAt: DateTime.now().toIso8601String(),
        readStatus: false,
      ),
    ];
  }


/// Admin advanced notification sending.
/// contentHtml supports limited HTML tags (<b>, <u>, <span style="color:#RRGGBB">).
Future<Map<String, dynamic>> sendTargeted({
  required String title,
  required String contentHtml,
  required Map<String, dynamic> targeting,
}) async {
  final body = <String, dynamic>{
    'title': title,
    'contentHtml': contentHtml,
    'targeting': targeting,
  };
  final resp = await _api.post('/admin/notifications/targeted', body: body);
  if (resp.statusCode >= 200 && resp.statusCode < 300) {
    final decoded = json.decode(utf8.decode(resp.bodyBytes));
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  throw Exception('Failed to send targeted notification: ${resp.statusCode}');
}

}


