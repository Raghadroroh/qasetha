import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthResult {
  final bool success;
  final String message;
  final User? user;
  
  AuthResult({required this.success, required this.message, this.user});
}

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _auth.currentUser;

  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(
        success: true, 
        message: 'تم تسجيل الدخول بنجاح',
        user: credential.user
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false, 
        message: _handleAuthException(e)
      );
    }
  }

  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await credential.user?.updateDisplayName(fullName);
      
      // حفظ بيانات المستخدم في Firestore
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'name': fullName,
        'email': email,
        'phone': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return AuthResult(
        success: true, 
        message: 'تم إنشاء الحساب بنجاح',
        user: credential.user
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false, 
        message: _handleAuthException(e)
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AuthResult> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(
        success: true,
        message: 'تم إرسال رابط إعادة تعيين كلمة المرور'
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _handleAuthException(e)
      );
    }
  }

  static Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    final service = FirebaseAuthService();
    return await service.signUpWithEmailAndPassword(
      email: email,
      password: password,
      fullName: name,
      phoneNumber: '',
    );
  }

  String _handleAuthException(FirebaseAuthException e) {
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
      default:
        return 'حدث خطأ غير متوقع: ${e.message}';
    }
  }
}