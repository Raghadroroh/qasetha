import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
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
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
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

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Perform logout
      // This should be implemented in each screen using the mixin
      await performLogout();

      // Close loading dialog
      if (mounted) {
        context.pop();
        // Navigate to login screen
        context.go('/login');
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

/// مساعد سريع لتسجيل الخروج مع توجيه مباشر
class QuickLogoutHelper {
  /// تسجيل خروج سريع مع توجيه تلقائي حسب نوع المستخدم
  static Future<void> performQuickLogout(
    BuildContext context,
    WidgetRef ref, {
    bool showConfirmation = true,
  }) async {
    final authState = ref.read(authStateProvider);
    final isGuest = authState.isGuest;
    
    bool shouldLogout = true;
    
    if (showConfirmation) {
      shouldLogout = await LogoutConfirmationDialog.show(context);
    }
    
    if (!shouldLogout || !context.mounted) return;
    
    try {
      // إظهار loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'جاري تسجيل الخروج...',
                  style: GoogleFonts.tajawal(),
                ),
              ],
            ),
          ),
        ),
      );

      // تنفيذ تسجيل الخروج من Firebase
      await FirebaseAuth.instance.signOut();
      
      // تنفيذ تسجيل الخروج من حالة التطبيق
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.signOut();
      
      if (context.mounted) {
        // إغلاق loading
        Navigator.of(context).pop();
        
        // انتظار قصير للتأكد من تحديث حالة المصادقة
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (context.mounted) {
          // محو stack الصفحات والتوجيه إلى login
          context.go('/login');
        }
      }
    } catch (e) {
      if (context.mounted) {
        // إغلاق loading
        Navigator.of(context).pop();
        
        // عرض رسالة خطأ
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
}