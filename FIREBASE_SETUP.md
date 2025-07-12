# إعداد Firebase للمصادقة والأمان

## 🔥 Firebase Console - الإعدادات المطلوبة:

### 1. **Authentication**
```
Firebase Console → Authentication → Sign-in method
```
- ✅ **Email/Password** - Enable
- ✅ **Phone** - Enable (للـ OTP)
- ✅ **Anonymous** - Enable (اختياري)

### 2. **Firestore Database**
```
Firebase Console → Firestore Database → Create database
```
- اختر **Production mode**
- اختر المنطقة الأقرب (europe-west1)

### 3. **Analytics**
```
Firebase Console → Analytics → Enable
```
- ✅ Enable Google Analytics
- ربط مع Google Analytics account

### 4. **Crashlytics**
```
Firebase Console → Crashlytics → Enable
```
- ✅ Enable Firebase Crashlytics

### 5. **Performance Monitoring**
```
Firebase Console → Performance → Enable
```
- ✅ Enable Performance Monitoring

### 6. **App Check** (مهم للأمان)
```
Firebase Console → App Check → Register app
```
- **Android**: Play Integrity API
- **iOS**: App Attest

## 📱 إعدادات التطبيق:

### Android (android/app/build.gradle):
```gradle
android {
    compileSdk 34
    
    defaultConfig {
        minSdk 21
        targetSdk 34
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
}
```

### iOS (ios/Runner/Info.plist):
```xml
<key>NSFaceIDUsageDescription</key>
<string>استخدام Face ID لتسجيل الدخول الآمن</string>
<key>NSCameraUsageDescription</key>
<string>للتحقق من الهوية</string>
```

## 🔐 Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## 📧 Email Templates (Authentication):
```
Firebase Console → Authentication → Templates
```
- **Email verification** - تخصيص الرسالة بالعربية
- **Password reset** - تخصيص الرسالة بالعربية

## 🔑 API Keys (Project Settings):
تأكد من وجود:
- ✅ **Web API Key**
- ✅ **Android API Key** 
- ✅ **iOS API Key**

## 📊 Analytics Events (تلقائي):
النظام سيسجل هذه الأحداث:
- `biometric_enabled`
- `biometric_auth_success`
- `financial_auth_attempt`
- `otp_sent`
- `otp_verified`

## ⚠️ مهم جداً:
1. **تفعيل Billing** في Google Cloud (مطلوب للـ Phone Auth)
2. **إضافة SHA-1** للـ Android في Project Settings
3. **تحديث google-services.json** و **GoogleService-Info.plist**