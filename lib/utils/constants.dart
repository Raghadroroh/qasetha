class AuthConstants {
  // Firebase Auth Error Codes
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String weakPassword = 'weak-password';
  static const String invalidEmail = 'invalid-email';
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String invalidPhoneNumber = 'invalid-phone-number';
  static const String quotaExceeded = 'quota-exceeded';
  static const String invalidVerificationCode = 'invalid-verification-code';
  static const String tooManyRequests = 'too-many-requests';
  static const String userDisabled = 'user-disabled';
  static const String credentialAlreadyInUse = 'credential-already-in-use';
  static const String sessionExpired = 'session-expired';
  static const String requiresRecentLogin = 'requires-recent-login';

  // Jordan Phone Number Patterns
  static const String jordanCountryCode = '+962';
  static const List<String> validJordanPrefixes = ['77', '78', '79'];

  // OTP Configuration
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;
  static const int resendCooldownSeconds = 60;

  // Password Requirements
  static const int minPasswordLength = 8;
  static const String passwordRegex =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$';

  // Error Messages (Arabic)
  static const Map<String, String> errorMessagesAr = {
    emailAlreadyInUse: 'البريد الإلكتروني مستخدم بالفعل',
    weakPassword: 'كلمة المرور ضعيفة جداً',
    invalidEmail: 'البريد الإلكتروني غير صحيح',
    userNotFound: 'لا يوجد مستخدم بهذا البريد الإلكتروني',
    wrongPassword: 'كلمة المرور غير صحيحة',
    invalidPhoneNumber: 'رقم الهاتف غير صحيح',
    quotaExceeded: 'تم تجاوز الحد المسموح من الرسائل',
    invalidVerificationCode: 'رمز التحقق غير صحيح',
    tooManyRequests: 'تم تجاوز عدد المحاولات المسموح، حاول لاحقاً',
    userDisabled: 'تم تعطيل هذا الحساب',
    credentialAlreadyInUse: 'رقم الهاتف مستخدم بالفعل',
    sessionExpired: 'انتهت صلاحية الجلسة، حاول مرة أخرى',
    requiresRecentLogin: 'يجب تسجيل الدخول مرة أخرى لإجراء هذه العملية',
  };

  // Error Messages (English)
  static const Map<String, String> errorMessagesEn = {
    emailAlreadyInUse: 'Email is already in use',
    weakPassword: 'Password is too weak',
    invalidEmail: 'Invalid email address',
    userNotFound: 'No user found with this email',
    wrongPassword: 'Incorrect password',
    invalidPhoneNumber: 'Invalid phone number',
    quotaExceeded: 'SMS quota exceeded',
    invalidVerificationCode: 'Invalid verification code',
    tooManyRequests: 'Too many requests, try again later',
    userDisabled: 'This account has been disabled',
    credentialAlreadyInUse: 'Phone number is already in use',
    sessionExpired: 'Session expired, try again',
    requiresRecentLogin: 'Please sign in again to perform this operation',
  };

  // Success Messages (Arabic)
  static const Map<String, String> successMessagesAr = {
    'account_created': 'تم إنشاء الحساب بنجاح',
    'login_success': 'تم تسجيل الدخول بنجاح',
    'otp_sent': 'تم إرسال رمز التحقق',
    'email_sent': 'تم إرسال بريد التحقق',
    'password_reset': 'تم إرسال رابط إعادة تعيين كلمة المرور',
    'phone_verified': 'تم التحقق من الهاتف بنجاح',
    'email_verified': 'تم تأكيد البريد الإلكتروني',
    'password_updated': 'تم تحديث كلمة المرور بنجاح',
  };

  // Success Messages (English)
  static const Map<String, String> successMessagesEn = {
    'account_created': 'Account created successfully',
    'login_success': 'Login successful',
    'otp_sent': 'Verification code sent',
    'email_sent': 'Verification email sent',
    'password_reset': 'Password reset link sent',
    'phone_verified': 'Phone verified successfully',
    'email_verified': 'Email verified successfully',
    'password_updated': 'Password updated successfully',
  };

  // Jordan Phone Validation Messages
  static const Map<String, String> phoneValidationAr = {
    'invalid_format': 'تنسيق رقم الهاتف غير صحيح',
    'not_jordanian': 'رقم الهاتف يجب أن يكون أردني',
    'invalid_prefix': 'رقم الهاتف يجب أن يبدأ بـ 77 أو 78 أو 79',
    'example': 'مثال: +962 79 123 4567',
  };

  static const Map<String, String> phoneValidationEn = {
    'invalid_format': 'Invalid phone number format',
    'not_jordanian': 'Phone number must be Jordanian',
    'invalid_prefix': 'Phone number must start with 77, 78, or 79',
    'example': 'Example: +962 79 123 4567',
  };
}
