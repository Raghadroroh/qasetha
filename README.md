# 🌟 Qasetha - Flutter Authentication App

تطبيق Flutter متكامل لإدارة المصادقة والتسجيل باستخدام Firebase مع دعم كامل للغة العربية.

## 📱 لقطات الشاشة

- شاشة تسجيل الدخول مع تصميم متدرج حديث
- دعم تسجيل الدخول بالبريد الإلكتروني أو رقم الهاتف
- واجهة عربية بالكامل مع خط Tajawal

## ✨ الميزات الرئيسية

### 🔐 المصادقة المتقدمة
- **تسجيل الدخول المزدوج**: بريد إلكتروني + كلمة مرور أو رقم هاتف + OTP
- **إنشاء الحسابات**: دعم التسجيل بالبريد أو الهاتف
- **إعادة تعيين كلمة المرور**: عبر البريد الإلكتروني أو SMS
- **تأكيد البريد الإلكتروني**: مع إعادة الإرسال التلقائي
- **رمز التحقق (OTP)**: للهواتف مع مؤقت إعادة الإرسال

### 🎨 التصميم والواجهة
- **تصميم متدرج حديث**: ألوان أزرق وبنفسجي متدرجة
- **أنيميشن سلس**: تأثيرات الظهور والانزلاق
- **دعم RTL كامل**: واجهة عربية احترافية
- **تصميم متجاوب**: يعمل على جميع أحجام الشاشات

### 🛡️ الأمان والحماية
- **التحقق من كلمة المرور**: 8 أحرف، أحرف كبيرة/صغيرة، أرقام، رموز خاصة
- **حماية async**: فحص `mounted` في جميع العمليات غير المتزامنة
- **معالجة الأخطاء**: رسائل خطأ واضحة بالعربية
- **تسجيل احترافي**: نظام logging متقدم

## 🏗️ هيكل المشروع

```
lib/
├── screens/
│   ├── auth/                    # شاشات المصادقة
│   │   ├── login_screen.dart    # تسجيل الدخول
│   │   ├── signup_screen.dart   # إنشاء حساب
│   │   ├── forgot_password_screen.dart  # نسيان كلمة المرور
│   │   ├── verify_email_screen.dart     # تأكيد البريد
│   │   ├── reset_password_screen.dart   # إعادة تعيين كلمة المرور
│   │   └── otp_screen.dart      # رمز التحقق
│   └── onboarding_screen.dart   # شاشة البداية
├── routes/
│   └── router.dart              # نظام التوجيه
├── services/
│   ├── firebase_auth_service.dart   # خدمات Firebase
│   └── logger_service.dart      # نظام التسجيل
└── utils/
    └── password_validator.dart  # التحقق من كلمة المرور
```

## 🔧 التقنيات المستخدمة

### Dependencies الأساسية
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.14.0      # Firebase الأساسي
  firebase_auth: ^5.6.0       # المصادقة
  cloud_firestore: ^5.6.9     # قاعدة البيانات
  go_router: ^15.2.4          # التوجيه
  google_fonts: ^6.2.1        # الخطوط العربية
  logger: ^2.4.0              # نظام التسجيل
```

### Firebase Services
- **Authentication**: تسجيل دخول بالبريد والهاتف
- **Firestore**: حفظ بيانات المستخدمين
- **Phone Auth**: رسائل OTP للهواتف الأردنية

## 🚀 البدء السريع

### 1. متطلبات التشغيل
```bash
Flutter SDK: >=3.8.1
Dart SDK: >=3.8.1
```

### 2. تثبيت المشروع
```bash
# استنساخ المشروع
git clone [repository-url]
cd qasetha

# تثبيت Dependencies
flutter pub get

# تشغيل التطبيق
flutter run
```

### 3. إعداد Firebase
1. إنشاء مشروع Firebase جديد
2. تفعيل Authentication (Email/Password + Phone)
3. تفعيل Firestore Database
4. إضافة ملفات التكوين:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

## 📱 الشاشات والوظائف

### 🔑 Login Screen
**المسار**: `/login`
**الميزات**:
- تبديل بين البريد والهاتف
- التحقق من متطلبات كلمة المرور
- رابط نسيان كلمة المرور
- تصميم متدرج مع أنيميشن

```dart
// مثال على الاستخدام
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

### 📝 Signup Screen
**المسار**: `/signup`
**الميزات**:
- إنشاء حساب بالبريد أو الهاتف
- التحقق من قوة كلمة المرور
- موافقة على الشروط والأحكام
- حفظ البيانات في Firestore

### 📱 OTP Screen
**المسار**: `/otp`
**الميزات**:
- إدخال رمز 6 أرقام
- إعادة إرسال مع مؤقت 60 ثانية
- التحقق التلقائي عند الامتلاء
- دعم مصادر متعددة (signup/login/forgot-password)

