class Trainer {
  final int? id;
  final int? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? dob;
  final String? region;
  final String? specialty;
  final String? experience;
  final String? license;
  final String? notes;
  final List<String>? images;
  final int? divisionId;

  Trainer({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.dob,
    this.region,
    this.specialty,
    this.experience,
    this.license,
    this.notes,
    this.images,
    this.divisionId,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    // accept nested user variants
    final userObj = (json['user'] ?? json['userDto'] ?? json['userDTO']) is Map
        ? Map<String, dynamic>.from(json['user'] ?? json['userDto'] ?? json['userDTO'])
        : null;

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    List<String>? _toStringList(dynamic v) {
      if (v is List) {
        return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      return null;
    }

    return Trainer(
      id: _toInt(json['id'] ?? userObj?['id']),
      userId: _toInt(json['userId'] ?? userObj?['id']),
      name: (json['name'] ?? json['nom'] ?? userObj?['nom'] ?? userObj?['name'])?.toString(),
      email: (json['email'] ?? userObj?['email'])?.toString(),
      phone: (json['phone'] ?? json['tel'] ?? userObj?['tel'] ?? userObj?['phone'])?.toString(),
      dob: (json['dob'] ?? userObj?['dateNaiss'] ?? userObj?['dob'])?.toString(),
      region: (json['region'] ?? userObj?['region'])?.toString(),
      specialty: (json['specialty'] ?? json['speciality'] ?? json['specialite'])?.toString(),
      experience: json['experience']?.toString(),
      license: json['license']?.toString(),
      notes: json['notes']?.toString(),
      images: _toStringList(json['images'] ?? json['imageUrl']),
      divisionId: _toInt(json['divisionId'] ?? json['division_id'] ?? (json['division'] is Map ? (json['division']['id']) : null)),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> m = {};
    if (id != null) m['id'] = id;
    if (userId != null) m['userId'] = userId;
    if (name != null) m['name'] = name;
    if (email != null) m['email'] = email;
    if (phone != null) m['phone'] = phone;
    if (dob != null) m['dob'] = dob;
    if (region != null) m['region'] = region;
    if (specialty != null) m['specialty'] = specialty;
    if (experience != null) m['experience'] = experience;
    if (license != null) m['license'] = license;
    if (notes != null) m['notes'] = notes;
    if (images != null) m['images'] = images;
    if (divisionId != null) m['divisionId'] = divisionId;
    return m;
  }
}


