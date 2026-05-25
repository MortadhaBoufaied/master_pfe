import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart' show StompUnsubscribe;

import '../models/chat_contact.dart';
import '../models/chat_message.dart';
import '../models/conversation_summary.dart';
import '../models/role.dart';
import '../services/chat_service.dart';

/// Chat state controller (Messenger-like):
/// - Conversations list with live updates
/// - Contact search (searches ALL users)
/// - Thread view with live messages
/// - Supports 1:1 and division group chats
///
/// Singleton pattern: use `ChatController()` to ensure single instance across the app.
class ChatController extends ChangeNotifier {
  static ChatController? _instance;

  factory ChatController({ChatService? service}) {
    _instance ??= ChatController._internal(service: service);
    return _instance!;
  }

  ChatController._internal({ChatService? service})
    : _service = service ?? ChatService();

  final ChatService _service;

  int? currentUserId;
  int? currentDivisionId;
  Role? currentUserRole;

  // Conversations
  List<ConversationSummary> conversations = [];
  List<ConversationSummary> filtered = [];
  String _lastConversationQuery = '';

  // Contacts search
  List<ChatContact> contacts = [];
  bool contactsLoading = false;

  // Current thread
  int? activeConversationId;
  List<ChatMessage> messages = [];

  bool loading = false;
  bool isBootstrapped = false;
  String? error;

  // STOMP unsubscribe callbacks
  StompUnsubscribe? _convUnsub;
  StompUnsubscribe? _msgUnsub;
  Map<int, StompUnsubscribe> _convDetailUnsub = {};

  bool get isReady => currentUserId != null;

  ConversationSummary? findConversationById(int conversationId) {
    try {
      return conversations.firstWhere((c) => c.id == conversationId);
    } catch (_) {
      return null;
    }
  }

