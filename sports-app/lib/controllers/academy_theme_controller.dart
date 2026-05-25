import 'package:flutter/foundation.dart';

import '../models/academy_theme.dart';
import '../services/academy_theme_service.dart';

class AcademyThemeController extends ChangeNotifier {
  AcademyThemeController({AcademyThemeService? service})
    : _service = service ?? AcademyThemeService();

  final AcademyThemeService _service;
  AcademyTheme _theme = AcademyTheme.fallback;
  bool _loading = false;
  bool _hasLoaded = false;
  String? _error;

  AcademyTheme get theme => _theme;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (!force && _hasLoaded) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _service.getCurrentTheme();
      if (loaded != null) _theme = loaded;
      _hasLoaded = true;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _theme = AcademyTheme.fallback;
    _hasLoaded = false;
    _error = null;
    notifyListeners();
  }
}

class AppAcademyTheme {
  AppAcademyTheme._();

  static final AppAcademyTheme instance = AppAcademyTheme._();

  final AcademyThemeController controller = AcademyThemeController();
}


