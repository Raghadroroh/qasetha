import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GlobalBackHandler extends StatelessWidget {
  final Widget child;

  const GlobalBackHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // First try Navigator
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }
        
        // Then try GoRouter
        final router = GoRouter.of(context);
        if (router.canPop()) {
          context.pop();
          return;
        }
        
        // If we're on the first screen, do nothing (don't exit app)
        // This ensures the app never exits with back button
      },
      child: child,
    );
  }

  // No exit confirmation needed as we never exit the app
}