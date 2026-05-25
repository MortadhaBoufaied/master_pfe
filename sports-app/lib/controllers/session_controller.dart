import 'package:flutter/foundation.dart';

import '../models/current_user.dart';
import '../models/role.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';

/// Loads the current user from storage and optionally refreshes from the server.
///
/// Single source of truth for identity, role, role-specific ids, and contact
/// information used across role dashboards and profile screens.
class SessionController extends ChangeNotifier {
  CurrentUser? _user;

  CurrentUser? get user => _user;

  Future<void> loadFromStorage() async {
    final raw = await AuthStorage.getUser();
    if (raw != null) {
      _user = CurrentUser.fromJson(raw);
      notifyListeners();

      if (_user?.role == Role.unknown) {
        try {
          await refreshFromServer();
        } catch (_) {}
      }
    }
  }

  Future<void> refreshFromServer() async {
    final raw = await AuthService().fetchCurrentUserFromServer();
    if (raw != null) {
      _user = CurrentUser.fromJson(raw);
      notifyListeners();
    }
  }

  Role get role => _user?.role ?? Role.unknown;

  String get displayName => _user?.nom ?? _user?.email ?? 'User';

  int? get userId => _user?.id;

  String? get email => _user?.email ?? _user?.raw?['email']?.toString();

  String? get phone =>
      _user?.raw?['tel']?.toString() ?? _user?.raw?['phone']?.toString();

  int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

  int? get playerId =>
      _toInt(_user?.raw?['playerId'] ?? _user?.raw?['player_id']);

  int? get parentId =>
      _toInt(_user?.raw?['parentId'] ?? _user?.raw?['parent_id']);

  int? get trainerId =>
      _toInt(_user?.raw?['trainerId'] ?? _user?.raw?['trainer_id']);

  int? get divisionId =>
      _toInt(_user?.raw?['divisionId'] ?? _user?.raw?['division_id']);

  void clear() {
    _user = null;
    notifyListeners();
  }
}

class AppSession {
  AppSession._();

  static final AppSession instance = AppSession._();

  final SessionController session = SessionController();
}


