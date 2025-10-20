import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _key = 'auth_token';
  static Future<void> saveToken(String token) async {
    final frefs = await SharedPreferences.getInstance();
    await frefs.setString(_key, token);
  }
  static Future<String?> getToken() async {
    final frefs = await SharedPreferences.getInstance();
    return frefs.getString(_key);
  }
  static Future<void> clearToken() async {
    final frefs = await SharedPreferences.getInstance();
    await frefs.remove(_key);
  }
}