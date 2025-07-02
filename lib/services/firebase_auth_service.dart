import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // الحصول على المستخدم الحالي
  static User? get currentUser => _auth.currentUser;

  // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // إنشاء حساب جديد
  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // تحديث اسم المستخدم
      await credential.user?.updateDisplayName(displayName);
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // إرسال بريد إعادة تعيين كلمة المرور
  static Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // إرسال بريد التحقق
  static Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // تسجيل الخروج
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // حذف الحساب
  static Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // تحديث كلمة المرور
  static Future<void> updatePassword({required String newPassword}) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // إعادة المصادقة
  static Future<void> reauthenticateWithCredential({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // تأكيد رقم الهاتف
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // تسجيل الدخول برقم الهاتف
  static Future<UserCredential?> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // تسجيل الدخول بـ Credential مباشرة
  static Future<UserCredential?> signInWithCredential(AuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // التحقق من حالة البريد الإلكتروني
  static bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // الاستماع لتغييرات حالة المصادقة
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // معالجة أخطاء Firebase Auth
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح، حاول لاحقاً';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموحة';
      case 'requires-recent-login':
        return 'يتطلب تسجيل دخول حديث';
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'invalid-verification-id':
        return 'معرف التحقق غير صحيح';
      case 'quota-exceeded':
        return 'تم تجاوز عدد المحاولات المسموح';
      default:
        return 'حدث خطأ غير متوقع: ${e.message}';
    }
  }
}