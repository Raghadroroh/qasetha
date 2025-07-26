import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';
import '../models/category.dart';
import '../services/logger_service.dart';
import '../services/analytics_service.dart';

// Import all screens
import '../screens/auth/enhanced_login_screen.dart';
import '../screens/auth/enhanced_signup_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/auth/phone_signup_screen.dart';
import '../screens/auth/enhanced_forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/otp_verify_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/verify_phone_screen.dart';
import '../screens/settings/app_settings_screen.dart';
import '../screens/settings/language_settings_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/language_selection_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/subcategory_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/profile_screen_new.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/notifications_screen.dart';

/// Enhanced Router Refresh Notifier
/// 
/// Listens to authentication state changes and refreshes the router
/// when the authentication status changes
class EnhancedGoRouterRefreshNotifier extends ChangeNotifier {
  EnhancedGoRouterRefreshNotifier(this._ref) {
    // Listen to auth state changes
    _ref.listen(authStateProvider, (previous, next) {
      // Only notify on significant status changes
      if (previous?.status != next.status) {
        LoggerService.info(
          'Auth status changed from ${previous?.status} to ${next.status}, refreshing router',
        );
        
        // Add a small delay to ensure state has settled
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_disposed) {
            notifyListeners();
          }
        });
      }
    });
  }

  final Ref _ref;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Enhanced App Router Provider
/// 
/// Provides a comprehensive routing system with:
/// - Authentication-based redirects
/// - Smooth page transitions
/// - Guest mode support
/// - Error handling
/// - Deep linking support
final enhancedAppRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/language-selection',
    refreshListenable: EnhancedGoRouterRefreshNotifier(ref),
    observers: [AnalyticsService.observer],
    
    redirect: (context, state) async {
      try {
        LoggerService.info('Router redirect check: ${state.uri.toString()}');

        final authState = ref.read(authStateProvider);
        final currentLocation = state.uri.toString();

        LoggerService.info(
          'Auth state - Status: ${authState.status}, '
          'isAuthenticated: ${authState.isAuthenticated}, '
          'isGuest: ${authState.isGuest}, '
          'isLoading: ${authState.isLoading}',
        );

        // Define public routes that don't require authentication
        final publicRoutes = {
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
        };

        // Handle loading state - allow navigation to public routes
        if (authState.isLoading) {
          if (publicRoutes.contains(currentLocation)) {
            LoggerService.info('Auth loading, allowing access to public route: $currentLocation');
            return null;
          }
          
          // For protected routes during loading, redirect to login if explicitly unauthenticated
          if (authState.status == AuthStatus.unauthenticated) {
            LoggerService.info('User unauthenticated during loading, redirecting to login');
            return '/login';
          }
          
          LoggerService.info('Auth loading, staying on current route: $currentLocation');
          return null;
        }

        // Handle email verification requirement
        if (authState.needsEmailVerification && currentLocation != '/verify-email') {
          LoggerService.info('User needs email verification, redirecting');
          return '/verify-email';
        }

        // Handle phone verification requirement
        if (authState.needsPhoneVerification && currentLocation != '/otp-verify') {
          LoggerService.info('User needs phone verification, redirecting');
          return '/otp-verify';
        }

        // Allow access to public routes for all users
        if (publicRoutes.contains(currentLocation)) {
          LoggerService.info('Allowing access to public route: $currentLocation');
          return null;
        }

        // If authenticated or guest user is on public routes, redirect to dashboard
        if ((authState.isAuthenticated || authState.isGuest) && 
            publicRoutes.contains(currentLocation)) {
          LoggerService.info(
            'Authenticated/guest user on public route $currentLocation, redirecting to dashboard',
          );
          return '/dashboard';
        }

        // If unauthenticated user tries to access protected route, redirect to login
        if (!authState.isAuthenticated && 
            !authState.isGuest && 
            !publicRoutes.contains(currentLocation)) {
          LoggerService.info(
            'Unauthenticated user accessing protected route $currentLocation, redirecting to login',
          );
          return '/login';
        }

        // No redirect needed
        return null;

      } catch (e) {
        LoggerService.error('Router redirect error: $e');
        // Safe fallback - redirect to login on error
        return '/login';
      }
    },

    routes: [
      // Language Selection
      GoRoute(
        path: '/language-selection',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const LanguageSelectionScreen(),
          transitionType: EnhancedTransitionType.fadeScale,
        ),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionType: EnhancedTransitionType.slideFromRight,
        ),
      ),

      // Enhanced Authentication Routes
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const EnhancedLoginScreen(),
          transitionType: EnhancedTransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const EnhancedSignupScreen(),
          transitionType: EnhancedTransitionType.slideFromBottom,
        ),
      ),

      // Phone Authentication Routes
      GoRoute(
        path: '/phone-login',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const PhoneLoginScreen(),
          transitionType: EnhancedTransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: '/phone-signup',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const PhoneSignupScreen(),
          transitionType: EnhancedTransitionType.slideFromBottom,
        ),
      ),

      // Password Reset Routes
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const EnhancedForgotPasswordScreen(),
          transitionType: EnhancedTransitionType.slideFromBottom,
        ),
      ),

      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const ResetPasswordScreen(),
          transitionType: EnhancedTransitionType.slideFromBottom,
        ),
      ),

      // Verification Routes
      GoRoute(
        path: '/otp-verify',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _buildEnhancedPage(
            key: state.pageKey,
            child: OTPVerifyScreen(data: extra),
            transitionType: EnhancedTransitionType.scaleRotate,
          );
        },
      ),

      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const VerifyEmailScreen(),
          transitionType: EnhancedTransitionType.scaleRotate,
        ),
      ),

      GoRoute(
        path: '/verify-phone',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phoneNumber = extra['phoneNumber'] as String? ?? '';
          return _buildEnhancedPage(
            key: state.pageKey,
            child: VerifyPhoneScreen(phoneNumber: phoneNumber),
            transitionType: EnhancedTransitionType.scaleRotate,
          );
        },
      ),

      // Main App Routes
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionType: EnhancedTransitionType.fadeScale,
        ),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionType: EnhancedTransitionType.slideFromRight,
        ),
      ),

      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
          transitionType: EnhancedTransitionType.slideFromRight,
        ),
      ),

      // Settings Routes
      GoRoute(
        path: '/app-settings',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const AppSettingsScreen(),
          transitionType: EnhancedTransitionType.slideFromRight,
        ),
      ),

      GoRoute(
        path: '/language-settings',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const LanguageSettingsScreen(),
          transitionType: EnhancedTransitionType.slideFromRight,
        ),
      ),

      // Notifications Route
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _buildEnhancedPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
          transitionType: EnhancedTransitionType.slideFromRight,
        ),
      ),

      // Category and Product Routes
      GoRoute(
        path: '/subcategories/:categoryId',
        pageBuilder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final category = state.extra as Category?;
          return _buildEnhancedPage(
            key: state.pageKey,
            child: SubcategoryScreen(
              parentCategoryId: categoryId,
              parentCategory: category,
            ),
            transitionType: EnhancedTransitionType.slideFromRight,
          );
        },
      ),

      GoRoute(
        path: '/products/category/:categoryId',
        pageBuilder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          final category = state.extra as Category?;
          return _buildEnhancedPage(
            key: state.pageKey,
            child: ProductListScreen(
              categoryId: categoryId,
              category: category,
            ),
            transitionType: EnhancedTransitionType.slideFromRight,
          );
        },
      ),
    ],

    // Enhanced Error Page
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1A1B3A),
              Color(0xFF2D1B69),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00E5FF),
                      const Color(0xFF00E5FF).withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'صفحة غير موجودة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'لم يتم العثور على الصفحة المطلوبة',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

