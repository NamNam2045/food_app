import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpiresIn,
    required String userRole,
  }) async {
    final int expiryEpoch = DateTime.now()
        .add(Duration(seconds: accessTokenExpiresIn))
        .millisecondsSinceEpoch;
    await _write(AppConstants.accessTokenKey, accessToken);
    await _write(AppConstants.refreshTokenKey, refreshToken);
    await _write(AppConstants.accessTokenExpiryKey, expiryEpoch.toString());
    await _write(AppConstants.userRoleKey, userRole);
  }

  Future<String?> readAccessToken() {
    return _read(AppConstants.accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _read(AppConstants.refreshTokenKey);
  }

  Future<String?> readUserRole() {
    return _read(AppConstants.userRoleKey);
  }

  Future<bool> hasValidAccessToken() async {
    final String? token = await readAccessToken();
    final String? expiryValue = await _read(AppConstants.accessTokenExpiryKey);
    if (token == null || token.isEmpty || expiryValue == null) {
      return false;
    }
    final int? expiryEpoch = int.tryParse(expiryValue);
    if (expiryEpoch == null) {
      return false;
    }
    return DateTime.now().millisecondsSinceEpoch < expiryEpoch;
  }

  Future<void> clearTokens() async {
    await _delete(AppConstants.accessTokenKey);
    await _delete(AppConstants.refreshTokenKey);
    await _delete(AppConstants.accessTokenExpiryKey);
    await _delete(AppConstants.userRoleKey);
  }

  Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingSeenKey) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingSeenKey, true);
  }

  Future<String?> _read(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } on PlatformException {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } on PlatformException {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } on PlatformException {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }
}