  Future<void> bootstrap({
    required int userId,
    int? divisionId,
    Role? userRole,
  }) async {
    // Skip if already bootstrapped with same user
    if (isBootstrapped && currentUserId == userId) {
      return;
    }

    currentUserId = userId;
    currentDivisionId = divisionId;
    currentUserRole = userRole ?? Role.unknown;

    loading = true;
    error = null;
    notifyListeners();

    try {
      await _service.connect();

      // Ensure division group exists (if user has a division)
      if (divisionId != null && divisionId > 0) {
        try {
          await _service.ensureDivisionGroup(divisionId);
        } catch (_) {
          // do not block chat if group creation fails
        }
      }

      // Load conversations and contacts in parallel for instant display
      await Future.wait([
        refreshConversations(),
        loadAllowedContacts(),
      ], eagerError: true);

      // Subscribe for live conversation list updates
      _convUnsub?.call();
      _convUnsub = await _service.subscribeConversations(
        userId,
        (update) => _upsertConversation(update),
      );

      // Subscribe to real-time updates for each conversation to catch new messages
      for (final conv in conversations) {
        _subscribeToConversationMessages(conv.id);
      }

      isBootstrapped = true;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Subscribe to individual conversation messages for real-time updates.
  /// This allows messages to appear instantly without opening the conversation.
  Future<void> _subscribeToConversationMessages(int convId) async {
    if (_convDetailUnsub.containsKey(convId)) return;
    try {
      final unsub = await _service.subscribeMessages(convId, (m) {
        // Update messages in active thread
        if (activeConversationId == convId) {
          _upsertMessage(m);
        }
        // Update conversation preview in list
        _updateConversationMessage(convId, m.content);
      });
      _convDetailUnsub[convId] = unsub;
    } catch (_) {
      // Silent fail - message subscription not critical
    }
  }

  Future<void> disposeController() async {
    _convUnsub?.call();
    _msgUnsub?.call();

    // Unsubscribe from all conversation detail subscriptions
    for (final unsub in _convDetailUnsub.values) {
      unsub.call();
    }
    _convDetailUnsub.clear();

    _service.disconnect();
  }

  Future<void> refreshConversations() async {
    try {
      if (kDebugMode) {
        debugPrint('[ChatController] Refreshing conversations...');
      }
      final list = await _service.getConversations();
      _sortConversationsByLatestActivity(list);
      conversations = list;
      filterConversations(_lastConversationQuery);
      error = null;
      if (kDebugMode) {
        debugPrint('[ChatController] Conversations refreshed successfully');
      }
    } catch (e) {
      error = 'Failed to load conversations: $e';
      if (kDebugMode) {
        debugPrint('[ChatController] Error refreshing conversations: $e');
      }
      notifyListeners();
      rethrow; // Allow pull-to-refresh to show error
    }
  }

  void filterConversations(String q) {
    final s = q.trim().toLowerCase();
    _lastConversationQuery = s;

    if (s.isEmpty) {
      filtered = List.of(conversations);
    } else {
      filtered =
          conversations.where((c) {
            final title = (c.title ?? '').toLowerCase();
            final last = c.lastMessage.toLowerCase();
            final names = c.participants
                .map((p) => p.name.toLowerCase())
                .join(' ');
            return title.contains(s) || last.contains(s) || names.contains(s);
          }).toList();
    }

    _sortConversationsByLatestActivity(filtered);
    notifyListeners();
  }

  /// Load role-based allowed contacts with role-specific optimizations.
  Future<void> loadAllowedContacts() async {
    contactsLoading = true;
    error = null;
    notifyListeners();
    try {
      List<ChatContact> res;

      // Use role-specific endpoints if available for instant loading
      switch (currentUserRole) {
        case Role.player:
          res = await _service.getPlayerDefaultContacts();
          break;
        case Role.parent:
          res = await _service.getParentDefaultContacts();
          break;
        case Role.trainer:
          res = await _service.getTrainerDefaultContacts();
          break;
        case Role.scouter:
          // Scouter uses broad contact scope like admin.
          res = await _service.getAllowedContacts();
          break;
        default:
          // Admin and unknown roles use generic contacts
          res = await _service.getAllowedContacts();
      }

      contacts = res.where((u) => u.id != currentUserId).toList();
    } catch (e) {
      error = e.toString();
      contacts = [];
    } finally {
      contactsLoading = false;
      notifyListeners();
    }
  }

  /// Search users with trainer scope if applicable.
  Future<void> searchUsers(String q) async {
    final s = q.trim();
    if (s.isEmpty) {
      await loadAllowedContacts();
      return;
    }
    contactsLoading = true;
    notifyListeners();
    try {
      final res =
          currentUserRole == Role.trainer
              ? await _service.searchTrainerScopedContacts(s)
              : await _service.searchUsers(s);
      // exclude myself
      contacts = res.where((u) => u.id != currentUserId).toList();
    } catch (e) {
      // keep silent but store error
      error = e.toString();
    } finally {
      contactsLoading = false;
      notifyListeners();
    }
  }

  /// Start/open a direct conversation with a user.
  Future<int?> openDirectWith(int otherUserId) async {
    try {
      final id = await _service.createDirectConversation(otherUserId);
      await refreshConversations();
      await loadAllowedContacts();
      return id;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<int?> contactAdmin({int? academyId}) async {
    try {
      final id = await _service.contactAdmin(academyId: academyId);
      await refreshConversations();
      return id;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Open a conversation thread.
  Future<void> openConversation(int conversationId) async {
    if (currentUserId == null) return;

    activeConversationId = conversationId;
    loading = true;
    error = null;
    notifyListeners();

    try {
      // load messages
      messages = await _service.getMessages(conversationId);

      // Ensure this conversation also has the background list subscription.
      await _subscribeToConversationMessages(conversationId);

      // subscribe for live messages
      _msgUnsub?.call();
      _msgUnsub = await _service.subscribeMessages(conversationId, (m) {
        _upsertMessage(m);
        _updateConversationMessage(conversationId, m.content);
      });

      // mark as read
      await _service.markAsRead(conversationId);
      // update local unread
      final idx = conversations.indexWhere((c) => c.id == conversationId);
      if (idx >= 0) {
        conversations[idx] = conversations[idx].copyWith(unreadCount: 0);
        filterConversations(_lastConversationQuery);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Send a message in the active conversation.
  Future<void> sendMessage({required String content}) async {
    final me = currentUserId;
    final cid = activeConversationId;
    if (me == null || cid == null) return;

    final text = content.trim();
    if (text.isEmpty) return;

    // infer receiver for direct chats (first participant != me)
    final ConversationSummary? conv =
        conversations.cast<ConversationSummary?>().firstWhere(
          (c) => c != null && c.id == cid,
          orElse: () => null,
        ) ??
        filtered.cast<ConversationSummary?>().firstWhere(
          (c) => c != null && c.id == cid,
          orElse: () => null,
        );
    if (conv == null) return;

    int? receiverId;
    if (conv.participants.length == 2) {
      for (final participant in conv.participants) {
        if (participant.id != me) {
          receiverId = participant.id;
          break;
        }
      }
    }

    final tmpId = _clientTempId();

    // optimistic insert
    final optimistic = ChatMessage(
      id: null,
      conversationId: cid,
      senderId: me,
      receiverId: receiverId,
      content: text,
      timestamp: DateTime.now(),
      read: true,
      clientTempId: tmpId,
    );
    messages.add(optimistic);
    _touchConversationPreview(cid, text);
    notifyListeners();

    try {
      await _service.queueMessage(
        conversationId: cid,
        receiverId: receiverId,
        content: text,
        clientTempId: tmpId,
        senderId: me,
      );
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // -------------------- helpers --------------------
  // -------------------- helpers --------------------
  void _upsertConversation(ConversationSummary update) {
    final idx = conversations.indexWhere((c) => c.id == update.id);
    if (idx >= 0) {
      conversations[idx] = update;
    } else {
      conversations.insert(0, update);
      // Subscribe to new conversation messages
      _subscribeToConversationMessages(update.id);
    }

    _sortConversationsByLatestActivity(conversations);
    filterConversations(_lastConversationQuery);
  }

  /// Update a message in the active thread (de-duplicated).
  void _upsertMessage(ChatMessage m) {
    int existingIndex = messages.indexWhere(
      (x) =>
          (x.id != null && m.id != null && x.id == m.id) ||
          (x.clientTempId != null &&
              m.clientTempId != null &&
              x.clientTempId == m.clientTempId),
    );

    if (existingIndex < 0) {
      final now = DateTime.now();
      existingIndex = messages.indexWhere((x) {
        if (x.id != null) return false;
        if (x.senderId != m.senderId) return false;
        if (x.content.trim() != m.content.trim()) return false;
        final dt = (x.timestamp.difference(m.timestamp)).inSeconds.abs();
        final dt2 = (x.timestamp.difference(now)).inSeconds.abs();
        return dt <= 3 || dt2 <= 3;
      });
    }

    if (existingIndex >= 0) {
      messages[existingIndex] = m;
    } else {
      messages.add(m);
    }
    notifyListeners();
  }

  /// Update conversation preview when new message arrives.
  void _updateConversationMessage(int convId, String content) {
    final idx = conversations.indexWhere((c) => c.id == convId);
    if (idx < 0) return;

    final now = DateTime.now();
    conversations[idx] = conversations[idx].copyWith(
      lastMessage: content,
      lastMessageAt: now,
      updatedAt: now,
    );

    _sortConversationsByLatestActivity(conversations);
    filterConversations(_lastConversationQuery);
  }

  void _touchConversationPreview(int conversationId, String last) {
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx >= 0) {
      final now = DateTime.now();
      conversations[idx] = conversations[idx].copyWith(
        lastMessage: last,
        lastMessageAt: now,
        updatedAt: now,
      );
      _sortConversationsByLatestActivity(conversations);
      filterConversations(_lastConversationQuery);
    }
  }

  void _sortConversationsByLatestActivity(List<ConversationSummary> list) {
    list.sort((a, b) {
      final ad = a.updatedAt ?? a.lastMessageAt;
      final bd = b.updatedAt ?? b.lastMessageAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
  }

  String _clientTempId() {
    final r = Random();
    final ms = DateTime.now().millisecondsSinceEpoch;
    return 'tmp_${ms}_${r.nextInt(1 << 31)}';
  }
}