/// Enhanced Transition Types
enum EnhancedTransitionType {
  fade,
  fadeScale,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  scaleRotate,
  bounceScale,
  fadeSlide,
  elastic,
}

/// Enhanced Page Builder
CustomTransitionPage _buildEnhancedPage({
  required LocalKey key,
  required Widget child,
  required EnhancedTransitionType transitionType,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _getEnhancedTransition(
        transitionType,
        animation,
        secondaryAnimation,
        child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}

/// Enhanced Transition Builder
Widget _getEnhancedTransition(
  EnhancedTransitionType type,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  switch (type) {
    case EnhancedTransitionType.fade:
      return FadeTransition(
        opacity: animation.drive(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        child: child,
      );

    case EnhancedTransitionType.fadeScale:
      return FadeTransition(
        opacity: animation.drive(
          CurveTween(curve: Curves.easeInOutQuart),
        ),
        child: ScaleTransition(
          scale: animation.drive(
            Tween(begin: 0.92, end: 1.0).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
          ),
          child: child,
        ),
      );

    case EnhancedTransitionType.slideFromRight:
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutQuart)),
        ),
        child: FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: Curves.easeInQuad),
          ),
          child: child,
        ),
      );

    case EnhancedTransitionType.slideFromLeft:
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutQuart)),
        ),
        child: FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: Curves.easeInQuad),
          ),
          child: child,
        ),
      );

    case EnhancedTransitionType.slideFromBottom:
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(0.0, 0.25),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutQuart)),
        ),
        child: FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: Curves.easeInQuad),
          ),
          child: child,
        ),
      );

    case EnhancedTransitionType.slideFromTop:
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: Curves.easeIn),
          ),
          child: child,
        ),
      );

    case EnhancedTransitionType.scaleRotate:
      return ScaleTransition(
        scale: animation.drive(
          Tween(begin: 0.85, end: 1.0).chain(
            CurveTween(curve: Curves.easeOutBack),
          ),
        ),
        child: RotationTransition(
          turns: animation.drive(
            Tween(begin: 0.02, end: 0.0).chain(
              CurveTween(curve: Curves.easeOutQuad),
            ),
          ),
          child: FadeTransition(
            opacity: animation.drive(
              CurveTween(curve: Curves.easeInQuad),
            ),
            child: child,
          ),
        ),
      );

    case EnhancedTransitionType.bounceScale:
      return ScaleTransition(
        scale: animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.bounceOut),
          ),
        ),
        child: FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: Curves.easeIn),
          ),
          child: child,
        ),
      );

    case EnhancedTransitionType.fadeSlide:
      return FadeTransition(
        opacity: animation.drive(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        child: SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutQuart)),
          ),
          child: child,
        ),
      );

    case EnhancedTransitionType.elastic:
      return ScaleTransition(
        scale: animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.elasticOut),
          ),
        ),
        child: FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: Curves.easeInQuad),
          ),
          child: child,
        ),
      );
  }
}