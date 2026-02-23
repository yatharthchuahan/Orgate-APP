import 'package:orangtre/StoredData/LoginData.dart';
import 'package:orangtre/model/login_response.dart';

/// Helper class to easily access user data from anywhere in the app
class UserHelper {
  /// Get the current logged-in user's data
  static Future<UserData?> getCurrentUser() async {
    final loginResponse = await LoginStorage.getLoginResponse();
    return loginResponse?.userData;
  }

  /// Get the current user's profile picture filename
  static Future<String?> getProfilePicture() async {
    final userData = await getCurrentUser();
    return userData?.profilePicture;
  }

  /// Get the current user's profile picture full URL/path (relative path from API)
  static Future<String?> getProfilePictureURL() async {
    final userData = await getCurrentUser();
    return userData?.fileURL;
  }

  /// Get the current user's profile picture full URL (with base URL)
  static Future<String> getFullProfilePictureURL() async {
    final fileUrl = await getProfilePictureURL();
    if (fileUrl == null || fileUrl.isEmpty) return '';
    // If fileUrl already starts with http, return as is
    if (fileUrl.startsWith('http')) return fileUrl;
    // Otherwise, combine with base URL
    return 'https://demoapi.wavelift.in/api/$fileUrl';
  }

  /// Get the current user's full name
  static Future<String> getFullName() async {
    final userData = await getCurrentUser();
    if (userData == null) return '';
    return '${userData.firstName} ${userData.lastName}'.trim();
  }

  /// Get the current user's username
  static Future<String> getUsername() async {
    final userData = await getCurrentUser();
    return userData?.username ?? '';
  }

  /// Get the current user's email
  static Future<String> getEmail() async {
    final userData = await getCurrentUser();
    return userData?.email ?? '';
  }

  /// Get the current user's role
  static Future<String> getRole() async {
    final userData = await getCurrentUser();
    return userData?.role ?? '';
  }

  /// Check if current user is admin
  static Future<bool> isAdmin() async {
    final userData = await getCurrentUser();
    return userData?.role == 'A' || userData?.userType == 'A';
  }

  /// Get the current user's employee code
  static Future<String> getEmpCode() async {
    final userData = await getCurrentUser();
    return userData?.empCode ?? '';
  }

  /// Get the current authentication token
  static Future<String> getToken() async {
    final loginResponse = await LoginStorage.getLoginResponse();
    return loginResponse?.token ?? '';
  }
}

