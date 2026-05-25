class AcademyInfo {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? description;
  final String? email;
  final String? city;
  final String? country;
  final String? logoUrl;
  final String? sportName;

  AcademyInfo({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.description,
    this.email,
    this.city,
    this.country,
    this.logoUrl,
    this.sportName,
  });

  factory AcademyInfo.fromJson(Map<String, dynamic> json) {
    final sport = json['sport'];
    return AcademyInfo(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(
                    '${json['id'] ?? json['academyId'] ?? json['academy_id']}',
                  ) ??
                  0,
      name:
          (json['name'] ?? json['academyName'] ?? json['nom'] ?? '').toString(),
      address: json['address'],
      phone: json['phone'],
      description: json['description'],
      email: json['email'],
      city: json['city'],
      country: json['country'],
      logoUrl: (json['logoUrl'] ?? json['imageUrl'])?.toString(),
      sportName:
          sport is Map
              ? sport['name']?.toString()
              : json['sportName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'email': email,
      'city': city,
      'country': country,
      'logoUrl': logoUrl,
      'sportName': sportName,
    };
  }
}


