import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/auth_result.dart';
import '../models/user_model.dart';
import '../utils/phone_validator.dart';
import '../utils/validators.dart';
import 'logger_service.dart';
import 'secure_storage_service.dart';

/// Enhanced Firebase Authentication Service
/// 
/// Provides a comprehensive authentication system with:
/// - Email/Password authentication
/// - Phone number authentication with OTP
/// - Anonymous/Guest authentication
/// - Email verification
/// - Password reset
/// - Session management
/// - User profile management
/// - Secure token storage
class EnhancedFirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream controllers for auth state
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  static bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  /// Initialize service and setup auth listeners
  static Future<void> initialize() async {
    try {
      LoggerService.info('Initializing Enhanced Firebase Auth Service');
      
      // Setup auth state listener
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          LoggerService.info('Auth state changed: User ${user.uid} - Anonymous: ${user.isAnonymous}');
        } else {
          LoggerService.info('Auth state changed: User signed out');
        }
      });
      
      LoggerService.info('Enhanced Firebase Auth Service initialized successfully');
    } catch (e) {
      LoggerService.error('Failed to initialize Enhanced Firebase Auth Service: $e');
    }
  }

  /// Create account with email and password
  static Future<AuthResult> createAccountWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('Starting email account creation: $email');

      // Validate inputs
      final emailValidation = context != null ? Validators.validateEmail(email, context) : (email.isEmpty ? 'البريد الإلكتروني مطلوب' : null);
      if (emailValidation != null) {
        return AuthResult.failure(message: emailValidation);
      }

      final passwordValidation = context != null ? Validators.validatePassword(password, context) : (password.isEmpty ? 'كلمة المرور مطلوبة' : null);
      if (passwordValidation != null) {
        return AuthResult.failure(message: passwordValidation);
      }

      final nameValidation = context != null ? Validators.validateName(name, context) : (name.isEmpty ? 'الاسم مطلوب' : null);
      if (nameValidation != null) {
        return AuthResult.failure(message: nameValidation);
      }

      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to create user account');
      }

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Create comprehensive user document
      await _createUserDocument(
        user: credential.user!,
        additionalData: {
          'fullName': name,
          'phoneNumber': phone ?? '',
          'authMethod': 'email',
          'registrationSource': 'app',
        },
      );

      // Send email verification
      await _sendEmailVerificationInternal(credential.user!);

      // Save auth session
      await _saveAuthSession(credential.user!);

      LoggerService.info('Email account created successfully: ${credential.user!.uid}');

      return AuthResult.success(
        message: 'تم إنشاء الحساب بنجاح! يرجى تأكيد بريدك الإلكتروني',
        user: credential.user,
        type: AuthResultType.accountCreated,
      );

    } on FirebaseAuthException catch (e) {
      LoggerService.error('Email account creation failed: ${e.code} - ${e.message}');
      
      // Clean up any partial user creation
      await _cleanupFailedRegistration();
      
      return AuthResult.failure(
        message: _getLocalizedErrorMessage(e),
        type: AuthResultType.accountCreated,
      );
    } catch (e) {
      LoggerService.error('Unexpected error during email account creation: $e');
      
      await _cleanupFailedRegistration();
      
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        type: AuthResultType.accountCreated,
      );
    }
  }

  /// Sign in with email and password
  static Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('Starting email sign in: $email');

      // Validate inputs
      if (email.trim().isEmpty) {
        return AuthResult.failure(message: 'البريد الإلكتروني مطلوب');
      }

      if (password.isEmpty) {
        return AuthResult.failure(message: 'كلمة المرور مطلوبة');
      }

      // Sign in with Firebase
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to sign in user');
      }

      // Check if email is verified
      if (!credential.user!.emailVerified) {
        LoggerService.warning('Email not verified for user: $email');
        return AuthResult.failure(
          message: 'يجب تأكيد البريد الإلكتروني أولاً. هل تريد إعادة إرسال رسالة التأكيد؟',
          user: credential.user,
          type: AuthResultType.emailNotVerified,
        );
      }

      // Ensure user document exists
      await _ensureUserDocumentExists(credential.user!);

      // Update last login and save session
      await _updateLastLogin(credential.user!);
      await _saveAuthSession(credential.user!);

      // Log successful login attempt
      await _logLoginAttempt(
        method: 'email',
        identifier: email,
        success: true,
        userId: credential.user!.uid,
      );

      LoggerService.info('Email sign in successful: ${credential.user!.uid}');

      return AuthResult.success(
        message: 'تم تسجيل الدخول بنجاح',
        user: credential.user,
        type: AuthResultType.loginSuccess,
      );

    } on FirebaseAuthException catch (e) {
      LoggerService.error('Email sign in failed: ${e.code} - ${e.message}');
      
      // Log failed login attempt
      await _logLoginAttempt(
        method: 'email',
        identifier: email,
        success: false,
        errorCode: e.code,
      );
      
      return AuthResult.failure(
        message: _getLocalizedErrorMessage(e),
        type: AuthResultType.loginSuccess,
      );
    } catch (e) {
      LoggerService.error('Unexpected error during email sign in: $e');
      
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        type: AuthResultType.loginSuccess,
      );
    }
  }

  /// Send OTP to phone number
  static Future<AuthResult> sendPhoneOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    Function(AuthResult)? onVerificationCompleted,
    Function(AuthResult)? onVerificationFailed,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('Starting phone OTP send: $phoneNumber');

      // Validate Jordanian phone number
      if (!PhoneValidator.isValidJordanianPhone(phoneNumber)) {
        return AuthResult.failure(
          message: 'رقم الهاتف الأردني غير صحيح. يجب أن يبدأ بـ 77 أو 78 أو 79',
        );
      }

      // Format phone number
      final formattedPhone = PhoneValidator.formatJordanianPhone(phoneNumber);

      // Verify phone number with Firebase
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          LoggerService.info('Phone verification completed automatically');
          
          try {
            final result = await _signInWithPhoneCredential(credential);
            onVerificationCompleted?.call(result);
          } catch (e) {
            LoggerService.error('Auto verification failed: $e');
            onVerificationCompleted?.call(
              AuthResult.failure(message: 'فشل التحقق التلقائي من الهاتف'),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          LoggerService.error('Phone verification failed: ${e.code} - ${e.message}');
          
          onVerificationFailed?.call(
            AuthResult.failure(
              message: _getLocalizedErrorMessage(e),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          LoggerService.info('OTP sent successfully to: $formattedPhone');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          LoggerService.info('OTP auto-retrieval timeout for: $formattedPhone');
        },
        timeout: const Duration(seconds: 60),
      );

      return AuthResult.success(
        message: 'تم إرسال رمز التحقق إلى هاتفك',
        type: AuthResultType.otpSent,
      );

    } on FirebaseAuthException catch (e) {
      LoggerService.error('Phone OTP send failed: ${e.code} - ${e.message}');
      
      return AuthResult.failure(
        message: _getLocalizedErrorMessage(e),
        type: AuthResultType.otpSent,
      );
    } catch (e) {
      LoggerService.error('Unexpected error during phone OTP send: $e');
      
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        type: AuthResultType.otpSent,
      );
    }
  }

  /// Verify OTP code
  static Future<AuthResult> verifyPhoneOTP({
    required String verificationId,
    required String otpCode,
    String? userName,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('Starting OTP verification');

      // Validate OTP code
      if (otpCode.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otpCode)) {
        return AuthResult.failure(message: 'رمز التحقق يجب أن يكون 6 أرقام');
      }

      // Create phone credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      // Sign in with credential
      final result = await _signInWithPhoneCredential(credential, userName);

      LoggerService.info('OTP verification successful');

      return result;

    } on FirebaseAuthException catch (e) {
      LoggerService.error('OTP verification failed: ${e.code} - ${e.message}');
      
      return AuthResult.failure(
        message: _getLocalizedErrorMessage(e),
        type: AuthResultType.verificationSuccess,
      );
    } catch (e) {
      LoggerService.error('Unexpected error during OTP verification: $e');
      
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        type: AuthResultType.verificationSuccess,
      );
    }
  }

  /// Sign in with phone credential (internal)
  static Future<AuthResult> _signInWithPhoneCredential(
    PhoneAuthCredential credential, [
    String? userName,
  ]) async {
    final userCredential = await _auth.signInWithCredential(credential);
    
    if (userCredential.user == null) {
      throw Exception('Failed to sign in with phone credential');
    }

    final user = userCredential.user!;

    // If new user, create user document
    if (userCredential.additionalUserInfo?.isNewUser == true) {
      if (userName != null && userName.isNotEmpty) {
        await user.updateDisplayName(userName);
      }

      await _createUserDocument(
        user: user,
        additionalData: {
          'fullName': userName ?? '',
          'phoneNumber': user.phoneNumber ?? '',
          'authMethod': 'phone',
          'phoneVerified': true,
          'registrationSource': 'app',
        },
      );
    } else {
      // Ensure existing user document exists
      await _ensureUserDocumentExists(user);
    }

    // Update last login and save session
    await _updateLastLogin(user);
    await _saveAuthSession(user);

    // Log successful login
    await _logLoginAttempt(
      method: 'phone',
      identifier: user.phoneNumber ?? '',
      success: true,
      userId: user.uid,
    );

    return AuthResult.success(
      message: 'تم التحقق من الهاتف بنجاح',
      user: user,
      type: AuthResultType.verificationSuccess,
    );
  }

  /// Sign in anonymously (Guest mode)
  static Future<AuthResult> signInAnonymously() async {
    try {
      LoggerService.info('Starting anonymous sign in');

      final userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user == null) {
        throw Exception('Failed to create anonymous user');
      }

      final user = userCredential.user!;

      // Create minimal guest document (don't interfere with existing Firestore rules)
      await _logGuestSession(user.uid);

      LoggerService.info('Anonymous sign in successful: ${user.uid}');

      return AuthResult.success(
        message: 'تم تسجيل الدخول كضيف بنجاح',
        user: user,
        type: AuthResultType.guestSignIn,
      );

    } on FirebaseAuthException catch (e) {
      LoggerService.error('Anonymous sign in failed: ${e.code} - ${e.message}');
      
      return AuthResult.failure(
        message: _getLocalizedErrorMessage(e),
        type: AuthResultType.guestSignIn,
      );
    } catch (e) {
      LoggerService.error('Unexpected error during anonymous sign in: $e');
      
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        type: AuthResultType.guestSignIn,
      );
    }
  }

  /// Convert anonymous user to permanent user
  static Future<AuthResult> linkAnonymousWithEmail({
    required String email,
    required String password,
    required String name,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('Starting anonymous to email linking');

      final currentUser = _auth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        return AuthResult.failure(
          message: 'لا يوجد مستخدم ضيف لربطه',
        );
      }

      // Validate inputs
      final emailValidation = Validators.validateEmail(email, context);
      if (emailValidation != null) {
        return AuthResult.failure(message: emailValidation);
      }

      final passwordValidation = Validators.validatePassword(password, context);
      if (passwordValidation != null) {
        return AuthResult.failure(message: passwordValidation);
      }

      // Create email credential and link
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final linkedCredential = await currentUser.linkWithCredential(credential);
      
      if (linkedCredential.user == null) {
        throw Exception('Failed to link anonymous user with email');
      }

      final user = linkedCredential.user!;

      // Update display name
      await user.updateDisplayName(name);

      // Create/update user document
      await _createUserDocument(
        user: user,
        additionalData: {
          'fullName': name,
          'authMethod': 'email',
          'convertedFromGuest': true,
          'conversionDate': FieldValue.serverTimestamp(),
          'registrationSource': 'guest_conversion',
        },
      );

      // Send email verification
      await _sendEmailVerificationInternal(user);

      // Save auth session
      await _saveAuthSession(user);

      LoggerService.info('Anonymous to email linking successful: ${user.uid}');

      return AuthResult.success(
        message: 'تم ربط الحساب بنجاح! يرجى تأكيد بريدك الإلكتروني',
        user: user,
        type: AuthResultType.conversion,
      );

    } on FirebaseAuthException catch (e) {
      LoggerService.error('Anonymous linking failed: ${e.code} - ${e.message}');
      
      return AuthResult.failure(
        message: _getLocalizedErrorMessage(e),
        type: AuthResultType.conversion,
      );
    } catch (e) {
      LoggerService.error('Unexpected error during anonymous linking: $e');
      
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        type: AuthResultType.conversion,
      );
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

      await _sendEmailVerificationInternal(user);

      LoggerService.info('Email verification sent: ${user.email}');

      return AuthResult.success(
        message: 'تم إرسال رسالة التأكيد إلى بريدك الإلكتروني',
        type: AuthResultType.emailSent,
      );

    } on FirebaseAuthException catch (e) {
      LoggerService.error('Email verification send failed: ${e.code} - ${e.message}');
      
      return AuthResult.failure(
        message: _getLocalizedErrorMessage(e),
        type: AuthResultType.emailSent,
      );
    } catch (e) {
      LoggerService.error('Unexpected error sending email verification: $e');
      
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        type: AuthResultType.emailSent,
      );
    }
  }

  /// Send password reset email
  static Future<AuthResult> sendPasswordResetEmail({
    required String email,
    BuildContext? context,
  }) async {
    try {
      LoggerService.info('Sending password reset email: $email');

      // Validate email
      final emailValidation = Validators.validateEmail(email, context);
      if (emailValidation != null) {
        return AuthResult.failure(message: emailValidation);
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      LoggerService.info('Password reset email sent successfully');

      return AuthResult.success(
        message: 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
        type: AuthResultType.passwordReset,
      );

    } on FirebaseAuthException catch (e) {
      LoggerService.error('Password reset email failed: ${e.code} - ${e.message}');
      
      return AuthResult.failure(
        message: _getLocalizedErrorMessage(e),
        type: AuthResultType.passwordReset,
      );
    } catch (e) {
      LoggerService.error('Unexpected error sending password reset: $e');
      
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        type: AuthResultType.passwordReset,
      );
    }
  }

  /// Update user password
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
      final passwordValidation = Validators.validatePassword(newPassword, context);
      if (passwordValidation != null) {
        return AuthResult.failure(message: passwordValidation);
      }

      await user.updatePassword(newPassword);

      LoggerService.info('Password updated successfully for user: ${user.uid}');

      return AuthResult.success(
        message: 'تم تحديث كلمة المرور بنجاح',
        type: AuthResultType.passwordReset,
      );

    } on FirebaseAuthException catch (e) {
      LoggerService.error('Password update failed: ${e.code} - ${e.message}');
      
      return AuthResult.failure(
        message: _getLocalizedErrorMessage(e),
        type: AuthResultType.passwordReset,
      );
    } catch (e) {
      LoggerService.error('Unexpected error updating password: $e');
      
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
        type: AuthResultType.passwordReset,
      );
    }
  }

  /// Reload current user data
  static Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      LoggerService.info('User data reloaded successfully');
    } catch (e) {
      LoggerService.error('Failed to reload user data: $e');
    }
  }

  /// Sign out current user
  static Future<AuthResult> signOut() async {
    try {
      LoggerService.info('Starting user sign out');

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Clear secure storage
        await SecureStorageService.clearAuthData();
        
        // Sign out from Firebase
        await _auth.signOut();
        
        LoggerService.info('User signed out successfully: ${currentUser.uid}');
      } else {
        LoggerService.info('No user to sign out');
      }

      return AuthResult.success(
        message: 'تم تسجيل الخروج بنجاح',
        type: AuthResultType.signOut,
      );

    } catch (e) {
      LoggerService.error('Sign out failed: $e');
      
      return AuthResult.failure(
        message: 'حدث خطأ أثناء تسجيل الخروج',
        type: AuthResultType.signOut,
      );
    }
  }

  /// Get current user profile from Firestore
  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      LoggerService.error('Failed to get user profile: $e');
      return null;
    }
  }

  // ========================= PRIVATE HELPER METHODS =========================

  /// Create comprehensive user document in Firestore
  static Future<void> _createUserDocument({
    required User user,
    Map<String, dynamic> additionalData = const {},
  }) async {
    try {
      final userData = {
        // Required fields by security rules
        'email': user.email ?? '',
        'fullName': additionalData['fullName'] ?? user.displayName ?? '',
        'phoneNumber': user.phoneNumber ?? additionalData['phoneNumber'] ?? '',
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
        
        // Auth related
        'emailVerified': user.emailVerified,
        'phoneVerified': user.phoneNumber != null,
        'authMethod': additionalData['authMethod'] ?? 'email',
        'registrationSource': additionalData['registrationSource'] ?? 'app',
        
        // Profile completion
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
        
        // Additional data
        ...additionalData,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      LoggerService.info('User document created successfully: ${user.uid}');
    } catch (e) {
      LoggerService.error('Failed to create user document: $e');
      rethrow;
    }
  }

  /// Ensure user document exists (for existing users)
  static Future<void> _ensureUserDocumentExists(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        LoggerService.warning('User document not found, creating: ${user.uid}');
        await _createUserDocument(user: user);
      }
    } catch (e) {
      LoggerService.error('Failed to ensure user document exists: $e');
    }
  }

  /// Update last login timestamp
  static Future<void> _updateLastLogin(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggerService.error('Failed to update last login: $e');
    }
  }

  /// Save authentication session to secure storage
  static Future<void> _saveAuthSession(User user) async {
    try {
      // Get ID token
      final idToken = await user.getIdToken();
      
      // Save to secure storage
      if (idToken != null) {
        await SecureStorageService.saveAuthToken(idToken);
      }
      await SecureStorageService.saveUserData(
        userId: user.uid,
        email: user.email,
        phone: user.phoneNumber,
        name: user.displayName,
      );
      
      // Set session expiry (30 days)
      final sessionExpiry = DateTime.now().add(const Duration(days: 30));
      await SecureStorageService.saveSessionExpiry(sessionExpiry);
      
      LoggerService.info('Auth session saved successfully');
    } catch (e) {
      LoggerService.error('Failed to save auth session: $e');
    }
  }

  /// Send email verification (internal)
  static Future<void> _sendEmailVerificationInternal(User user) async {
    try {
      await user.sendEmailVerification();
      LoggerService.info('Email verification sent to: ${user.email}');
    } catch (e) {
      LoggerService.error('Failed to send email verification: $e');
      rethrow;
    }
  }

  /// Clean up after failed registration
  static Future<void> _cleanupFailedRegistration() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        LoggerService.info('Cleaned up failed registration user');
      }
    } catch (e) {
      LoggerService.error('Failed to cleanup failed registration: $e');
    }
  }

  /// Log login attempts
  static Future<void> _logLoginAttempt({
    required String method,
    required String identifier,
    required bool success,
    String? userId,
    String? errorCode,
  }) async {
    try {
      await _firestore.collection('login_attempts').add({
        'method': method,
        'identifier': identifier,
        'success': success,
        'userId': userId,
        'errorCode': errorCode,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': {
          'platform': 'mobile',
          'userAgent': 'Flutter App',
        },
      });
    } catch (e) {
      LoggerService.error('Failed to log login attempt: $e');
    }
  }

  /// Log guest session creation
  static Future<void> _logGuestSession(String guestUid) async {
    try {
      await _firestore.collection('guest_sessions').doc(guestUid).set({
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      LoggerService.error('Failed to log guest session: $e');
    }
  }

  /// Get localized error message
  static String _getLocalizedErrorMessage(FirebaseAuthException e) {
    final Map<String, String> errorMessages = {
      'user-not-found': 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني',
      'wrong-password': 'كلمة المرور غير صحيحة',
      'email-already-in-use': 'البريد الإلكتروني مستخدم بالفعل',
      'weak-password': 'كلمة المرور ضعيفة جداً',
      'invalid-email': 'البريد الإلكتروني غير صحيح',
      'user-disabled': 'تم تعطيل هذا الحساب',
      'too-many-requests': 'محاولات كثيرة جداً. يرجى المحاولة لاحقاً',
      'network-request-failed': 'خطأ في الاتصال. تحقق من الإنترنت',
      'invalid-verification-code': 'رمز التحقق غير صحيح',
      'invalid-verification-id': 'رمز التحقق منتهي الصلاحية',
      'credential-already-in-use': 'هذه البيانات مستخدمة بالفعل',
      'invalid-credential': 'بيانات الاعتماد غير صحيحة',
      'operation-not-allowed': 'العملية غير مسموحة',
      'account-exists-with-different-credential': 'يوجد حساب بنفس البريد ولكن بطريقة تسجيل دخول مختلفة',
    };

    return errorMessages[e.code] ?? 'حدث خطأ غير متوقع: ${e.message}';
  }
}