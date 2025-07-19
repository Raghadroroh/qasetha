import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:async';
import '../models/guest_session.dart';
import '../models/auth_result.dart';
import '../services/secure_storage_service.dart';
import '../services/logger_service.dart';

class GuestService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _guestSessionKey = 'guest_session';

  // Sign in anonymously - OPTIMIZED
  static Future<AuthResult> signInAnonymously() async {
    try {
      LoggerService.info('Starting anonymous sign in');
      
      // Use timeout to prevent hanging
      final userCredential = await _auth.signInAnonymously()
          .timeout(const Duration(seconds: 10));
      final user = userCredential.user;
      
      if (user != null) {
        // Create guest session asynchronously to avoid blocking
        final guestSession = GuestSession.create();
        
        // Save session in background
        unawaited(_saveGuestSession(guestSession));
        
        // Log analytics in background
        unawaited(_logGuestAnalytics('guest_signin', {
          'user_id': user.uid,
          'timestamp': DateTime.now().toIso8601String(),
          'session_id': guestSession.id,
        }));
        
        LoggerService.info('Anonymous sign in successful: ${user.uid}');
        
        return AuthResult.success(
          message: 'تم تسجيل الدخول كضيف بنجاح',
          user: user,
          type: AuthResultType.guestSignIn,
        );
      } else {
        throw Exception('Failed to create anonymous user');
      }
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Anonymous sign in failed: ${e.code} - ${e.message}');
      return AuthResult.failure(
        message: _handleAuthException(e),
        type: AuthResultType.guestSignIn,
      );
    } catch (e) {
      LoggerService.error('Unexpected error during anonymous sign in: $e');
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع',
        type: AuthResultType.guestSignIn,
      );
    }
  }

  // Get current guest session
  static Future<GuestSession?> getCurrentGuestSession() async {
    try {
      final sessionData = await SecureStorageService.getData(_guestSessionKey);
      if (sessionData != null) {
        final sessionJson = jsonDecode(sessionData);
        final session = GuestSession.fromJson(sessionJson);
        
        // Check if session is expired
        if (session.isExpired) {
          await clearGuestSession();
          return null;
        }
        
        return session;
      }
      return null;
    } catch (e) {
      LoggerService.error('Failed to get guest session: $e');
      return null;
    }
  }

  // Save guest session
  static Future<void> _saveGuestSession(GuestSession session) async {
    try {
      final sessionJson = jsonEncode(session.toJson());
      await SecureStorageService.saveData(_guestSessionKey, sessionJson);
      LoggerService.info('Guest session saved successfully');
    } catch (e) {
      LoggerService.error('Failed to save guest session: $e');
    }
  }

  // Update guest session
  static Future<void> updateGuestSession(GuestSession session) async {
    await _saveGuestSession(session);
  }

  // Clear guest session
  static Future<void> clearGuestSession() async {
    try {
      await SecureStorageService.deleteData(_guestSessionKey);
      LoggerService.info('Guest session cleared');
    } catch (e) {
      LoggerService.error('Failed to clear guest session: $e');
    }
  }

  // Track guest feature usage
  static Future<void> trackFeatureUsage(String feature) async {
    try {
      final session = await getCurrentGuestSession();
      if (session != null) {
        final updatedSession = session.addFeatureUsed(feature);
        await updateGuestSession(updatedSession);
        
        // Log analytics
        await _logGuestAnalytics('feature_used', {
          'feature': feature,
          'session_id': session.id,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      LoggerService.error('Failed to track feature usage: $e');
    }
  }

  // Track page visit
  static Future<void> trackPageVisit(String page) async {
    try {
      final session = await getCurrentGuestSession();
      if (session != null) {
        final updatedSession = session.updatePageVisit(page);
        await updateGuestSession(updatedSession);
      }
    } catch (e) {
      LoggerService.error('Failed to track page visit: $e');
    }
  }

  // Update temporary data
  static Future<void> updateTemporaryData(String key, dynamic value) async {
    try {
      final session = await getCurrentGuestSession();
      if (session != null) {
        final updatedSession = session.updateTemporaryData(key, value);
        await updateGuestSession(updatedSession);
      }
    } catch (e) {
      LoggerService.error('Failed to update temporary data: $e');
    }
  }

  // Mark conversion prompt as shown
  static Future<void> markConversionPromptShown() async {
    try {
      final session = await getCurrentGuestSession();
      if (session != null) {
        final updatedSession = session.markConversionPromptShown();
        await updateGuestSession(updatedSession);
        
        // Log analytics
        await _logGuestAnalytics('conversion_prompt_shown', {
          'session_id': session.id,
          'prompt_count': updatedSession.conversionPromptCount,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      LoggerService.error('Failed to mark conversion prompt as shown: $e');
    }
  }

  // Convert guest to registered user
  static Future<AuthResult> convertGuestToRegistered({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      LoggerService.info('Starting guest to registered conversion');
      
      final currentUser = _auth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        return AuthResult.failure(
          message: 'لا يوجد مستخدم ضيف لتحويله',
          type: AuthResultType.conversion,
        );
      }

      // Create email credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Link the credential to the current anonymous user
      final linkedUser = await currentUser.linkWithCredential(credential);
      
      // Update display name
      await linkedUser.user?.updateDisplayName(name);
      
      // Get guest session data before clearing
      final guestSession = await getCurrentGuestSession();
      
      // Create user document in Firestore
      await _createUserDocumentFromGuest(linkedUser.user!, name, guestSession);
      
      // Send email verification
      await linkedUser.user?.sendEmailVerification();
      
      // Log conversion analytics
      await _logGuestAnalytics('guest_converted', {
        'user_id': linkedUser.user!.uid,
        'email': email,
        'guest_session_id': guestSession?.id,
        'session_count': guestSession?.sessionCount ?? 0,
        'features_used': guestSession?.featuresUsed ?? [],
        'conversion_time': DateTime.now().toIso8601String(),
      });
      
      // Clear guest session
      await clearGuestSession();
      
      LoggerService.info('Guest to registered conversion successful');
      
      return AuthResult.success(
        message: 'تم تحويل الحساب بنجاح! يرجى تأكيد البريد الإلكتروني',
        user: linkedUser.user,
        type: AuthResultType.conversion,
      );
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Guest conversion failed: ${e.code} - ${e.message}');
      return AuthResult.failure(
        message: _handleAuthException(e),
        type: AuthResultType.conversion,
      );
    } catch (e) {
      LoggerService.error('Unexpected error during guest conversion: $e');
      return AuthResult.failure(
        message: 'حدث خطأ غير متوقع',
        type: AuthResultType.conversion,
      );
    }
  }

  // Get guest analytics
  static Future<Map<String, dynamic>> getGuestAnalytics() async {
    try {
      final session = await getCurrentGuestSession();
      if (session != null) {
        return {
          'session_count': session.sessionCount,
          'features_used': session.featuresUsed,
          'total_duration': session.totalDuration.inMinutes,
          'total_actions': session.totalActions,
          'pages_visited': session.pageVisitCount,
          'should_show_conversion_prompt': session.shouldShowConversionPrompt,
          'conversion_prompt_count': session.conversionPromptCount,
          'created_at': session.createdAt.toIso8601String(),
          'last_activity': session.lastActivity.toIso8601String(),
        };
      }
      return {};
    } catch (e) {
      LoggerService.error('Failed to get guest analytics: $e');
      return {};
    }
  }

  // Check if user should see conversion prompt
  static Future<bool> shouldShowConversionPrompt() async {
    try {
      final session = await getCurrentGuestSession();
      return session?.shouldShowConversionPrompt ?? false;
    } catch (e) {
      LoggerService.error('Failed to check conversion prompt status: $e');
      return false;
    }
  }

  // Get restricted features for guests
  static List<String> getRestrictedFeatures() {
    return [
      'save_favorites',
      'export_data',
      'advanced_analytics',
      'premium_features',
      'data_backup',
      'profile_customization',
      'notifications',
      'sharing',
      'comments',
      'ratings',
    ];
  }

  // Check if feature is restricted for guests
  static bool isFeatureRestricted(String feature) {
    return getRestrictedFeatures().contains(feature);
  }

  // Create user document from guest session
  static Future<void> _createUserDocumentFromGuest(
    User user,
    String name,
    GuestSession? guestSession,
  ) async {
    try {
      final userData = {
        // Required fields by security rules
        'email': user.email ?? '',
        'fullName': name,
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
        
        // Guest conversion data
        'convertedFromGuest': true,
        'guestSessionData': guestSession?.toJson(),
        'guestConversionDate': FieldValue.serverTimestamp(),
        
        // Legacy fields for compatibility
        'name': name,
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
      
      await _firestore.collection('users').doc(user.uid).set(userData);
      LoggerService.info('User document created from guest session');
    } catch (e) {
      LoggerService.error('Failed to create user document from guest: $e');
      rethrow;
    }
  }

  // Log guest analytics
  static Future<void> _logGuestAnalytics(String event, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('guest_analytics').add({
        'event': event,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': _auth.currentUser?.uid,
      });
    } catch (e) {
      LoggerService.error('Failed to log guest analytics: $e');
    }
  }

  // Handle authentication exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'credential-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة';
      case 'operation-not-allowed':
        return 'العملية غير مسموحة';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً';
      default:
        return 'حدث خطأ غير متوقع: ${e.message}';
    }
  }

  // Cleanup expired guest sessions (call this periodically)
  static Future<void> cleanupExpiredGuestSessions() async {
    try {
      final session = await getCurrentGuestSession();
      if (session != null && session.isExpired) {
        await clearGuestSession();
        LoggerService.info('Expired guest session cleaned up');
      }
    } catch (e) {
      LoggerService.error('Failed to cleanup expired guest sessions: $e');
    }
  }
}