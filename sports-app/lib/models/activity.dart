class Activity {
  final int id;
  final int? trainerId;
  final String titre;        // backend: required
  final String? description; // backend: optional
  final String date;         // backend LocalDate -> String yyyy-MM-dd
  final String? lieu;        // place

  Activity({
    required this.id,
    this.trainerId,
    required this.titre,
    this.description,
    required this.date,
    this.lieu,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      trainerId: json['trainerId'],
      titre: json['titre'] ?? '',
      description: json['description'],
      date: json['date'], // should be yyyy-MM-dd
      lieu: json['lieu'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'titre': titre,
      'description': description,
      'date': date,
      'lieu': lieu,
    };
  }
}


