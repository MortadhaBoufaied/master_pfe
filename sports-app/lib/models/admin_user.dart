class AdminUser {
  final int id;
  final String nom;
  final String email;
  final String? mainRole;
  final String? responsibility;

  const AdminUser({
    required this.id,
    required this.nom,
    required this.email,
    this.mainRole,
    this.responsibility,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] ?? 0) is int ? (json['id'] ?? 0) : int.tryParse('${json['id']}') ?? 0,
      nom: (json['nom'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      mainRole: (json['mainRole'] ?? json['role'] ?? json['userRole'])?.toString(),
      responsibility: (json['responsibility'])?.toString(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      if (mainRole != null) 'mainRole': mainRole,
      // responsibility is managed by the academy-admins endpoint
    };
  }
}
