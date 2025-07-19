import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/theme_service.dart';
import '../providers/auth_state_provider.dart';
import 'guest_conversion_modal.dart';

class GuestAccountCreationDialog extends ConsumerWidget {
  final String title;
  final String message;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onLogin;
  final VoidCallback? onCancel;

  const GuestAccountCreationDialog({
    super.key,
    required this.title,
    required this.message,
    this.onCreateAccount,
    this.onLogin,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1A1B3A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDarkMode 
                  ? const Color(0xFF00E5FF).withOpacity(0.3)
                  : const Color(0xFF2E7D8A).withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [const Color(0xFF00E5FF), const Color(0xFF2D1B69)]
                        : [const Color(0xFF2E7D8A), const Color(0xFF7FB3B3)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF1A4B52).withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? const Color(0xFF00E5FF).withOpacity(0.1)
                      : const Color(0xFF2E7D8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode 
                        ? const Color(0xFF00E5FF).withOpacity(0.3)
                        : const Color(0xFF2E7D8A).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'مزايا إنشاء حساب:' : 'Account Benefits:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...[
                      isArabic ? 'حفظ البيانات والتفضيلات' : 'Save data and preferences',
                      isArabic ? 'الوصول لجميع الميزات' : 'Access all features',
                      isArabic ? 'المزامنة عبر الأجهزة' : 'Sync across devices',
                    ].map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: isDarkMode 
                                ? const Color(0xFF00E5FF)
                                : const Color(0xFF2E7D8A),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            benefit,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode 
                                  ? Colors.white.withOpacity(0.8)
                                  : const Color(0xFF1A4B52).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(
                isArabic ? 'إلغاء' : 'Cancel',
                style: TextStyle(
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF1A4B52).withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onLogin != null) {
                  onLogin!();
                } else {
                  _navigateToLogin(context);
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDarkMode 
                      ? const Color(0xFF00E5FF).withOpacity(0.7)
                      : const Color(0xFF2E7D8A).withOpacity(0.7),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isArabic ? 'تسجيل دخول' : 'Login',
                style: TextStyle(
                  color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCreateAccount != null) {
                  onCreateAccount!();
                } else {
                  _navigateToSignup(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isArabic ? 'إنشاء حساب' : 'Create Account',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin(BuildContext context) {
    context.push('/login');
  }

  void _navigateToSignup(BuildContext context) {
    context.push('/signup');
  }

  /// Show account creation dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onCreateAccount,
    VoidCallback? onLogin,
    VoidCallback? onCancel,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GuestAccountCreationDialog(
        title: title,
        message: message,
        onCreateAccount: onCreateAccount,
        onLogin: onLogin,
        onCancel: onCancel,
      ),
    );
  }

  /// Show profile restriction dialog
  static Future<void> showProfileRestriction(BuildContext context) async {
    await show(
      context,
      title: 'تحرير الملف الشخصي',
      message: 'يرجى إنشاء حساب أو تسجيل الدخول أولاً لتحرير الملف الشخصي',
      onCreateAccount: () => _navigateToSignupFromContext(context),
      onLogin: () => _navigateToLoginFromContext(context),
    );
  }

  /// Show feature restriction dialog
  static Future<void> showFeatureRestriction(
    BuildContext context, {
    required String featureName,
  }) async {
    await show(
      context,
      title: 'ميزة محدودة',
      message: 'هذه الميزة متاحة للمستخدمين المسجلين فقط. يرجى إنشاء حساب للوصول إلى $featureName',
      onCreateAccount: () => _navigateToSignupFromContext(context),
      onLogin: () => _navigateToLoginFromContext(context),
    );
  }

  /// Show conversion modal
  static Future<void> showConversionModal(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const GuestConversionModal(),
    );
  }

  static void _navigateToLoginFromContext(BuildContext context) {
    context.push('/login');
  }

  static void _navigateToSignupFromContext(BuildContext context) {
    context.push('/signup');
  }
}

/// Quick access buttons for guest mode
class GuestQuickActions extends ConsumerWidget {
  const GuestQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    if (!authState.isGuest) {
      return const SizedBox.shrink();
    }

    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      const Color(0xFF2D1B69).withOpacity(0.3),
                      const Color(0xFF1A1B3A).withOpacity(0.3),
                    ]
                  : [
                      const Color(0xFF7FB3B3).withOpacity(0.3),
                      const Color(0xFF2E7D8A).withOpacity(0.3),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? const Color(0xFF00E5FF).withOpacity(0.3)
                  : const Color(0xFF2E7D8A).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/signup'),
                  icon: const Icon(Icons.person_add, size: 16),
                  label: Text(
                    isArabic ? 'إنشاء حساب' : 'Create Account',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login, size: 16),
                  label: Text(
                    isArabic ? 'تسجيل دخول' : 'Login',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
                    ),
                    foregroundColor: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}