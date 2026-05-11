import 'package:flutter/foundation.dart';

class AppConstants {
  const AppConstants._();

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }

    // Android emulator cannot access host via localhost.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1';
    }

    return 'http://localhost:8080/api/v1';
  }

  static const String onboardingSeenKey = 'onboarding_seen';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String accessTokenExpiryKey = 'access_token_expiry_epoch';
  static const String userRoleKey = 'user_role';

  static String get webSocketUrl {
    final uri = Uri.parse(apiBaseUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port/ws';
  }
}
