import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];

  // النصوص المترجمة - التطبيق العام
  String get appTitle => locale.languageCode == 'ar' ? 'قسطها' : 'Qasetha';
  String get welcome =>
      locale.languageCode == 'ar' ? 'أهلاً بك' : 'Welcome Back';
  String get loading =>
      locale.languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...';
  String get error => locale.languageCode == 'ar' ? 'خطأ' : 'Error';
  String get success => locale.languageCode == 'ar' ? 'تم بنجاح' : 'Success';
  String get cancel => locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get confirm => locale.languageCode == 'ar' ? 'تأكيد' : 'Confirm';
  String get close => locale.languageCode == 'ar' ? 'إغلاق' : 'Close';
  String get next => locale.languageCode == 'ar' ? 'التالي' : 'Next';
  String get back => locale.languageCode == 'ar' ? 'رجوع' : 'Back';
  String get continueButton =>
      locale.languageCode == 'ar' ? 'متابعة' : 'Continue';
  String get retry => locale.languageCode == 'ar' ? 'إعادة المحاولة' : 'Retry';
  String get noInternetConnection => locale.languageCode == 'ar'
      ? 'لا يوجد اتصال بالإنترنت'
      : 'No internet connection';
  String get somethingWentWrong =>
      locale.languageCode == 'ar' ? 'حدث خطأ ما' : 'Something went wrong';
  String get fieldRequired => locale.languageCode == 'ar'
      ? 'هذا الحقل مطلوب'
      : 'This field is required';
  String get or => locale.languageCode == 'ar' ? 'أو' : 'OR';

  // نصوص المصادقة - تسجيل الدخول
  String get login => locale.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login';
  String get loginSuccess => locale.languageCode == 'ar'
      ? 'تم تسجيل الدخول بنجاح'
      : 'Login successful';
  String get loginError =>
      locale.languageCode == 'ar' ? 'خطأ في تسجيل الدخول' : 'Login error';
  String get email =>
      locale.languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email';
  String get password =>
      locale.languageCode == 'ar' ? 'كلمة المرور' : 'Password';
  String get phone =>
      locale.languageCode == 'ar' ? 'رقم الهاتف' : 'Phone Number';
  String get emailMode =>
      locale.languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email';
  String get phoneMode =>
      locale.languageCode == 'ar' ? 'رقم الهاتف' : 'Phone Number';
  String get forgotPassword =>
      locale.languageCode == 'ar' ? 'نسيت كلمة المرور؟' : 'Forgot Password?';
  String get dontHaveAccount =>
      locale.languageCode == 'ar' ? 'ليس لديك حساب؟' : "Don't have an account?";
  String get phoneNumberPlaceholder => locale.languageCode == 'ar'
      ? 'يرجى إدخال رقم الهاتف'
      : 'Please enter phone number';

  // نصوص المصادقة - إنشاء الحساب
  String get signup => locale.languageCode == 'ar' ? 'إنشاء حساب' : 'Sign Up';
  String get name => locale.languageCode == 'ar' ? 'الاسم الكامل' : 'Full Name';
  String get confirmPassword =>
      locale.languageCode == 'ar' ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get alreadyHaveAccount => locale.languageCode == 'ar'
      ? 'لديك حساب بالفعل؟'
      : 'Already have an account?';
  String get accountCreated => locale.languageCode == 'ar'
      ? 'تم إنشاء الحساب بنجاح'
      : 'Account created successfully';
  String get passwordsDoNotMatch => locale.languageCode == 'ar'
      ? 'كلمات المرور غير متطابقة'
      : 'Passwords do not match';

  // نصوص استعادة كلمة المرور
  String get backToLogin =>
      locale.languageCode == 'ar' ? 'العودة إلى تسجيل الدخول' : 'Back to Login';
  String get sendResetLink =>
      locale.languageCode == 'ar' ? 'إرسال رابط الاسترداد' : 'Send Reset Link';
  String get resetLinkSent => locale.languageCode == 'ar'
      ? 'تم إرسال رابط إعادة تعيين كلمة المرور'
      : 'Password reset link sent';
  String get forgotPasswordDesc => locale.languageCode == 'ar'
      ? 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور'
      : 'Enter your email and we will send you a password reset link';
  String get emailSent => locale.languageCode == 'ar' ? 'تم الإرسال!' : 'Sent!';
  String get emailSentDesc => locale.languageCode == 'ar'
      ? 'تم إرسال رابط إعادة تعيين كلمة المرور إلى:'
      : 'Password reset link sent to:';
  String get checkInboxSpam => locale.languageCode == 'ar'
      ? 'تحقق من صندوق الوارد وقد تحتاج للتحقق من مجلد الرسائل غير المرغوب فيها'
      : 'Check your inbox and spam folder';
  String get sendAgain =>
      locale.languageCode == 'ar' ? 'إرسال مرة أخرى' : 'Send Again';
  String get backToLoginButton =>
      locale.languageCode == 'ar' ? 'العودة إلى تسجيل الدخول' : 'Back to Login';

  // نصوص OTP والتحقق
  String get otpVerification =>
      locale.languageCode == 'ar' ? 'رمز التحقق' : 'Verification Code';
  String get otpSentTo => locale.languageCode == 'ar'
      ? 'أدخل الرمز المرسل إلى'
      : 'Enter code sent to';
  String get confirmCode =>
      locale.languageCode == 'ar' ? 'تأكيد الرمز' : 'Confirm Code';
  String get didntReceiveCode =>
      locale.languageCode == 'ar' ? 'لم تستلم الرمز؟' : "Didn't receive code?";
  String get resendCode =>
      locale.languageCode == 'ar' ? 'إعادة الإرسال' : 'Resend';
  String get resendIn =>
      locale.languageCode == 'ar' ? 'يمكنك إعادة الإرسال خلال' : 'Resend in';
  String get seconds => locale.languageCode == 'ar' ? 'ثانية' : 'seconds';
  String get otpRequired => locale.languageCode == 'ar'
      ? 'أدخل رمز التحقق كاملاً'
      : 'Enter complete verification code';
  String get otpInvalid => locale.languageCode == 'ar'
      ? 'رمز التحقق غير صحيح'
      : 'Invalid verification code';
  String get otpResent => locale.languageCode == 'ar'
      ? 'تم إعادة إرسال رمز التحقق'
      : 'Verification code resent';
  String get otpError =>
      locale.languageCode == 'ar' ? 'خطأ في إعادة الإرسال' : 'Resend error';

  // رسائل خطأ Firebase Auth
  String get userNotFound => locale.languageCode == 'ar'
      ? 'لا يوجد مستخدم بهذا البريد الإلكتروني'
      : 'No user found with this email';
  String get wrongPassword =>
      locale.languageCode == 'ar' ? 'كلمة المرور غير صحيحة' : 'Wrong password';
  String get emailAlreadyInUse => locale.languageCode == 'ar'
      ? 'البريد الإلكتروني مستخدم بالفعل'
      : 'Email already in use';
  String get weakPassword => locale.languageCode == 'ar'
      ? 'كلمة المرور ضعيفة جداً'
      : 'Password is too weak';
  String get invalidEmail => locale.languageCode == 'ar'
      ? 'البريد الإلكتروني غير صحيح'
      : 'Invalid email';
  String get userDisabled => locale.languageCode == 'ar'
      ? 'تم تعطيل هذا الحساب'
      : 'User account disabled';
  String get tooManyRequests => locale.languageCode == 'ar'
      ? 'تم تجاوز عدد المحاولات المسموح، حاول لاحقاً'
      : 'Too many requests, try again later';
  String get unexpectedError => locale.languageCode == 'ar'
      ? 'حدث خطأ غير متوقع'
      : 'Unexpected error occurred';

  // رسائل التحقق من كلمة المرور
  String get passwordMinLength => locale.languageCode == 'ar'
      ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'
      : 'Password must be at least 8 characters';
  String get passwordNeedsUppercase => locale.languageCode == 'ar'
      ? 'يجب أن تحتوي على حرف كبير واحد على الأقل'
      : 'Must contain at least one uppercase letter';
  String get passwordNeedsLowercase => locale.languageCode == 'ar'
      ? 'يجب أن تحتوي على حرف صغير واحد على الأقل'
      : 'Must contain at least one lowercase letter';
  String get passwordNeedsNumber => locale.languageCode == 'ar'
      ? 'يجب أن تحتوي على رقم واحد على الأقل'
      : 'Must contain at least one number';
  String get passwordNeedsSpecialChar => locale.languageCode == 'ar'
      ? 'يجب أن تحتوي على رمز خاص واحد على الأقل'
      : 'Must contain at least one special character';
  String get passwordRequired => locale.languageCode == 'ar'
      ? 'كلمة المرور مطلوبة'
      : 'Password is required';
  String get confirmPasswordRequired => locale.languageCode == 'ar'
      ? 'تأكيد كلمة المرور مطلوب'
      : 'Password confirmation required';

  // نصوص الإعدادات والثيم
  String get settings => locale.languageCode == 'ar' ? 'الإعدادات' : 'Settings';
  String get language =>
      locale.languageCode == 'ar' ? 'اختر اللغة' : 'Choose Language';
  String get chooseLanguage =>
      locale.languageCode == 'ar' ? 'اختر اللغة' : 'Choose Language';
  String get chooseTheme =>
      locale.languageCode == 'ar' ? 'اختر المظهر' : 'Choose Theme';
  String get systemLanguage =>
      locale.languageCode == 'ar' ? 'لغة النظام' : 'System Language';
  String get lightTheme =>
      locale.languageCode == 'ar' ? 'المظهر الفاتح' : 'Light Theme';
  String get darkTheme =>
      locale.languageCode == 'ar' ? 'المظهر الداكن' : 'Dark Theme';
  String get systemTheme =>
      locale.languageCode == 'ar' ? 'مظهر النظام' : 'System Theme';
  String get arabic => locale.languageCode == 'ar' ? 'العربية' : 'العربية';
  String get english => locale.languageCode == 'ar' ? 'English' : 'English';
  String get languageChangedSuccessfully => locale.languageCode == 'ar'
      ? 'تم تغيير اللغة بنجاح'
      : 'Language changed successfully';
  String get themeChangedSuccessfully => locale.languageCode == 'ar'
      ? 'تم تغيير المظهر بنجاح'
      : 'Theme changed successfully';
  String get selectLanguageFirst => locale.languageCode == 'ar'
      ? 'اختر لغتك المفضلة'
      : 'Select your preferred language';
  String get canChangeLanguageLater => locale.languageCode == 'ar'
      ? 'يمكنك تغيير اللغة لاحقاً من الإعدادات'
      : 'You can change language later in settings';
  String get welcomeToApp => locale.languageCode == 'ar'
      ? 'مرحباً بك في التطبيق'
      : 'Welcome to the App';

  // نصوص onboarding
  String get onboardingTitle1 =>
      locale.languageCode == 'ar' ? 'أهلاً بك في قسطها' : 'Welcome to Qasetha';
  String get onboardingSubtitle1 => locale.languageCode == 'ar'
      ? 'حيث تبدأ خطتك الذكية للتقسيط بدون بنوك، بأمان، وتحكم كامل بين يديك!'
      : 'Start your smart installment plan without banks, safely, with full control!';

  String get onboardingTitle2 => locale.languageCode == 'ar'
      ? 'اشتري وادفع بالتقسيط'
      : 'Buy and Pay in Installments';
  String get onboardingSubtitle2 => locale.languageCode == 'ar'
      ? 'منتجات وخدمات. ابدأ خطة تقسيط بدون أي وسطاء أو تعقيدات.'
      : 'Products and services. Start installment plan without intermediaries.';

  String get onboardingTitle3 => locale.languageCode == 'ar'
      ? 'دفع آمن وخيارات مرنة'
      : 'Secure Payment & Flexible Options';
  String get onboardingSubtitle3 => locale.languageCode == 'ar'
      ? 'ادفع أقساطك بكل سهولة عبر وسائل دفع متعددة، مع حماية كاملة لبياناتك.'
      : 'Pay installments easily through multiple payment methods with complete data protection.';

  String get skip => locale.languageCode == 'ar' ? 'تخطي' : 'Skip';
  String get getStarted =>
      locale.languageCode == 'ar' ? 'ابدأ الآن' : 'Get Started';

  // نصوص إضافية للواجهة
  String get home => locale.languageCode == 'ar' ? 'الرئيسية' : 'Home';
  String get profile =>
      locale.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile';
  String get notifications =>
      locale.languageCode == 'ar' ? 'الإشعارات' : 'Notifications';
  String get help => locale.languageCode == 'ar' ? 'المساعدة' : 'Help';
  String get about => locale.languageCode == 'ar' ? 'حول التطبيق' : 'About';
  String get logout => locale.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout';
  String get version => locale.languageCode == 'ar' ? 'الإصدار' : 'Version';

  // نصوص التحقق من البريد الإلكتروني
  String get emailVerification => locale.languageCode == 'ar'
      ? 'تأكيد البريد الإلكتروني'
      : 'Email Verification';
  String get emailVerificationDesc => locale.languageCode == 'ar'
      ? 'تم إرسال رمز التحقق إلى:'
      : 'Verification code sent to:';
  String get verifyCode =>
      locale.languageCode == 'ar' ? 'تأكيد الرمز' : 'Verify Code';
  String get emailVerified => locale.languageCode == 'ar'
      ? 'تم التحقق من البريد الإلكتروني'
      : 'Email verified successfully';

  // نصوص إعادة تعيين كلمة المرور
  String get resetPassword => locale.languageCode == 'ar'
      ? 'إعادة تعيين كلمة المرور'
      : 'Reset Password';
  String get newPassword =>
      locale.languageCode == 'ar' ? 'كلمة المرور الجديدة' : 'New Password';
  String get confirmNewPassword => locale.languageCode == 'ar'
      ? 'تأكيد كلمة المرور الجديدة'
      : 'Confirm New Password';
  String get passwordResetSuccess => locale.languageCode == 'ar'
      ? 'تم إعادة تعيين كلمة المرور بنجاح'
      : 'Password reset successfully';

  // نصوص النجاح
  String get successTitle =>
      locale.languageCode == 'ar' ? 'تم بنجاح!' : 'Success!';
  String get accountCreatedSuccess => locale.languageCode == 'ar'
      ? 'تم إنشاء حسابك بنجاح'
      : 'Your account has been created successfully';
  String get welcomeMessage =>
      locale.languageCode == 'ar' ? 'مرحباً بك في قسطها' : 'Welcome to Qasetha';
  String get continueToApp =>
      locale.languageCode == 'ar' ? 'متابعة للتطبيق' : 'Continue to App';

  // نصوص إضافية للمصادقة
  String get phoneVerificationSuccess => locale.languageCode == 'ar'
      ? 'تم التحقق من الهاتف بنجاح'
      : 'Phone verified successfully';
  String get emailVerificationSent => locale.languageCode == 'ar'
      ? 'تم إرسال بريد التحقق'
      : 'Verification email sent';
  String get otpCodeSent => locale.languageCode == 'ar'
      ? 'تم إرسال رمز التحقق'
      : 'Verification code sent';
  String get invalidPhoneNumber => locale.languageCode == 'ar'
      ? 'رقم الهاتف غير صحيح'
      : 'Invalid phone number';
  String get phoneAlreadyInUse => locale.languageCode == 'ar'
      ? 'رقم الهاتف مستخدم بالفعل'
      : 'Phone number already in use';
  String get smsQuotaExceeded => locale.languageCode == 'ar'
      ? 'تم تجاوز الحد المسموح من الرسائل'
      : 'SMS quota exceeded';
  String get sessionExpired => locale.languageCode == 'ar'
      ? 'انتهت صلاحية الجلسة، حاول مرة أخرى'
      : 'Session expired, try again';
  String get recentLoginRequired => locale.languageCode == 'ar'
      ? 'يجب تسجيل الدخول مرة أخرى لإجراء هذه العملية'
      : 'Please sign in again to perform this operation';
  String get emailNotVerifiedError => locale.languageCode == 'ar'
      ? 'يجب تأكيد البريد الإلكتروني أولاً'
      : 'Please verify your email first';
  String get noUserSignedIn => locale.languageCode == 'ar'
      ? 'لا يوجد مستخدم مسجل دخول'
      : 'No user signed in';
  String get emailAlreadyVerified => locale.languageCode == 'ar'
      ? 'البريد الإلكتروني مؤكد بالفعل'
      : 'Email already verified';
  String get verificationEmailResent => locale.languageCode == 'ar'
      ? 'تم إعادة إرسال بريد التأكيد'
      : 'Verification email resent';
  String get checkingVerification => locale.languageCode == 'ar'
      ? 'جاري فحص التحقق...'
      : 'Checking verification...';
  String get autoVerifyMessage => locale.languageCode == 'ar'
      ? 'سيتم التحقق تلقائياً عند النقر على الرابط'
      : 'Will verify automatically when you click the link';
  String get didntReceiveEmail => locale.languageCode == 'ar'
      ? 'لم تستلم البريد؟'
      : "Didn't receive email?";
  String get passwordSecurityNote => locale.languageCode == 'ar'
      ? 'كلمة المرور الجديدة ستكون مشفرة وآمنة تماماً'
      : 'Your new password will be encrypted and completely secure';
  String get otpDelayMessage => locale.languageCode == 'ar'
      ? 'قد تستغرق الرسالة بضع دقائق للوصول. تحقق من رسائل SMS.'
      : 'The message may take a few minutes to arrive. Check your SMS messages.';
  String get enjoyAllFeatures => locale.languageCode == 'ar'
      ? 'يمكنك الآن الاستمتاع بجميع ميزات التطبيق'
      : 'You can now enjoy all app features';
  String get enterFullName =>
      locale.languageCode == 'ar' ? 'أدخل اسمك الكامل' : 'Enter your full name';
  String get optional => locale.languageCode == 'ar' ? 'اختياري' : 'Optional';
  String get createNewAccount => locale.languageCode == 'ar'
      ? 'أنشئ حسابك الجديد'
      : 'Create your new account';
  String get enterNewPassword => locale.languageCode == 'ar'
      ? 'أدخل كلمة المرور الجديدة لحسابك'
      : 'Enter your new password for your account';
  String get passwordRequirementsTitle => locale.languageCode == 'ar'
      ? 'متطلبات كلمة المرور:'
      : 'Password Requirements:';
  String get verificationLinkSentTo => locale.languageCode == 'ar'
      ? 'تم إرسال رابط التحقق إلى:'
      : 'Verification link sent to:';
  String get verificationIdNotFound => locale.languageCode == 'ar'
      ? 'لم يتم العثور على رمز التحقق'
      : 'Verification ID not found';

  // Missing translations for current usage
  String get enterValidPhoneNumber => locale.languageCode == 'ar'
      ? 'أدخل رقم هاتف صحيح'
      : 'Enter a valid phone number';
  String get otpSendingError => locale.languageCode == 'ar'
      ? 'خطأ في إرسال رمز التحقق'
      : 'Error sending verification code';
  String get phoneVerification =>
      locale.languageCode == 'ar' ? 'تحقق من رقم الهاتف' : 'Phone Verification';
  String get enterCodeSentTo => locale.languageCode == 'ar'
      ? 'أدخل رمز التحقق المرسل إلى'
      : 'Enter the verification code sent to';
  String get verify => locale.languageCode == 'ar' ? 'تحقق' : 'Verify';
  String get resendCodeText =>
      locale.languageCode == 'ar' ? 'إعادة إرسال الرمز' : 'Resend Code';
  String get canResendAfter => locale.languageCode == 'ar'
      ? 'يمكنك إعادة الإرسال بعد'
      : 'You can resend after';
  String get secondsText => locale.languageCode == 'ar' ? 'ثانية' : 'seconds';

  String get pleaseEnterOtp => locale.languageCode == 'ar'
      ? 'يرجى إدخال رمز التحقق'
      : 'Please enter verification code';
  String get pleaseEnterSixDigits => locale.languageCode == 'ar'
      ? 'يرجى إدخال رمز التحقق المكون من 6 أرقام'
      : 'Please enter 6-digit verification code';
  String get otpMustBeNumbers => locale.languageCode == 'ar'
      ? 'رمز التحقق يجب أن يحتوي على أرقام فقط'
      : 'Verification code must contain only numbers';
  String get verificationIdMissing => locale.languageCode == 'ar'
      ? 'معرف التحقق مفقود. يرجى إعادة المحاولة'
      : 'Verification ID missing. Please try again';
  String get unexpectedErrorOccurred => locale.languageCode == 'ar'
      ? 'حدث خطأ غير متوقع'
      : 'An unexpected error occurred';
  String get otpCodeResent => locale.languageCode == 'ar'
      ? 'تم إعادة إرسال رمز التحقق'
      : 'Verification code resent';
  String get otpMustBeSixDigits => locale.languageCode == 'ar'
      ? 'رمز التحقق يجب أن يكون مكوناً من 6 أرقام'
      : 'Verification code must be 6 digits';
  String get otpMustContainOnlyNumbers => locale.languageCode == 'ar'
      ? 'رمز التحقق يجب أن يحتوي على أرقام فقط'
      : 'Verification code must contain only numbers';
  String get phoneVerifiedSuccessfully => locale.languageCode == 'ar'
      ? 'تم التحقق من الهاتف بنجاح'
      : 'Phone verified successfully';
  String get internetConnectionError => locale.languageCode == 'ar'
      ? 'انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مرة أخرى'
      : 'Connection timeout. Check internet and try again';
  String get jordanianPhoneError => locale.languageCode == 'ar'
      ? 'رقم الهاتف الأردني غير صحيح. يجب أن يبدأ بـ 77 أو 78 أو 79'
      : 'Invalid Jordanian phone number. Must start with 77, 78, or 79';
  String get phoneVerificationSent => locale.languageCode == 'ar'
      ? 'تم إرسال رمز التحقق إلى هاتفك'
      : 'Verification code sent to your phone';
  String get verificationCodeSentTimeout => locale.languageCode == 'ar'
      ? 'انتهت مهلة إرسال رمز التحقق. حاول مرة أخرى'
      : 'Verification code sending timeout. Try again';
  String get verificationCodeSendError => locale.languageCode == 'ar'
      ? 'حدث خطأ في إرسال رمز التحقق. حاول مرة أخرى'
      : 'Error sending verification code. Try again';
  String get accountCreationSuccessful => locale.languageCode == 'ar'
      ? 'تم إنشاء الحساب بنجاح. تحقق من بريدك الإلكتروني'
      : 'Account created successfully. Check your email';
  String get mustAcceptTerms => locale.languageCode == 'ar'
      ? 'يجب الموافقة على الشروط والأحكام'
      : 'You must accept the terms and conditions';

  // نصوص عامة إضافية
  String get save => locale.languageCode == 'ar' ? 'حفظ' : 'Save';
  String get edit => locale.languageCode == 'ar' ? 'تعديل' : 'Edit';
  String get delete => locale.languageCode == 'ar' ? 'حذف' : 'Delete';
  String get update => locale.languageCode == 'ar' ? 'تحديث' : 'Update';
  String get refresh => locale.languageCode == 'ar' ? 'تحديث' : 'Refresh';
  String get search => locale.languageCode == 'ar' ? 'بحث' : 'Search';
  String get apply => locale.languageCode == 'ar' ? 'تطبيق' : 'Apply';
  String get reset => locale.languageCode == 'ar' ? 'إعادة تعيين' : 'Reset';
  String get clear => locale.languageCode == 'ar' ? 'مسح' : 'Clear';
  String get done => locale.languageCode == 'ar' ? 'تم' : 'Done';
  String get complete => locale.languageCode == 'ar' ? 'مكتمل' : 'Complete';
  String get pending => locale.languageCode == 'ar' ? 'معلق' : 'Pending';
  String get processing =>
      locale.languageCode == 'ar' ? 'جاري المعالجة' : 'Processing';
  String get failed => locale.languageCode == 'ar' ? 'فشل' : 'Failed';
  String get cancelled => locale.languageCode == 'ar' ? 'ملغي' : 'Cancelled';
  String get enabled => locale.languageCode == 'ar' ? 'مفعل' : 'Enabled';
  String get disabled => locale.languageCode == 'ar' ? 'معطل' : 'Disabled';
  String get available => locale.languageCode == 'ar' ? 'متاح' : 'Available';
  String get unavailable =>
      locale.languageCode == 'ar' ? 'غير متاح' : 'Unavailable';
  String get online => locale.languageCode == 'ar' ? 'متصل' : 'Online';
  String get offline => locale.languageCode == 'ar' ? 'غير متصل' : 'Offline';

  // Profile Screen Translations
  String get profileCompletion => locale.languageCode == 'ar'
      ? 'اكتمال الملف الشخصي'
      : 'Profile Completion';
  String get personalInformation => locale.languageCode == 'ar'
      ? 'المعلومات الشخصية'
      : 'Personal Information';
  String get creditInformation =>
      locale.languageCode == 'ar' ? 'معلومات الائتمان' : 'Credit Information';
  String get quickActions =>
      locale.languageCode == 'ar' ? 'الإجراءات السريعة' : 'Quick Actions';
  String get securityPrivacy =>
      locale.languageCode == 'ar' ? 'الأمان والخصوصية' : 'Security & Privacy';
  String get fullName =>
      locale.languageCode == 'ar' ? 'الاسم الكامل' : 'Full Name';
  String get nationalId =>
      locale.languageCode == 'ar' ? 'رقم الهوية الوطنية' : 'National ID';
  String get employment => locale.languageCode == 'ar' ? 'العمل' : 'Employment';
  String get address => locale.languageCode == 'ar' ? 'العنوان' : 'Address';
  String get creditLimit =>
      locale.languageCode == 'ar' ? 'حد الائتمان' : 'Credit Limit';
  String get availableCredit =>
      locale.languageCode == 'ar' ? 'الائتمان المتاح' : 'Available Credit';
  String get usedCredit =>
      locale.languageCode == 'ar' ? 'الائتمان المستخدم' : 'Used Credit';
  String get totalDebt =>
      locale.languageCode == 'ar' ? 'إجمالي الدين' : 'Total Debt';
  String get creditHistory =>
      locale.languageCode == 'ar' ? 'تاريخ الائتمان' : 'Credit History';
  String get viewCreditHistory => locale.languageCode == 'ar'
      ? 'عرض تاريخ الائتمان'
      : 'View Credit History';
  String get requestCreditIncrease => locale.languageCode == 'ar'
      ? 'طلب زيادة الائتمان'
      : 'Request Credit Increase';
  String get viewTransactions =>
      locale.languageCode == 'ar' ? 'عرض المعاملات' : 'View Transactions';
  String get paymentHistory =>
      locale.languageCode == 'ar' ? 'تاريخ المدفوعات' : 'Payment History';
  String get creditReport =>
      locale.languageCode == 'ar' ? 'تقرير الائتمان' : 'Credit Report';
  String get downloadStatement =>
      locale.languageCode == 'ar' ? 'تحميل الكشف' : 'Download Statement';
  String get contactSupport =>
      locale.languageCode == 'ar' ? 'الاتصال بالدعم' : 'Contact Support';
  String get referFriend =>
      locale.languageCode == 'ar' ? 'أحل صديق' : 'Refer a Friend';
  String get changePassword =>
      locale.languageCode == 'ar' ? 'تغيير كلمة المرور' : 'Change Password';
  String get twoFactorAuth => locale.languageCode == 'ar'
      ? 'المصادقة الثنائية'
      : 'Two-Factor Authentication';
  String get biometricLogin => locale.languageCode == 'ar'
      ? 'تسجيل الدخول البيومتري'
      : 'Biometric Login';
  String get loginHistory =>
      locale.languageCode == 'ar' ? 'تاريخ تسجيل الدخول' : 'Login History';
  String get pushNotifications =>
      locale.languageCode == 'ar' ? 'الإشعارات الفورية' : 'Push Notifications';
  String get privacyPolicy =>
      locale.languageCode == 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get dataExport =>
      locale.languageCode == 'ar' ? 'تصدير البيانات' : 'Data Export';
  String get deleteAccount =>
      locale.languageCode == 'ar' ? 'حذف الحساب' : 'Delete Account';
  String get verified => locale.languageCode == 'ar' ? 'موثق' : 'Verified';
  String get unverified =>
      locale.languageCode == 'ar' ? 'غير موثق' : 'Unverified';
  String get customer => locale.languageCode == 'ar' ? 'عميل' : 'Customer';
  String get storeOwner =>
      locale.languageCode == 'ar' ? 'صاحب متجر' : 'Store Owner';
  String get admin => locale.languageCode == 'ar' ? 'مدير' : 'Admin';
  String get employed => locale.languageCode == 'ar' ? 'موظف' : 'Employed';
  String get unemployed =>
      locale.languageCode == 'ar' ? 'غير موظف' : 'Unemployed';
  String get sector => locale.languageCode == 'ar' ? 'القطاع' : 'Sector';
  String get publicSector =>
      locale.languageCode == 'ar' ? 'القطاع العام' : 'Public Sector';
  String get privateSector =>
      locale.languageCode == 'ar' ? 'القطاع الخاص' : 'Private Sector';
  String get employer => locale.languageCode == 'ar' ? 'جهة العمل' : 'Employer';
  String get jobTitle =>
      locale.languageCode == 'ar' ? 'المسمى الوظيفي' : 'Job Title';
  String get employeeId =>
      locale.languageCode == 'ar' ? 'رقم الموظف' : 'Employee ID';
  String get street => locale.languageCode == 'ar' ? 'الشارع' : 'Street';
  String get city => locale.languageCode == 'ar' ? 'المدينة' : 'City';
  String get governorate =>
      locale.languageCode == 'ar' ? 'المحافظة' : 'Governorate';
  String get postalCode =>
      locale.languageCode == 'ar' ? 'الرمز البريدي' : 'Postal Code';
  String get chooseFromGallery =>
      locale.languageCode == 'ar' ? 'اختر من المعرض' : 'Choose from Gallery';
  String get takePhoto =>
      locale.languageCode == 'ar' ? 'التقط صورة' : 'Take Photo';
  String get removePhoto =>
      locale.languageCode == 'ar' ? 'إزالة الصورة' : 'Remove Photo';
  String get profileImageUpdated => locale.languageCode == 'ar'
      ? 'تم تحديث صورة الملف الشخصي'
      : 'Profile image updated';
  String get profileUpdated =>
      locale.languageCode == 'ar' ? 'تم تحديث الملف الشخصي' : 'Profile updated';
  String get currentPassword =>
      locale.languageCode == 'ar' ? 'كلمة المرور الحالية' : 'Current Password';
  String get passwordChanged =>
      locale.languageCode == 'ar' ? 'تم تغيير كلمة المرور' : 'Password changed';
  String get passwordsDoNotMatchError => locale.languageCode == 'ar'
      ? 'كلمات المرور غير متطابقة'
      : 'Passwords do not match';
  String get biometricNotAvailable => locale.languageCode == 'ar'
      ? 'المصادقة البيومترية غير متاحة'
      : 'Biometric authentication not available';
  String get requestSubmitted =>
      locale.languageCode == 'ar' ? 'تم إرسال الطلب' : 'Request submitted';
  String get missingFields =>
      locale.languageCode == 'ar' ? 'الحقول المفقودة' : 'Missing Fields';
  String get completeTheseFields => locale.languageCode == 'ar'
      ? 'أكمل هذه الحقول لتحسين ملفك الشخصي'
      : 'Complete these fields to improve your profile';
  String get gotIt => locale.languageCode == 'ar' ? 'فهمت' : 'Got it';
  String get profileAlmostComplete => locale.languageCode == 'ar'
      ? 'ملفك الشخصي شبه مكتمل!'
      : 'Your profile is almost complete!';
  String get goodProgress => locale.languageCode == 'ar'
      ? 'تقدم جيد! بقي بعض الحقول.'
      : 'Good progress! A few more fields to go.';
  String get halfwayThere => locale.languageCode == 'ar'
      ? 'أنت في منتصف الطريق! استمر.'
      : 'You\'re halfway there! Keep going.';
  String get completeProfileBetter => locale.languageCode == 'ar'
      ? 'أكمل ملفك الشخصي للحصول على تجربة أفضل'
      : 'Complete your profile for better experience';
  String get currentlyEmployed =>
      locale.languageCode == 'ar' ? 'موظف حالياً' : 'Currently Employed';
  String get employerName =>
      locale.languageCode == 'ar' ? 'اسم جهة العمل' : 'Employer Name';
  String get required => locale.languageCode == 'ar' ? 'مطلوب' : 'Required';
  String get requestedAmount =>
      locale.languageCode == 'ar' ? 'المبلغ المطلوب' : 'Requested Amount';
  String get reasonForIncrease =>
      locale.languageCode == 'ar' ? 'سبب الزيادة' : 'Reason for Increase';
  String get submit => locale.languageCode == 'ar' ? 'إرسال' : 'Submit';
  String get creditIncreaseRequestSubmitted => locale.languageCode == 'ar'
      ? 'تم إرسال طلب زيادة الائتمان بنجاح!'
      : 'Credit increase request submitted successfully!';
  String get fillAllFields => locale.languageCode == 'ar'
      ? 'يرجى ملء جميع الحقول'
      : 'Please fill all fields';
  String get featureComingSoon => locale.languageCode == 'ar'
      ? 'هذه الميزة قادمة قريباً!'
      : 'This feature is coming soon!';
  String get addExtraSecurityLayer => locale.languageCode == 'ar'
      ? 'إضافة طبقة أمان إضافية'
      : 'Add an extra layer of security';
  String get useFingerprintFace => locale.languageCode == 'ar'
      ? 'استخدم بصمة الإصبع أو التعرف على الوجه'
      : 'Use fingerprint or face recognition';
  String get viewRecentLoginActivity => locale.languageCode == 'ar'
      ? 'عرض نشاط تسجيل الدخول الأخير'
      : 'View your recent login activity';
  String get receiveAlertsUpdates => locale.languageCode == 'ar'
      ? 'تلقي التنبيهات والتحديثات'
      : 'Receive alerts and updates';
  String get reviewPrivacyPolicy => locale.languageCode == 'ar'
      ? 'مراجعة سياسة الخصوصية'
      : 'Review our privacy policy';
  String get downloadPersonalData => locale.languageCode == 'ar'
      ? 'تحميل بياناتك الشخصية'
      : 'Download your personal data';
  String get permanentlyDeleteAccount => locale.languageCode == 'ar'
      ? 'حذف حسابك نهائياً'
      : 'Permanently delete your account';
  String get change => locale.languageCode == 'ar' ? 'تغيير' : 'Change';
  String get twoFactorAuthDescription => locale.languageCode == 'ar'
      ? 'تضيف المصادقة الثنائية طبقة أمان إضافية لحسابك.'
      : 'Two-factor authentication adds an extra layer of security to your account.';
  String get exportDataDescription => locale.languageCode == 'ar'
      ? 'تصدير بياناتك الشخصية ومعلومات الحساب.'
      : 'Export your personal data and account information.';
  String get deleteAccountConfirmation => locale.languageCode == 'ar'
      ? 'هل أنت متأكد أنك تريد حذف حسابك؟'
      : 'Are you sure you want to delete your account?';
  String get actionCannotBeUndone => locale.languageCode == 'ar'
      ? 'لا يمكن التراجع عن هذا الإجراء وستتم إزالة جميع بياناتك نهائياً.'
      : 'This action cannot be undone and all your data will be permanently removed.';
  String get logoutConfirmation => locale.languageCode == 'ar'
      ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
      : 'Are you sure you want to logout?';
  String get jod => locale.languageCode == 'ar' ? 'دينار' : 'JOD';
  String get creditUsed =>
      locale.languageCode == 'ar' ? 'الائتمان المستخدم' : 'Credit Used';
  String get updatePassword => locale.languageCode == 'ar'
      ? 'تحديث كلمة المرور لحسابك'
      : 'Update your account password';
  String get privacySettings =>
      locale.languageCode == 'ar' ? 'إعدادات الخصوصية' : 'Privacy Settings';
  String get tapToSeeMissingFields => locale.languageCode == 'ar'
      ? 'اضغط لرؤية الحقول المفقودة'
      : 'Tap to see missing fields';
  String get currentCreditLimit => locale.languageCode == 'ar'
      ? 'حد الائتمان الحالي'
      : 'Current Credit Limit';
  String get none => locale.languageCode == 'ar' ? 'لا يوجد' : 'None';
  String get public => locale.languageCode == 'ar' ? 'عام' : 'Public';
  String get private => locale.languageCode == 'ar' ? 'خاص' : 'Private';
  String get employmentStatus =>
      locale.languageCode == 'ar' ? 'حالة العمل' : 'Employment Status';
  String get profileImage =>
      locale.languageCode == 'ar' ? 'صورة الملف الشخصي' : 'Profile Image';
  String get streetAddress =>
      locale.languageCode == 'ar' ? 'عنوان الشارع' : 'Street Address';
  String get accountVerification =>
      locale.languageCode == 'ar' ? 'التحقق من الحساب' : 'Account Verification';

  // Profile Completion Modal translations
  String get completeYourProfileModal => locale.languageCode == 'ar'
      ? 'أكمل ملفك الشخصي'
      : 'Complete Your Profile';
  String get completeProfileModalDescription => locale.languageCode == 'ar'
      ? 'أكمل ملفك الشخصي لتتمكن من الشراء بالأقساط والاستفادة من جميع المميزات'
      : 'Complete your profile to enable credit purchases and unlock all features';
  String get completeNowButton =>
      locale.languageCode == 'ar' ? 'أكمل الآن' : 'Complete Now';
  String get laterButton => locale.languageCode == 'ar' ? 'لاحقاً' : 'Later';

  // Profile Completion Wizard translations
  String get stepNumber => locale.languageCode == 'ar' ? 'الخطوة' : 'Step';
  String get ofTotal => locale.languageCode == 'ar' ? 'من' : 'of';
  String get personalInformationStep => locale.languageCode == 'ar'
      ? 'المعلومات الشخصية'
      : 'Personal Information';
  String get employmentInformationStep =>
      locale.languageCode == 'ar' ? 'معلومات العمل' : 'Employment Information';
  String get addressInformationStep =>
      locale.languageCode == 'ar' ? 'معلومات العنوان' : 'Address Information';
  String get reviewAndSubmit =>
      locale.languageCode == 'ar' ? 'مراجعة وإرسال' : 'Review & Submit';
  String get skipButton => locale.languageCode == 'ar' ? 'تخطي' : 'Skip';
  String get finishButton => locale.languageCode == 'ar' ? 'إنهاء' : 'Complete';
  String get tapToAddPhoto =>
      locale.languageCode == 'ar' ? 'اضغط لإضافة صورة' : 'Tap to add photo';

  // Profile Completion Indicator translations
  String get completeProfileForBetterExperience => locale.languageCode == 'ar'
      ? 'أكمل ملفك الشخصي للحصول على تجربة أفضل'
      : 'Complete your profile for better experience';
  String get profileAlmostCompleteIndicator => locale.languageCode == 'ar'
      ? 'ملفك الشخصي شبه مكتمل!'
      : 'Your profile is almost complete!';
  String get goodProgressFewMoreFields => locale.languageCode == 'ar'
      ? 'تقدم جيد! بقي بعض الحقول.'
      : 'Good progress! A few more fields to go.';
  String get halfwayThereKeepGoing => locale.languageCode == 'ar'
      ? 'أنت في منتصف الطريق! استمر.'
      : 'You\'re halfway there! Keep going.';
  String get completeStatus =>
      locale.languageCode == 'ar' ? 'مكتمل' : 'Complete';
  String get profileCompletionTitle =>
      locale.languageCode == 'ar' ? 'إكمال الملف الشخصي' : 'Profile Completion';
  String get yourProfileIsComplete => locale.languageCode == 'ar'
      ? 'ملفك الشخصي مكتمل!'
      : 'Your profile is complete!';
  String get completeProfileToUnlockFeatures => locale.languageCode == 'ar'
      ? 'أكمل ملفك الشخصي للحصول على المزيد من المميزات'
      : 'Complete your profile to unlock more features';
  String get missingFieldsCount =>
      locale.languageCode == 'ar' ? 'الحقول المفقودة' : 'Missing fields';

  // Profile Completion Service translations
  String get profileCompletionIncentives => locale.languageCode == 'ar'
      ? 'مميزات إكمال الملف الشخصي'
      : 'Profile Completion Benefits';
  String get higherCreditLimit => locale.languageCode == 'ar'
      ? 'حد ائتمان أعلى يصل إلى 500 دينار'
      : 'Higher credit limit up to 500 JOD';
  String get fasterCheckout => locale.languageCode == 'ar'
      ? 'عملية شراء أسرع'
      : 'Faster checkout process';
  String get exclusiveOffers =>
      locale.languageCode == 'ar' ? 'عروض حصرية' : 'Exclusive offers';
  String get prioritySupport =>
      locale.languageCode == 'ar' ? 'أولوية في الدعم' : 'Priority support';
  String get additionalFeatures =>
      locale.languageCode == 'ar' ? 'مميزات إضافية' : 'Additional features';

  // Employment specific translations
  String get employmentInformation =>
      locale.languageCode == 'ar' ? 'معلومات العمل' : 'Employment Information';
  String get addressInformation =>
      locale.languageCode == 'ar' ? 'معلومات العنوان' : 'Address Information';
  String get goodStart => locale.languageCode == 'ar'
      ? 'بداية جيدة! أكمل ملفك الشخصي.'
      : 'Good start! Complete your profile.';

  // Error and validation messages
  String get profileImageRequired => locale.languageCode == 'ar'
      ? 'صورة الملف الشخصي مطلوبة'
      : 'Profile image is required';
  String get employerNameRequired => locale.languageCode == 'ar'
      ? 'اسم جهة العمل مطلوب'
      : 'Employer name is required';
  String get jobTitleRequired => locale.languageCode == 'ar'
      ? 'المسمى الوظيفي مطلوب'
      : 'Job title is required';
  String get employmentSectorRequired => locale.languageCode == 'ar'
      ? 'قطاع العمل مطلوب'
      : 'Employment sector is required';
  String get streetRequired =>
      locale.languageCode == 'ar' ? 'الشارع مطلوب' : 'Street is required';
  String get cityRequired =>
      locale.languageCode == 'ar' ? 'المدينة مطلوبة' : 'City is required';
  String get governorateRequired => locale.languageCode == 'ar'
      ? 'المحافظة مطلوبة'
      : 'Governorate is required';
  String get postalCodeRequired => locale.languageCode == 'ar'
      ? 'الرمز البريدي مطلوب'
      : 'Postal code is required';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension للوصول السهل
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  // Helper للحصول على اتجاه النص
  bool get isRTL => AppLocalizations.of(this)!.locale.languageCode == 'ar';

  // Helper للحصول على TextDirection
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;
}
