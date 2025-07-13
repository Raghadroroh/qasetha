import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  // النصوص المترجمة
  String get appTitle => locale.languageCode == 'ar' ? 'قسطها' : 'Qasetha';
  String get welcome => locale.languageCode == 'ar' ? 'أهلاً بك' : 'Welcome Back';
  String get login => locale.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login';
  String get signup => locale.languageCode == 'ar' ? 'إنشاء حساب' : 'Sign Up';
  String get email => locale.languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email';
  String get password => locale.languageCode == 'ar' ? 'كلمة المرور' : 'Password';
  String get phone => locale.languageCode == 'ar' ? 'رقم الهاتف' : 'Phone Number';
  String get name => locale.languageCode == 'ar' ? 'الاسم الكامل' : 'Full Name';
  String get confirmPassword => locale.languageCode == 'ar' ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get forgotPassword => locale.languageCode == 'ar' ? 'نسيت كلمة المرور؟' : 'Forgot Password?';
  String get dontHaveAccount => locale.languageCode == 'ar' ? 'ليس لديك حساب؟' : "Don't have an account?";
  String get alreadyHaveAccount => locale.languageCode == 'ar' ? 'لديك حساب بالفعل؟' : 'Already have an account?';
  String get verifyPhone => locale.languageCode == 'ar' ? 'تسجيل الدخول برقم الهاتف' : 'Login with Phone Number';
  String get language => locale.languageCode == 'ar' ? 'اختر اللغة' : 'Choose Language';
  String get arabic => locale.languageCode == 'ar' ? 'العربية' : 'العربية';
  String get english => locale.languageCode == 'ar' ? 'English' : 'English';
  String get fieldRequired => locale.languageCode == 'ar' ? 'هذا الحقل مطلوب' : 'This field is required';
  String get passwordsDoNotMatch => locale.languageCode == 'ar' ? 'كلمات المرور غير متطابقة' : 'Passwords do not match';
  String get loginSuccess => locale.languageCode == 'ar' ? 'تم تسجيل الدخول بنجاح' : 'Login successful';
  String get loginError => locale.languageCode == 'ar' ? 'خطأ في تسجيل الدخول' : 'Login error';
  String get or => locale.languageCode == 'ar' ? 'أو' : 'OR';
  String get settings => locale.languageCode == 'ar' ? 'الإعدادات' : 'Settings';
  String get accountCreated => locale.languageCode == 'ar' ? 'تم إنشاء الحساب بنجاح' : 'Account created successfully';
  String get error => locale.languageCode == 'ar' ? 'خطأ' : 'Error';
  String get backToLogin => locale.languageCode == 'ar' ? 'العودة إلى تسجيل الدخول' : 'Back to Login';
  String get sendResetLink => locale.languageCode == 'ar' ? 'إرسال رابط الاسترداد' : 'Send Reset Link';
  String get resetLinkSent => locale.languageCode == 'ar' ? 'تم إرسال رابط إعادة تعيين كلمة المرور' : 'Password reset link sent';
  String get forgotPasswordDesc => locale.languageCode == 'ar' ? 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور' : 'Enter your email and we will send you a password reset link';
  
  // نصوص الإعدادات والثيم
  String get chooseLanguage => locale.languageCode == 'ar' ? 'اختر اللغة' : 'Choose Language';
  String get chooseTheme => locale.languageCode == 'ar' ? 'اختر المظهر' : 'Choose Theme';
  String get systemLanguage => locale.languageCode == 'ar' ? 'لغة النظام' : 'System Language';
  String get lightTheme => locale.languageCode == 'ar' ? 'المظهر الفاتح' : 'Light Theme';
  String get darkTheme => locale.languageCode == 'ar' ? 'المظهر الداكن' : 'Dark Theme';
  String get systemTheme => locale.languageCode == 'ar' ? 'مظهر النظام' : 'System Theme';
  String get languageChangedSuccessfully => locale.languageCode == 'ar' ? 'تم تغيير اللغة بنجاح' : 'Language changed successfully';
  String get themeChangedSuccessfully => locale.languageCode == 'ar' ? 'تم تغيير المظهر بنجاح' : 'Theme changed successfully';
  String get selectLanguageFirst => locale.languageCode == 'ar' ? 'اختر لغتك المفضلة' : 'Select your preferred language';
  String get canChangeLanguageLater => locale.languageCode == 'ar' ? 'يمكنك تغيير اللغة لاحقاً من الإعدادات' : 'You can change language later in settings';
  String get welcomeToApp => locale.languageCode == 'ar' ? 'مرحباً بك في التطبيق' : 'Welcome to the App';
  String get backButton => locale.languageCode == 'ar' ? 'رجوع' : 'Back';
  String get continueButton => locale.languageCode == 'ar' ? 'متابعة' : 'Continue';
  String get cancel => locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get confirm => locale.languageCode == 'ar' ? 'تأكيد' : 'Confirm';
  String get close => locale.languageCode == 'ar' ? 'إغلاق' : 'Close';
  
  // نصوص onboarding
  String get onboardingTitle1 => locale.languageCode == 'ar' ? 'أهلاً بك في قسطها' : 'Welcome to Qasetha';
  String get onboardingSubtitle1 => locale.languageCode == 'ar' 
      ? 'حيث تبدأ خطتك الذكية للتقسيط بدون بنوك، بأمان، وتحكم كامل بين يديك!'
      : 'Start your smart installment plan without banks, safely, with full control!';
  
  String get onboardingTitle2 => locale.languageCode == 'ar' ? 'اشتري وادفع بالتقسيط' : 'Buy and Pay in Installments';
  String get onboardingSubtitle2 => locale.languageCode == 'ar'
      ? 'منتجات وخدمات. ابدأ خطة تقسيط بدون أي وسطاء أو تعقيدات.'
      : 'Products and services. Start installment plan without intermediaries.';
  
  String get onboardingTitle3 => locale.languageCode == 'ar' ? 'دفع آمن وخيارات مرنة' : 'Secure Payment & Flexible Options';
  String get onboardingSubtitle3 => locale.languageCode == 'ar'
      ? 'ادفع أقساطك بكل سهولة عبر وسائل دفع متعددة، مع حماية كاملة لبياناتك.'
      : 'Pay installments easily through multiple payment methods with complete data protection.';
  
  String get skip => locale.languageCode == 'ar' ? 'تخطي' : 'Skip';
  String get next => locale.languageCode == 'ar' ? 'التالي' : 'Next';
  String get getStarted => locale.languageCode == 'ar' ? 'ابدأ الآن' : 'Get Started';
  
  // نصوص إضافية للواجهة
  String get home => locale.languageCode == 'ar' ? 'الرئيسية' : 'Home';
  String get profile => locale.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile';
  String get notifications => locale.languageCode == 'ar' ? 'الإشعارات' : 'Notifications';
  String get help => locale.languageCode == 'ar' ? 'المساعدة' : 'Help';
  String get about => locale.languageCode == 'ar' ? 'حول التطبيق' : 'About';
  String get logout => locale.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout';
  String get version => locale.languageCode == 'ar' ? 'الإصدار' : 'Version';
  String get loading => locale.languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...';
  String get retry => locale.languageCode == 'ar' ? 'إعادة المحاولة' : 'Retry';
  String get noInternetConnection => locale.languageCode == 'ar' ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
  String get somethingWentWrong => locale.languageCode == 'ar' ? 'حدث خطأ ما' : 'Something went wrong';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
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
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;
}