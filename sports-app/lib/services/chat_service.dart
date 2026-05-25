import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // renamed to avoid shadowing ApiClient _api
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../components/Constants.dart';
import '../models/chat_message.dart';
import '../models/conversation_summary.dart';
import '../models/chat_contact.dart';
import '../services/ApiService.dart';
import '../services/auth_storage.dart';

/// Real-time chat service (REST + STOMP over native WebSocket).
///
/// IMPORTANT:
/// - Spring exposes a native websocket endpoint at `/ws`.
/// - `StompConfig.sockJS` expects an HTTP(S) URL. Mobile should use native WS.
/// - Therefore we use `StompConfig` with the `ws://` URL (API_WS_BASE_URL).
class ChatService {
  final ApiClient _api = ApiClient();

  StompClient? _client;
  bool _connected = false;

  bool get isConnected => _connected;

  /// Connects the STOMP client and waits for the real handshake.
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
        url: API_WS_BASE_URL, // e.g. ws://10.0.2.2:8091/ws
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        reconnectDelay: const Duration(seconds: 3),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        connectionTimeout: const Duration(seconds: 6),
        onConnect: (StompFrame frame) {
          _connected = true;
          if (!completer.isCompleted) completer.complete();
        },
        onWebSocketError: (dynamic error) {
          _connected = false;
          if (!completer.isCompleted) {
            completer.completeError(Exception('WebSocket error: $error'));
          }
        },
        onStompError: (StompFrame frame) {
          _connected = false;
          if (!completer.isCompleted) {
            completer.completeError(Exception('STOMP error: ${frame.body ?? ''}'));
          }
        },
        onDisconnect: (frame) {
          _connected = false;
        },
      ),
    );

    _client!.activate();

    // Wait for real STOMP handshake
    await completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () {
        _connected = false;
        throw Exception('Chat socket connection timeout');
      },
    );
  }

  void disconnect() {
    _client?.deactivate();
    _connected = false;
  }

  // ---------- helpers ----------
  dynamic _decodeBody(http.Response resp) =>
      jsonDecode(utf8.decode(resp.bodyBytes));

  List<dynamic> _unwrapList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      for (final k in [
        'data',
        'results',
        'content',
        'items',
        'list',
        'messages',
        'conversations'
      ]) {
        final v = decoded[k];
        if (v is List) return v;
      }
    }
    return const [];
  }

  // -------------------- REST --------------------
  Future<List<ConversationSummary>> getConversations() async {
    try {
      debugPrint('[ChatService] Fetching conversations...');
      final resp = await _api.get('/chat/conversations');
      debugPrint('[ChatService] Conversations response: ${resp.statusCode}');
      
      if (resp.statusCode == 200) {
        final decoded = _decodeBody(resp);
        final list = _unwrapList(decoded);
        debugPrint('[ChatService] Successfully loaded ${list.length} conversations');
        return list.map((e) => ConversationSummary.fromJson(e)).toList();
      }
      
      throw Exception('Failed to fetch conversations: ${resp.statusCode}');
    } catch (e) {
      debugPrint('[ChatService] Error fetching conversations: $e');
      rethrow;
    }
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final resp = await _api.get('/chat/conversations/$conversationId/messages');
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      final list = _unwrapList(decoded);
      return list.map((e) => ChatMessage.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch messages: ${resp.statusCode}');
  }

  /// Create (or get) a direct 1:1 conversation.
  Future<int> createDirectConversation(int otherUserId) async {
    final resp = await _api.post('/chat/conversations/direct', body: {
      'otherUserId': otherUserId,
    });
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      return int.parse(data['conversationId'].toString());
    }
    throw Exception('Failed to create direct conversation: ${resp.statusCode}');
  }

  Future<int> contactAdmin({int? academyId}) async {
    final resp = await _api.post('/chat/contact-admin', body: {
      if (academyId != null) 'academyId': academyId,
    });
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      return int.parse(data['conversationId'].toString());
    }
    throw Exception('Failed to contact admin: ${resp.statusCode}');
  }

  Future<List<Map<String, dynamic>>> getScoutingSports() async {
    final resp = await _api.get('/scouting-ai/sports');
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      final list = _unwrapList(decoded);
      return list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    throw Exception('Failed to load sports: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> getScouterAcademyContactList({
    int? sportId,
    String? academyName,
    String orderBy = 'performance',
    int page = 0,
    int size = 20,
  }) async {
    final resp = await _api.get(
      '/scouter/academies/contact-list',
      query: {
        if (sportId != null) 'sportId': sportId,
        if (academyName != null && academyName.trim().isNotEmpty)
          'academyName': academyName.trim(),
        'orderBy': orderBy,
        'page': page,
        'size': size,
      },
    );
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Failed to load academy contacts: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> getScouterAcademyDetail(int academyId) async {
    final resp = await _api.get('/scouter/academies/$academyId/detail');
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Failed to load academy detail: ${resp.statusCode}');
  }

  /// Ensure a division group conversation exists. Returns the conversationId.
  Future<int> ensureDivisionGroup(int divisionId) async {
    final resp =
    await _api.post('/chat/conversations/division/$divisionId', body: {});
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      return int.parse(data['conversationId'].toString());
    }
    throw Exception('Failed to ensure division group: ${resp.statusCode}');
  }

  /// Search contacts (role-scoped).
  Future<List<ChatContact>> searchUsers(String q) async {
    final s = q.trim();
    if (s.length < 2) return [];
    final resp =
    await _api.get('/chat/contacts?q=${Uri.encodeQueryComponent(s)}');
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      final list = _unwrapList(decoded);
      return list
          .map((e) => ChatContact.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to search contacts: ${resp.statusCode}');
  }

  /// Queue a message (direct or group). For group chats, receiverId can be null.
  Future<String> queueMessage({
    required int conversationId,
    int? receiverId,
    required String content,
    required String clientTempId,
    required int senderId,
  }) async {
    final body = <String, dynamic>{
      'content': content,
      'clientTempId': clientTempId,
      'senderId': senderId,
    };
    if (receiverId != null) body['receiverId'] = receiverId;

    final resp = await _api.post(
      '/chat/conversations/$conversationId/messages',
      body: body,
    );

    if (resp.statusCode == 202) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      return data['clientTempId']?.toString() ?? clientTempId;
    }
    throw Exception('Failed to queue message: ${resp.statusCode}');
  }

  Future<void> markAsRead(int conversationId) async {
    final resp = await _api.put(
      '/chat/conversations/$conversationId/read',
      body: {},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to mark as read: ${resp.statusCode}');
    }
  }

  // -------------------- STOMP subscriptions --------------------
  // Safer on mobile: connect-first, then subscribe.
  Future<StompUnsubscribe> subscribeMessages(
      int conversationId, void Function(ChatMessage) onMessage) async {
    if (!_connected) await connect();
    final dest = '/topic/messages/$conversationId';
    return _client!.subscribe(
      destination: dest,
      callback: (frame) {
        if (frame.body == null || frame.body!.isEmpty) return;
        final json = jsonDecode(frame.body!);
        onMessage(ChatMessage.fromJson(json));
      },
    );
  }

  Future<StompUnsubscribe> subscribeConversations(
      int userId, void Function(ConversationSummary) onUpdate) async {
    if (!_connected) await connect();
    final dest = '/topic/conversations/$userId';
    return _client!.subscribe(
      destination: dest,
      callback: (frame) {
        if (frame.body == null || frame.body!.isEmpty) return;
        final json = jsonDecode(frame.body!);
        if (json is Map && json['event'] == 'conversationCreated') return;
        onUpdate(ConversationSummary.fromJson(json));
      },
    );
  }

  /// Role-scoped default contacts (backward compatibility).
  Future<List<ChatContact>> getAllowedContacts() async {
    final resp = await _api.get('/chat/contacts');
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      final list = _unwrapList(decoded);
      return list
          .map((e) => ChatContact.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to load contacts: ${resp.statusCode}');
  }

  /// Get default contacts for PLAYER role.
  /// Returns: Admin, Trainers of their division, Division group chat.
  Future<List<ChatContact>> getPlayerDefaultContacts() async {
    final resp = await _api.get('/chat/contacts?category=player');
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      final list = _unwrapList(decoded);
      return list
          .map((e) => ChatContact.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to load player contacts: ${resp.statusCode}');
  }

  /// Get default contacts for PARENT role.
  /// Returns: All parents group, child division groups, trainers, admin.
  Future<List<ChatContact>> getParentDefaultContacts() async {
    final resp = await _api.get('/chat/contacts?category=parent');
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      final list = _unwrapList(decoded);
      return list
          .map((e) => ChatContact.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to load parent contacts: ${resp.statusCode}');
  }

  /// Get default contacts for TRAINER role.
  /// Returns: Division groups they train, admin, parent groups, scoped search.
  Future<List<ChatContact>> getTrainerDefaultContacts() async {
    final resp = await _api.get('/chat/contacts?category=trainer');
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      final list = _unwrapList(decoded);
      return list
          .map((e) => ChatContact.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to load trainer contacts: ${resp.statusCode}');
  }

  /// Search contacts scoped to trainer's divisions.
  /// Only searches for players and parents in trainer's divisions.
  Future<List<ChatContact>> searchTrainerScopedContacts(String q) async {
    final s = q.trim();
    if (s.length < 2) return [];
    final resp = await _api
      .get('/chat/contacts?category=trainer&q=${Uri.encodeQueryComponent(s)}');
    if (resp.statusCode == 200) {
      final decoded = _decodeBody(resp);
      final list = _unwrapList(decoded);
      return list
          .map((e) => ChatContact.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to search trainer contacts: ${resp.statusCode}');
  }
}

