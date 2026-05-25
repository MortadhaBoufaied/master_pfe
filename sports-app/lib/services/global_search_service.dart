import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'ApiService.dart';
import '../models/global_search_result.dart';

class GlobalSearchService {
  final ApiClient _api = ApiClient();

  Future<List<GlobalSearchResult>> search(String q) async {
    final query = q.trim();
    if (query.isEmpty) return [];

    final r = await _api.get('/search?q=${Uri.encodeQueryComponent(query)}');
    if (r.statusCode != 200) {
      debugPrint('Global search failed: ${r.statusCode} ${r.body}');
      return [];
    }

    final decoded = jsonDecode(r.body);
    if (decoded is List) {
      return decoded
          .map((e) => GlobalSearchResult.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (decoded is Map) {
      final payload = decoded['results'] ?? decoded['data'] ?? decoded['content'];
      if (payload is List) {
        return payload
            .map((e) => GlobalSearchResult.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    return [];
  }
}


