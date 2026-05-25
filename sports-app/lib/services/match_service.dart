import 'dart:convert';
import 'package:flutter/cupertino.dart';

import 'ApiService.dart';
import '../models/match.dart';

class MatchService {
  final ApiClient _api = ApiClient();


  Future<List<MatchModel>> getAll() async {
    try {
      final resp = await _api.get('/matches');
      if (resp.statusCode != 200) {
        final body = utf8.decode(resp.bodyBytes);
        throw Exception('Failed to fetch matches: ${resp.statusCode} - $body');
      }
      final decoded = json.decode(utf8.decode(resp.bodyBytes));
      final list = _extractList(decoded);

      final out = <MatchModel>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            out.add(MatchModel.fromJson(item));
          } catch (e, st) {
            debugPrint('[MatchService] MatchModel.fromJson failed: $e\n$st\nItem: $item');
          }
        } else {
          debugPrint('[MatchService] Non-map item in matches list: $item');
        }
      }
      return out;
    } catch (e, st) {
      debugPrint('[MatchService] getAll failed: $e');
      debugPrint('[MatchService] Stack:\n$st');
      rethrow;
    }
  }

  /// Handles wrapped payloads: {data|results|content|items|list|matches}
  List<dynamic> _extractList(dynamic body) {
    if (body == null) return const [];
    dynamic b = body;

    if (b is String) {
      try { b = json.decode(b); } catch (_) { return const []; }
    }

    if (b is List) return b;

    if (b is Map) {
      final candidates = [
        b['data'], b['results'], b['content'], b['items'], b['list'], b['matches']
      ];
      for (final c in candidates) {
        if (c is List) return c;
        if (c is Map && c['list'] is List) return c['list'] as List;
      }
    }
    return const [];
  }

  Future<MatchModel?> create(Map<String,dynamic> body) async {
    final r= await _api.post('/matches', body: jsonEncode(body));
    if(r.statusCode==200||r.statusCode==201){
      return MatchModel.fromJson(jsonDecode(r.body));
    }
    return null;
  }
  Future<MatchModel?> update(int id, Map<String,dynamic> body) async {
    final r= await _api.put('/matches/$id', body: jsonEncode(body));
    if(r.statusCode==200){
      return MatchModel.fromJson(jsonDecode(r.body));
    }
    return null;
  }
  Future<bool> delete(int id) async {
    final r= await _api.delete('/matches/$id');
    return r.statusCode==200 || r.statusCode==204;
  }
}


