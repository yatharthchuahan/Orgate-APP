import 'package:flutter/material.dart';
import 'package:orangtre/StoredData/LoginData.dart';

void logout(BuildContext context) async {
  // Clear all stored data
  await LoginStorage.clearLoginResponse();

  // Navigate to login screen and remove all previous routes
  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false, // This removes all previous routes
    );
  }
}
