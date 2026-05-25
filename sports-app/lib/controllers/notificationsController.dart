import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/notification_data.dart';
import '../services/notification_realtime_service.dart';
import '../services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  final NotificationRealtimeService _realtime = NotificationRealtimeService();

  List<NotificationData> notifications = [];
  bool isLoading = false;
  String? error;
  int unreadCount = 0;

  StompUnsubscribe? _notificationSub;
  StompUnsubscribe? _countSub;
  int? _subscribedUserId;

  Future<void> loadNotifications() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      notifications = await _service.getNotifications();
      unreadCount = await _service.getUnreadCount();
      _sortNotifications();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startRealtime({required int userId}) async {
    if (_subscribedUserId == userId &&
        _notificationSub != null &&
        _countSub != null &&
        _realtime.isConnected) {
      return;
    }

    await stopRealtime();

    try {
      await _realtime.connect();
      _notificationSub = await _realtime.subscribeNotifications(userId, _handleRealtimeNotification);
      _countSub = await _realtime.subscribeUnreadCount(userId, (count) {
        unreadCount = count;
        notifyListeners();
      });
      _subscribedUserId = userId;
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopRealtime() async {
    _notificationSub?.call();
    _countSub?.call();
    _notificationSub = null;
    _countSub = null;
    _subscribedUserId = null;
    _realtime.disconnect();
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      final index = notifications.indexWhere((item) => item.id == notificationId);
      if (index >= 0 && !notifications[index].readStatus) {
        notifications[index] = notifications[index].copyWith(
          readStatus: true,
          readAt: DateTime.now().toIso8601String(),
        );
        unreadCount = notifications.where((item) => !item.readStatus).length;
        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<NotificationData?> openNotification(NotificationData notification) async {
    if (!notification.readStatus) {
      await markAsRead(notification.id);
      final index = notifications.indexWhere((item) => item.id == notification.id);
      if (index >= 0) {
        return notifications[index];
      }
    }
    return notification;
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      for (int i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(
          readStatus: true,
          readAt: DateTime.now().toIso8601String(),
        );
      }
      unreadCount = 0;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _service.deleteNotification(notificationId);
      notifications.removeWhere((item) => item.id == notificationId);
      unreadCount = notifications.where((item) => !item.readStatus).length;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void addNotification(NotificationData notification) {
    _upsert(notification);
    notifyListeners();
  }

  Future<void> sendPaymentReminder(int userId, String message) async {
    try {
      await _service.sendPaymentReminder(userId, message);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendActivityReminder(int userId, String activityTitle, DateTime date) async {
    try {
      await _service.sendActivityReminder(userId, activityTitle, date);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void _handleRealtimeNotification(NotificationData notification) {
    _upsert(notification);
    notifyListeners();
  }

  void _upsert(NotificationData notification) {
    final index = notifications.indexWhere((item) => item.id == notification.id);
    if (index >= 0) {
      notifications[index] = notification;
    } else {
      notifications.insert(0, notification);
    }
    unreadCount = notifications.where((item) => !item.readStatus).length;
    _sortNotifications();
  }

  void _sortNotifications() {
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void dispose() {
    stopRealtime();
    super.dispose();
  }
}


