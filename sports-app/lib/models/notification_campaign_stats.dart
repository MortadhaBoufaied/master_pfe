class NotificationCampaignStats {
  final int id;
  final int? academyId;
  final int? createdBy;
  final String title;
  final String contentPreview;
  final String targetingMode;
  final String audienceSummary;
  final String? senderName;
  final String? category;
  final int totalRecipients;
  final int readCount;
  final int unreadCount;
  final double readPercentage;
  final String createdAt;

  NotificationCampaignStats({
    required this.id,
    this.academyId,
    this.createdBy,
    required this.title,
    required this.contentPreview,
    required this.targetingMode,
    required this.audienceSummary,
    this.senderName,
    this.category,
    required this.totalRecipients,
    required this.readCount,
    required this.unreadCount,
    required this.readPercentage,
    required this.createdAt,
  });

  factory NotificationCampaignStats.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    double toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return NotificationCampaignStats(
      id: toInt(json['id']),
      academyId: json['academyId'] != null ? toInt(json['academyId']) : null,
      createdBy: json['createdBy'] != null ? toInt(json['createdBy']) : null,
      title: (json['title'] ?? '').toString(),
      contentPreview: (json['contentPreview'] ?? '').toString(),
      targetingMode: (json['targetingMode'] ?? '').toString(),
      audienceSummary: (json['audienceSummary'] ?? '').toString(),
      senderName: json['senderName']?.toString(),
      category: json['category']?.toString(),
      totalRecipients: toInt(json['totalRecipients']),
      readCount: toInt(json['readCount']),
      unreadCount: toInt(json['unreadCount']),
      readPercentage: toDouble(json['readPercentage']),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }

  NotificationCampaignStats copyWith({
    int? id,
    int? academyId,
    int? createdBy,
    String? title,
    String? contentPreview,
    String? targetingMode,
    String? audienceSummary,
    String? senderName,
    String? category,
    int? totalRecipients,
    int? readCount,
    int? unreadCount,
    double? readPercentage,
    String? createdAt,
  }) {
    return NotificationCampaignStats(
      id: id ?? this.id,
      academyId: academyId ?? this.academyId,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      contentPreview: contentPreview ?? this.contentPreview,
      targetingMode: targetingMode ?? this.targetingMode,
      audienceSummary: audienceSummary ?? this.audienceSummary,
      senderName: senderName ?? this.senderName,
      category: category ?? this.category,
      totalRecipients: totalRecipients ?? this.totalRecipients,
      readCount: readCount ?? this.readCount,
      unreadCount: unreadCount ?? this.unreadCount,
      readPercentage: readPercentage ?? this.readPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


