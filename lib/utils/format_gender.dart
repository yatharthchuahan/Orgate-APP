/// Formats gender from API format (M/F) to readable format (Male/Female)
String formatGender(String? gender) {
  if (gender == null || gender.isEmpty) {
    return 'Not Specified';
  }

  // Convert to uppercase for comparison
  final genderUpper = gender.toUpperCase();

  switch (genderUpper) {
    case 'M':
      return 'Male';
    case 'F':
      return 'Female';
    default:
      // Return original value if not M or F
      return gender;
  }
}

/// Gets gender icon based on the gender value
String getGenderEmoji(String? gender) {
  if (gender == null || gender.isEmpty) {
    return '👤';
  }

  final genderUpper = gender.toUpperCase();

  switch (genderUpper) {
    case 'M':
      return '👨';
    case 'F':
      return '👩';
    default:
      return '👤';
  }
}

