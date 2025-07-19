import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import '../providers/auth_state_provider.dart';
import '../services/theme_service.dart';

class GuestBanner extends ConsumerStatefulWidget {
  final bool showConversionButton;
  final VoidCallback? onConversionPressed;
  final VoidCallback? onDismiss;

  const GuestBanner({
    super.key,
    this.showConversionButton = true,
    this.onConversionPressed,
    this.onDismiss,
  });

  @override
  ConsumerState<GuestBanner> createState() => _GuestBannerState();
}

class _GuestBannerState extends ConsumerState<GuestBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  void _handleConversion() {
    if (widget.onConversionPressed != null) {
      widget.onConversionPressed!();
    } else {
      context.push('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(isGuestProvider);
    final guestSession = ref.watch(guestSessionProvider);
    
    if (!isGuest || guestSession == null) {
      return const SizedBox.shrink();
    }

    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value * 100),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              const Color(0xFF2D1B69).withValues(alpha: 0.9),
                              const Color(0xFF1A1B3A).withValues(alpha: 0.9),
                            ]
                          : [
                              const Color(0xFF7FB3B3).withValues(alpha: 0.9),
                              const Color(0xFF2E7D8A).withValues(alpha: 0.9),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                            : const Color(0xFF2E7D8A).withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: isDarkMode
                                    ? const Color(0xFF00E5FF)
                                    : Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'أنت تستخدم الوضع الضيف' : 'You\'re using Guest Mode',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isArabic 
                                        ? 'سجل حساب جديد للوصول إلى جميع الميزات'
                                        : 'Create an account to access all features',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _handleDismiss,
                              icon: Icon(
                                Icons.close,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Stats
                            _buildStatChip(
                              icon: Icons.access_time,
                              label: isArabic ? 'الجلسة' : 'Session',
                              value: '${guestSession.sessionCount}',
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              icon: Icons.star_outline,
                              label: isArabic ? 'الميزات' : 'Features',
                              value: '${guestSession.featuresUsed.length}',
                              isDarkMode: isDarkMode,
                            ),
                            const Spacer(),
                            if (widget.showConversionButton) ...[
                              ElevatedButton(
                                onPressed: _handleConversion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: isDarkMode
                                      ? const Color(0xFF2D1B69)
                                      : const Color(0xFF2E7D8A),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  isArabic ? 'إنشاء حساب' : 'Sign Up',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
          Text(
            '$value $label',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}