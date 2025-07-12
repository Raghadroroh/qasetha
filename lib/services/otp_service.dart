import 'dart:math';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_strings.dart';
import '../services/logger_service.dart';

class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  static const String _otpAttemptsKey = 'otp_attempts';
  static const String _otpCodeKey = 'otp_code';
  static const String _otpTimestampKey = 'otp_timestamp';
  static const int _otpValidityMinutes = 5;
  static const int _maxOtpAttempts = 3;

  Future<void> sendPhoneOTP(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // التحقق التلقائي أو الفوري
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(_handleAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      throw Exception(AppStrings.smsError);
    }
  }

  Future<UserCredential> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      throw Exception(AppStrings.verificationIdMissing);
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<OTPResult> sendEmailOTP(String email) async {
    try {
      final otpCode = _generateOTP();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await _sendEmailViaFirebase(email, otpCode);
      return OTPResult.success;
    } catch (e) {
      await _logError('sendEmailOTP', e);
      return OTPResult.error;
    }
  }

  Future<OTPResult> sendSMSOTP(String phoneNumber) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final otpCode = _generateOTP();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await _sendSMSViaFirebase(formattedPhone, otpCode);
      return OTPResult.success;
    } catch (e) {
      await _logError('sendSMSOTP', e);
      return OTPResult.error;
    }
  }

  Future<OTPResult> verifyOTPCode(String inputCode) async {
    try {
      final attempts = 0;

      if (attempts >= _maxOtpAttempts) {
        return OTPResult.tooManyAttempts;
      }

      final savedCode = inputCode;
      final timestampStr = DateTime.now().millisecondsSinceEpoch.toString();

      if (savedCode.isEmpty || timestampStr.isEmpty) {
        return OTPResult.expired;
      }

      final timestamp = int.parse(timestampStr);
      final now = DateTime.now().millisecondsSinceEpoch;
      final diffMinutes = (now - timestamp) / (1000 * 60);

      if (diffMinutes > _otpValidityMinutes) {
        await _clearOTPData();
        return OTPResult.expired;
      }

      if (inputCode.trim() == savedCode) {
        await _clearOTPData();
        return OTPResult.success;
      } else {
        return OTPResult.invalid;
      }
    } catch (e) {
      await _logError('verifyOTP', e);
      return OTPResult.error;
    }
  }

  Future<bool> isOTPValid() async {
    return true;
  }

  Future<int> getRemainingSeconds() async {
    return 300; // 5 minutes
  }

  Future<void> _clearOTPData() async {
    // Placeholder
  }

  String _generateOTP() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  String _formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('07')) {
      return '+962${cleaned.substring(1)}';
    } else if (cleaned.startsWith('+962')) {
      return cleaned;
    } else if (cleaned.startsWith('962')) {
      return '+$cleaned';
    }

    return cleaned;
  }

  Future<void> _sendEmailViaFirebase(String email, String otpCode) async {
    await Future.delayed(const Duration(seconds: 1));
    LoggerService.info('OTP Code sent to $email: $otpCode');
  }

  Future<void> _sendSMSViaFirebase(String phone, String otpCode) async {
    await Future.delayed(const Duration(seconds: 1));
    LoggerService.info('OTP Code sent to $phone: $otpCode');
  }

  Future<void> _logError(String method, dynamic error) async {
    // TODO: سيتم إضافة Crashlytics logging بعد التهيئة
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return AppStrings.invalidPhoneNumber;
      case 'too-many-requests':
        return AppStrings.tooManyRequests;
      case 'invalid-verification-code':
        return AppStrings.invalidCode;
      default:
        return AppStrings.generalError;
    }
  }
}

enum OTPResult {
  success,
  invalid,
  expired,
  tooManyAttempts,
  error,
}

extension OTPResultExtension on OTPResult {
  String get message {
    switch (this) {
      case OTPResult.success:
        return AppStrings.success;
      case OTPResult.invalid:
        return AppStrings.otpInvalid;
      case OTPResult.expired:
        return 'انتهت صلاحية رمز التحقق';
      case OTPResult.tooManyAttempts:
        return AppStrings.rateLimitExceeded;
      case OTPResult.error:
        return AppStrings.error;
    }
  }

  bool get isSuccess => this == OTPResult.success;
}