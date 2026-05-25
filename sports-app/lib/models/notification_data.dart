class NotificationData {
  final int id;
  final int userId;
  final int? campaignId;
  final int? createdBy;
  final String title;
  final String content;
  final String? contentHtml;
  final String? senderName;
  final String? category;
  final String createdAt;
  final String? readAt;
  final bool readStatus;

  NotificationData({
    required this.id,
    required this.userId,
    this.campaignId,
    this.createdBy,
    this.title = '',
    required this.content,
    this.contentHtml,
    this.senderName,
    this.category,
    required this.createdAt,
    this.readAt,
    required this.readStatus,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    bool toBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = (v ?? '').toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    final title = (json['title'] ?? '').toString();
    final content = (json['content'] ?? '').toString();
    return NotificationData(
      id: toInt(json['id']),
      userId: toInt(json['userId'] ?? json['user_id']),
      campaignId: json['campaignId'] != null || json['campaign_id'] != null
          ? toInt(json['campaignId'] ?? json['campaign_id'])
          : null,
      createdBy: json['createdBy'] != null || json['created_by'] != null
          ? toInt(json['createdBy'] ?? json['created_by'])
          : null,
      title: title,
      content: content,
      contentHtml: json['contentHtml']?.toString() ?? json['content_html']?.toString(),
      senderName: json['senderName']?.toString() ?? json['sender_name']?.toString(),
      category: json['category']?.toString(),
      createdAt: (json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()).toString(),
      readAt: json['readAt']?.toString() ?? json['read_at']?.toString(),
      readStatus: toBool(json['readStatus'] ?? json['isRead'] ?? json['read']),
    );
  }

  NotificationData copyWith({
    int? id,
    int? userId,
    int? campaignId,
    int? createdBy,
    String? title,
    String? content,
    String? contentHtml,
    String? senderName,
    String? category,
    String? createdAt,
    String? readAt,
    bool? readStatus,
  }) {
    return NotificationData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      campaignId: campaignId ?? this.campaignId,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      content: content ?? this.content,
      contentHtml: contentHtml ?? this.contentHtml,
      senderName: senderName ?? this.senderName,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      readStatus: readStatus ?? this.readStatus,
    );
  }

  String get preview {
    final merged = [
      if (title.trim().isNotEmpty) title.trim(),
      if (content.trim().isNotEmpty) content.trim(),
    ].join('\n');
    return merged.trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'campaignId': campaignId,
      'createdBy': createdBy,
      'title': title,
      'content': content,
      'contentHtml': contentHtml,
      'senderName': senderName,
      'category': category,
      'createdAt': createdAt,
      'readAt': readAt,
      'readStatus': readStatus,
    };
  }
}


