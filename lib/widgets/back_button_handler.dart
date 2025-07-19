import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'smart_back_handler.dart';

class BackButtonHandler extends StatelessWidget {
  final Widget child;
  final String? fallbackRoute;
  final bool canPop;
  final VoidCallback? onBackPressed;
  final bool isMainScreen;

  const BackButtonHandler({
    super.key,
    required this.child,
    this.fallbackRoute,
    this.canPop = true,
    this.onBackPressed,
    this.isMainScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMainScreen) {
      // الشاشة الرئيسية - استخدام SmartBackHandler
      return SmartBackHandler(isMainScreen: true, child: child);
    }

    // الشاشات العادية - معالجة عادية
    return WillPopScope(
      onWillPop: () async {
        if (onBackPressed != null) {
          onBackPressed!();
        } else if (fallbackRoute != null) {
          context.go(fallbackRoute!);
        } else if (canPop) {
          Navigator.of(context).pop();
        }
        return false;
      },
      child: child,
    );
  }
}
