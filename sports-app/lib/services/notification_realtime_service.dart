import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../components/Constants.dart';
import '../models/notification_campaign_stats.dart';
import '../models/notification_data.dart';
import 'auth_storage.dart';

class NotificationRealtimeService {
  StompClient? _client;
  bool _connected = false;

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_connected) return;

    final token = await AuthStorage.getAccessToken();
    final completer = Completer<void>();
    final headers = <String, String>{};
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    _client = StompClient(
      config: StompConfig(
        url: API_WS_BASE_URL,
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        reconnectDelay: const Duration(seconds: 3),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        connectionTimeout: const Duration(seconds: 6),
        onConnect: (_) {
          _connected = true;
          if (!completer.isCompleted) completer.complete();
        },
        onWebSocketError: (dynamic error) {
          _connected = false;
          if (!completer.isCompleted) {
            completer.completeError(Exception('Notification socket error: $error'));
          }
        },
        onStompError: (frame) {
          _connected = false;
          if (!completer.isCompleted) {
            completer.completeError(Exception('Notification STOMP error: ${frame.body ?? ''}'));
          }
        },
        onDisconnect: (_) {
          _connected = false;
        },
      ),
    );

    _client!.activate();

    await completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () {
        _connected = false;
        throw Exception('Notification socket connection timeout');
      },
    );
  }

  void disconnect() {
    _client?.deactivate();
    _connected = false;
  }

  Future<StompUnsubscribe> subscribeNotifications(
    int userId,
    void Function(NotificationData) onNotification,
  ) async {
    if (!_connected) await connect();
    return _client!.subscribe(
      destination: '/topic/notifications/$userId',
      callback: (frame) {
        if (frame.body == null || frame.body!.isEmpty) return;
        final json = jsonDecode(frame.body!);
        if (json is Map<String, dynamic>) {
          onNotification(NotificationData.fromJson(json));
        } else if (json is Map) {
          onNotification(NotificationData.fromJson(Map<String, dynamic>.from(json)));
        }
      },
    );
  }

  Future<StompUnsubscribe> subscribeUnreadCount(
    int userId,
    void Function(int count) onCount,
  ) async {
    if (!_connected) await connect();
    return _client!.subscribe(
      destination: '/topic/notification-count/$userId',
      callback: (frame) {
        if (frame.body == null || frame.body!.isEmpty) return;
        final json = jsonDecode(frame.body!);
        if (json is Map) {
          final raw = json['unreadCount'];
          final count = raw is int ? raw : int.tryParse(raw.toString()) ?? 0;
          onCount(count);
        }
      },
    );
  }

  Future<StompUnsubscribe> subscribeCampaignStats(
    int userId,
    void Function(NotificationCampaignStats stats) onStats,
  ) async {
    if (!_connected) await connect();
    return _client!.subscribe(
      destination: '/topic/notification-stats/$userId',
      callback: (frame) {
        if (frame.body == null || frame.body!.isEmpty) return;
        final json = jsonDecode(frame.body!);
        if (json is Map<String, dynamic>) {
          onStats(NotificationCampaignStats.fromJson(json));
        } else if (json is Map) {
          onStats(NotificationCampaignStats.fromJson(Map<String, dynamic>.from(json)));
        }
      },
    );
  }
}


