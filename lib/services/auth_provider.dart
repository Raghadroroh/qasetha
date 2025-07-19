import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_auth_service.dart';
import 'guest_service.dart';
import '../models/guest_session.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  guestMode,
}

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  User? _user;
  String? _verificationId;
  String? _errorMessage;
  bool _isLoading = false;
  GuestSession? _guestSession;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get verificationId => _verificationId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  bool get isGuestMode => _state == AuthState.guestMode;
  bool get isRegisteredUser => _user != null && !_user!.isAnonymous;
  GuestSession? get guestSession => _guestSession;

  AuthProvider() {
    _initializeAuth();
  }

  // تهيئة المصادقة
  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _user = user;
      if (user == null) {
        _guestSession = null;
        _setState(AuthState.unauthenticated);
      } else if (user.isAnonymous) {
        // Guest mode
        _guestSession = await GuestService.getCurrentGuestSession();
        _setState(AuthState.guestMode);
      } else if (!user.emailVerified && user.email != null) {
        _guestSession = null;
        _setState(AuthState.emailNotVerified);
      } else {
        _guestSession = null;
        _setState(AuthState.authenticated);
      }
    });
  }

  // تحديث الحالة
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  // تحديث حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // تحديث رسالة الخطأ
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // مسح الخطأ
  void clearError() {
    _setError(null);
  }

  // إنشاء حساب جديد
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await FirebaseAuthService.createAccount(
        email: email,
        password: password,
        name: name,
        phone: phone,
        context: context,
      );

      if (result.success) {
        print('تم إنشاء الحساب بنجاح في AuthProvider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في إنشاء الحساب');
        return false;
      }
    } catch (e) {
      print('خطأ في إنشاء الحساب في AuthProvider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // تسجيل الدخول
  Future<bool> signIn({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await FirebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
        context: context,
      );

      if (result.success) {
        print('تم تسجيل الدخول بنجاح في AuthProvider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في تسجيل الدخول');
        // إذا كان البريد غير مؤكد، تحديث الحالة
        if (result.user != null && !result.user!.emailVerified) {
          _user = result.user;
          _setState(AuthState.emailNotVerified);
        }
        return false;
      }
    } catch (e) {
      print('خطأ في تسجيل الدخول في AuthProvider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // إرسال رمز OTP
  Future<bool> sendOTP({
    required String phoneNumber,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await FirebaseAuthService.sendOTP(
        phoneNumber: phoneNumber,
        context: context,
        onCodeSent: (String verificationId) {
          _verificationId = verificationId;
          print('تم حفظ verificationId في AuthProvider');
        },
        onVerificationCompleted: (result) {
          if (result.success) {
            print('تم التحقق التلقائي من الهاتف في AuthProvider');
          } else {
            _setError(result.message ?? 'حدث خطأ في التحقق التلقائي');
          }
        },
        onVerificationFailed: (result) {
          _setError(result.message ?? 'فشل في التحقق من الهاتف');
        },
      );

      if (result.success) {
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في إرسال رمز التحقق');
        return false;
      }
    } catch (e) {
      print('خطأ في إرسال OTP في AuthProvider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // التحقق من رمز OTP
  Future<bool> verifyOTP({
    required String smsCode,
    String? name,
    BuildContext? context,
  }) async {
    if (_verificationId == null) {
      _setError('لم يتم العثور على رمز التحقق');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await FirebaseAuthService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
        name: name,
        context: context,
      );

      if (result.success) {
        print('تم التحقق من OTP بنجاح في AuthProvider');
        _verificationId = null; // مسح الـ verification ID
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في التحقق من رمز OTP');
        return false;
      }
    } catch (e) {
      print('خطأ في التحقق من OTP في AuthProvider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // إرسال بريد تأكيد البريد الإلكتروني
  Future<bool> sendEmailVerification({BuildContext? context}) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await FirebaseAuthService.sendEmailVerification(
        context: context,
      );

      if (result.success) {
        print('تم إرسال بريد التأكيد بنجاح في AuthProvider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في إرسال بريد التأكيد');
        return false;
      }
    } catch (e) {
      print('خطأ في إرسال بريد التأكيد في AuthProvider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // إرسال بريد إعادة تعيين كلمة المرور
  Future<bool> sendPasswordResetEmail({
    required String email,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await FirebaseAuthService.sendPasswordResetEmail(
        email: email,
        context: context,
      );

      if (result.success) {
        print('تم إرسال بريد إعادة تعيين كلمة المرور بنجاح في AuthProvider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في إرسال بريد إعادة تعيين كلمة المرور');
        return false;
      }
    } catch (e) {
      print('خطأ في إرسال بريد إعادة تعيين كلمة المرور في AuthProvider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // تحديث كلمة المرور
  Future<bool> updatePassword({
    required String newPassword,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await FirebaseAuthService.updatePassword(
        newPassword: newPassword,
        context: context,
      );

      if (result.success) {
        print('تم تحديث كلمة المرور بنجاح في AuthProvider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في تحديث كلمة المرور');
        return false;
      }
    } catch (e) {
      print('خطأ في تحديث كلمة المرور في AuthProvider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // تحديث حالة تأكيد البريد الإلكتروني
  Future<void> checkEmailVerification() async {
    try {
      await FirebaseAuthService.reloadUser();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        _user = user;
        _setState(AuthState.authenticated);
        print('تم تأكيد البريد الإلكتروني');
      }
    } catch (e) {
      print('خطأ في فحص تأكيد البريد الإلكتروني: $e');
    }
  }

  // تسجيل الدخول كضيف
  Future<bool> signInAsGuest() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await GuestService.signInAnonymously();
      if (result.success) {
        _guestSession = await GuestService.getCurrentGuestSession();
        print('تم تسجيل الدخول كضيف بنجاح في AuthProvider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في تسجيل الدخول كضيف');
        return false;
      }
    } catch (e) {
      print('خطأ في تسجيل الدخول كضيف في AuthProvider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // تحويل الضيف إلى مستخدم مسجل
  Future<bool> convertGuestToUser({
    required String email,
    required String password,
    required String name,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await GuestService.convertGuestToRegistered(
        email: email,
        password: password,
        name: name,
      );

      if (result.success) {
        _guestSession = null;
        print('تم تحويل الضيف إلى مستخدم مسجل بنجاح');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في تحويل الحساب');
        return false;
      }
    } catch (e) {
      print('خطأ في تحويل الضيف إلى مستخدم مسجل: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // تتبع استخدام الميزة (للضيوف)
  Future<void> trackFeatureUsage(String feature) async {
    if (isGuestMode) {
      await GuestService.trackFeatureUsage(feature);
      _guestSession = await GuestService.getCurrentGuestSession();
      notifyListeners();
    }
  }

  // تتبع زيارة الصفحة (للضيوف)
  Future<void> trackPageVisit(String page) async {
    if (isGuestMode) {
      await GuestService.trackPageVisit(page);
      _guestSession = await GuestService.getCurrentGuestSession();
      notifyListeners();
    }
  }

  // تحديث البيانات المؤقتة للضيف
  Future<void> updateGuestTemporaryData(String key, dynamic value) async {
    if (isGuestMode) {
      await GuestService.updateTemporaryData(key, value);
      _guestSession = await GuestService.getCurrentGuestSession();
      notifyListeners();
    }
  }

  // إشارة لعرض نافذة التحويل للضيف
  Future<void> markConversionPromptShown() async {
    if (isGuestMode) {
      await GuestService.markConversionPromptShown();
      _guestSession = await GuestService.getCurrentGuestSession();
      notifyListeners();
    }
  }

  // فحص ما إذا كان يجب عرض نافذة التحويل
  Future<bool> shouldShowConversionPrompt() async {
    if (isGuestMode) {
      return await GuestService.shouldShowConversionPrompt();
    }
    return false;
  }

  // فحص ما إذا كانت الميزة مقيدة للضيوف
  bool isFeatureRestricted(String feature) {
    if (isGuestMode) {
      return GuestService.isFeatureRestricted(feature);
    }
    return false;
  }

  // الحصول على الميزات المقيدة للضيوف
  List<String> getRestrictedFeatures() {
    return GuestService.getRestrictedFeatures();
  }

  // الحصول على تحليلات الضيف
  Future<Map<String, dynamic>> getGuestAnalytics() async {
    if (isGuestMode) {
      return await GuestService.getGuestAnalytics();
    }
    return {};
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    _setLoading(true);

    try {
      if (isGuestMode) {
        // Clean up guest session
        await GuestService.clearGuestSession();
        _guestSession = null;
      }
      
      await FirebaseAuthService.signOut();
      _user = null;
      _verificationId = null;
      _setError(null);
      _setState(AuthState.unauthenticated);
      print('تم تسجيل الخروج بنجاح في AuthProvider');
    } catch (e) {
      print('خطأ في تسجيل الخروج في AuthProvider: $e');
    } finally {
      _setLoading(false);
    }
  }
}
