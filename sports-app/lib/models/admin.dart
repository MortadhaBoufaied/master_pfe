class Admin {
  final int id;
  final int userId;

  final String? responsibility;

  Admin({
    required this.id,
    required this.userId,
    this.responsibility,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      userId: json['userId'],
      responsibility: json['responsibility'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'responsibility': responsibility,
    };
  }
}


