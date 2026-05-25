import 'participant.dart';

class ConversationSummary {
  final int id;
  final String? title;
  final List<Participant> participants;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime? updatedAt;

  ConversationSummary({
    required this.id,
    this.title,
    required this.participants,
    required this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    this.updatedAt,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) => v is String ? DateTime.tryParse(v) : null;

    final ps = (json['participants'] as List? ?? [])
        .map((e) => Participant.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return ConversationSummary(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString(),
      participants: ps,
      lastMessage: (json['lastMessage'] ?? '').toString(),
      lastMessageAt: parse(json['lastMessageAt']),
      unreadCount: (json['unreadCount'] as num? ?? 0).toInt(),
      updatedAt: parse(json['updatedAt']),
    );
  }
}

extension ConversationSummaryCopy on ConversationSummary {
  ConversationSummary copyWith({
    String? title,
    List<Participant>? participants,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ConversationSummary(
      id: id,
      title: title ?? this.title,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


