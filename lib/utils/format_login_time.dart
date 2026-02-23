import 'package:intl/intl.dart';

/// Formats login time from API format (1900-01-01T23:18:00) to HH:MM:SS format
String formatLoginTime(String? loginTime) {
  if (loginTime == null || loginTime.isEmpty) {
    return 'N/A';
  }

  try {
    // Parse the datetime string from API
    final dateTime = DateTime.parse(loginTime);
    
    // Format to HH:MM:SS
    final formattedTime = DateFormat('HH:mm:ss').format(dateTime);
    
    return formattedTime;
  } catch (e) {
    // If parsing fails, return the original string
    return loginTime;
  }
}

/// Formats login time with date and time
String formatLoginDateTime(String? loginTime) {
  if (loginTime == null || loginTime.isEmpty) {
    return 'N/A';
  }

  try {
    // Parse the datetime string from API
    final dateTime = DateTime.parse(loginTime);
    
    // Format to dd/MM/yyyy HH:MM:SS
    final formattedDateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    
    return formattedDateTime;
  } catch (e) {
    // If parsing fails, return the original string
    return loginTime;
  }
}

