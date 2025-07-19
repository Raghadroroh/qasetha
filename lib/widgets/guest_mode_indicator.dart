import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme_service.dart';
import '../providers/auth_state_provider.dart';
import 'guest_conversion_modal.dart';

class GuestModeIndicator extends ConsumerWidget {
  final bool showInAppBar;
  final VoidCallback? onTap;

  const GuestModeIndicator({
    super.key,
    this.showInAppBar = false,
    this.onTap,
  });

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

        if (showInAppBar) {
          return _buildAppBarIndicator(isDarkMode, isArabic, authState);
        }

        return _buildFloatingIndicator(isDarkMode, isArabic, authState);
      },
    );
  }

  Widget _buildAppBarIndicator(bool isDarkMode, bool isArabic, AuthState authState) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: onTap ?? () => _showConversionModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF00E5FF), const Color(0xFF2D1B69)]
                : [const Color(0xFF2E7D8A), const Color(0xFF7FB3B3)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A))
                  .withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              isArabic ? 'ضيف' : 'Guest',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.upgrade,
                size: 12,
                color: isDarkMode ? const Color(0xFF2D1B69) : const Color(0xFF2E7D8A),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFloatingIndicator(bool isDarkMode, bool isArabic, AuthState authState) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: onTap ?? () => _showConversionModal(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF00E5FF), const Color(0xFF2D1B69)]
                : [const Color(0xFF2E7D8A), const Color(0xFF7FB3B3)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A))
                  .withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              isArabic ? 'ضيف' : 'Guest',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.upgrade,
                size: 12,
                color: isDarkMode ? const Color(0xFF2D1B69) : const Color(0xFF2E7D8A),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  void _showConversionModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const GuestConversionModal(),
    );
  }
}

/// Guest mode badge for app bars
class GuestBadge extends ConsumerWidget {
  final EdgeInsets padding;
  final double fontSize;

  const GuestBadge({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.fontSize = 12,
  });

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
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF00E5FF), const Color(0xFF2D1B69)]
                  : [const Color(0xFF2E7D8A), const Color(0xFF7FB3B3)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A))
                    .withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                isArabic ? 'ضيف' : 'Guest',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Guest mode upgrade prompt
class GuestUpgradePrompt extends ConsumerWidget {
  final String message;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDismiss;

  const GuestUpgradePrompt({
    super.key,
    required this.message,
    this.onUpgrade,
    this.onDismiss,
  });

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
                      const Color(0xFF2D1B69).withOpacity(0.9),
                      const Color(0xFF1A1B3A).withOpacity(0.9),
                    ]
                  : [
                      const Color(0xFF7FB3B3).withOpacity(0.9),
                      const Color(0xFF2E7D8A).withOpacity(0.9),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? const Color(0xFF00E5FF).withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? const Color(0xFF00E5FF).withOpacity(0.2)
                    : const Color(0xFF2E7D8A).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.upgrade,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'ترقية الحساب' : 'Upgrade Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: onUpgrade ?? () => _showConversionModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: isDarkMode
                          ? const Color(0xFF2D1B69)
                          : const Color(0xFF2E7D8A),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isArabic ? 'ترقية' : 'Upgrade',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onDismiss,
                    child: Text(
                      isArabic ? 'لاحقاً' : 'Later',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConversionModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const GuestConversionModal(),
    );
  }
}