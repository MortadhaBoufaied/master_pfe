import 'dart:convert';

import 'ApiService.dart';

class AcademyRanking {
  final int academyId;
  final String academyName;
  final String sportName;
  final String city;
  final String country;
  final int rankingPosition;
  final double overallScore;
  final double mlScore;
  final double confidence;
  final String tier;
  final String explanation;
  final String mainStrengths;
  final String mainWeaknesses;
  final int observationsCount;
  final double playerProgressionScore;

  const AcademyRanking({
    required this.academyId,
    required this.academyName,
    required this.sportName,
    required this.city,
    required this.country,
    required this.rankingPosition,
    required this.overallScore,
    required this.mlScore,
    required this.confidence,
    required this.tier,
    required this.explanation,
    required this.mainStrengths,
    required this.mainWeaknesses,
    required this.observationsCount,
    required this.playerProgressionScore,
  });

  factory AcademyRanking.fromJson(Map<String, dynamic> json) {
    return AcademyRanking(
      academyId: _toInt(json['academyId']),
      academyName: _text(json['academyName'], 'Academy'),
      sportName: _text(json['sportName'], ''),
      city: _text(json['city'], ''),
      country: _text(json['country'], ''),
      rankingPosition: _toInt(json['rankingPosition'] ?? json['rank']),
      overallScore: _toDouble(json['overallScore']),
      mlScore: _toDouble(json['mlScore'] ?? json['overallScore']),
      confidence: _toDouble(json['confidence']),
      tier: _text(json['tier'], 'Developing'),
      explanation: _text(
        json['explanation'],
        'Academy ranking calculated from backend performance data.',
      ),
      mainStrengths: _text(json['mainStrengths'], ''),
      mainWeaknesses: _text(json['mainWeaknesses'], ''),
      observationsCount: _toInt(json['observationsCount']),
      playerProgressionScore: _toDouble(json['playerProgressionScore']),
    );
  }
}

class AcademyRankingService {
  final ApiClient _api;

  AcademyRankingService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  Future<List<AcademyRanking>> getTopAcademies({int limit = 5}) async {
    final response = await _api.get(
      '/academy-rankings/top',
      query: {'limit': limit},
    );

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Academy rankings failed: ${response.statusCode}');
    }

    final items =
        decoded is Map ? decoded['items'] : decoded is List ? decoded : const [];
    if (items is! List) return const [];

    return items
        .whereType<Map>()
        .map((item) => AcademyRanking.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}

String _text(dynamic value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
