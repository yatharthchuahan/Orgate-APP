import 'dart:convert';
import 'package:orangtre/model/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginStorage {
  static const String _keyLoginResponse = 'loginResponse';

  /// Save the full API response locally
  static Future<void> saveLoginResponse(LoginResponse login) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(login.toJson());
    await prefs.setString(_keyLoginResponse, jsonString);
  }

  /// Retrieve the stored API response as LoginResponse
  static Future<LoginResponse?> getLoginResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyLoginResponse);

    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      return LoginResponse.fromJson(jsonMap);
    }
    return null; // No data stored
  }

  /// Clear stored login response (logout)
  static Future<void> clearLoginResponse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoginResponse);
  }
}