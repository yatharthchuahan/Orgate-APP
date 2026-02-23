import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orangtre/StoredData/LoginData.dart';
import 'package:orangtre/model/userResponse.dart';
import 'package:orangtre/utils/auth_handler.dart';

class GetAllUserService {
  Future<UserResponse> getAllUser() async {
    final url = Uri.parse("https://demoapi.wavelift.in/api/UserMasterCRUD/GetAllUsers");

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

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('API Response: $jsonResponse');
        
        // Convert JSON to UserResponse object
        final userResponse = UserResponse.fromJson(jsonResponse);
        return userResponse;
      } else if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Triggering automatic logout');
        // Automatically handle 401 - logout user
        await handle401Unauthorized();
        throw UnauthorizedException('Session expired. Please login again.');
      } else {
        print('API Error: ${response.statusCode}');
        print('Get user api reponse ${response.body}');
        throw Exception('Failed to load Users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in get all users service: $e');
      // Re-throw UnauthorizedException without wrapping
      if (e is UnauthorizedException) {
        rethrow;
      }
      throw Exception('Error loading Users: $e');
    }
  }
}
