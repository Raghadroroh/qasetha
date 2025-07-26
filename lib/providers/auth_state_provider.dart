import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/guest_session.dart';
import '../services/secure_storage_service.dart';
import '../services/auth_service.dart';
import '../services/guest_service.dart';
import '../services/logger_service.dart';

// Auth state enum
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  guest,
  emailNotVerified,
  phoneNotVerified,
  expired,
  error,
}

// Auth state model
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool isLoading;
  final String? verificationId;
  final DateTime? sessionExpiry;
  final bool biometricEnabled;
  final bool rememberMe;
  final bool isGuestMode;
  final GuestSession? guestSession;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isLoading = false,
    this.verificationId,
    this.sessionExpiry,
    this.biometricEnabled = false,
    this.rememberMe = true,
    this.isGuestMode = false,
    this.guestSession,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? isLoading,
    String? verificationId,
    DateTime? sessionExpiry,
    bool? biometricEnabled,
    bool? rememberMe,
    bool? isGuestMode,
    GuestSession? guestSession,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      verificationId: verificationId ?? this.verificationId,
      sessionExpiry: sessionExpiry ?? this.sessionExpiry,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      rememberMe: rememberMe ?? this.rememberMe,
      isGuestMode: isGuestMode ?? this.isGuestMode,
      guestSession: guestSession ?? this.guestSession,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isGuest => status == AuthStatus.guest;
  bool get needsEmailVerification => status == AuthStatus.emailNotVerified;
  bool get needsPhoneVerification => status == AuthStatus.phoneNotVerified;
  bool get hasError => error != null;
  bool get isSessionExpired => status == AuthStatus.expired;
  bool get canAccessApp => isAuthenticated || isGuest;
  bool get isRegisteredUser => isAuthenticated && !isGuestMode;
  bool get shouldShowGuestBanner => isGuest && guestSession != null;
  bool get canConvertToRegistered => isGuest && guestSession != null;
}

// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState()) {
    _initialize();
  }

  // Initialize auth state
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);

      // Check Firebase Auth state first (Firebase is the source of truth)
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        if (currentUser.isAnonymous) {
          // Guest user - restore guest session
          await _initializeGuestSession();
        } else {
          // Registered user - check if has valid local session
          final hasValidSession = await SecureStorageService.hasValidSession();
          final isWithinAutoLoginPeriod = await SecureStorageService.isWithinAutoLoginPeriod();
          
          if (hasValidSession && isWithinAutoLoginPeriod) {
            await _restoreUserSession();
          } else {
            // Update user from Firebase
            _updateUserFromFirebase(currentUser);
          }
        }
      } else {
        // No Firebase user - clear any local data and set unauthenticated
        await SecureStorageService.clearAuthData();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        );
      }

      // Listen to Firebase auth state changes
      FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);

      // Cleanup expired guest sessions
      await GuestService.cleanupExpiredGuestSessions();
    } catch (e) {
      LoggerService.error('Failed to initialize auth state: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to initialize authentication',
        isLoading: false,
      );
    }
  }

  // Restore user session from secure storage
  Future<void> _restoreUserSession() async {
    try {
      final userData = await SecureStorageService.getUserData();
      final sessionExpiry = await SecureStorageService.getSessionExpiry();
      final biometricEnabled = await SecureStorageService.isBiometricEnabled();

      if (userData['userId'] != null) {
        final user = UserModel(
          id: userData['userId']!,
          email: userData['email'],
          phone: userData['phone'],
          name: userData['name'] ?? '',
          emailVerified: true, // Assuming verified if session exists
          phoneVerified: userData['phone'] != null,
          createdAt: DateTime.now(), // Will be updated from Firestore if needed
          lastLogin: DateTime.now(),
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          sessionExpiry: sessionExpiry,
          biometricEnabled: biometricEnabled,
          isLoading: false,
        );

        LoggerService.info('User session restored successfully');
      }
    } catch (e) {
      LoggerService.error('Failed to restore user session: $e');
      await SecureStorageService.clearAuthData();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    }
  }

  // Firebase auth state change listener
  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      // User signed out
      if (state.isAuthenticated) {
        signOut();
      }
    } else {
      // User signed in - update local state if needed
      if (!state.isAuthenticated) {
        _updateUserFromFirebase(firebaseUser);
      }
    }
  }

  // Update user data from Firebase user
  void _updateUserFromFirebase(User firebaseUser) {
    final user = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      phone: firebaseUser.phoneNumber,
      name: firebaseUser.displayName ?? '',
      emailVerified: firebaseUser.emailVerified,
      phoneVerified: firebaseUser.phoneNumber != null,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLogin: DateTime.now(),
    );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      error: null,
      isLoading: false,
    );
  }

  // Sign up with email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    BuildContext? context,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await AuthService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        context: context,
      );

      if (result.isSuccess) {
        final user = UserModel(
          id: result.user!.uid,
          email: result.user!.email!,
          name: name,
          emailVerified: result.user!.emailVerified,
          phoneVerified: false,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _saveUserSession(user);

        final newStatus = result.user!.emailVerified
            ? AuthStatus.authenticated
            : AuthStatus.emailNotVerified;

        LoggerService.info('Setting auth status to: $newStatus');

        state = state.copyWith(
          status: newStatus,
          user: user,
          isLoading: false,
          error: null, // Clear any previous errors
        );

        LoggerService.info('Auth state updated successfully');
        return true;
      } else {
        LoggerService.error('Signup failed: ${result.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('Sign up error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ غير متوقع',
        isLoading: false,
      );
      return false;
    }
  }

  // Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await AuthService.signInWithEmail(
        email: email,
        password: password,
        context: context,
      );

      if (result.isSuccess) {
        final user = UserModel(
          id: result.user!.uid,
          email: result.user!.email!,
          name: result.user!.displayName ?? '',
          emailVerified: result.user!.emailVerified,
          phoneVerified: result.user!.phoneNumber != null,
          createdAt: result.user!.metadata.creationTime ?? DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _saveUserSession(user);

        state = state.copyWith(
          status: result.user!.emailVerified
              ? AuthStatus.authenticated
              : AuthStatus.emailNotVerified,
          user: user,
          isLoading: false,
        );

        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('Sign in error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ غير متوقع',
        isLoading: false,
      );
      return false;
    }
  }

  // Send OTP for phone verification
  Future<bool> sendOTP({
    required String phoneNumber,
    BuildContext? context,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await AuthService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          state = state.copyWith(
            verificationId: verificationId,
            status: AuthStatus.phoneNotVerified,
            isLoading: false,
          );
        },
        onVerificationCompleted: (result) {
          if (result.isSuccess) {
            _handlePhoneVerificationSuccess(result.user!);
          } else {
            state = state.copyWith(
              status: AuthStatus.error,
              error: result.message,
              isLoading: false,
            );
          }
        },
        onVerificationFailed: (result) {
          state = state.copyWith(
            status: AuthStatus.error,
            error: result.message,
            isLoading: false,
          );
        },
        context: context,
      );

      return result.isSuccess;
    } catch (e) {
      LoggerService.error('Send OTP error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ في إرسال رمز التحقق',
        isLoading: false,
      );
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({
    required String smsCode,
    String? name,
    BuildContext? context,
  }) async {
    try {
      if (state.verificationId == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: 'لم يتم العثور على رمز التحقق',
          isLoading: false,
        );
        return false;
      }

      state = state.copyWith(isLoading: true, error: null);

      final result = await AuthService.verifyOTP(
        verificationId: state.verificationId!,
        smsCode: smsCode,
        name: name,
        context: context,
      );

      if (result.isSuccess) {
        await _handlePhoneVerificationSuccess(result.user!);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('Verify OTP error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ في التحقق من الرمز',
        isLoading: false,
      );
      return false;
    }
  }

  // Handle phone verification success
  Future<void> _handlePhoneVerificationSuccess(User firebaseUser) async {
    final user = UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      phone: firebaseUser.phoneNumber!,
      name: firebaseUser.displayName ?? '',
      emailVerified: firebaseUser.emailVerified,
      phoneVerified: true,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLogin: DateTime.now(),
    );

    await _saveUserSession(user);

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      verificationId: null,
      isLoading: false,
    );
  }

  // Save user session to secure storage
  Future<void> _saveUserSession(UserModel user) async {
    try {
      // Save auth token (using Firebase ID token)
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        await SecureStorageService.saveAuthToken(idToken);
      }

      // Save user data
      await SecureStorageService.saveUserData(
        userId: user.id,
        email: user.email,
        phone: user.phone,
        name: user.name,
      );

      // Save session expiry (30 days from now)
      final sessionExpiry = DateTime.now().add(const Duration(days: 30));
      await SecureStorageService.saveSessionExpiry(sessionExpiry);

      LoggerService.info('User session saved successfully');
    } catch (e) {
      LoggerService.error('Failed to save user session: $e');
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification({BuildContext? context}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await AuthService.sendEmailVerification(context: context);

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('Send email verification error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ في إرسال بريد التأكيد',
        isLoading: false,
      );
      return false;
    }
  }

  // Check email verification status
  Future<void> checkEmailVerification() async {
    try {
      await AuthService.reloadUser();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.emailVerified) {
        final user = state.user?.copyWith(emailVerified: true);
        state = state.copyWith(status: AuthStatus.authenticated, user: user);

        if (user != null) {
          await _saveUserSession(user);
        }
      }
    } catch (e) {
      LoggerService.error('Check email verification error: $e');
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail({
    required String email,
    BuildContext? context,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await AuthService.sendPasswordResetEmail(
        email: email,
        context: context,
      );

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('Send password reset error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ في إرسال بريد إعادة تعيين كلمة المرور',
        isLoading: false,
      );
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword({
    required String newPassword,
    BuildContext? context,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await AuthService.updatePassword(
        newPassword: newPassword,
        context: context,
      );

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('Update password error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ في تحديث كلمة المرور',
        isLoading: false,
      );
      return false;
    }
  }

  // Toggle biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    try {
      await SecureStorageService.setBiometricEnabled(enabled);
      state = state.copyWith(biometricEnabled: enabled);
      LoggerService.info(
        'Biometric authentication ${enabled ? 'enabled' : 'disabled'}',
      );
    } catch (e) {
      LoggerService.error('Failed to toggle biometric: $e');
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      // Handle guest mode cleanup
      if (state.isGuest) {
        await GuestService.clearGuestSession();
      }

      // Set state to unauthenticated first to trigger router redirect
      state = const AuthState(status: AuthStatus.unauthenticated);
      
      // Then perform actual signout operations
      await AuthService.signOut();
      await SecureStorageService.clearAuthData();

      LoggerService.info('User signed out successfully');
    } catch (e) {
      LoggerService.error('Sign out error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ في تسجيل الخروج',
        isLoading: false,
      );
    }
  }

  // Force logout (for security purposes)
  Future<void> forceLogout() async {
    try {
      // Handle guest mode cleanup
      if (state.isGuest) {
        await GuestService.clearGuestSession();
      }

      await AuthService.signOut();
      await SecureStorageService.clearAllData();

      state = const AuthState(status: AuthStatus.unauthenticated);

      LoggerService.info('User forced logout successfully');
    } catch (e) {
      LoggerService.error('Force logout error: $e');
    }
  }

  // Guest authentication methods
  Future<bool> signInAsGuest([BuildContext? context]) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await GuestService.signInAnonymously();

      if (result.isSuccess) {
        final guestSession = await GuestService.getCurrentGuestSession();

        // Ensure guestSession is available before updating state
        if (guestSession != null) {
          // Update state first with loading false to ensure router can process
          state = state.copyWith(
            status: AuthStatus.guest,
            isGuestMode: true,
            guestSession: guestSession,
            isLoading: false,
            error: null,
          );
        } else {
          // Fallback: create a basic guest session if none exists
          final fallbackSession = GuestSession.create();
          await GuestService.updateGuestSession(fallbackSession);

          state = state.copyWith(
            status: AuthStatus.guest,
            isGuestMode: true,
            guestSession: fallbackSession,
            isLoading: false,
            error: null,
          );
        }

        LoggerService.info('Guest sign in successful, state updated');
        LoggerService.info(
          '🟢 Guest state updated - Status: ${state.status}, isGuest: ${state.isGuest}, isLoading: ${state.isLoading}',
        );

        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('Guest sign in error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ في تسجيل الدخول كضيف',
        isLoading: false,
      );
      return false;
    }
  }

  // Convert guest to registered user
  Future<bool> convertGuestToRegistered({
    required String email,
    required String password,
    required String name,
    BuildContext? context,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await GuestService.convertGuestToRegistered(
        email: email,
        password: password,
        name: name,
      );

      if (result.isSuccess) {
        final user = UserModel(
          id: result.user!.uid,
          email: result.user!.email!,
          name: name,
          emailVerified: result.user!.emailVerified,
          phoneVerified: false,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _saveUserSession(user);

        state = state.copyWith(
          status: result.user!.emailVerified
              ? AuthStatus.authenticated
              : AuthStatus.emailNotVerified,
          user: user,
          isGuestMode: false,
          guestSession: null,
          isLoading: false,
          error: null,
        );

        LoggerService.info('Guest to registered conversion successful');
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: result.message,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('Guest conversion error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'حدث خطأ في تحويل الحساب',
        isLoading: false,
      );
      return false;
    }
  }

  // Track guest feature usage
  Future<void> trackGuestFeature(String feature) async {
    try {
      await GuestService.trackFeatureUsage(feature);
      final updatedSession = await GuestService.getCurrentGuestSession();
      state = state.copyWith(guestSession: updatedSession);
    } catch (e) {
      LoggerService.error('Failed to track guest feature: $e');
    }
  }

  // Track guest page visit
  Future<void> trackGuestPageVisit(String page) async {
    try {
      await GuestService.trackPageVisit(page);
      final updatedSession = await GuestService.getCurrentGuestSession();
      state = state.copyWith(guestSession: updatedSession);
    } catch (e) {
      LoggerService.error('Failed to track guest page visit: $e');
    }
  }

  // Mark conversion prompt as shown
  Future<void> markConversionPromptShown() async {
    try {
      await GuestService.markConversionPromptShown();
      final updatedSession = await GuestService.getCurrentGuestSession();
      state = state.copyWith(guestSession: updatedSession);
    } catch (e) {
      LoggerService.error('Failed to mark conversion prompt as shown: $e');
    }
  }

  // Check if guest should see conversion prompt
  Future<bool> shouldShowConversionPrompt() async {
    try {
      return await GuestService.shouldShowConversionPrompt();
    } catch (e) {
      LoggerService.error('Failed to check conversion prompt: $e');
      return false;
    }
  }

  // Get guest analytics
  Future<Map<String, dynamic>> getGuestAnalytics() async {
    try {
      return await GuestService.getGuestAnalytics();
    } catch (e) {
      LoggerService.error('Failed to get guest analytics: $e');
      return {};
    }
  }

  // Update guest session data
  Future<void> updateGuestTemporaryData(String key, dynamic value) async {
    try {
      await GuestService.updateTemporaryData(key, value);
      final updatedSession = await GuestService.getCurrentGuestSession();
      state = state.copyWith(guestSession: updatedSession);
    } catch (e) {
      LoggerService.error('Failed to update guest temporary data: $e');
    }
  }

  // Check if feature is restricted for guests
  bool isFeatureRestricted(String feature) {
    return GuestService.isFeatureRestricted(feature);
  }

  // Get list of restricted features
  List<String> getRestrictedFeatures() {
    return GuestService.getRestrictedFeatures();
  }

  // Initialize guest session on app start
  Future<void> _initializeGuestSession() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        final guestSession = await GuestService.getCurrentGuestSession();
        if (guestSession != null) {
          state = state.copyWith(
            status: AuthStatus.guest,
            isGuestMode: true,
            guestSession: guestSession,
            isLoading: false,
          );
          LoggerService.info('Guest session restored successfully');
        }
      }
    } catch (e) {
      LoggerService.error('Failed to initialize guest session: $e');
    }
  }
}

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier();
});

// Convenient computed providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isGuest;
});

final canAccessAppProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).canAccessApp;
});

final isRegisteredUserProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isRegisteredUser;
});

final shouldShowGuestBannerProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).shouldShowGuestBanner;
});

final canConvertToRegisteredProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).canConvertToRegistered;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).user;
});

final guestSessionProvider = Provider<GuestSession?>((ref) {
  return ref.watch(authStateProvider).guestSession;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).error;
});
