import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? errorCode;
  final String? verificationId;
  final AuthResultType type;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.errorCode,
    this.verificationId,
    this.type = AuthResultType.general,
  });

  // Getter for backward compatibility
  bool get isSuccess => success;

  factory AuthResult.success({
    String? message,
    User? user,
    String? verificationId,
    AuthResultType type = AuthResultType.general,
  }) {
    return AuthResult(
      success: true,
      message: message,
      user: user,
      verificationId: verificationId,
      type: type,
    );
  }

  factory AuthResult.failure({
    String? message,
    String? errorCode,
    User? user,
    AuthResultType type = AuthResultType.general,
  }) {
    return AuthResult(
      success: false,
      message: message,
      errorCode: errorCode,
      user: user,
      type: type,
    );
  }

  factory AuthResult.fromFirebaseException(FirebaseAuthException e) {
    String messageAr;

    switch (e.code) {
      case 'user-not-found':
        messageAr = 'المستخدم غير موجود';
        break;
      case 'wrong-password':
        messageAr = 'كلمة المرور خاطئة';
        break;
      case 'email-already-in-use':
        messageAr = 'البريد الإلكتروني مستخدم بالفعل';
        break;
      case 'weak-password':
        messageAr = 'كلمة المرور ضعيفة';
        break;
      case 'invalid-email':
        messageAr = 'البريد الإلكتروني غير صحيح';
        break;
      case 'user-disabled':
        messageAr = 'تم تعطيل المستخدم';
        break;
      case 'too-many-requests':
        messageAr = 'عدد كبير من المحاولات، حاول لاحقاً';
        break;
      case 'invalid-verification-code':
        messageAr = 'رمز التحقق غير صحيح';
        break;
      case 'quota-exceeded':
        messageAr = 'تم تجاوز الحد المسموح من الرسائل';
        break;
      case 'invalid-phone-number':
        messageAr = 'رقم الهاتف غير صحيح';
        break;
      case 'requires-recent-login':
        messageAr = 'يجب تسجيل الدخول مؤخراً لتنفيذ هذه العملية';
        break;
      default:
        messageAr = e.message ?? 'حدث خطأ غير متوقع';
    }

    return AuthResult(success: false, message: messageAr, errorCode: e.code);
  }

  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message, errorCode: $errorCode)';
  }
}

enum AuthResultType {
  general,
  emailNotVerified,
  phoneNotVerified,
  otpSent,
  emailSent,
  passwordReset,
  accountCreated,
  loginSuccess,
  verificationSuccess,
  guestSignIn,
  conversion,
  guestError,
}
