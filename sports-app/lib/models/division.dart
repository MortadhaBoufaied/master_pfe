import 'package:moez_project/models/trainer.dart';

import 'player.dart';

class Division {
  final int id;
  final String nom;
  final String categorie;
  final int? playersCount;
  final int? coachesCount;
  final double? averageAge;
  final List<Player>? players;
  final List<Trainer>? trainers;

  const Division({
    required this.id,
    required this.nom,
    required this.categorie,
    this.playersCount,
    this.coachesCount,
    this.averageAge,
    this.players,
    this.trainers,
  });

  factory Division.fromJson(Map<String, dynamic> json) {
    final trainersJson = json['trainers'];
    final playersJson = json['players'];
    return Division(
      id: (json['id'] ?? 0) is int ? (json['id'] ?? 0) : int.tryParse('${json['id']}') ?? 0,
      nom: (json['nom'] ?? json['name'] ?? '').toString(),
      categorie: (json['categorie'] ?? json['category'] ?? '').toString(),
      playersCount: json['playerCount'] is int ? json['playerCount'] : int.tryParse('${json['playerCount']}'),
      averageAge: json['averageAge'] is num ? (json['averageAge'] as num).toDouble() : double.tryParse('${json['averageAge']}'),
      players: playersJson is List
          ? playersJson.map((e) => Player.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      trainers: trainersJson is List
          ? trainersJson.map((e) => Trainer.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'categorie': categorie,
      if (playersCount != null) 'playerCount': playersCount,
      if (coachesCount != null) 'coachesCount': coachesCount,
      if (averageAge != null) 'averageAge': averageAge,
      if (players != null) 'players': players!.map((p) => p.toJson()).toList(),
      if (trainers != null) 'trainers': trainers!.map((p) => p.toJson()).toList(),
    };
  }
}


