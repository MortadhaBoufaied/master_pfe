class ScoutingPlayerCard {
  final int playerExternalId;
  final String fullName;
  final String? position;
  final int? age;
  final String? divisionName;
  final String? academyName;
  final String? sportName;
  final String? positionGroup;
  final double potentialScore;
  final double scoutingOpportunityScore;
  final double rolePerformanceIndex;
  final double roleFitScore;
  final double progressionVelocity;
  final double churnRisk;
  final String trendLabel;
  final double avgRating;
  final double goalsPerMatch;
  final double assistsPerMatch;
  final double attendanceRatio;
  final double? shortlistScore;

  const ScoutingPlayerCard({
    required this.playerExternalId,
    required this.fullName,
    required this.position,
    required this.age,
    required this.divisionName,
    this.academyName,
    this.sportName,
    this.positionGroup,
    required this.potentialScore,
    required this.scoutingOpportunityScore,
    required this.rolePerformanceIndex,
    required this.roleFitScore,
    required this.progressionVelocity,
    required this.churnRisk,
    required this.trendLabel,
    required this.avgRating,
    required this.goalsPerMatch,
    required this.assistsPerMatch,
    required this.attendanceRatio,
    required this.shortlistScore,
  });

  factory ScoutingPlayerCard.fromJson(Map<String, dynamic> json) {
    return ScoutingPlayerCard(
      playerExternalId: _toInt(
        json['player_external_id'] ?? json['playerExternalId'] ?? json['playerId'],
      ),
      fullName: (json['full_name'] ?? json['fullName'] ?? json['playerName'] ?? 'Unknown').toString(),
      position: (json['position']?.toString()),
      age: _toNullableInt(json['age']),
      divisionName: (json['division_name'] ?? json['divisionName'])?.toString(),
      academyName: (json['academyName'] ?? json['academy_name'])?.toString(),
      sportName: (json['sport'] ?? json['sportName'] ?? json['sport_name'])?.toString(),
      positionGroup: (json['positionGroup'] ?? json['position_group'])?.toString(),
      potentialScore: _toDouble(json['potential_score'] ?? json['potentialScore']),
      scoutingOpportunityScore: _toDouble(json['scouting_opportunity_score'] ?? json['scoutingOpportunityScore']),
      rolePerformanceIndex: _toDouble(json['role_performance_index'] ?? json['rolePerformanceIndex']),
      roleFitScore: _toDouble(json['role_fit_score'] ?? json['roleFitScore']),
      progressionVelocity: _toDouble(json['progression_velocity'] ?? json['progressionVelocity']),
      churnRisk: _toDouble(json['churn_risk'] ?? json['churnRisk']),
      trendLabel: (json['trend_label'] ?? json['trendLabel'] ?? json['progression'] ?? '-').toString(),
      avgRating: _toDouble(json['avg_rating'] ?? json['avgRating'] ?? json['rating']),
      goalsPerMatch: _toDouble(json['goals_per_match'] ?? json['goalsPerMatch']),
      assistsPerMatch: _toDouble(json['assists_per_match'] ?? json['assistsPerMatch']),
      attendanceRatio: _toDouble(json['attendance_ratio'] ?? json['attendanceRatio']),
      shortlistScore: _toNullableDouble(json['shortlist_score'] ?? json['shortlistScore']),
    );
  }
}

class ScoutingSearchResult {
  final int total;
  final List<ScoutingPlayerCard> items;

  const ScoutingSearchResult({required this.total, required this.items});

  factory ScoutingSearchResult.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return ScoutingSearchResult(
      total: _toInt(json['total']),
      items: rawItems
          .whereType<Map>()
          .map((e) => ScoutingPlayerCard.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ScoutingCompareResult {
  final List<ScoutingPlayerCard> players;
  final Map<String, int> highlights;

  const ScoutingCompareResult({
    required this.players,
    required this.highlights,
  });

  factory ScoutingCompareResult.fromJson(Map<String, dynamic> json) {
    final rawPlayers = (json['players'] as List?) ?? const [];
    final rawHighlights = (json['highlights'] as Map?) ?? const {};

    return ScoutingCompareResult(
      players: rawPlayers
          .whereType<Map>()
          .map((e) => ScoutingPlayerCard.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      highlights: rawHighlights.map(
        (key, value) => MapEntry(key.toString(), _toInt(value)),
      ),
    );
  }
}

class ScoutingShortlistResult {
  final String title;
  final String strategy;
  final DateTime? generatedAt;
  final int total;
  final List<ScoutingPlayerCard> players;

  const ScoutingShortlistResult({
    required this.title,
    required this.strategy,
    required this.generatedAt,
    required this.total,
    required this.players,
  });

  factory ScoutingShortlistResult.fromJson(Map<String, dynamic> json) {
    final rawPlayers = (json['players'] as List?) ?? const [];

    return ScoutingShortlistResult(
      title: (json['title'] ?? 'Shortlist').toString(),
      strategy: (json['strategy'] ?? 'balanced').toString(),
      generatedAt: _toDateTime(json['generated_at'] ?? json['generatedAt']),
      total: _toInt(json['total']),
      players: rawPlayers
          .whereType<Map>()
          .map((e) => ScoutingPlayerCard.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  return _toInt(value, fallback: 0);
}

double _toDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  return _toDouble(value, fallback: 0.0);
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

