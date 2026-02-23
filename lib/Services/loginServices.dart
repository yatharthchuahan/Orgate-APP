import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orangtre/model/login_response.dart';

class LoginService {
  Future<dynamic> loginService({
    required String email,
    required String password,
    required String loginTime,
    required String ipadress,
    required String deviceinfo
  }) async {
    final url = Uri.parse("https://demoapi.wavelift.in/Login/AdminLogin");

    // Function to clean header values
    String cleanHeader(String value) {
      // remove null chars and extra spaces
      return value.replaceAll('\u0000', '').trim();
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'emailIdID': cleanHeader(email),
      'Password': cleanHeader(password),
      'IPAddress': ipadress,
      'browserName': deviceinfo,
      'loginTime': loginTime,
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse);
        print("Login API Response $jsonResponse");
        return loginResponse;
      } else if (response.statusCode == 401) {
        print('Login failed: Unauthorized (401)');
        throw Exception('Login failed: Invalid email or password');
      } else {
        print('Login failed: ${response.statusCode}');
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }
}
