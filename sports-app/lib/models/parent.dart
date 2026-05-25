class Parent {
  final int id;
  final int userId;
  final String? nom;
  final String? email;
  final String? tel;
  final String? tel2;
  final String? address;

  Parent({
    required this.id,
    required this.userId,
    this.nom,
    this.email,
    this.tel,
    this.tel2,
    this.address,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    final userObj = (json['user'] ?? json['userDto'] ?? json['userDTO']) is Map
        ? Map<String, dynamic>.from(json['user'] ?? json['userDto'] ?? json['userDTO'])
        : null;

    int _toIntReq(dynamic v) => int.parse(v.toString());
    int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

    return Parent(
      id: _toIntReq(json['id']),
      userId: _toInt(json['userId'] ?? userObj?['id']) ?? _toIntReq(json['id']),
      nom: (json['nom'] ?? json['name'] ?? userObj?['nom'] ?? userObj?['name'])?.toString(),
      email: (json['email'] ?? userObj?['email'])?.toString(),
      tel: (json['tel'] ?? json['phone'] ?? userObj?['tel'] ?? userObj?['phone'])?.toString(),
      tel2: json['tel2']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'nom': nom,
        'email': email,
        'tel': tel,
        'tel2': tel2,
        'address': address,
      };
}


