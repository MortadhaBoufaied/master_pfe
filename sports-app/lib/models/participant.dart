class Participant {
  final int id;
  final String name;
  final String? email;

  Participant({required this.id, required this.name, this.email});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? 'User').toString(),
      email: json['email']?.toString(),
    );
  }
}


