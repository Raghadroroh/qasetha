import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../services/theme_service.dart';
import '../../widgets/app_controls.dart';

import '../../providers/auth_state_provider.dart';

class OceanColors {
  static const Color lightBackground1 = Color(0xFFE8F4F8);
  static const Color lightBackground2 = Color(0xFFB8D4D9);
  static const Color lightAccent = Color(0xFF7FB3B3);
  static const Color oceanBlue = Color(0xFF2E7D8A);
  static const Color deepOcean = Color(0xFF1A4B52);
  static const Color darkBackground1 = Color(0xFF0A0E21);
  static const Color darkBackground2 = Color(0xFF1A1B3A);
  static const Color darkAccent = Color(0xFF2D1B69);
  static const Color darkBlue = Color(0xFF0A192F);
  static const Color neonCyan = Color(0xFF00E5FF);
}

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  bool _isLoading = false;

  late AnimationController _glowController;
  late AnimationController _waveController;
  late Animation<double> _glowAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _startEmailCheck();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startEmailCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.checkEmailVerification();
      
      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        timer.cancel();
        if (mounted) {
          context.go('/dashboard');
        }
      }
    });
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.sendEmailVerification(context: context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تم إرسال بريد التأكيد' : 'حدث خطأ في الإرسال'),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('حدث خطأ في إعادة الإرسال'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';
        final authState = ref.watch(authStateProvider);
        final user = authState.user;

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        OceanColors.darkBackground1,
                        OceanColors.darkBackground2,
                        OceanColors.darkAccent,
                        OceanColors.darkBlue,
                      ]
                    : [
                        OceanColors.lightBackground1,
                        OceanColors.lightBackground2,
                        OceanColors.lightAccent,
                        OceanColors.oceanBlue,
                      ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Animated Wave Background
                  AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: WavePainter(_waveAnimation.value, isDarkMode),
                        size: Size.infinite,
                      );
                    },
                  ),

                  // App Controls
                  const Positioned(top: 16, right: 16, child: AppControls()),

                  // Main Content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDarkMode
                                    ? [
                                        Colors.white.withValues(alpha: 0.1),
                                        Colors.white.withValues(alpha: 0.05),
                                      ]
                                    : [
                                        Colors.white.withValues(alpha: 0.3),
                                        Colors.white.withValues(alpha: 0.1),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDarkMode
                                    ? OceanColors.neonCyan.withValues(alpha: 
                                        0.3 * _glowAnimation.value,
                                      )
                                    : OceanColors.oceanBlue.withValues(alpha: 
                                        0.3 * _glowAnimation.value,
                                      ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? OceanColors.neonCyan.withValues(alpha: 
                                          0.2 * _glowAnimation.value,
                                        )
                                      : OceanColors.oceanBlue.withValues(alpha: 
                                          0.2 * _glowAnimation.value,
                                        ),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon
                                _buildGlassIcon(isDarkMode),

                                const SizedBox(height: 32),

                                // Title
                                Text(
                                  isArabic
                                      ? 'تأكيد البريد الإلكتروني'
                                      : 'Email Verification',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : OceanColors.deepOcean,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 16),

                                // Description
                                Text(
                                  isArabic
                                      ? 'تم إرسال رابط التأكيد إلى بريدك الإلكتروني'
                                      : 'Verification link sent to your email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : OceanColors.deepOcean.withValues(alpha: 0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 8),

                                if (user?.email != null)
                                  Text(
                                    user!.email!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? OceanColors.neonCyan
                                          : OceanColors.oceanBlue,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                const SizedBox(height: 32),

                                // Resend Button
                                _buildResendButton(isDarkMode, isArabic),

                                const SizedBox(height: 16),

                                // Back to Login
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: Text(
                                    isArabic
                                        ? 'العودة لتسجيل الدخول'
                                        : 'Back to Login',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? OceanColors.neonCyan
                                          : OceanColors.oceanBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassIcon(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
            ),
            border: Border.all(
              color: isDarkMode
                  ? OceanColors.neonCyan.withValues(alpha: 0.5 * _glowAnimation.value)
                  : OceanColors.oceanBlue.withValues(alpha: 0.5 * _glowAnimation.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? OceanColors.neonCyan.withValues(alpha: 0.3 * _glowAnimation.value)
                    : OceanColors.oceanBlue.withValues(alpha: 0.3 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.email_outlined,
            size: 40,
            color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
          ),
        );
      },
    );
  }

  Widget _buildResendButton(bool isDarkMode, bool isArabic) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: _isLoading
                ? LinearGradient(colors: [Colors.grey, Colors.grey.shade700])
                : LinearGradient(
                    colors: isDarkMode
                        ? [
                            OceanColors.neonCyan,
                            OceanColors.neonCyan.withValues(alpha: 0.7),
                          ]
                        : [OceanColors.oceanBlue, OceanColors.deepOcean],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isLoading
                ? []
                : [
                    BoxShadow(
                      color: isDarkMode
                          ? OceanColors.neonCyan.withValues(alpha: 0.5 * _glowAnimation.value)
                          : OceanColors.oceanBlue.withValues(alpha: 0.5 * _glowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resendEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isArabic ? 'إعادة الإرسال' : 'Resend Email',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  WavePainter(this.animationValue, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    final Path path = Path();

    paint.color = isDarkMode
        ? OceanColors.neonCyan.withValues(alpha: 0.1)
        : OceanColors.oceanBlue.withValues(alpha: 0.25);

    path.moveTo(0, size.height * 0.7);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.7 +
            30 *
                math.sin(
                  (i / size.width * 2 * math.pi) +
                      (animationValue * 2 * math.pi),
                ),
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}