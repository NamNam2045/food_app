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
      return 'http://192.168.50.23:8080/api/v1';
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

  static String? resolveMediaUrl(String? rawUrl) {
    if (rawUrl == null) {
      return null;
    }
    final value = rawUrl.trim();
    if (value.isEmpty) {
      return null;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final api = Uri.parse(apiBaseUrl);
    final path = value.startsWith('/') ? value : '/$value';
    return '${api.scheme}://${api.host}${api.hasPort ? ':${api.port}' : ''}$path';
  }
}
