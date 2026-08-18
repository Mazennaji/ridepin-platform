import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kRole = 'user_role';
  static const _kName = 'user_name';
  static const _kEmail = 'user_email';

  Future<void> saveAuth({
    required String token,
    required int userId,
    required String role,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setInt(_kUserId, userId);
    await prefs.setString(_kRole, role);
    await prefs.setString(_kName, name);
    await prefs.setString(_kEmail, email);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRole);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUserId);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kName);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmail);
  }

  Future<bool> isLoggedIn() async => (await getToken()) != null;

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kRole);
    await prefs.remove(_kName);
    await prefs.remove(_kEmail);
  }
}
