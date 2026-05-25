/// Unified ChatMessage model used by BOTH:
/// - Chatbot (role/content/time/meta)
/// - Real chat (id/conversationId/senderId/receiverId/content/timestamp/read/clientTempId)
///
/// This keeps the old API working (ChatMessage.user/bot + getters role/time/meta)
/// while supporting the new Messenger-like chat implementation.
class ChatMessage {
  // ---- Real chat fields ----
  final int? id;
  final int conversationId;
  final int senderId;
  final int? receiverId;
  final DateTime timestamp;
  final bool read;
  final String? clientTempId;

  // ---- Chatbot/legacy fields ----
  final String? _role; // 'user' or 'bot'
  final DateTime? _time; // legacy alias
  final Map<String, dynamic>? _meta;

  // Common
  final String content;

  ChatMessage({
    // chat
    this.id = 0,
    this.conversationId = 0,
    this.senderId = 0,
    this.receiverId,
    DateTime? timestamp,
    this.read = false,
    this.clientTempId,

    // chatbot
    String? role,
    DateTime? time,
    Map<String, dynamic>? meta,

    // common
    required this.content,
  })  : timestamp = timestamp ?? DateTime.now(),
        _role = role,
        _time = time,
        _meta = meta;

  // ----------------------------
  // Backward compatible API
  // ----------------------------

  /// Old chatbot usage: ChatMessage.user('hi')
  factory ChatMessage.user(String content, {Map<String, dynamic>? meta}) =>
      ChatMessage(role: 'user', content: content, time: DateTime.now(), meta: meta);

  /// Old chatbot usage: ChatMessage.bot('hello')
  factory ChatMessage.bot(String content, {Map<String, dynamic>? meta}) =>
      ChatMessage(role: 'bot', content: content, time: DateTime.now(), meta: meta);

  /// Getter expected by old chatbot UI.
  String get role {
    if (_role != null) return _role!;
    // For real chat messages, infer role if meta provides currentUserId
    final currentUserId = _meta?['currentUserId'];
    if (currentUserId != null) {
      final me = int.tryParse(currentUserId.toString());
      if (me != null && senderId == me) return 'user';
      return 'bot';
    }
    // Fallback: if senderId is set => treat as user
    return senderId > 0 ? 'user' : 'bot';
  }

  /// Getter expected by old chatbot UI.
  DateTime get time => _time ?? timestamp;

  /// Getter expected by old chatbot UI.
  Map<String, dynamic>? get meta {
    if (_meta != null) return _meta;
    // Provide a useful default meta for real chat
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'clientTempId': clientTempId,
      'read': read,
    };
  }

  // ----------------------------
  // JSON
  // ----------------------------

  /// Supports BOTH JSON shapes:
  /// - Chatbot: {role, content, time, meta}
  /// - Chat: {id, conversationId, senderId, receiverId, content, timestamp, read, clientTempId}
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Chatbot shape
    if (json.containsKey('role') || json.containsKey('time')) {
      final t = json['time'];
      DateTime parsedTime;
      if (t is String) {
        parsedTime = DateTime.tryParse(t) ?? DateTime.now();
      } else if (t is int) {
        parsedTime = DateTime.fromMillisecondsSinceEpoch(t);
      } else if (t is DateTime) {
        parsedTime = t;
      } else {
        parsedTime = DateTime.now();
      }

      final metaRaw = json['meta'];
      final metaMap = metaRaw is Map ? Map<String, dynamic>.from(metaRaw) : null;

      return ChatMessage(
        role: (json['role'] ?? 'bot').toString(),
        content: (json['content'] ?? '').toString(),
        time: parsedTime,
        meta: metaMap,
      );
    }

    // Chat shape
    final ts = json['timestamp'];
    DateTime parsedTs;
    if (ts is String) {
      parsedTs = DateTime.tryParse(ts) ?? DateTime.now();
    } else if (ts is int) {
      parsedTs = DateTime.fromMillisecondsSinceEpoch(ts);
    } else {
      parsedTs = DateTime.now();
    }

    return ChatMessage(
      id: (json['id'] as num? ?? 0).toInt(),
      conversationId: (json['conversationId'] as num? ?? 0).toInt(),
      senderId: (json['senderId'] as num? ?? 0).toInt(),
      receiverId: json['receiverId'] == null ? null : (json['receiverId'] as num).toInt(),
      content: (json['content'] ?? '').toString(),
      timestamp: parsedTs,
      read: (json['read'] ?? json['isRead'] ?? false) as bool,
      clientTempId: json['clientTempId']?.toString(),
      meta: json['meta'] is Map ? Map<String, dynamic>.from(json['meta']) : null,
    );
  }

  /// Default serialization for REAL chat API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'clientTempId': clientTempId,
    };
  }

  /// Optional legacy serialization (chatbot/local UI).
  Map<String, dynamic> toLegacyJson() {
    return {
      'role': role,
      'content': content,
      'time': time.toIso8601String(),
      if (meta != null) 'meta': meta,
    };
  }
}


