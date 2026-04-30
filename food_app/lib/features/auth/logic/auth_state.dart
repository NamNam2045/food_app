import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    required this.onboardingSeen,
    this.isSubmitting = false,
    this.errorMessage,
    this.userEmail,
    this.userFullName,
    this.userRole,
  });

  final AuthStatus status;
  final bool onboardingSeen;
  final bool isSubmitting;
  final String? errorMessage;
  final String? userEmail;
  final String? userFullName;
  final String? userRole;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isRestaurantAdmin => userRole == 'RESTAURANT_ADMIN';

  AuthState copyWith({
    AuthStatus? status,
    bool? onboardingSeen,
    bool? isSubmitting,
    String? errorMessage,
    String? userEmail,
    String? userFullName,
    String? userRole,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userEmail: userEmail ?? this.userEmail,
      userFullName: userFullName ?? this.userFullName,
      userRole: userRole ?? this.userRole,
    );
  }

  factory AuthState.initial() =>
      const AuthState(status: AuthStatus.unknown, onboardingSeen: false);

  @override
  List<Object?> get props => [
    status,
    onboardingSeen,
    isSubmitting,
    errorMessage,
    userEmail,
    userFullName,
    userRole,
  ];
}
