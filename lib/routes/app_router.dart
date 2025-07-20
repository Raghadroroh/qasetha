import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/auth/phone_signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/otp_verify_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/verify_phone_screen.dart';
import '../screens/settings/security_settings_screen.dart';
import '../screens/settings/app_settings_screen.dart';
import '../screens/settings/language_settings_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/language_selection_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen_new.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/notifications_screen.dart';

import '../services/logger_service.dart';

// Router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/language-selection',
    redirect: (context, state) async {
      try {
        LoggerService.info('Router redirect: ${state.uri.toString()}');

        final authState = ref.read(authStateProvider);
        final isAuthenticated = authState.isAuthenticated;
        final isGuest = authState.isGuest;
        final currentLocation = state.uri.toString();

        LoggerService.info(
          'Auth state - isAuthenticated: $isAuthenticated, isGuest: $isGuest, isLoading: ${authState.isLoading}',
        );

        // If user is loading, stay on current page
        if (authState.isLoading) {
          LoggerService.info('Auth loading, staying on current page');
          return null;
        }

        // Routes that don't require authentication
        final publicRoutes = [
          '/language-selection',
          '/onboarding',
          '/login',
          '/signup',
          '/phone-login',
          '/phone-signup',
          '/forgot-password',
          '/reset-password',
          '/otp-verify',
          '/verify-email',
          '/verify-phone',
          '/success',
        ];

        // If user needs email verification
        if (authState.needsEmailVerification &&
            currentLocation != '/verify-email') {
          LoggerService.info(
            'User needs email verification, redirecting from $currentLocation to /verify-email',
          );
          return '/verify-email';
        }

        // If user needs phone verification
        if (authState.needsPhoneVerification &&
            currentLocation != '/otp-verify') {
          LoggerService.info('User needs phone verification');
          return '/otp-verify';
        }

        // If user is authenticated (including guest) but on public route, redirect to dashboard
        if ((isAuthenticated || isGuest) &&
            publicRoutes.contains(currentLocation)) {
          LoggerService.info(
            'Authenticated/guest user on public route, redirecting to dashboard',
          );
          return '/dashboard';
        }

        // If user is not authenticated and trying to access protected route, redirect to login
        if (!isAuthenticated && !isGuest && currentLocation == '/dashboard') {
          LoggerService.info(
            'Unauthenticated user trying to access dashboard, redirecting to login',
          );
          return '/login';
        }

        return null;
      } catch (e) {
        LoggerService.error('Router redirect error: $e');
        return null;
      }
    },
    routes: [
      // Language selection
      GoRoute(
        path: '/language-selection',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const LanguageSelectionScreen(),
          transitionType: TransitionType.fadeScale,
        ),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionType: TransitionType.slideFromRight,
        ),
      ),

      // Authentication routes
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionType: TransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionType: TransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: '/phone-login',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const PhoneLoginScreen(),
          transitionType: TransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: '/phone-signup',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const PhoneSignupScreen(),
          transitionType: TransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionType: TransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const ResetPasswordScreen(),
          transitionType: TransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: '/otp-verify',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _buildModernPage(
            key: state.pageKey,
            child: OTPVerifyScreen(data: extra),
            transitionType: TransitionType.scaleRotate,
          );
        },
      ),

      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const VerifyEmailScreen(),
          transitionType: TransitionType.scaleRotate,
        ),
      ),

      GoRoute(
        path: '/verify-phone',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phoneNumber = extra['phoneNumber'] as String? ?? '';
          return _buildModernPage(
            key: state.pageKey,
            child: VerifyPhoneScreen(phoneNumber: phoneNumber),
            transitionType: TransitionType.scaleRotate,
          );
        },
      ),

      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionType: TransitionType.slideFromRight,
        ),
      ),

      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
          transitionType: TransitionType.slideFromRight,
        ),
      ),

      // Settings routes
      GoRoute(
        path: '/security-settings',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const SecuritySettingsScreen(),
          transitionType: TransitionType.slideFromRight,
        ),
      ),

      GoRoute(
        path: '/app-settings',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const AppSettingsScreen(),
          transitionType: TransitionType.slideFromRight,
        ),
      ),

      GoRoute(
        path: '/language-settings',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const LanguageSettingsScreen(),
          transitionType: TransitionType.slideFromRight,
        ),
      ),

      // Dashboard route
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionType: TransitionType.fadeScale,
        ),
      ),

      // Notifications route
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _buildModernPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
          transitionType: TransitionType.slideFromRight,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'صفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على الصفحة المطلوبة',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Transition types
enum TransitionType {
  fade,
  fadeScale,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  scaleRotate,
  bounceScale,
  fadeSlide,
}

// Page builder helper
CustomTransitionPage _buildModernPage({
  required LocalKey key,
  required Widget child,
  required TransitionType transitionType,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _getTransition(
        transitionType,
        animation,
        secondaryAnimation,
        child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}

// Transition builder
Widget _getTransition(
  TransitionType type,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  switch (type) {
    case TransitionType.fade:
      return FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
        child: child,
      );

    case TransitionType.fadeScale:
      return FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeInOutCubic)),
        child: ScaleTransition(
          scale: animation.drive(
            Tween(
              begin: 0.8,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOutBack)),
          ),
          child: child,
        ),
      );

    case TransitionType.slideFromRight:
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        ),
      );

    case TransitionType.slideFromLeft:
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        ),
      );

    case TransitionType.slideFromBottom:
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        ),
      );

    case TransitionType.slideFromTop:
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        ),
      );

    case TransitionType.scaleRotate:
      return ScaleTransition(
        scale: animation.drive(
          Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.elasticOut)),
        ),
        child: RotationTransition(
          turns: animation.drive(
            Tween(
              begin: 0.1,
              end: 0.0,
            ).chain(CurveTween(curve: Curves.easeOut)),
          ),
          child: FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
            child: child,
          ),
        ),
      );

    case TransitionType.bounceScale:
      return ScaleTransition(
        scale: animation.drive(
          Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.bounceOut)),
        ),
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
          child: child,
        ),
      );

    case TransitionType.fadeSlide:
      return FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeInOutCubic)),
        child: SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutQuart)),
          ),
          child: child,
        ),
      );
  }
}
