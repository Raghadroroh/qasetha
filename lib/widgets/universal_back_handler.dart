import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hook موحد للتعامل مع زر الرجوع في جميع الشاشات
/// يدعم زر النظام وزر التطبيق مع double-tap للخروج
class UniversalBackHandler extends StatefulWidget {
  final Widget child;
  final bool isMainScreen;  // للشاشات الرئيسية (dashboard)
  final String? fallbackRoute;  // الروت البديل إذا لم يكن هناك صفحة سابقة
  final VoidCallback? onExit;  // دالة مخصصة للخروج
  final bool showExitDialog;  // عرض تأكيد الخروج
  final bool preventExit;  // منع الخروج من التطبيق
  final bool enableDoubleTap;  // تفعيل الضغط المزدوج للخروج

  const UniversalBackHandler({
    super.key,
    required this.child,
    this.isMainScreen = false,
    this.fallbackRoute,
    this.onExit,
    this.showExitDialog = true,
    this.preventExit = false,
    this.enableDoubleTap = true,
  });

  @override
  State<UniversalBackHandler> createState() => _UniversalBackHandlerState();
}

class _UniversalBackHandlerState extends State<UniversalBackHandler> {
  DateTime? _currentBackPressTime;
  bool _isShowingSnackBar = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        await _handleBackNavigation(context);
      },
      child: widget.child,
    );
  }

  /// معالجة التنقل للخلف بشكل ذكي
  Future<void> _handleBackNavigation(BuildContext context) async {
    if (!context.mounted) return;
    
    // إذا كانت شاشة رئيسية ومُعدة لمنع الخروج
    if (widget.isMainScreen && widget.preventExit) {
      return;
    }

    // إذا كانت شاشة رئيسية وتفعيل الضغط المزدوج
    if (widget.isMainScreen && widget.enableDoubleTap) {
      await _handleDoubleTapExit(context);
      return;
    }

    // إذا كانت شاشة رئيسية ونريد تأكيد الخروج مباشرة
    if (widget.isMainScreen && widget.showExitDialog) {
      final shouldExit = await _showExitConfirmation(context);
      if (!context.mounted) return;
      if (shouldExit) {
        _exitApp();
      }
      return;
    }

    // محاولة الرجوع العادي
    if (await _tryNavigateBack(context)) {
      return;
    }

    if (!context.mounted) return;
    
    // إذا لم ينجح الرجوع العادي، استخدم الروت البديل
    if (widget.fallbackRoute != null) {
      context.go(widget.fallbackRoute!);
      return;
    }

    // إذا لم يكن هناك بديل، اذهب للداش بورد
    context.go('/dashboard');
  }

  /// معالجة الضغط المزدوج للخروج
  Future<void> _handleDoubleTapExit(BuildContext context) async {
    final now = DateTime.now();

    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      // الضغطة الأولى
      _currentBackPressTime = now;
      _showExitToast(context);
    } else {
      // الضغطة الثانية خلال ثانيتين
      if (widget.showExitDialog) {
        final shouldExit = await _showExitConfirmation(context);
        if (shouldExit) {
          _exitApp();
        }
      } else {
        _exitApp();
      }
    }
  }

  /// عرض رسالة الضغط المزدوج
  void _showExitToast(BuildContext context) {
    if (_isShowingSnackBar) return;

    _isShowingSnackBar = true;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final message = isArabic ? 'اضغط مرة أخرى للخروج' : 'Press again to exit';

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: isArabic ? 'خروج' : 'Exit',
              textColor: Colors.white,
              onPressed: () => _exitApp(),
            ),
          ),
        )
        .closed
        .then((_) {
          _isShowingSnackBar = false;
        });
  }

  /// الخروج من التطبيق
  void _exitApp() {
    if (widget.onExit != null) {
      widget.onExit!();
    } else {
      SystemNavigator.pop();
    }
  }

  /// محاولة الرجوع باستخدام الطرق المختلفة
  Future<bool> _tryNavigateBack(BuildContext context) async {
    try {
      // أولاً جرب Navigator العادي
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        return true;
      }

      // ثم جرب GoRouter
      final router = GoRouter.of(context);
      if (router.canPop()) {
        context.pop();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// عرض حوار تأكيد الخروج
  Future<bool> _showExitConfirmation(BuildContext context) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isArabic ? 'تأكيد الخروج' : 'Confirm Exit',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ],
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد من أنك تريد الخروج من التطبيق؟'
                : 'Are you sure you want to exit the app?',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                isArabic ? 'إلغاء' : 'Cancel',
                style: GoogleFonts.tajawal(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.error,
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  isArabic ? 'خروج' : 'Exit',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actionsAlignment: isArabic
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
        );
      },
    ) ?? false;
  }

}

/// Hook مبسط للاستخدام السريع
class QuickBackHandler extends StatelessWidget {
  final Widget child;
  final String? fallbackRoute;

  const QuickBackHandler({
    super.key,
    required this.child,
    this.fallbackRoute = '/dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return UniversalBackHandler(
      fallbackRoute: fallbackRoute,
      child: child,
    );
  }
}

/// Hook للشاشات الرئيسية مع الضغط المزدوج وتأكيد الخروج
class MainScreenBackHandler extends StatelessWidget {
  final Widget child;
  final bool enableDoubleTap;
  final bool showExitDialog;

  const MainScreenBackHandler({
    super.key,
    required this.child,
    this.enableDoubleTap = true,
    this.showExitDialog = true,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalBackHandler(
      isMainScreen: true,
      enableDoubleTap: enableDoubleTap,
      showExitDialog: showExitDialog,
      child: child,
    );
  }
}

/// Hook للشاشات الرئيسية مع الضغط المزدوج فقط (بدون حوار تأكيد)
class MainScreenDoubleTapHandler extends StatelessWidget {
  final Widget child;

  const MainScreenDoubleTapHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalBackHandler(
      isMainScreen: true,
      enableDoubleTap: true,
      showExitDialog: false,
      child: child,
    );
  }
}