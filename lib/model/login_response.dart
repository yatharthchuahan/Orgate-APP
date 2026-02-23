import 'dart:convert';

class LoginResponse {
  final int code;
  final String message;
  final String token;
  final UserData userData;

  LoginResponse({
    required this.code,
    required this.message,
    required this.token,
    required this.userData,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['Code'] ?? 0,
      message: json['Message'] ?? '',
      token: json['Token'] ?? '',
      userData: UserData.fromJson(json['UserData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'Code': code,
    'Message': message,
    'Token': token,
    'UserData': userData.toJson(),
  };
}

class UserData {
  final int code;
  final String message;
  final int loginBigID;
  final String loginTimeUser;
  final bool approvalStatus;
  final String approvalStatusName;
  final String firstName;
  final String lastName;
  final String username;
  final String? email;
  final String userType;
  final String userTypeName;
  final String gender;
  final String role;
  final String empCode;
  final String profilePicture;
  final String fileURL;
  final List<PageModel> pages;

  UserData({
    required this.code,
    required this.message,
    required this.loginBigID,
    required this.loginTimeUser,
    required this.approvalStatus,
    required this.approvalStatusName,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.userType,
    required this.userTypeName,
    required this.gender,
    required this.role,
    required this.empCode,
    required this.profilePicture,
    required this.fileURL,
    required this.pages,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    // 'Pages' comes as a JSON string, so decode it first
    final List<dynamic> pagesJson = json['Pages'] != null
        ? jsonDecode(json['Pages'])
        : [];

    return UserData(
      code: json['Code'] ?? 0,
      message: json['Message'] ?? '',
      loginBigID: json['LoginBigID'] ?? 0,
      loginTimeUser: json['LoginTimeUser'] ?? '',
      approvalStatus: json['ApprovalStatus'] ?? false,
      approvalStatusName: json['ApprovalStatusName'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      username: json['Username'] ?? '',
      email: json['Email'],
      userType: json['UserType'] ?? '',
      userTypeName: json['UserTypeName'] ?? '',
      gender: json['Gender'] ?? '',
      role: json['Role'] ?? '',
      empCode: json['EmpCode'] ?? '',
      profilePicture: json['ProfilePicture'] ?? '',
      fileURL: json['FileURL'] ?? '',
      pages: pagesJson.map((p) => PageModel.fromJson(p)).toList(),
    );
  }
  Map<String, dynamic> toJson() => {
    'Code': code,
    'Message': message,
    'LoginBigID': loginBigID,
    'LoginTimeUser': loginTimeUser,
    'ApprovalStatus': approvalStatus,
    'ApprovalStatusName': approvalStatusName,
    'FirstName': firstName,
    'LastName': lastName,
    'Username': username,
    'Email': email,
    'UserType': userType,
    'UserTypeName': userTypeName,
    'Gender': gender,
    'Role': role,
    'EmpCode': empCode,
    'ProfilePicture': profilePicture,
    'FileURL': fileURL,
    'Pages': jsonEncode(pages.map((p) => p.toJson()).toList()),
  };
}

class PageModel {
  final int pageId;
  final String pageName;
  final String pageURL;
  final String accessStatus;

  PageModel({
    required this.pageId,
    required this.pageName,
    required this.pageURL,
    required this.accessStatus,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      pageId: json['PageId'] ?? 0,
      pageName: json['PageName'] ?? '',
      pageURL: json['PageURL'] ?? '',
      accessStatus: json['AccessStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'PageId': pageId,
    'PageName': pageName,
    'PageURL': pageURL,
    'AccessStatus': accessStatus,
  };
}
