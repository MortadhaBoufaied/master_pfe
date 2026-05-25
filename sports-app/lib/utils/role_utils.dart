import '../controllers/session_controller.dart';
import '../models/role.dart';

class UserRoleUtil {
  static Role get currentRole => AppSession.instance.session.role;

  static bool isSuperAdmin() => currentRole == Role.superAdmin;
  static bool isAdmin() => currentRole == Role.admin || isSuperAdmin();
  static bool isTrainer() => currentRole == Role.trainer;
  static bool isParent() => currentRole == Role.parent;
  static bool isPlayer() => currentRole == Role.player;
  static bool isScouter() => currentRole == Role.scouter;

  static Future<bool> canEdit() async => isAdmin() || isTrainer();
  static Future<bool> canDelete() async => isAdmin();
}


