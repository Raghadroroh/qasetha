import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'logger_service.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'qasetha_app',
    ),
  );

  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _userNameKey = 'user_name';
  static const String _lastLoginKey = 'last_login';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _sessionExpiryKey = 'session_expiry';
  static const String _deviceIdKey = 'device_id';

  // Token management
  static Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
      LoggerService.info('Auth token saved successfully');
    } catch (e) {
      LoggerService.error('Failed to save auth token: $e');
    }
  }

  static Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      LoggerService.error('Failed to read auth token: $e');
      return null;
    }
  }

  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      LoggerService.info('Refresh token saved successfully');
    } catch (e) {
      LoggerService.error('Failed to save refresh token: $e');
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      LoggerService.error('Failed to read refresh token: $e');
      return null;
    }
  }

  // User data management
  static Future<void> saveUserData({
    required String userId,
    String? email,
    String? phone,
    String? name,
  }) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
      if (email != null) await _storage.write(key: _userEmailKey, value: email);
      if (phone != null) await _storage.write(key: _userPhoneKey, value: phone);
      if (name != null) await _storage.write(key: _userNameKey, value: name);
      await _storage.write(key: _lastLoginKey, value: DateTime.now().toIso8601String());
      LoggerService.info('User data saved successfully');
    } catch (e) {
      LoggerService.error('Failed to save user data: $e');
    }
  }

  static Future<Map<String, String?>> getUserData() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      final email = await _storage.read(key: _userEmailKey);
      final phone = await _storage.read(key: _userPhoneKey);
      final name = await _storage.read(key: _userNameKey);
      final lastLogin = await _storage.read(key: _lastLoginKey);
      
      return {
        'userId': userId,
        'email': email,
        'phone': phone,
        'name': name,
        'lastLogin': lastLogin,
      };
    } catch (e) {
      LoggerService.error('Failed to read user data: $e');
      return {};
    }
  }

  // Session management
  static Future<void> saveSessionExpiry(DateTime expiry) async {
    try {
      await _storage.write(key: _sessionExpiryKey, value: expiry.toIso8601String());
      LoggerService.info('Session expiry saved successfully');
    } catch (e) {
      LoggerService.error('Failed to save session expiry: $e');
    }
  }

  static Future<DateTime?> getSessionExpiry() async {
    try {
      final expiryStr = await _storage.read(key: _sessionExpiryKey);
      if (expiryStr != null) {
        return DateTime.parse(expiryStr);
      }
      return null;
    } catch (e) {
      LoggerService.error('Failed to read session expiry: $e');
      return null;
    }
  }

  static Future<bool> isSessionExpired() async {
    try {
      final expiry = await getSessionExpiry();
      if (expiry == null) return true;
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      LoggerService.error('Failed to check session expiry: $e');
      return true;
    }
  }

  // Device management
  static Future<void> saveDeviceId(String deviceId) async {
    try {
      await _storage.write(key: _deviceIdKey, value: deviceId);
      LoggerService.info('Device ID saved successfully');
    } catch (e) {
      LoggerService.error('Failed to save device ID: $e');
    }
  }

  static Future<String?> getDeviceId() async {
    try {
      return await _storage.read(key: _deviceIdKey);
    } catch (e) {
      LoggerService.error('Failed to read device ID: $e');
      return null;
    }
  }

  // Biometric settings
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
      LoggerService.info('Biometric setting saved: $enabled');
    } catch (e) {
      LoggerService.error('Failed to save biometric setting: $e');
    }
  }

  static Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      LoggerService.error('Failed to read biometric setting: $e');
      return false;
    }
  }

  // Check if user has valid session
  static Future<bool> hasValidSession() async {
    try {
      final token = await getAuthToken();
      final userData = await getUserData();
      final isExpired = await isSessionExpired();
      
      return token != null && 
             userData['userId'] != null && 
             !isExpired;
    } catch (e) {
      LoggerService.error('Failed to check valid session: $e');
      return false;
    }
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    try {
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userEmailKey);
      await _storage.delete(key: _userPhoneKey);
      await _storage.delete(key: _userNameKey);
      await _storage.delete(key: _lastLoginKey);
      await _storage.delete(key: _sessionExpiryKey);
      await _storage.delete(key: _deviceIdKey);
      
      LoggerService.info('Auth data cleared successfully');
    } catch (e) {
      LoggerService.error('Failed to clear auth data: $e');
    }
  }

  // Clear all stored data
  static Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
      LoggerService.info('All secure storage cleared');
    } catch (e) {
      LoggerService.error('Failed to clear all secure storage: $e');
    }
  }

  // Check if user exists (for first-time setup)
  static Future<bool> hasUserData() async {
    try {
      final userData = await getUserData();
      return userData['userId'] != null;
    } catch (e) {
      LoggerService.error('Failed to check user data: $e');
      return false;
    }
  }

  // Get last login time
  static Future<DateTime?> getLastLoginTime() async {
    try {
      final lastLoginStr = await _storage.read(key: _lastLoginKey);
      if (lastLoginStr != null) {
        return DateTime.parse(lastLoginStr);
      }
      return null;
    } catch (e) {
      LoggerService.error('Failed to read last login time: $e');
      return null;
    }
  }

  // Check if session is within 30 days
  static Future<bool> isWithinAutoLoginPeriod() async {
    try {
      final lastLogin = await getLastLoginTime();
      if (lastLogin == null) return false;
      
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      return lastLogin.isAfter(thirtyDaysAgo);
    } catch (e) {
      LoggerService.error('Failed to check auto-login period: $e');
      return false;
    }
  }

  // Generic data storage for guest sessions and other data
  static Future<void> saveData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      LoggerService.info('Data saved successfully for key: $key');
    } catch (e) {
      LoggerService.error('Failed to save data for key $key: $e');
    }
  }

  static Future<String?> getData(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      LoggerService.error('Failed to read data for key $key: $e');
      return null;
    }
  }

  static Future<void> deleteData(String key) async {
    try {
      await _storage.delete(key: key);
      LoggerService.info('Data deleted successfully for key: $key');
    } catch (e) {
      LoggerService.error('Failed to delete data for key $key: $e');
    }
  }

  // Debug method to print all stored keys (only in debug mode)
  static Future<void> debugPrintAllKeys() async {
    if (kDebugMode) {
      try {
        final allKeys = await _storage.readAll();
        LoggerService.info('Stored keys: ${allKeys.keys.toList()}');
      } catch (e) {
        LoggerService.error('Failed to read all keys: $e');
      }
    }
  }
}