### 📧 Verify Email Screen
**المسار**: `/verify-email`
**الميزات**:
- فحص تلقائي لحالة التحقق
- إعادة إرسال بريد التحقق
- عرض البريد الحالي
- حماية من الإرسال المتكرر

### 🔒 Reset Password Screen
**المسار**: `/reset-password`
**الميزات**:
- تعيين كلمة مرور جديدة
- التحقق من المتطلبات
- تأكيد كلمة المرور
- تحديث آمن

### 🤔 Forgot Password Screen
**المسار**: `/forgot-password`
**الميزات**:
- إعادة تعيين بالبريد أو الهاتف
- دعم الأرقام الأردنية (+962)
- تبديل بين الطرق

## 🔐 نظام الأمان

### Password Requirements
- ✅ 8 أحرف على الأقل
- ✅ حرف كبير واحد (A-Z)
- ✅ حرف صغير واحد (a-z)
- ✅ رقم واحد (0-9)
- ✅ رمز خاص (!@#$%^&*)

### Async Safety
```dart
// مثال على الحماية
if (!mounted) return;
context.go('/home');
```

### Error Handling
- رسائل خطأ واضحة بالعربية
- معالجة جميع أخطاء Firebase
- تسجيل الأخطاء للمطورين

## 📊 قاعدة البيانات

### Firestore Collections

#### Users Collection
```dart
{
  'name': 'اسم المستخدم',
  'email': 'user@example.com',    // للحسابات بالبريد
  'phone': '+962xxxxxxxxx',       // للحسابات بالهاتف
  'createdAt': Timestamp.now(),
}
```

## 🎨 التصميم

### نظام الألوان
```dart
Primary: Color(0xFF00E5FF)     // أزرق فاتح
Secondary: Color(0xFF0099CC)   // أزرق متوسط

// التدرج الخلفي
Gradient: [
  Color(0xFF0A0E21),  // أزرق داكن
  Color(0xFF1A1B3A),  // بنفسجي داكن
  Color(0xFF2D1B69),  // بنفسجي
  Color(0xFF0A192F),  // أزرق داكن
]
```

### الخطوط
```dart
GoogleFonts.tajawal(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.white,
)
```

## 🔄 تدفق التطبيق

### تسجيل الدخول
```
Onboarding → Login → [Email/Phone] → Home
                  ↓
              Forgot Password → Reset → Login
```

### إنشاء الحساب
```
Login → Signup → [Email: Verify Email] → Home
              ↓
         [Phone: OTP] → Home
```

## 🛠️ الخدمات المطورة

### Firebase Auth Service
```dart
class FirebaseAuthService {
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  static Future<void> sendPasswordResetEmail({
    required String email,
  });
  
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    // callbacks...
  });
}
```

### Logger Service
```dart
class LoggerService {
  static void info(String message);
  static void warning(String message);
  static void error(String message);
  static void debug(String message);
}
```

### Password Validator
```dart
class PasswordValidator {
  static String? validate(String? password);
  static Map<String, bool> checkRequirements(String password);
}
```

## 📱 الدعم والتوافق

- ✅ **Android**: API 21+
- ✅ **iOS**: iOS 11+
- ✅ **Web**: Chrome, Firefox, Safari
- ✅ **RTL**: دعم كامل للعربية
- ✅ **Responsive**: جميع أحجام الشاشات

## 🚀 الميزات المتقدمة

### Real-time Validation
- التحقق الفوري من كلمة المرور
- عرض المتطلبات بصرياً
- تحديث الحالة في الوقت الفعلي

### Smart Navigation
- حفظ حالة المستخدم
- توجيه ذكي حسب حالة المصادقة
- دعم Deep Links

### Performance Optimization
- تحميل كسول للشاشات
- إدارة ذاكرة محسنة
- أنيميشن محسن للأداء

## 🐛 استكشاف الأخطاء

### مشاكل شائعة
1. **Firebase not initialized**: تأكد من استدعاء `Firebase.initializeApp()`
2. **SHA keys**: أضف SHA1/SHA256 في Firebase Console
3. **Phone Auth**: تأكد من تفعيل Phone Authentication

### Debugging
```dart
// تفعيل التسجيل المفصل
LoggerService.debug('تفاصيل العملية');
```

## 📄 الترخيص

هذا المشروع مطور لأغراض تعليمية وتجارية.

## 👨‍💻 المطور

تم تطوير هذا المشروع باستخدام أحدث تقنيات Flutter و Firebase مع التركيز على:
- الأمان والحماية
- تجربة المستخدم
- الأداء المحسن
- الكود النظيف

---

**🎯 المشروع جاهز للإنتاج مع جميع الميزات المطلوبة للتطبيقات التجارية!**