class Conversation {
  final int id;
  final List<int> participantIds;
  final String? createdAt;

  Conversation({
    required this.id,
    required this.participantIds,
    this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participantIds: json['participantIds'] != null
          ? List<int>.from(json['participantIds'])
          : [],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'createdAt': createdAt,
    };
  }
}


