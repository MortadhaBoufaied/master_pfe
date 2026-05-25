class Training {
  final int id;
  final String type;                 // always "TRAINING"
  final String date;                 // yyyy-MM-dd
  final int? divisionId;
  final int? trainerId;

  final String? sessionType;
  final String? objectives;
  final List<int> attendeeIds;

  Training({
    required this.id,
    required this.type,
    required this.date,
    this.divisionId,
    this.trainerId,
    this.sessionType,
    this.objectives,
    this.attendeeIds = const [],
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    List<int> ids(dynamic value) {
      if (value is! List) return const [];
      return value
          .map((item) => int.tryParse(item.toString()))
          .whereType<int>()
          .toList();
    }

    return Training(
      id: json['id'],
      type: json['type'],
      date: json['date'],
      divisionId: json['divisionId'],
      trainerId: json['trainerId'],
      sessionType: json['sessionType'],
      objectives: json['objectives'],
      attendeeIds: ids(json['attendeeIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'date': date,
      'divisionId': divisionId,
      'trainerId': trainerId,
      'sessionType': sessionType,
      'objectives': objectives,
      'attendeeIds': attendeeIds,
    };
  }
}


