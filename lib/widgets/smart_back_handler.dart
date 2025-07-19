import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SmartBackHandler extends StatefulWidget {
  final Widget child;
  final bool isMainScreen;
  final VoidCallback? onExit;
  final String? customRoute;

  const SmartBackHandler({
    super.key,
    required this.child,
    this.isMainScreen = false,
    this.onExit,
    this.customRoute,
  });

  @override
  State<SmartBackHandler> createState() => _SmartBackHandlerState();
}

class _SmartBackHandlerState extends State<SmartBackHandler> {
  DateTime? _currentBackPressTime;
  bool _isShowingSnackBar = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBackPress(context);
        return false;
      },
      child: widget.child,
    );
  }

  Future<void> _handleBackPress(BuildContext context) async {
    if (!widget.isMainScreen) {
      // الشاشات العادية - رجوع عادي
      Navigator.of(context).pop();
      return;
    }

    // الشاشة الرئيسية - منطق الضغط المزدوج
    final now = DateTime.now();

    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      // الضغطة الأولى
      _currentBackPressTime = now;
      _showExitToast(context);
    } else {
      // الضغطة الثانية خلال ثانيتين
      _showExitDialog(context);
    }
  }

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
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
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
              onPressed: () => _exitApp(context),
            ),
          ),
        )
        .closed
        .then((_) {
          _isShowingSnackBar = false;
        });
  }

  void _showExitDialog(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.1),
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
            height: 1.5,
          ),
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
              onPressed: () {
                Navigator.of(context).pop();
                _exitApp(context);
              },
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
      ),
    );
  }

  void _exitApp(BuildContext context) {
    if (widget.onExit != null) {
      widget.onExit!();
    } else {
      SystemNavigator.pop();
    }
  }
}

// Extension للاستخدام السهل
extension SmartBackHandlerExtension on Widget {
  Widget withSmartBackHandler({
    bool isMainScreen = false,
    VoidCallback? onExit,
    String? customRoute,
  }) {
    return SmartBackHandler(
      isMainScreen: isMainScreen,
      onExit: onExit,
      customRoute: customRoute,
      child: this,
    );
  }
}
