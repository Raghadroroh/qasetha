import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/theme_service.dart';
import '../providers/auth_state_provider.dart';

class LogoutConfirmationDialog extends ConsumerWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const LogoutConfirmationDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isGuest = authState.isGuest;

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
                isGuest
                    ? (isArabic 
                        ? 'هل أنت متأكد من إنهاء الجلسة الضيف؟'
                        : 'Are you sure you want to end your guest session?')
                    : (isArabic 
                        ? 'هل أنت متأكد من تسجيل الخروج؟'
                        : 'Are you sure you want to logout?'),
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF1A4B52).withOpacity(0.9),
                ),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode 
                                ? Colors.white.withOpacity(0.8)
                                : const Color(0xFF1A4B52).withOpacity(0.8),
                          ),
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm?.call();
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
                isArabic ? 'نعم' : 'Yes',
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

  /// Show logout confirmation dialog
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LogoutConfirmationDialog(),
    );
    return result ?? false;
  }

  /// Show logout confirmation with custom callbacks
  static Future<void> showWithCallbacks(
    BuildContext context, {
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogoutConfirmationDialog(
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}

/// Logout helper mixin for screens
mixin LogoutMixin<T extends StatefulWidget> on State<T> {
  Future<void> showLogoutConfirmation() async {
    final shouldLogout = await LogoutConfirmationDialog.show(context);
    if (shouldLogout) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Perform logout
      // This should be implemented in each screen using the mixin
      await performLogout();

      // Close loading dialog
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تسجيل الخروج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Override this method in each screen
  Future<void> performLogout();
}