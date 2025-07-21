import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/logout_service.dart';

/// Legacy wrapper for the new LogoutService
/// Use LogoutService directly for new implementations
class LogoutConfirmationDialog extends ConsumerWidget {
  final Future<void> Function()? onConfirm;
  final VoidCallback? onCancel;

  const LogoutConfirmationDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the new LogoutService directly
    return FutureBuilder<bool>(
      future: LogoutService.showLogoutConfirmation(context, ref),
      builder: (context, snapshot) {
        // This widget should never actually be built in new implementations
        return const SizedBox.shrink();
      },
    );
  }

  /// Show logout confirmation dialog (legacy method)
  static Future<bool> show(BuildContext context, WidgetRef ref) async {
    return LogoutService.showLogoutConfirmation(context, ref);
  }

  /// Show logout confirmation with custom callbacks (legacy method)
  static Future<void> showWithCallbacks(
    BuildContext context,
    WidgetRef ref, {
    Future<void> Function()? onConfirm,
    VoidCallback? onCancel,
  }) async {
    if (onConfirm != null) {
      final shouldLogout = await LogoutService.showLogoutConfirmation(context, ref);
      if (shouldLogout) {
        await onConfirm();
      } else {
        onCancel?.call();
      }
    } else {
      await LogoutService.showLogoutConfirmationAndPerform(context, ref);
    }
  }
}

/// Legacy mixin - use LogoutMixin from LogoutService instead
@Deprecated('Use LogoutMixin from LogoutService instead')
mixin LegacyLogoutMixin<T extends StatefulWidget> on State<T> {
  Future<void> showLogoutConfirmation() async {
    // This is deprecated - implement LogoutMixin from LogoutService
    throw UnimplementedError('Use LogoutMixin from LogoutService instead');
  }
}

/// Legacy helper class - use LogoutService instead
@Deprecated('Use LogoutService instead')
class QuickLogoutHelper {
  static Future<void> performQuickLogout(
    BuildContext context,
    WidgetRef ref, {
    bool showConfirmation = true,
  }) async {
    if (showConfirmation) {
      await LogoutService.showLogoutConfirmationAndPerform(context, ref);
    } else {
      await LogoutService.performQuickLogout(context, ref);
    }
  }
}