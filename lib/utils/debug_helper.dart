import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'simple_logger.dart';

class DebugHelper {
  static Future<void> checkFirebaseConnection() async {
    try {
      SimpleLogger.info('🔍 فحص اتصال Firebase...');
      
      // فحص Firebase Core
      final app = Firebase.app();
      SimpleLogger.info('✅ Firebase Core متصل: ${app.name}');
      
      // فحص Firebase Auth
      final auth = FirebaseAuth.instance;
      SimpleLogger.info('✅ Firebase Auth جاهز: ${auth.app.name}');
      
      // فحص Firestore
      final firestore = FirebaseFirestore.instance;
      SimpleLogger.info('✅ Firestore جاهز: ${firestore.app.name}');
      
      // اختبار كتابة بسيطة في Firestore
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected'
      });
      SimpleLogger.info('✅ اختبار الكتابة في Firestore نجح');
      
    } catch (e) {
      SimpleLogger.error('❌ خطأ في فحص Firebase: $e');
    }
  }
  
  static Future<void> testEmailSignup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      SimpleLogger.info('🧪 اختبار إنشاء حساب بالبريد الإلكتروني...');
      SimpleLogger.info('📧 البريد: $email');
      SimpleLogger.info('👤 الاسم: $name');
      
      // إنشاء الحساب
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      SimpleLogger.info('✅ تم إنشاء الحساب: ${credential.user?.uid}');
      
      // تحديث الاسم
      await credential.user?.updateDisplayName(name);
      SimpleLogger.info('✅ تم تحديث الاسم');
      
      // حفظ في Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
        'authMethod': 'email',
      });
      
      SimpleLogger.info('✅ تم حفظ البيانات في Firestore');
      
      // إرسال بريد التحقق
      await credential.user?.sendEmailVerification();
      SimpleLogger.info('✅ تم إرسال بريد التحقق');
      
    } catch (e) {
      SimpleLogger.error('❌ خطأ في اختبار إنشاء الحساب: $e');
      
      if (e is FirebaseAuthException) {
        SimpleLogger.error('🔥 Firebase Auth Error Code: ${e.code}');
        SimpleLogger.error('🔥 Firebase Auth Error Message: ${e.message}');
      }
    }
  }
  
  static void logSystemInfo() {
    SimpleLogger.info('📱 معلومات النظام:');
    SimpleLogger.info('🔧 Firebase Core Version: ${Firebase.apps.length} apps');
    SimpleLogger.info('🔐 Firebase Auth Instance: ${FirebaseAuth.instance.hashCode}');
    SimpleLogger.info('🗄️ Firestore Instance: ${FirebaseFirestore.instance.hashCode}');
  }
}