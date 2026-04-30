class UserProfileModel {
  UserProfileModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    required this.profilePictureUrl,
    required this.emailVerified,
    required this.createdAt,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String role;
  final String? profilePictureUrl;
  final bool emailVerified;
  final DateTime? createdAt;

  String get fullName => '$firstName $lastName'.trim();

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      role: (json['role'] ?? '').toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString(),
      emailVerified:
          json['emailVerified'] == true || json['isEmailVerified'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
