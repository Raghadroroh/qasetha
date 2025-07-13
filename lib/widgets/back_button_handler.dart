import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackButtonHandler extends StatelessWidget {
  final Widget child;
  final String? fallbackRoute;
  final bool canPop;
  final VoidCallback? onBackPressed;

  const BackButtonHandler({
    super.key,
    required this.child,
    this.fallbackRoute,
    this.canPop = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (onBackPressed != null) {
            onBackPressed!();
          } else if (fallbackRoute != null) {
            context.go(fallbackRoute!);
          } else if (context.canPop()) {
            context.pop();
          }
        }
      },
      child: child,
    );
  }
}

// Extension لتسهيل الاستخدام
extension BackButtonHandlerX on Widget {
  Widget withBackButton({
    String? fallbackRoute,
    bool canPop = true,
    VoidCallback? onBackPressed,
  }) {
    return BackButtonHandler(
      fallbackRoute: fallbackRoute,
      canPop: canPop,
      onBackPressed: onBackPressed,
      child: this,
    );
  }
}