import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/auth_result.dart';
import '../utils/constants.dart';
import '../utils/phone_validator.dart';
import '../utils/validators.dart';
import '../utils/simple_logger.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user getter
  static User? get currentUser => _auth.currentUser;

  // Email verification status
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Auth state stream
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Sign up with email and password
  static Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    BuildContext? context,
  }) async {
    try {
      SimpleLogger.info('Starting email signup: $email');

      // Validate inputs
      String? emailError = Validators.validateEmail(email, context);
      if (emailError != null) {
        return AuthResult.failure(message: emailError);
      }

      String? passwordError = Validators.validatePassword(password, context);
      if (passwordError != null) {
        return AuthResult.failure(message: passwordError);
      }

      if (context != null) {
        String? nameError = Validators.validateName(name, context);
        if (nameError != null) {
          return AuthResult.failure(message: nameError);
        }
      }

      // Create account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Save user data to Firestore
      final uid = credential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'fullName': name,
        'phoneNumber': '',
        'userType': 'customer',
        'isVerified': false,
        'creditLimit': 0,
        'availableCredit': 0,
        'totalDebt': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
        'authMethod': 'email',
      });

      // Send verification email automatically
      await credential.user?.sendEmailVerification();

      SimpleLogger.info(
        'Account created successfully: ${credential.user?.uid}',
      );

      return AuthResult.success(
        message: 'تم إنشاء الحساب بنجاح. تحقق من بريدك الإلكتروني',
        user: credential.user,
        type: AuthResultType.accountCreated,
      );
    } on FirebaseAuthException catch (e) {
      SimpleLogger.error('Email signup error: ${e.code} - ${e.message}');
      return AuthResult.failure(message: _handleAuthException(e, context));
    } catch (e) {
      SimpleLogger.error('Unexpected email signup error: $e');
      return AuthResult.failure(message: 'حدث خطأ غير متوقع');
    }
  }

  /// Sign in with email and password
  static Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      SimpleLogger.info('Starting email signin: $email');

      // Validate inputs
      if (context != null) {
        String? emailError = Validators.validateEmail(email, context);
        if (emailError != null) {
          return AuthResult.failure(message: emailError);
        }
      }

      if (password.isEmpty) {
        return AuthResult.failure(message: 'كلمة المرور مطلوبة');
      }

      // Sign in
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check email verification
      if (!credential.user!.emailVerified) {
        SimpleLogger.warning('Email not verified: $email');
        return AuthResult.failure(
          message: 'يجب تأكيد البريد الإلكتروني أولاً',
          user: credential.user,
          type: AuthResultType.emailNotVerified,
        );
      }

      // Log successful login
      await _logLoginAttempt('email', email, success: true);

      SimpleLogger.info('Email signin successful: ${credential.user?.uid}');

      return AuthResult.success(
        message: 'تم تسجيل الدخول بنجاح',
        user: credential.user,
        type: AuthResultType.loginSuccess,
      );
    } on FirebaseAuthException catch (e) {
      SimpleLogger.error('Email signin error: ${e.code} - ${e.message}');
      return AuthResult.failure(message: _handleAuthException(e, context));
    } catch (e) {
      SimpleLogger.error('Unexpected email signin error: $e');
      return AuthResult.failure(message: 'حدث خطأ غير متوقع');
    }
  }

  /// Verify phone number and send OTP
  static Future<AuthResult> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    Function(AuthResult)? onVerificationCompleted,
    Function(AuthResult)? onVerificationFailed,
    BuildContext? context,
  }) async {
    try {
      SimpleLogger.info('Starting phone verification: $phoneNumber');

      // Validate Jordanian phone number
      if (!PhoneValidator.isValidJordanianPhone(phoneNumber)) {
        return AuthResult.failure(
          message: 'رقم الهاتف الأردني غير صحيح. يجب أن يبدأ بـ 77 أو 78 أو 79',
        );
      }

      // Format phone number
      String formattedPhone = PhoneValidator.formatJordanianPhone(phoneNumber);

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          SimpleLogger.info('Phone verification completed automatically');
          try {
            final result = await _auth.signInWithCredential(credential);
            await _logLoginAttempt('phone', formattedPhone, success: true);

            onVerificationCompleted?.call(
              AuthResult.success(
                message: 'تم التحقق من الهاتف بنجاح',
                user: result.user,
                type: AuthResultType.verificationSuccess,
              ),
            );
          } catch (e) {
            onVerificationCompleted?.call(
              AuthResult.failure(message: 'حدث خطأ في التحقق التلقائي'),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          SimpleLogger.error(
            'Phone verification failed: ${e.code} - ${e.message}',
          );
          onVerificationFailed?.call(
            AuthResult.failure(message: _handleAuthException(e, context)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          SimpleLogger.info('OTP sent successfully');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          SimpleLogger.info('Auto-retrieval timeout');
        },
        timeout: const Duration(seconds: AuthConstants.otpTimeoutSeconds),
      );

      return AuthResult.success(
        message: 'تم إرسال رمز التحقق إلى هاتفك',
        type: AuthResultType.otpSent,
      );
    } on FirebaseAuthException catch (e) {
      SimpleLogger.error('Phone verification error: ${e.code} - ${e.message}');
      return AuthResult.failure(message: _handleAuthException(e, context));
    } catch (e) {
      SimpleLogger.error('Unexpected phone verification error: $e');
      return AuthResult.failure(message: 'حدث خطأ غير متوقع');
    }
  }

  /// Verify OTP code
  static Future<AuthResult> verifyOTP({
    required String verificationId,
    required String smsCode,
    String? name,
    BuildContext? context,
  }) async {
    try {
      SimpleLogger.info('Starting OTP verification');

      // Validate OTP
      if (context != null) {
        String? otpError = Validators.validateOTP(smsCode, context);
        if (otpError != null) {
          return AuthResult.failure(message: otpError);
        }
      }

      // Create credential and sign in
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = await _auth.signInWithCredential(credential);

      // If new user, save additional data
      if (result.additionalUserInfo?.isNewUser == true && name != null) {
        await result.user?.updateDisplayName(name);
        final uid = result.user!.uid;
        await _firestore.collection('users').doc(uid).set({
          'email': '',
          'fullName': name,
          'phoneNumber': result.user?.phoneNumber ?? '',
          'userType': 'customer',
          'isVerified': false,
          'creditLimit': 0,
          'availableCredit': 0,
          'totalDebt': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'phoneVerified': true,
          'authMethod': 'phone',
        });
      }

      // Log successful login
      await _logLoginAttempt(
        'phone',
        result.user?.phoneNumber ?? '',
        success: true,
      );

      SimpleLogger.info('OTP verification successful: ${result.user?.uid}');

      return AuthResult.success(
        message: 'تم التحقق من الهاتف بنجاح',
        user: result.user,
        type: AuthResultType.verificationSuccess,
      );
    } on FirebaseAuthException catch (e) {
      SimpleLogger.error('OTP verification error: ${e.code} - ${e.message}');
      return AuthResult.failure(message: _handleAuthException(e, context));
    } catch (e) {
      SimpleLogger.error('Unexpected OTP verification error: $e');
      return AuthResult.failure(message: 'حدث خطأ غير متوقع');
    }
  }

  /// Send email verification
  static Future<AuthResult> sendEmailVerification({
    BuildContext? context,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(message: 'لا يوجد مستخدم مسجل دخول');
      }

      if (user.emailVerified) {
        return AuthResult.success(
          message: 'البريد الإلكتروني مؤكد بالفعل',
          type: AuthResultType.emailSent,
        );
      }

      SimpleLogger.info('Sending email verification: ${user.email}');

      await user.sendEmailVerification();

      SimpleLogger.info('Email verification sent successfully');

      return AuthResult.success(
        message: 'تم إرسال بريد التأكيد',
        type: AuthResultType.emailSent,
      );
    } on FirebaseAuthException catch (e) {
      SimpleLogger.error('Email verification error: ${e.code} - ${e.message}');
      return AuthResult.failure(message: _handleAuthException(e, context));
    } catch (e) {
      SimpleLogger.error('Unexpected email verification error: $e');
      return AuthResult.failure(message: 'حدث خطأ غير متوقع');
    }
  }

  /// Send password reset email
  static Future<AuthResult> sendPasswordResetEmail({
    required String email,
    BuildContext? context,
  }) async {
    try {
      SimpleLogger.info('Sending password reset email: $email');

      // Validate email
      if (context != null) {
        String? emailError = Validators.validateEmail(email, context);
        if (emailError != null) {
          return AuthResult.failure(message: emailError);
        }
      }

      await _auth.sendPasswordResetEmail(email: email);

      SimpleLogger.info('Password reset email sent successfully');

      return AuthResult.success(
        message: 'تم إرسال رابط إعادة تعيين كلمة المرور',
        type: AuthResultType.passwordReset,
      );
    } on FirebaseAuthException catch (e) {
      SimpleLogger.error('Password reset error: ${e.code} - ${e.message}');
      return AuthResult.failure(message: _handleAuthException(e, context));
    } catch (e) {
      SimpleLogger.error('Unexpected password reset error: $e');
      return AuthResult.failure(message: 'حدث خطأ غير متوقع');
    }
  }

  /// Update password
  static Future<AuthResult> updatePassword({
    required String newPassword,
    BuildContext? context,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(message: 'لا يوجد مستخدم مسجل دخول');
      }

      // Validate password
      if (context != null) {
        String? passwordError = Validators.validatePassword(newPassword, context);
        if (passwordError != null) {
          return AuthResult.failure(message: passwordError);
        }
      }

      SimpleLogger.info('Updating password for user: ${user.uid}');

      await user.updatePassword(newPassword);

      SimpleLogger.info('Password updated successfully');

      return AuthResult.success(
        message: 'تم تحديث كلمة المرور بنجاح',
        type: AuthResultType.passwordReset,
      );
    } on FirebaseAuthException catch (e) {
      SimpleLogger.error('Password update error: ${e.code} - ${e.message}');
      return AuthResult.failure(message: _handleAuthException(e, context));
    } catch (e) {
      SimpleLogger.error('Unexpected password update error: $e');
      return AuthResult.failure(message: 'حدث خطأ غير متوقع');
    }
  }

  /// Reload current user
  static Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      SimpleLogger.info('Signing out user');
      await _auth.signOut();
      SimpleLogger.info('Sign out successful');
    } catch (e) {
      SimpleLogger.error('Sign out error: $e');
    }
  }

  /// Log login attempts to Firestore
  static Future<void> _logLoginAttempt(
    String method,
    String identifier, {
    bool success = false,
  }) async {
    try {
      await _firestore.collection('logins').add({
        'userId': _auth.currentUser?.uid,
        'method': method,
        'identifier': identifier,
        'success': success,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': {'platform': 'mobile'},
      });
    } catch (e) {
      SimpleLogger.error('Login attempt logging error: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  static String _handleAuthException(
    FirebaseAuthException e,
    BuildContext? context,
  ) {
    Map<String, String> errorMessages = AuthConstants.errorMessagesAr;

    return errorMessages[e.code] ?? 'حدث خطأ غير متوقع: ${e.message}';
  }
}
