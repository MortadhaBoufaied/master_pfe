class Player {
  final int id;
  final int userId;
  final int? trainerId;
  final int? parentId;
  final int? divisionId;
  final String? nom;
  final String? email;
  final String? tel;
  final String? dateNaissance;
  final String? nationalite;
  final String? imageUrl;
  final String? position;
  final int? age;
  final double? height;
  final double? weight;
  final String? divisionName;
  final int? number;
  final int? matches;
  final int? goals;
  final int? assists;
  final double? rating;
  final bool? played;
  final int? sportId;
  final String? sportName;
  final int? sportPositionId;
  final String? sportPositionName;

  const Player({
    required this.id,
    required this.userId,
    this.trainerId,
    this.parentId,
    this.divisionId,
    this.nom,
    this.email,
    this.tel,
    this.dateNaissance,
    this.nationalite,
    this.imageUrl,
    this.position,
    this.age,
    this.height,
    this.weight,
    this.divisionName,
    this.number,
    this.matches,
    this.goals,
    this.assists,
    this.rating,
    this.played,
    this.sportId,
    this.sportName,
    this.sportPositionId,
    this.sportPositionName,
  });

  /// Robust JSON parsing: supports both flattened and nested user payloads.
  factory Player.fromJson(Map<String, dynamic> json) {
    final userObj = (json['user'] ?? json['userDto'] ?? json['userDTO']) is Map
        ? Map<String, dynamic>.from(json['user'] ?? json['userDto'] ?? json['userDTO'])
        : null;

    // safer helpers
    int _toIntReq(dynamic v) {
      final s = v?.toString();
      final parsed = int.tryParse(s ?? '');
      if (parsed == null) {
        throw FormatException('Invalid int: $v');
      }
      return parsed;
    }
    int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
    double? _toDouble(dynamic v) => v == null ? null : double.tryParse(v.toString());

    return Player(
      id: _toIntReq(json['id']),
      userId: _toInt(json['userId'] ?? userObj?['id']) ?? _toIntReq(json['id']),
      trainerId: _toInt(json['trainerId']),
      parentId: _toInt(json['parentId']),
      divisionId: _toInt(json['divisionId']),
      nom: (json['nom'] ?? userObj?['nom'] ?? json['name'] ?? userObj?['name'])?.toString(),
      email: (json['email'] ?? userObj?['email'])?.toString(),
      tel: (json['tel'] ?? json['phone'] ?? userObj?['tel'] ?? userObj?['phone'])?.toString(),
      dateNaissance:
      (json['dateNaissance'] ?? json['dateNaiss'] ?? userObj?['dateNaiss'])?.toString(),
      nationalite: (json['nationalite'] ?? json['nationality'])?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      position: json['position']?.toString(),
      age: _toInt(json['age']),
      height: _toDouble(json['height']),
      weight: _toDouble(json['weight']),
      divisionName: json['divisionName']?.toString(),
      number: _toInt(json['number']),
      matches: _toInt(json['matches']),
      goals: _toInt(json['goals']),
      assists: _toInt(json['assists']),
      rating: _toDouble(json['rating'] ?? json['averageRating']),
      played: json['played'] is bool ? json['played'] as bool : null,
      sportId: _toInt(json['sportId'] ?? json['sport']?['id']),
      sportName: (json['sportName'] ?? json['sport']?['name'])?.toString(),
      sportPositionId: _toInt(json['sportPositionId'] ?? json['sportPosition']?['id']),
      sportPositionName:
          (json['sportPositionName'] ?? json['sportPosition']?['name'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'trainerId': trainerId,
    'parentId': parentId,
    'divisionId': divisionId,
    'nom': nom,
    'email': email,
    'tel': tel,
    'dateNaissance': dateNaissance,
    'nationalite': nationalite,
    'imageUrl': imageUrl,
    'position': position,
    'age': age,
    'height': height,
    'weight': weight,
    'divisionName': divisionName,
    'number': number,
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'rating': rating,
    'played': played,
    'sportId': sportId,
    'sportName': sportName,
    'sportPositionId': sportPositionId,
    'sportPositionName': sportPositionName,
  };

  Player copyWith({
    int? id,
    int? userId,
    int? trainerId,
    int? parentId,
    int? divisionId,
    String? nom,
    String? email,
    String? tel,
    String? dateNaissance,
    String? nationalite,
    String? imageUrl,
    String? position,
    int? age,
    double? height,
    double? weight,
    String? divisionName,
    int? number,
    int? matches,
    int? goals,
    int? assists,
    double? rating,
    bool? played,
    int? sportId,
    String? sportName,
    int? sportPositionId,
    String? sportPositionName,
  }) {
    return Player(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainerId: trainerId ?? this.trainerId,
      parentId: parentId ?? this.parentId,
      divisionId: divisionId ?? this.divisionId,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      tel: tel ?? this.tel,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      nationalite: nationalite ?? this.nationalite,
      imageUrl: imageUrl ?? this.imageUrl,
      position: position ?? this.position,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      divisionName: divisionName ?? this.divisionName,
      number: number ?? this.number,
      matches: matches ?? this.matches,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      rating: rating ?? this.rating,
      played: played ?? this.played,
      sportId: sportId ?? this.sportId,
      sportName: sportName ?? this.sportName,
      sportPositionId: sportPositionId ?? this.sportPositionId,
      sportPositionName: sportPositionName ?? this.sportPositionName,
    );
  }
}


