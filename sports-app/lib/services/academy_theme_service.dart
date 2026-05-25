import 'dart:convert';

import '../models/academy_theme.dart';
import 'ApiService.dart';

class AcademyThemeService {
  final ApiClient _api = ApiClient();

  Future<AcademyTheme?> getCurrentTheme() async {
    final response = await _api.get('/theme/current');
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return AcademyTheme.fromJson(decoded);
    }
    if (decoded is Map) {
      return AcademyTheme.fromJson(Map<String, dynamic>.from(decoded));
    }
    return null;
  }
}


