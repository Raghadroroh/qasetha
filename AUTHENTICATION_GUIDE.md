# دليل نظام المصادقة والأمان - قاسيثا

## نظرة عامة

تم تطوير نظام مصادقة شامل يدعم:
- التسجيل بالبيومترك (البصمة، الوجه، رمز الجهاز)
- المصادقة بكلمة المرور
- نظام OTP احتياطي للأجهزة غير المدعومة
- حماية العمليات المالية

## الملفات الرئيسية

### الخدمات (Services)
- `biometric_auth_service.dart` - خدمة المصادقة البيومترية
- `otp_service.dart` - خدمة OTP الاحتياطية
- `firebase_auth_service.dart` - خدمة Firebase للمصادقة

### الشاشات (Screens)
- `signup_screen.dart` - شاشة التسجيل مع إعداد البيومترك
- `login_screen.dart` - شاشة الدخول مع خيارات متعددة
- `transaction_security_screen.dart` - شاشة أمان العمليات المالية
- `security_settings_screen.dart` - إعدادات الأمان

### المساعدات (Helpers)
- `transaction_security_helper.dart` - مساعد لاستخدام شاشة الأمان

## كيفية الاستخدام

### 1. التسجيل مع البيومترك

```dart
// في شاشة التسجيل، بعد إنشاء الحساب بنجاح:
if (_availableBiometrics.isNotEmpty) {
  _showBiometricSetupDialog();
} else {
  _showFallbackMessage();
}
```

### 2. تسجيل الدخول

```dart
// تسجيل دخول بالبيومترك
Future<void> _loginWithBiometric() async {
  final result = await _biometricService.authenticateUser(
    reason: AppStrings.biometricLogin,
  );
  
  if (result.isSuccess) {
    context.go('/home');
  }
}

// تسجيل دخول بكلمة المرور
Future<void> _loginWithPassword() async {
  final result = await _authService.signInWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );
}
```

### 3. حماية العمليات المالية

```dart
// استخدام المساعد للعمليات المالية
Future<void> _sendMoney() async {
  final isAuthenticated = await TransactionSecurityHelper.authenticateForSendMoney(
    context: context,
    amount: '100 دينار',
    recipient: 'أحمد محمد',
  );

  if (isAuthenticated) {
    // تنفيذ العملية
    _processSendMoney();
  } else {
    // إلغاء العملية
    _showCancelledMessage();
  }
}
```

### 4. إدارة إعدادات الأمان

```dart
// التنقل لشاشة إعدادات الأمان
context.go('/security-settings');

// تفعيل/إلغاء البيومترك
Future<void> _toggleBiometric(bool enable) async {
  if (enable) {
    final result = await _biometricService.enableBiometric();
    if (result.isSuccess) {
      // تم التفعيل بنجاح
    }
  } else {
    await _biometricService.disableBiometric();
    // تم الإلغاء
  }
}
```

## تدفق العمل

### تسجيل حساب جديد
1. المستخدم يدخل البيانات (الاسم، البريد، الهاتف، كلمة المرور)
2. إنشاء الحساب في Firebase
3. فحص توفر البيومترك على الجهاز
4. إذا متوفر: عرض حوار تفعيل البيومترك
5. إذا غير متوفر: عرض رسالة الاعتماد على OTP

### تسجيل الدخول
1. فحص حالة البيومترك (متوفر ومفعل)
2. إذا مفعل: عرض زر الدخول السريع
3. إذا غير مفعل: عرض نموذج كلمة المرور فقط
4. إمكانية التبديل بين الطرق

### العمليات المالية
1. المستخدم يطلب عملية مالية
2. عرض شاشة التحقق الأمني
3. إذا البيومترك متاح: طلب المصادقة البيومترية
4. إذا فشل أو غير متاح: عرض خيارات OTP
5. إرسال OTP عبر البريد أو SMS
6. التحقق من الرمز
7. إتمام أو إلغاء العملية

## الأمان والحماية

### البيومترك
- فحص توفر الجهاز قبل الاستخدام
- تشفير البيانات المحلية
- تسجيل جميع محاولات المصادقة
- دعم أنواع متعددة (بصمة، وجه، رمز الجهاز)

### OTP
- رموز مؤقتة (5 دقائق صلاحية)
- حد أقصى 3 محاولات
- تشفير الرموز المحفوظة
- دعم البريد الإلكتروني و SMS

### تسجيل الأحداث
- جميع محاولات المصادقة مسجلة في Firebase Analytics
- الأخطاء مسجلة في Firebase Crashlytics
- معلومات مفصلة لتحليل الأمان

## التخصيص

### إضافة طرق مصادقة جديدة
1. إضافة الطريقة في `BiometricAuthService`
2. تحديث واجهة المستخدم
3. إضافة النصوص في `AppStrings`

### تخصيص رسائل الخطأ
- تحديث `BiometricAuthResultExtension`
- إضافة رسائل جديدة في `AppStrings`

### تخصيص مدة OTP
- تغيير `_otpValidityMinutes` في `OTPService`
- تحديث عدد المحاولات `_maxOtpAttempts`

## الاختبار

### اختبار البيومترك
```dart
// فحص التوفر
final isAvailable = await BiometricAuthService().isBiometricAvailable();

// اختبار المصادقة
final result = await BiometricAuthService().authenticateUser(
  reason: 'اختبار المصادقة',
);
```

### اختبار OTP
```dart
// إرسال OTP
final result = await OTPService().sendEmailOTP('test@example.com');

// التحقق من OTP
final verifyResult = await OTPService().verifyOTP('123456');
```

## الأخطاء الشائعة وحلولها

### البيومترك غير متاح
- التأكد من دعم الجهاز
- التأكد من إعداد البيومترك في الجهاز
- فحص أذونات التطبيق

### فشل OTP
- التأكد من صحة البريد الإلكتروني/الهاتف
- فحص انتهاء صلاحية الرمز
- التأكد من عدم تجاوز عدد المحاولات

### مشاكل Firebase
- التأكد من تكوين Firebase
- فحص اتصال الإنترنت
- التأكد من صحة مفاتيح API

## الدعم والصيانة

- مراجعة دورية لسجلات الأمان
- تحديث مكتبات الأمان
- اختبار دوري للوظائف
- مراقبة معدلات نجاح المصادقة

## المتطلبات التقنية

### الأذونات المطلوبة (Android)
```xml
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### الأذونات المطلوبة (iOS)
```xml
<key>NSFaceIDUsageDescription</key>
<string>استخدام Face ID لتسجيل الدخول الآمن</string>
```

### المكتبات المطلوبة
- `local_auth: ^2.1.6`
- `flutter_secure_storage: ^9.0.0`
- `firebase_auth: ^4.20.0`
- `firebase_analytics: ^10.10.7`
- `firebase_crashlytics: ^3.4.8`