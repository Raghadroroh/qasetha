import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme_service.dart';
import '../providers/auth_state_provider.dart';
import '../services/guest_data_service.dart';
import 'guest_conversion_modal.dart';

enum ConversionTrigger {
  cartThreshold,
  wishlistThreshold,
  viewHistoryThreshold,
  featureAccess,
  timeSpent,
  sessionCount,
}

class StrategicConversionPrompt extends ConsumerStatefulWidget {
  final ConversionTrigger trigger;
  final String? customMessage;
  final VoidCallback? onDismiss;
  final VoidCallback? onConvert;

  const StrategicConversionPrompt({
    super.key,
    required this.trigger,
    this.customMessage,
    this.onDismiss,
    this.onConvert,
  });

  @override
  ConsumerState<StrategicConversionPrompt> createState() =>
      _StrategicConversionPromptState();
}

class _StrategicConversionPromptState
    extends ConsumerState<StrategicConversionPrompt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    if (!authState.isGuest) {
      return const SizedBox.shrink();
    }

    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _opacityAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                const Color(0xFF2D1B69).withOpacity(0.95),
                                const Color(0xFF1A1B3A).withOpacity(0.95),
                              ]
                            : [
                                const Color(0xFF7FB3B3).withOpacity(0.95),
                                const Color(0xFF2E7D8A).withOpacity(0.95),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0xFF00E5FF).withOpacity(0.4)
                            : Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? const Color(0xFF00E5FF).withOpacity(0.3)
                              : const Color(0xFF2E7D8A).withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _getTriggerIcon(),
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTriggerTitle(isArabic),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getTriggerSubtitle(isArabic),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _dismiss,
                              icon: Icon(
                                Icons.close,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Message
                        Text(
                          widget.customMessage ?? _getTriggerMessage(isArabic),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // Data preview
                        FutureBuilder<String>(
                          future: GuestDataService.getDataSizeDescription(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.data_usage,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${isArabic ? 'البيانات المحفوظة: ' : 'Saved Data: '}${snapshot.data}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: 20),

                        // Benefits
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'ستحصل على:' : 'You\'ll get:',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._getBenefits(isArabic).map(
                                (benefit) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          benefit,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _dismiss,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isArabic ? 'لاحقاً' : 'Later',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _convert,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: isDarkMode
                                      ? const Color(0xFF2D1B69)
                                      : const Color(0xFF2E7D8A),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isArabic ? 'إنشاء حساب' : 'Create Account',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
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

  IconData _getTriggerIcon() {
    switch (widget.trigger) {
      case ConversionTrigger.cartThreshold:
        return Icons.shopping_cart;
      case ConversionTrigger.wishlistThreshold:
        return Icons.favorite;
      case ConversionTrigger.viewHistoryThreshold:
        return Icons.history;
      case ConversionTrigger.featureAccess:
        return Icons.lock_open;
      case ConversionTrigger.timeSpent:
        return Icons.access_time;
      case ConversionTrigger.sessionCount:
        return Icons.repeat;
    }
  }

  String _getTriggerTitle(bool isArabic) {
    switch (widget.trigger) {
      case ConversionTrigger.cartThreshold:
        return isArabic ? 'سلة مليئة!' : 'Cart is Full!';
      case ConversionTrigger.wishlistThreshold:
        return isArabic ? 'قائمة أمنيات رائعة!' : 'Great Wishlist!';
      case ConversionTrigger.viewHistoryThreshold:
        return isArabic ? 'تصفح كثير!' : 'Lots of Browsing!';
      case ConversionTrigger.featureAccess:
        return isArabic ? 'ميزات إضافية!' : 'Extra Features!';
      case ConversionTrigger.timeSpent:
        return isArabic ? 'وقت ممتع!' : 'Great Time!';
      case ConversionTrigger.sessionCount:
        return isArabic ? 'زائر دائم!' : 'Regular Visitor!';
    }
  }

  String _getTriggerSubtitle(bool isArabic) {
    switch (widget.trigger) {
      case ConversionTrigger.cartThreshold:
        return isArabic
            ? 'احفظ مشترياتك إلى الأبد'
            : 'Save your purchases forever';
      case ConversionTrigger.wishlistThreshold:
        return isArabic
            ? 'لا تفقد منتجاتك المفضلة'
            : 'Don\'t lose your favorites';
      case ConversionTrigger.viewHistoryThreshold:
        return isArabic ? 'احفظ تاريخ تصفحك' : 'Save your browsing history';
      case ConversionTrigger.featureAccess:
        return isArabic ? 'فتح جميع الميزات' : 'Unlock all features';
      case ConversionTrigger.timeSpent:
        return isArabic ? 'استمتع بتجربة أفضل' : 'Get a better experience';
      case ConversionTrigger.sessionCount:
        return isArabic ? 'أنت مستخدم رائع!' : 'You\'re an awesome user!';
    }
  }

  String _getTriggerMessage(bool isArabic) {
    switch (widget.trigger) {
      case ConversionTrigger.cartThreshold:
        return isArabic
            ? 'لديك عدة منتجات في السلة! أنشئ حساب لحفظها وإتمام الشراء بسهولة.'
            : 'You have several items in your cart! Create an account to save them and complete purchases easily.';
      case ConversionTrigger.wishlistThreshold:
        return isArabic
            ? 'قائمة أمنياتك تحتوي على منتجات رائعة! أنشئ حساب لحفظها ومتابعة الأسعار.'
            : 'Your wishlist has great products! Create an account to save them and track prices.';
      case ConversionTrigger.viewHistoryThreshold:
        return isArabic
            ? 'تصفحت العديد من المنتجات! أنشئ حساب لحفظ تاريخ تصفحك والحصول على اقتراحات شخصية.'
            : 'You\'ve browsed many products! Create an account to save your history and get personalized recommendations.';
      case ConversionTrigger.featureAccess:
        return isArabic
            ? 'هذه الميزة متاحة للمستخدمين المسجلين فقط. أنشئ حساب للوصول إليها.'
            : 'This feature is available for registered users only. Create an account to access it.';
      case ConversionTrigger.timeSpent:
        return isArabic
            ? 'تقضي وقتاً ممتعاً في التطبيق! أنشئ حساب لحفظ تفضيلاتك وتحسين تجربتك.'
            : 'You\'re spending quality time in the app! Create an account to save your preferences and improve your experience.';
      case ConversionTrigger.sessionCount:
        return isArabic
            ? 'أنت زائر دائم! أنشئ حساب لحفظ جميع بياناتك والاستفادة من جميع الميزات.'
            : 'You\'re a regular visitor! Create an account to save all your data and enjoy all features.';
    }
  }

  List<String> _getBenefits(bool isArabic) {
    return [
      isArabic ? 'حفظ البيانات بشكل دائم' : 'Save data permanently',
      isArabic ? 'مزامنة عبر الأجهزة' : 'Sync across devices',
      isArabic ? 'إشعارات شخصية' : 'Personal notifications',
      isArabic ? 'اقتراحات ذكية' : 'Smart recommendations',
      isArabic ? 'دعم فني مخصص' : 'Dedicated support',
    ];
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  void _convert() {
    if (widget.onConvert != null) {
      widget.onConvert!();
    } else {
      _showConversionModal();
    }
  }

  void _showConversionModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const GuestConversionModal(),
    );
  }

  /// Show strategic conversion prompt based on trigger
  static void showForTrigger(
    BuildContext context,
    ConversionTrigger trigger, {
    String? customMessage,
    VoidCallback? onDismiss,
    VoidCallback? onConvert,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StrategicConversionPrompt(
        trigger: trigger,
        customMessage: customMessage,
        onDismiss: onDismiss,
        onConvert: onConvert,
      ),
    );
  }
}
