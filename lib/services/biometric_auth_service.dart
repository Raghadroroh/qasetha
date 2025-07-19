import 'package:local_auth/local_auth.dart';
// TODO: Uncomment after running flutter pub get
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../constants/app_strings.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  // TODO: Uncomment after adding dependencies
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Keys for future use when secure storage is added
  // static const String _biometricEnabledKey = 'biometric_enabled';
  // static const String _biometricTypeKey = 'biometric_type';

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
      // TODO: Uncomment after adding flutter_secure_storage
      // final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      // return enabled == 'true';
      return false; // Temporary
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
        // TODO: Uncomment after adding dependencies
        // await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
        // final preferredType = await getPreferredBiometricType();
        // if (preferredType != null) {
        //   await _secureStorage.write(key: _biometricTypeKey, value: preferredType.name);
        // }
        // await _analytics.logEvent(name: 'biometric_enabled');
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
      // TODO: Uncomment after adding dependencies
      // await _secureStorage.delete(key: _biometricEnabledKey);
      // await _secureStorage.delete(key: _biometricTypeKey);
      // await _analytics.logEvent(name: 'biometric_disabled');
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
        // TODO: Uncomment after adding dependencies
        // await _analytics.logEvent(name: 'biometric_auth_success');
        return BiometricAuthResult.success;
      } else {
        // TODO: Uncomment after adding dependencies
        // await _analytics.logEvent(name: 'biometric_auth_cancelled');
        return BiometricAuthResult.cancelled;
      }
    } catch (e) {
      await _logError('authenticateUser', e);
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('not available') ||
          errorString.contains('not enrolled')) {
        return BiometricAuthResult.notSetup;
      } else if (errorString.contains('cancelled') ||
          errorString.contains('user_cancel')) {
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
    // TODO: Uncomment after adding dependencies
    // await _analytics.logEvent(
    //   name: 'biometric_transaction_auth',
    //   parameters: {
    //     'transaction_type': transactionType,
    //     'result': result.name,
    //   },
    // );
    return result;
  }

  Future<void> _logError(String method, dynamic error) async {
    // TODO: Uncomment after adding firebase_crashlytics dependency
    // await FirebaseCrashlytics.instance.recordError(
    //   error,
    //   null,
    //   information: 'BiometricAuthService.$method',
    // );
    // Temporary logging - replace with proper logging
    // print('BiometricAuthService.$method: $error');
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
  bool get shouldShowFallback =>
      this != BiometricAuthResult.success &&
      this != BiometricAuthResult.cancelled;
}
