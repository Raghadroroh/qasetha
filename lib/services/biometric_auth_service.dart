import 'package:local_auth/local_auth.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// TODO: سيتم إضافة Firebase imports بعد التهيئة
import '../constants/app_strings.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // TODO: سيتم إضافة Firebase Analytics instance بعد التهيئة

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricTypeKey = 'biometric_type';

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      await _logError('isDeviceSupported', e);
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      await _logError('isBiometricAvailable', e);
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      await _logError('getAvailableBiometrics', e);
      return [];
    }
  }

  Future<BiometricType?> getPreferredBiometricType() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return null;
      if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricType.face;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      } else {
        return availableBiometrics.first;
      }
    } catch (e) {
      await _logError('getPreferredBiometricType', e);
      return null;
    }
  }

  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return AppStrings.faceIdLogin;
      case BiometricType.fingerprint:
        return AppStrings.fingerprintLogin;
      case BiometricType.iris:
        return 'الدخول بالعين';
      case BiometricType.strong:
      case BiometricType.weak:
        return AppStrings.devicePinLogin;
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      // final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      final enabled = 'false';
      return enabled == 'true';
    } catch (e) {
      await _logError('isBiometricEnabled', e);
      return false;
    }
  }

  Future<BiometricAuthResult> enableBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult.unavailable;
      }

      final authResult = await authenticateUser(
        reason: AppStrings.enableQuickLogin,
        isSetup: true,
      );

      if (authResult == BiometricAuthResult.success) {
        // await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
        // final preferredType = await getPreferredBiometricType();
        // if (preferredType != null) {
        //   await _secureStorage.write(key: _biometricTypeKey, value: preferredType.name);
        // }
        // TODO: سيتم إضافة Analytics logging بعد التهيئة
        return BiometricAuthResult.success;
      }
      return authResult;
    } catch (e) {
      await _logError('enableBiometric', e);
      return BiometricAuthResult.error;
    }
  }

  Future<void> disableBiometric() async {
    try {
      // await _secureStorage.delete(key: _biometricEnabledKey);
      // await _secureStorage.delete(key: _biometricTypeKey);
      // TODO: سيتم إضافة Analytics logging بعد التهيئة
    } catch (e) {
      await _logError('disableBiometric', e);
    }
  }

  Future<BiometricAuthResult> authenticateUser({
    required String reason,
    bool isSetup = false,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult.unavailable;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // TODO: سيتم إضافة Analytics logging بعد التهيئة
        return BiometricAuthResult.success;
      } else {
        // TODO: سيتم إضافة Analytics logging بعد التهيئة
        return BiometricAuthResult.cancelled;
      }
    } catch (e) {
      await _logError('authenticateUser', e);
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('not available') || errorString.contains('not enrolled')) {
        return BiometricAuthResult.notSetup;
      } else if (errorString.contains('cancelled') || errorString.contains('user_cancel')) {
        return BiometricAuthResult.cancelled;
      } else {
        return BiometricAuthResult.error;
      }
    }
  }

  Future<BiometricAuthResult> authenticateForTransaction({
    required String transactionType,
  }) async {
    final reason = '${AppStrings.verifyForTransaction}\n$transactionType';
    final result = await authenticateUser(reason: reason);
    // TODO: سيتم إضافة Analytics logging بعد التهيئة
    return result;
  }

  Future<void> _logError(String method, dynamic error) async {
    // TODO: سيتم إضافة Crashlytics logging بعد التهيئة
  }
}

enum BiometricAuthResult {
  success,
  cancelled,
  failed,
  unavailable,
  notSetup,
  error,
}

extension BiometricAuthResultExtension on BiometricAuthResult {
  String get message {
    switch (this) {
      case BiometricAuthResult.success:
        return AppStrings.success;
      case BiometricAuthResult.cancelled:
        return AppStrings.biometricCancelled;
      case BiometricAuthResult.failed:
        return AppStrings.biometricFailed;
      case BiometricAuthResult.unavailable:
        return AppStrings.biometricUnavailable;
      case BiometricAuthResult.notSetup:
        return AppStrings.biometricNotSetup;
      case BiometricAuthResult.error:
        return AppStrings.error;
    }
  }

  bool get isSuccess => this == BiometricAuthResult.success;
  bool get shouldShowFallback => this != BiometricAuthResult.success && this != BiometricAuthResult.cancelled;
}