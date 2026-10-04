import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';

  Future<void> setLoginState({
    required bool isLoggedIn,
    String? userRole,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    if (userRole != null) {
      await prefs.setString(_userRoleKey, userRole);
    }
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userIdKey);
  }
}
