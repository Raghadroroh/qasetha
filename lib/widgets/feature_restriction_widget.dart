import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../providers/auth_state_provider.dart';
import '../services/theme_service.dart';
import 'guest_conversion_modal.dart';

class FeatureRestrictionWidget extends ConsumerWidget {
  final String featureName;
  final IconData icon;
  final String description;
  final Widget? child;
  final VoidCallback? onUnlock;
  final bool showUpgradeButton;

  const FeatureRestrictionWidget({
    super.key,
    required this.featureName,
    required this.icon,
    required this.description,
    this.child,
    this.onUnlock,
    this.showUpgradeButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    final isRestricted = isGuest && authNotifier.isFeatureRestricted(featureName);

    if (!isRestricted) {
      return child ?? const SizedBox.shrink();
    }

    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF2D1B69).withValues(alpha: 0.3),
                      const Color(0xFF1A1B3A).withValues(alpha: 0.3),
                    ]
                  : [
                      const Color(0xFF7FB3B3).withValues(alpha: 0.3),
                      const Color(0xFF2E7D8A).withValues(alpha: 0.3),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                  : const Color(0xFF2E7D8A).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock Icon with Animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                  const Color(0xFF2D1B69).withValues(alpha: 0.8),
                                ]
                              : [
                                  const Color(0xFF2E7D8A).withValues(alpha: 0.8),
                                  const Color(0xFF7FB3B3).withValues(alpha: 0.8),
                                ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                                : const Color(0xFF2E7D8A).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Feature Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF1A4B52).withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                isArabic ? 'ميزة محدودة' : 'Feature Locked',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode 
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF1A4B52).withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Upgrade Button
              if (showUpgradeButton) ...[
                ElevatedButton(
                  onPressed: () {
                    if (onUnlock != null) {
                      onUnlock!();
                    } else {
                      _showConversionModal(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? const Color(0xFF00E5FF)
                        : const Color(0xFF2E7D8A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upgrade,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'إنشاء حساب' : 'Create Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isArabic 
                      ? 'سجل حساب جديد للوصول إلى هذه الميزة'
                      : 'Create an account to access this feature',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode 
                        ? Colors.white.withValues(alpha: 0.6)
                        : const Color(0xFF1A4B52).withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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

class FeatureRestrictionOverlay extends ConsumerWidget {
  final String featureName;
  final Widget child;
  final VoidCallback? onTap;

  const FeatureRestrictionOverlay({
    super.key,
    required this.featureName,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    final isRestricted = isGuest && authNotifier.isFeatureRestricted(featureName);

    if (!isRestricted) {
      return child;
    }

    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        return Stack(
          children: [
            // Blurred content
            Opacity(
              opacity: 0.3,
              child: child,
            ),
            
            // Overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: onTap ?? () => _showConversionModal(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [
                                      const Color(0xFF00E5FF),
                                      const Color(0xFF2D1B69),
                                    ]
                                  : [
                                      const Color(0xFF2E7D8A),
                                      const Color(0xFF7FB3B3),
                                    ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                                    : const Color(0xFF2E7D8A).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isArabic ? 'اضغط لإنشاء حساب' : 'Tap to create account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? const Color(0xFF2D1B69)
                                  : const Color(0xFF1A4B52),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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

class RestrictedFeaturesList extends ConsumerWidget {
  const RestrictedFeaturesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authStateProvider.notifier);
    final restrictedFeatures = authNotifier.getRestrictedFeatures();

    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        final featureLabels = {
          'save_favorites': isArabic ? 'حفظ المفضلات' : 'Save Favorites',
          'export_data': isArabic ? 'تصدير البيانات' : 'Export Data',
          'advanced_analytics': isArabic ? 'التحليلات المتقدمة' : 'Advanced Analytics',
          'premium_features': isArabic ? 'الميزات المميزة' : 'Premium Features',
          'data_backup': isArabic ? 'نسخ البيانات الاحتياطي' : 'Data Backup',
          'profile_customization': isArabic ? 'تخصيص الملف الشخصي' : 'Profile Customization',
          'notifications': isArabic ? 'الإشعارات' : 'Notifications',
          'sharing': isArabic ? 'المشاركة' : 'Sharing',
          'comments': isArabic ? 'التعليقات' : 'Comments',
          'ratings': isArabic ? 'التقييمات' : 'Ratings',
        };

        final featureIcons = {
          'save_favorites': Icons.favorite,
          'export_data': Icons.download,
          'advanced_analytics': Icons.analytics,
          'premium_features': Icons.star,
          'data_backup': Icons.backup,
          'profile_customization': Icons.person,
          'notifications': Icons.notifications,
          'sharing': Icons.share,
          'comments': Icons.comment,
          'ratings': Icons.star_rate,
        };

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                      const Color(0xFF2D1B69).withValues(alpha: 0.3),
                      const Color(0xFF1A1B3A).withValues(alpha: 0.3),
                    ]
                  : [
                      const Color(0xFF7FB3B3).withValues(alpha: 0.3),
                      const Color(0xFF2E7D8A).withValues(alpha: 0.3),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                  : const Color(0xFF2E7D8A).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'الميزات المحدودة للضيوف' : 'Guest Restricted Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                ),
              ),
              const SizedBox(height: 16),
              ...restrictedFeatures.map((feature) {
                final label = featureLabels[feature] ?? feature;
                final icon = featureIcons[feature] ?? Icons.lock;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFF1A4B52).withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.8)
                                : const Color(0xFF1A4B52).withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.lock,
                        size: 16,
                        color: isDarkMode
                            ? const Color(0xFF00E5FF).withValues(alpha: 0.7)
                            : const Color(0xFF2E7D8A).withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showConversionModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? const Color(0xFF00E5FF)
                      : const Color(0xFF2E7D8A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.upgrade,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isArabic ? 'فتح جميع الميزات' : 'Unlock All Features',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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