import 'package:shared_preferences/shared_preferences.dart';

class FirstLoginStore {
  static const String _prefix = 'first_login_done_';

  static Future<bool> isDone(int? userId) async {
    if (userId == null || userId <= 0) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$userId') ?? false;
  }

  static Future<void> markDone(int? userId) async {
    if (userId == null || userId <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$userId', true);
  }

  static Future<bool> shouldShow(int? userId) async {
    if (userId == null || userId <= 0) return false;
    return !(await isDone(userId));
  }
}


