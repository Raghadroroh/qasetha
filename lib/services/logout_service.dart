import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;

import '../providers/auth_state_provider.dart';
import '../services/theme_service.dart';
import '../services/logger_service.dart';

/// Unified logout service for the entire application
/// This service replaces the scattered logout implementations
class LogoutService {
  /// Show logout confirmation dialog
  static Future<bool> showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
    final authState = ref.watch(authStateProvider);
    final isGuest = authState.isGuest;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogoutConfirmationDialog(isGuest: isGuest),
    );
    return result ?? false;
  }

  /// Perform logout with proper navigation
  static Future<void> performLogout(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LogoutLoadingDialog(),
      );

      // Execute logout through AuthStateProvider (this handles Firebase signOut internally)
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.signOut();

      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Force immediate navigation to login
        if (context.mounted) {
          // Force navigation to login instead of relying on router redirect
          // This ensures immediate navigation after logout
          context.go('/login');
          LoggerService.info('Logout completed, navigated to login');
        }
      }
    } catch (e) {
      LoggerService.error('Logout error: $e');
      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في تسجيل الخروج: $e',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Quick logout without confirmation (for programmatic use)
  static Future<void> performQuickLogout(BuildContext context, WidgetRef ref) async {
    await performLogout(context, ref);
  }

  /// Show logout confirmation and perform logout if confirmed
  static Future<void> showLogoutConfirmationAndPerform(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showLogoutConfirmation(context, ref);
    if (shouldLogout && context.mounted) {
      await performLogout(context, ref);
    }
  }
}

/// Logout confirmation dialog
class LogoutConfirmationDialog extends StatelessWidget {
  final bool isGuest;

  const LogoutConfirmationDialog({
    super.key,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Icon(
                  isGuest ? Icons.person_off : Icons.logout,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isArabic ? 'تأكيد الخروج' : 'Confirm Logout',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                  ),
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGuest
                    ? (isArabic 
                        ? 'هل أنت متأكد من إنهاء الجلسة الضيف؟'
                        : 'Are you sure you want to end your guest session?')
                    : (isArabic 
                        ? 'هل أنت متأكد من تسجيل الخروج؟'
                        : 'Are you sure you want to logout?'),
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF1A4B52).withOpacity(0.9),
                  height: 1.5,
                ),
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              ),
              if (isGuest) ...[
                const SizedBox(height: 12),
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isArabic 
                              ? 'سيتم حذف جميع بياناتك المؤقتة'
                              : 'All your temporary data will be deleted',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: isDarkMode 
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF1A4B52).withOpacity(0.8),
                          ),
                          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                isArabic ? 'إلغاء' : 'Cancel',
                style: GoogleFonts.tajawal(
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF1A4B52).withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isArabic ? 'نعم' : 'Yes',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Loading dialog shown during logout
class LogoutLoadingDialog extends StatelessWidget {
  const LogoutLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isArabic = themeService.languageCode == 'ar';

        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  isArabic ? 'جاري تسجيل الخروج...' : 'Signing out...',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Mixin for screens that need logout functionality
mixin LogoutMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Future<void> showLogoutConfirmation() async {
    await LogoutService.showLogoutConfirmationAndPerform(context, ref);
  }

  Future<void> performQuickLogout() async {
    await LogoutService.performQuickLogout(context, ref);
  }
}