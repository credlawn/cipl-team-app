class ProfileModel {
  final String id;
  final String username;
  final String email;
  final bool verified;
  final String employeeName;
  final String employeeCode;
  final String dateOfJoining;
  final String dateOfBirth;
  final String avatar;
  final String designation;
  final String department;
  final String vertical;
  final String role;
  final String fcmToken;

  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.verified,
    required this.employeeName,
    required this.employeeCode,
    required this.dateOfJoining,
    required this.dateOfBirth,
    required this.avatar,
    required this.designation,
    required this.department,
    required this.vertical,
    required this.role,
    required this.fcmToken,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      verified: json['verified'] ?? false,
      employeeName: json['employee_name'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      dateOfJoining: json['date_of_joining'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      avatar: json['avatar'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      vertical: json['vertical'] ?? '',
      role: json['role'] ?? '',
      fcmToken: json['fcm_token'] ?? '',
    );
  }
}
