enum UnifiedActivityType { training, match }

class UnifiedActivity {
  final UnifiedActivityType type;
  final int id;
  final String date; // yyyy-MM-dd
  final String title;
  final String? location;
  final int? trainerId;
  final int? divisionId;
  final String? meta;

  const UnifiedActivity({
    required this.type,
    required this.id,
    required this.date,
    required this.title,
    this.location,
    this.trainerId,
    this.divisionId,
    this.meta,
  });
}


