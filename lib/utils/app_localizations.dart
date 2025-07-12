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

  // النصوص المترجمة - افتراضي عربي
  String get appTitle => 'قسطها';
  String get welcome => 'أهلاً بك';
  String get login => 'تسجيل الدخول';
  String get signup => 'إنشاء حساب';
  String get email => 'البريد الإلكتروني';
  String get password => 'كلمة المرور';
  String get phone => 'رقم الهاتف';
  String get name => 'الاسم الكامل';
  String get confirmPassword => 'تأكيد كلمة المرور';
  String get forgotPassword => 'نسيت كلمة المرور؟';
  String get dontHaveAccount => 'ليس لديك حساب؟';
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';
  String get verifyPhone => 'تسجيل الدخول برقم الهاتف';
  String get language => 'اختر اللغة';
  String get arabic => 'العربية';
  String get english => 'English';
  String get fieldRequired => 'هذا الحقل مطلوب';
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';
  
  // نصوص onboarding - عربي فقط
  String get onboardingTitle1 => 'أهلاً بك في قسطها';
  String get onboardingSubtitle1 => 'حيث تبدأ خطتك الذكية للتقسيط بدون بنوك، بأمان، وتحكم كامل بين يديك!';
  
  String get onboardingTitle2 => 'اشتري وادفع بالتقسيط';
  String get onboardingSubtitle2 => 'منتجات وخدمات. ابدأ خطة تقسيط بدون أي وسطاء أو تعقيدات.';
  
  String get onboardingTitle3 => 'دفع آمن وخيارات مرنة';
  String get onboardingSubtitle3 => 'ادفع أقساطك بكل سهولة عبر وسائل دفع متعددة، مع حماية كاملة لبياناتك.';
  
  String get skip => 'تخطي';
  String get next => 'التالي';
  String get getStarted => 'ابدأ الآن';
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
}