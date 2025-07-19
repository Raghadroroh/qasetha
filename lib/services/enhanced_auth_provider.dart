import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_result.dart';
import 'auth_service.dart';
import 'logger_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  phoneNotVerified,
}

class EnhancedAuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  User? _user;
  String? _verificationId;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get verificationId => _verificationId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  EnhancedAuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication state listener
  void _initializeAuth() {
    AuthService.authStateChanges().listen((User? user) {
      _user = user;
      if (user == null) {
        _setState(AuthState.unauthenticated);
      } else if (user.email != null && !user.emailVerified) {
        _setState(AuthState.emailNotVerified);
      } else {
        _setState(AuthState.authenticated);
      }
    });
  }

  /// Update state
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Update error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _setError(null);
  }

  /// Sign up with email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        context: context,
      );

      if (result.success) {
        LoggerService.info('Email signup successful in provider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في إنشاء الحساب');
        return false;
      }
    } catch (e) {
      LoggerService.error('Email signup error in provider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.signInWithEmail(
        email: email,
        password: password,
        context: context,
      );

      if (result.success) {
        LoggerService.info('Email signin successful in provider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في تسجيل الدخول');
        // Handle email not verified case
        if (result.type == AuthResultType.emailNotVerified &&
            result.user != null) {
          _user = result.user;
          _setState(AuthState.emailNotVerified);
        }
        return false;
      }
    } catch (e) {
      LoggerService.error('Email signin error in provider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send OTP to phone
  Future<bool> sendOTP({
    required String phoneNumber,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        context: context,
        onCodeSent: (String verificationId) {
          _verificationId = verificationId;
          LoggerService.info('Verification ID saved in provider');
        },
        onVerificationCompleted: (AuthResult result) {
          if (result.success) {
            LoggerService.info('Auto-verification successful in provider');
          } else {
            _setError(result.message ?? 'حدث خطأ في التحقق التلقائي');
          }
        },
        onVerificationFailed: (AuthResult result) {
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
      LoggerService.error('Send OTP error in provider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify OTP
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
      final result = await AuthService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
        name: name,
        context: context,
      );

      if (result.success) {
        LoggerService.info('OTP verification successful in provider');
        _verificationId = null; // Clear verification ID
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في التحقق من رمز OTP');
        return false;
      }
    } catch (e) {
      LoggerService.error('OTP verification error in provider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification({BuildContext? context}) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.sendEmailVerification(context: context);

      if (result.success) {
        LoggerService.info('Email verification sent successfully in provider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في إرسال بريد التأكيد');
        return false;
      }
    } catch (e) {
      LoggerService.error('Send email verification error in provider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({
    required String email,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.sendPasswordResetEmail(
        email: email,
        context: context,
      );

      if (result.success) {
        LoggerService.info(
          'Password reset email sent successfully in provider',
        );
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في إرسال بريد إعادة تعيين كلمة المرور');
        return false;
      }
    } catch (e) {
      LoggerService.error('Send password reset error in provider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update password
  Future<bool> updatePassword({
    required String newPassword,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthService.updatePassword(
        newPassword: newPassword,
        context: context,
      );

      if (result.success) {
        LoggerService.info('Password updated successfully in provider');
        return true;
      } else {
        _setError(result.message ?? 'حدث خطأ في تحديث كلمة المرور');
        return false;
      }
    } catch (e) {
      LoggerService.error('Update password error in provider: $e');
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Check email verification status
  Future<void> checkEmailVerification() async {
    try {
      await AuthService.reloadUser();
      final user = AuthService.currentUser;
      if (user != null && user.emailVerified) {
        _user = user;
        _setState(AuthState.authenticated);
        LoggerService.info('Email verification confirmed');
      }
    } catch (e) {
      LoggerService.error('Check email verification error: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await AuthService.signOut();
      _user = null;
      _verificationId = null;
      _setError(null);
      _setState(AuthState.unauthenticated);
      LoggerService.info('Sign out successful in provider');
    } catch (e) {
      LoggerService.error('Sign out error in provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Resend OTP (reuse existing verification ID or get new one)
  Future<bool> resendOTP({
    required String phoneNumber,
    BuildContext? context,
  }) async {
    // Clear existing verification ID to force new one
    _verificationId = null;
    return await sendOTP(phoneNumber: phoneNumber, context: context);
  }
}
