import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_strings.dart';
import '../services/logger_service.dart';

class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  // Constants for future use when storage is implemented
  // static const String _otpAttemptsKey = 'otp_attempts';
  // static const String _otpCodeKey = 'otp_code';
  // static const String _otpTimestampKey = 'otp_timestamp';
  // static const int _otpValidityMinutes = 5;
  // static const int _maxOtpAttempts = 3;

  Future<void> sendPhoneOTP(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
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

      LoggerService.info('OTP sent to $phoneNumber');
    } catch (e) {
      throw Exception(AppStrings.smsError);
    }
  }

  Future<dynamic> verifyOTP(String smsCode) async {
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
      await _sendSMSViaFirebase(formattedPhone, otpCode);
      return OTPResult.success;
    } catch (e) {
      await _logError('sendSMSOTP', e);
      return OTPResult.error;
    }
  }

  Future<OTPResult> verifyOTPCode(String inputCode) async {
    try {
      // Validate OTP format
      if (inputCode.length != 6) {
        return OTPResult.invalid;
      }

      if (!RegExp(r'^\d{6}$').hasMatch(inputCode)) {
        return OTPResult.invalid;
      }

      // Use Firebase phone auth verification
      if (_verificationId == null) {
        LoggerService.error('Verification ID is null');
        return OTPResult.error;
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: inputCode,
      );

      await _auth.signInWithCredential(credential);
      return OTPResult.success;
    } on FirebaseAuthException catch (e) {
      await _logError('verifyOTP', e);
      switch (e.code) {
        case 'invalid-verification-code':
          return OTPResult.invalid;
        case 'session-expired':
          return OTPResult.expired;
        case 'too-many-requests':
          return OTPResult.tooManyAttempts;
        default:
          return OTPResult.error;
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
    LoggerService.info('OTP Code sent to $email: $otpCode (محاكاة)');
  }

  Future<void> _sendSMSViaFirebase(String phone, String otpCode) async {
    await Future.delayed(const Duration(seconds: 1));
    LoggerService.info('OTP Code sent to $phone: $otpCode (محاكاة)');
  }

  Future<void> _logError(String method, dynamic error) async {
    LoggerService.error('OTP Service Error in $method: $error');
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح';
      case 'quota-exceeded':
        return 'تم تجاوز الحد المسموح من الرسائل';
      default:
        return AppStrings.generalError;
    }
  }
}

enum OTPResult { success, invalid, expired, tooManyAttempts, error }

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
