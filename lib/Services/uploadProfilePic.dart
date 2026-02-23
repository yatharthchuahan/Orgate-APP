import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orangtre/StoredData/LoginData.dart';
import 'package:orangtre/utils/auth_handler.dart';

class Uploadprofilepic {
  Future<dynamic> uploadprofilepic({
    required String base64Image,
  }) async {
    final url = Uri.parse("https://demoapi.wavelift.in/api/ProfilePicture/Upload");

    // Get the authentication token from stored login data
    final loginResponse = await LoginStorage.getLoginResponse();
    final token = loginResponse?.token ?? '';

    if (token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'AuthenticationToken': token,
    };

    final body = jsonEncode({
      'base64Image': base64Image,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Upload profile picture API Response: $jsonResponse');
        return jsonResponse;
      } else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Triggering automatic logout');
        // Automatically handle 401 - logout user
        await handle401Unauthorized();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to upload profile picture: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in upload profile picture service: $e');
      // Re-throw UnauthorizedException without wrapping
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw Exception('Error uploading profile picture: $e');
    }
  }
}
