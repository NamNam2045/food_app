class AuthSession {
  AuthSession({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresIn,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String accessToken;
  final String refreshToken;
  final int accessTokenExpiresIn;

  String get fullName => '$firstName $lastName'.trim();

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      accessTokenExpiresIn:
          (json['accessTokenExpiresIn'] as num?)?.toInt() ?? 0,
    );
  }
}
