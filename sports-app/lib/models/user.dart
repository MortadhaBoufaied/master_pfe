class User {
  final int id;
  final String nom;
  final String? dateNaiss;
  final String? tel;
  final String email;
  final String? mdp;              // password coming as "mdp"
  final String mainRole;          // ENUM string
  final List<String> roles;
  final String? photoFileId;
  final int? trainerId;
  final int? parentId;
  final int? divisionId;

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.mainRole,
    required this.roles,
    this.dateNaiss,
    this.tel,
    this.mdp,
    this.photoFileId,
    this.trainerId,
    this.parentId,
    this.divisionId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      mainRole: json['mainRole'] ?? '',
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : [],
      dateNaiss: json['dateNaiss'],
      tel: json['tel'],
      mdp: json['mdp'],
      photoFileId: json['photoFileId'],
      trainerId: json['trainerId'],
      parentId: json['parentId'],
      divisionId: json['divisionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'mainRole': mainRole,
      'roles': roles,
      'dateNaiss': dateNaiss,
      'tel': tel,
      'mdp': mdp,
      'photoFileId': photoFileId,
      'trainerId': trainerId,
      'parentId': parentId,
      'divisionId': divisionId,
    };
  }
}


