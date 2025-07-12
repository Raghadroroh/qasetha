import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> testConnection() async {
    try {
      print('🔥 اختبار اتصال Firestore...');
      
      // إضافة بيانات تجريبية
      await _firestore.collection('test').add({
        'name': 'تجربة اتصال',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'success'
      });
      
      print('✅ تم الاتصال بـ Firestore بنجاح!');
      
      // قراءة البيانات للتأكد
      final snapshot = await _firestore.collection('test').limit(1).get();
      print('📄 عدد المستندات: ${snapshot.docs.length}');
      
    } catch (e) {
      print('❌ خطأ في الاتصال بـ Firestore: $e');
    }
  }
}