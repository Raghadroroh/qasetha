import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../utils/constants.dart';
import '../utils/phone_validator.dart';
import '../models/auth_result.dart';
import 'logger_service.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  static Future<AuthResult> createAccount({
    required String email,
    required String password,
    required String name,
    String? phone,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('بدء إنشاء حساب جديد: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      // Create user document with EXACT structure required by security rules
      final userData = {
        // Required fields by security rules
        'email': email,
        'fullName': name,
        'phoneNumber': phone ?? '',
        'userType': 'customer',
        
        // Required numeric fields (must be 0 for new users)
        'creditLimit': 0,
        'availableCredit': 0,
        'totalDebt': 0,
        'rating': 0,
        
        // Required boolean
        'isVerified': false,
        
        // Required objects
        'employment': {
          'isEmployed': false,
          'sector': 'none',
          'employerName': '',
          'jobTitle': '',
          'employeeId': ''
        },
        
        'address': {
          'street': '',
          'city': '',
          'governorate': ''
          // NO postalCode
        },
        
        // Optional fields
        'profileImage': '',
        'nationalId': '',
        
        // Timestamps
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        
        // Legacy fields for compatibility
        'name': name, // Keep for backward compatibility
        'phone': phone ?? '', // Keep for backward compatibility
        'emailVerified': false,
        'profileCompletion': {
          'percentage': 0.0,
          'missingFields': [],
          'hasSeenWelcomeModal': false,
          'lastPromptDate': null,
          'isBasicInfoComplete': false,
          'isEmploymentInfoComplete': false,
          'isAddressInfoComplete': false,
          'hasProfileImage': false,
        },
      };
      
      LoggerService.info('Creating Firestore document with data: ${userData.toString()}');
      
      await _firestore.collection('users').doc(credential.user?.uid).set(userData);

      await sendEmailVerification();

      LoggerService.info('تم إنشاء الحساب بنجاح: ${credential.user?.uid}');

      return AuthResult.success(
        message: context?.l10n.accountCreated ?? 'تم إنشاء الحساب بنجاح',
        user: credential.user,
        type: AuthResultType.accountCreated,
      );
    } on FirebaseAuthException catch (e) {
      LoggerService.error('خطأ في إنشاء الحساب: ${e.code} - ${e.message}');
      
      // If user was created but document failed, clean up
      if (_auth.currentUser != null) {
        try {
          await _auth.currentUser!.delete();
          LoggerService.info('Cleaned up auth user after failed document creation');
        } catch (deleteError) {
          LoggerService.error('Failed to clean up auth user: $deleteError');
        }
      }
      
      return AuthResult(
        success: false,
        message: _handleAuthException(e, context),
      );
    } catch (e) {
      LoggerService.error('خطأ غير متوقع في إنشاء الحساب: $e');
      
      // If user was created but document failed, clean up
      if (_auth.currentUser != null) {
        try {
          await _auth.currentUser!.delete();
          LoggerService.info('Cleaned up auth user after failed document creation');
        } catch (deleteError) {
          LoggerService.error('Failed to clean up auth user: $deleteError');
        }
      }
      
      return AuthResult(
        success: false,
        message: context?.l10n.unexpectedError ?? 'حدث خطأ غير متوقع',
      );
    }
  }

  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('بدء تسجيل الدخول: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user document exists
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user?.uid)
          .get();
          
      if (!userDoc.exists) {
        LoggerService.warning('User document not found, creating missing document');
        await _createMissingUserDocument(credential.user!);
      }

      if (!credential.user!.emailVerified) {
        LoggerService.warning('البريد الإلكتروني غير مؤكد: $email');
        return AuthResult(
          success: false,
          message: context?.l10n.locale.languageCode == 'ar'
              ? 'يجب تأكيد البريد الإلكتروني أولاً'
              : 'Please verify your email first',
          user: credential.user,
        );
      }

      await _logLoginAttempt('email', email, success: true);

      LoggerService.info('تم تسجيل الدخول بنجاح: ${credential.user?.uid}');

      return AuthResult(
        success: true,
        message: context?.l10n.loginSuccess ?? 'تم تسجيل الدخول بنجاح',
        user: credential.user,
      );
    } on FirebaseAuthException catch (e) {
      LoggerService.error('خطأ في تسجيل الدخول: ${e.code} - ${e.message}');
      
      await _logLoginAttempt('email', email, success: false);
      
      return AuthResult(
        success: false,
        message: _handleAuthException(e, context),
      );
    } catch (e) {
      LoggerService.error('خطأ غير متوقع في تسجيل الدخول: $e');
      
      await _logLoginAttempt('email', email, success: false);
      
      return AuthResult(
        success: false,
        message: context?.l10n.unexpectedError ?? 'حدث خطأ غير متوقع',
      );
    }
  }

  static Future<AuthResult> sendOTP({
    required String phoneNumber,
    BuildContext? context,
    Function(String)? onCodeSent,
    Function(AuthResult)? onVerificationCompleted,
    Function(AuthResult)? onVerificationFailed,
  }) async {
    try {
      LoggerService.info('بدء إرسال OTP: $phoneNumber');

      if (!_isValidJordanianPhone(phoneNumber)) {
        return AuthResult(
          success: false,
          message: context?.l10n.locale.languageCode == 'ar'
              ? 'رقم الهاتف الأردني غير صحيح. يجب أن يبدأ بـ 77 أو 78 أو 79'
              : 'Invalid Jordanian phone number. Must start with 77, 78, or 79',
        );
      }

      String formattedPhone = _formatJordanianPhone(phoneNumber);

      await _logLoginAttempt('phone', formattedPhone);

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          LoggerService.info('تم التحقق التلقائي من الهاتف');
          try {
            final result = await _auth.signInWithCredential(credential);
            onVerificationCompleted?.call(
              AuthResult(
                success: true,
                message: context?.l10n.locale.languageCode == 'ar'
                    ? 'تم التحقق من الهاتف بنجاح'
                    : 'Phone verified successfully',
                user: result.user,
              ),
            );
          } catch (e) {
            onVerificationCompleted?.call(
              AuthResult(
                success: false,
                message: context?.l10n.unexpectedError ?? 'حدث خطأ غير متوقع',
              ),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          LoggerService.error('فشل التحقق من الهاتف: ${e.code} - ${e.message}');
          onVerificationFailed?.call(
            AuthResult(
              success: false,
              message: _handleAuthException(e, context),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          LoggerService.info('تم إرسال رمز OTP بنجاح');
          onCodeSent?.call(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          LoggerService.info('انتهت مهلة الاسترداد التلقائي للرمز');
        },
        timeout: const Duration(seconds: 60),
      );

      return AuthResult(
        success: true,
        message: context?.l10n.locale.languageCode == 'ar'
            ? 'تم إرسال رمز التحقق'
            : 'Verification code sent',
      );
    } on FirebaseAuthException catch (e) {
      LoggerService.error('خطأ في إرسال OTP: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        message: _handleAuthException(e, context),
      );
    } catch (e) {
      LoggerService.error('خطأ غير متوقع في إرسال OTP: $e');
      return AuthResult(
        success: false,
        message: context?.l10n.unexpectedError ?? 'حدث خطأ غير متوقع',
      );
    }
  }

  static Future<AuthResult> verifyOTP({
    required String verificationId,
    required String smsCode,
    String? name,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('بدء التحقق من رمز OTP');

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = await _auth.signInWithCredential(credential);

      if (result.additionalUserInfo?.isNewUser == true && name != null) {
        await result.user?.updateDisplayName(name);
        
        // Create user document with EXACT structure for phone auth
        final userData = {
          // Required fields by security rules
          'email': result.user?.email ?? '',
          'fullName': name,
          'phoneNumber': result.user?.phoneNumber ?? '',
          'userType': 'customer',
          
          // Required numeric fields
          'creditLimit': 0,
          'availableCredit': 0,
          'totalDebt': 0,
          'rating': 0,
          
          // Required boolean
          'isVerified': false,
          
          // Required objects
          'employment': {
            'isEmployed': false,
            'sector': 'none',
            'employerName': '',
            'jobTitle': '',
            'employeeId': ''
          },
          
          'address': {
            'street': '',
            'city': '',
            'governorate': ''
          },
          
          // Optional fields
          'profileImage': '',
          'nationalId': '',
          
          // Timestamps
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          
          // Legacy fields for compatibility
          'name': name,
          'phone': result.user?.phoneNumber ?? '',
          'phoneVerified': true,
          'profileCompletion': {
            'percentage': 0.0,
            'missingFields': [],
            'hasSeenWelcomeModal': false,
            'lastPromptDate': null,
            'isBasicInfoComplete': false,
            'isEmploymentInfoComplete': false,
            'isAddressInfoComplete': false,
            'hasProfileImage': false,
          },
        };
        
        LoggerService.info('Creating phone auth Firestore document: ${userData.toString()}');
        
        await _firestore.collection('users').doc(result.user?.uid).set(userData);
      }

      await _logLoginAttempt(
        'phone',
        result.user?.phoneNumber ?? '',
        success: true,
      );

      LoggerService.info('تم التحقق من OTP بنجاح: ${result.user?.uid}');

      return AuthResult(
        success: true,
        message: context?.l10n.locale.languageCode == 'ar'
            ? 'تم التحقق من الهاتف بنجاح'
            : 'Phone verified successfully',
        user: result.user,
      );
    } on FirebaseAuthException catch (e) {
      LoggerService.error('خطأ في التحقق من OTP: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        message: _handleAuthException(e, context),
      );
    } catch (e) {
      LoggerService.error('خطأ غير متوقع في التحقق من OTP: $e');
      return AuthResult(
        success: false,
        message: context?.l10n.unexpectedError ?? 'حدث خطأ غير متوقع',
      );
    }
  }

  static Future<AuthResult> sendEmailVerification({
    BuildContext? context,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult(
          success: false,
          message: context?.l10n.locale.languageCode == 'ar'
              ? 'لا يوجد مستخدم مسجل دخول'
              : 'No user signed in',
        );
      }

      if (user.emailVerified) {
        return AuthResult(
          success: true,
          message: context?.l10n.locale.languageCode == 'ar'
              ? 'البريد الإلكتروني مؤكد بالفعل'
              : 'Email already verified',
        );
      }

      LoggerService.info('إرسال بريد تأكيد البريد الإلكتروني: ${user.email}');

      await user.sendEmailVerification();

      LoggerService.info('تم إرسال بريد التأكيد بنجاح');

      return AuthResult(
        success: true,
        message: context?.l10n.locale.languageCode == 'ar'
            ? 'تم إرسال بريد التأكيد'
            : 'Verification email sent',
      );
    } on FirebaseAuthException catch (e) {
      LoggerService.error(
        'خطأ في إرسال بريد التأكيد: ${e.code} - ${e.message}',
      );
      return AuthResult(
        success: false,
        message: _handleAuthException(e, context),
      );
    } catch (e) {
      LoggerService.error('خطأ غير متوقع في إرسال بريد التأكيد: $e');
      return AuthResult(
        success: false,
        message: context?.l10n.unexpectedError ?? 'حدث خطأ غير متوقع',
      );
    }
  }

  static Future<AuthResult> sendPasswordResetEmail({
    required String email,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('إرسال بريد إعادة تعيين كلمة المرور: $email');

      await _auth.sendPasswordResetEmail(email: email);

      LoggerService.info('تم إرسال بريد إعادة تعيين كلمة المرور بنجاح');

      return AuthResult(
        success: true,
        message:
            context?.l10n.resetLinkSent ??
            'تم إرسال رابط إعادة تعيين كلمة المرور',
      );
    } on FirebaseAuthException catch (e) {
      LoggerService.error(
        'خطأ في إرسال بريد إعادة تعيين كلمة المرور: ${e.code} - ${e.message}',
      );
      return AuthResult(
        success: false,
        message: _handleAuthException(e, context),
      );
    } catch (e) {
      LoggerService.error(
        'خطأ غير متوقع في إرسال بريد إعادة تعيين كلمة المرور: $e',
      );
      return AuthResult(
        success: false,
        message: context?.l10n.unexpectedError ?? 'حدث خطأ غير متوقع',
      );
    }
  }

  static Future<AuthResult> updatePassword({
    required String newPassword,
    BuildContext? context,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult(
          success: false,
          message: context?.l10n.locale.languageCode == 'ar'
              ? 'لا يوجد مستخدم مسجل دخول'
              : 'No user signed in',
        );
      }

      LoggerService.info('تحديث كلمة المرور للمستخدم: ${user.uid}');

      await user.updatePassword(newPassword);

      LoggerService.info('تم تحديث كلمة المرور بنجاح');

      return AuthResult(
        success: true,
        message:
            context?.l10n.passwordResetSuccess ?? 'تم تحديث كلمة المرور بنجاح',
      );
    } on FirebaseAuthException catch (e) {
      LoggerService.error('خطأ في تحديث كلمة المرور: ${e.code} - ${e.message}');
      return AuthResult(
        success: false,
        message: _handleAuthException(e, context),
      );
    } catch (e) {
      LoggerService.error('خطأ غير متوقع في تحديث كلمة المرور: $e');
      return AuthResult(
        success: false,
        message: context?.l10n.unexpectedError ?? 'حدث خطأ غير متوقع',
      );
    }
  }

  static Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  static Future<void> signOut() async {
    try {
      LoggerService.info('تسجيل خروج المستخدم');
      await _auth.signOut();
      LoggerService.info('تم تسجيل الخروج بنجاح');
    } catch (e) {
      LoggerService.error('خطأ في تسجيل الخروج: $e');
    }
  }

  static String _formatJordanianPhone(String phone) {
    return PhoneValidator.formatJordanianPhone(phone);
  }

  static bool _isValidJordanianPhone(String phone) {
    return PhoneValidator.isValidJordanianPhone(phone);
  }

  static Future<void> _createMissingUserDocument(User user) async {
    try {
      LoggerService.info('Creating missing user document for: ${user.uid}');
      
      final userData = {
        // Required fields by security rules
        'email': user.email ?? '',
        'fullName': user.displayName ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'userType': 'customer',
        
        // Required numeric fields
        'creditLimit': 0,
        'availableCredit': 0,
        'totalDebt': 0,
        'rating': 0,
        
        // Required boolean
        'isVerified': false,
        
        // Required objects
        'employment': {
          'isEmployed': false,
          'sector': 'none',
          'employerName': '',
          'jobTitle': '',
          'employeeId': ''
        },
        
        'address': {
          'street': '',
          'city': '',
          'governorate': ''
        },
        
        // Optional fields
        'profileImage': '',
        'nationalId': '',
        
        // Timestamps
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        
        // Legacy fields for compatibility
        'name': user.displayName ?? '',
        'phone': user.phoneNumber ?? '',
        'emailVerified': user.emailVerified,
        'profileCompletion': {
          'percentage': 0.0,
          'missingFields': [],
          'hasSeenWelcomeModal': false,
          'lastPromptDate': null,
          'isBasicInfoComplete': false,
          'isEmploymentInfoComplete': false,
          'isAddressInfoComplete': false,
          'hasProfileImage': false,
        },
      };
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData);
          
      LoggerService.info('Missing user document created successfully');
    } catch (e) {
      LoggerService.error('Error creating missing user document: $e');
      rethrow;
    }
  }

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
      LoggerService.error('خطأ في تسجيل محاولة تسجيل الدخول: $e');
    }
  }

  static String _handleAuthException(
    FirebaseAuthException e,
    BuildContext? context,
  ) {
    bool isArabic = context?.l10n.locale.languageCode == 'ar' || context == null;

    Map<String, String> errorMessages = isArabic
        ? AuthConstants.errorMessagesAr
        : AuthConstants.errorMessagesEn;

    return errorMessages[e.code] ??
        '${context?.l10n.unexpectedError ?? 'حدث خطأ غير متوقع'}: ${e.message}';
  }
}
