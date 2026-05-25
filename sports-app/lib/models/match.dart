import 'package:flutter/foundation.dart';

class MatchModel {
  final int id;
  final String type;      // e.g. "MATCH" (default if missing)
  final String date;      // normalized 'YYYY-MM-DD' ('' if unknown)
  final int? divisionId;
  final int? trainerId;

  final String opponent;  // defaults to 'Unknown'
  final String location;  // defaults to 'Unknown'
  final String result;    // 'Win'|'Loss'|'Draw'|'Unknown'
  final String score;     // defaults to ''

  MatchModel({
    required this.id,
    required this.type,
    required this.date,
    this.divisionId,
    this.trainerId,
    required this.opponent,
    required this.location,
    required this.result,
    required this.score,
  });

  // ----------------- helpers -----------------

  static int _intRequired(dynamic v, {String field = 'id'}) {
    final parsed = int.tryParse(v?.toString() ?? '');
    if (parsed == null) {
      throw FormatException("Invalid int for '$field': $v");
    }
    return parsed;
  }

  static int? _intOrNull(dynamic v) => v == null ? null : int.tryParse(v.toString());
  static String _strOr(dynamic v, String fallback) => v == null ? fallback : v.toString();

  static String _normalizeDate(dynamic v) {
    if (v == null) return '';
    if (v is DateTime) {
      final y = v.year.toString().padLeft(4, '0');
      final m = v.month.toString().padLeft(2, '0');
      final d = v.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    final s = v.toString().trim();
    if (s.isEmpty) return '';
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) return s;
    if (RegExp(r'^\d{4}-\d{2}$').hasMatch(s)) return '$s-01';
    final epoch = int.tryParse(s);
    if (epoch != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true).toLocal();
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    final parts = s.split(RegExp(r'[T ]'));
    final maybeDate = parts.isNotEmpty ? parts.first : s;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(maybeDate)) return maybeDate;
    return '';
  }

  static String _normalizeResult(String raw) {
    final r = raw.toLowerCase();
    if (r.contains('win'))  return 'Win';
    if (r.contains('loss')) return 'Loss';
    if (r.contains('draw')) return 'Draw';
    return 'Unknown';
  }

  // ----------------- parsing -----------------

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    // Some APIs nest the object under 'match'
    final src = json['match'] is Map ? Map<String, dynamic>.from(json['match']) : json;

    final id       = _intRequired(src['id'], field: 'id');
    final type     = _strOr(src['type'], 'MATCH');
    final date     = _normalizeDate(src['date'] ?? src['matchDate'] ?? src['day']);
    final result   = _normalizeResult(_strOr(src['result'], 'Unknown'));
    final opponent = _strOr(src['opponent'] ?? src['versus'] ?? src['team'], 'Unknown');
    final location = _strOr(src['location'] ?? src['stadium'] ?? src['place'], 'Unknown');
    final score    = _strOr(src['score'] ?? src['finalScore'] ?? src['ft'], '');

    return MatchModel(
      id: id,
      type: type,
      date: date,
      divisionId: _intOrNull(src['divisionId'] ?? src['division']),
      trainerId:  _intOrNull(src['trainerId']  ?? src['coachId']),
      opponent: opponent,
      location: location,
      result: result,
      score: score,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'date': date,
    'divisionId': divisionId,
    'trainerId': trainerId,
    'opponent': opponent,
    'location': location,
    'result': result,
    'score': score,
  };
}


