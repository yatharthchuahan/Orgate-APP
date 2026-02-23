import 'package:flutter/material.dart';
import 'package:orangtre/StoredData/LoginData.dart';

/// Global navigator key to access navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Custom exception for 401 Unauthorized responses
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

/// Handle 401 Unauthorized response - automatically logout user
Future<void> handle401Unauthorized() async {
  print('⚠️ 401 Unauthorized - Logging out user...');
  
  // Clear all stored login data
  await LoginStorage.clearLoginResponse();
  
  // Get the navigator context
  final context = navigatorKey.currentContext;
  
  if (context != null && context.mounted) {
    // Show a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please login again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Navigate to login screen and clear all routes
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}

/// Check if response status code is 401 and handle it
Future<bool> checkAndHandle401(int statusCode) async {
  if (statusCode == 401) {
    await handle401Unauthorized();
    return true;
  }
  return false;
}

