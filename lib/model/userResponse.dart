class UserResponse {
  final int code;
  final String message;
  final bool success;
  final int totalRecords;
  final List<User> data;
  final String timestamp;

  UserResponse({
    required this.code,
    required this.message,
    required this.success,
    required this.totalRecords,
    required this.data,
    required this.timestamp,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      totalRecords: json['totalRecords'] ?? 0,
      data: ((json['data'] ?? []) as List<dynamic>)
          .map((item) => User.fromJson(item))
          .toList(),
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'success': success,
      'totalRecords': totalRecords,
      'data': data.map((user) => user.toJson()).toList(),
      'timestamp': timestamp,
    };
  }
}

class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final String? email;
  final String userType;
  final String userTypeName;
  final bool status;
  final String statusName;
  final String? address;
  final String? gstin;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    this.email,
    required this.userType,
    required this.userTypeName,
    required this.status,
    required this.statusName,
    this.address,
    this.gstin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['UserId'] ?? 0,
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      username: json['Username'] ?? '',
      password: json['Password'] ?? '',
      email: json['Email'],
      userType: json['UserType'] ?? '',
      userTypeName: json['UserTypeName'] ?? '',
      status: json['Status'] ?? false,
      statusName: json['StatusName'] ?? '',
      address: json['Address'],
      gstin: json['GSTIN'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Password': password,
      'Email': email,
      'UserType': userType,
      'UserTypeName': userTypeName,
      'Status': status,
      'StatusName': statusName,
      'Address': address,
      'GSTIN': gstin,
    };
  }

  // Helper getter for full name
  String get fullName => '$firstName $lastName';

  // Helper getter to check if user is admin
  bool get isAdmin => userType == 'A';

  // Helper getter to check if user is super admin
  bool get isSuperAdmin => userType == 'S';

  // Helper getter to check if user is distributor
  bool get isDistributor => userType == 'D';

  // Helper getter to check if user is retailer
  bool get isRetailer => userType == 'R';

  // Helper getter for display email (handle null)
  String get displayEmail => email ?? 'N/A';

  // Helper getter for display address (handle null)
  String get displayAddress => address ?? 'N/A';

  // Helper getter for display GSTIN (handle null)
  String get displayGSTIN => gstin ?? 'N/A';
}

