import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../services/firebase_auth_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/app_controls.dart';
import '../../utils/app_localizations.dart';

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

class OTPVerifyScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const OTPVerifyScreen({super.key, required this.data});

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen>
    with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _countdown = 60;
  Timer? _timer;
  bool _canResend = false;

  late AnimationController _glowController;
  late AnimationController _waveController;
  late Animation<double> _glowAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _startCountdown();

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
    _otpController.dispose();
    _timer?.cancel();
    _glowController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    final otpCode = _otpController.text.trim();

    // Validate OTP format
    if (otpCode.isEmpty) {
      _showErrorSnackBar(context.l10n.pleaseEnterOtp);
      return;
    }

    if (otpCode.length != 6) {
      _showErrorSnackBar(context.l10n.pleaseEnterSixDigits);
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otpCode)) {
      _showErrorSnackBar(context.l10n.otpMustBeNumbers);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final verificationId = widget.data['verificationId'] as String?;
      if (verificationId == null || verificationId.isEmpty) {
        _showErrorSnackBar(context.l10n.verificationIdMissing);
        return;
      }

      final name = widget.data['name'] as String?;
      
      final result = await FirebaseAuthService.verifyOTP(
        verificationId: verificationId,
        smsCode: otpCode,
        name: name,
        context: context,
      );

      if (!mounted) return;

      if (result.success) {
        _showSuccessSnackBar(result.message ?? 'تم التحقق بنجاح');

        // Add delay to show success message
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        final source = widget.data['source'] ?? '';
        if (source == 'email-signup') {
          context.go('/verify-email');
        } else {
          context.go('/dashboard');
        }
      } else {
        _showErrorSnackBar(result.message ?? 'خطأ في التحقق من رمز OTP');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          '${context.l10n.unexpectedErrorOccurred}: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    try {
      final phoneNumber = widget.data['phoneNumber'] as String?;
      if (phoneNumber == null || phoneNumber.isEmpty) {
        _showErrorSnackBar('رقم الهاتف غير متوفر');
        return;
      }
      
      String? newVerificationId;
      final result = await FirebaseAuthService.sendOTP(
        phoneNumber: phoneNumber,
        context: context,
        onCodeSent: (String id) {
          newVerificationId = id;
        },
      );

      if (!mounted) return;

      if (result.success && newVerificationId != null) {
        widget.data['verificationId'] = newVerificationId;
        _startCountdown();
        _showSuccessSnackBar(context.l10n.otpCodeResent);
      } else {
        _showErrorSnackBar(result.message ?? 'خطأ في التحقق من رمز OTP');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.l10n.otpSendingError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

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

                  // Back Button
                  Positioned(
                    top: 16,
                    left: isArabic ? null : 16,
                    right: isArabic ? 16 : null,
                    child: _buildGlassButton(
                      icon: Icons.arrow_back,
                      onTap: () => context.pop(),
                      isDarkMode: isDarkMode,
                    ),
                  ),

                  // App Controls
                  Positioned(
                    top: 16,
                    right: isArabic ? null : 16,
                    left: isArabic ? 16 : null,
                    child: const AppControls(),
                  ),

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
                                  context.l10n.phoneVerification,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : OceanColors.deepOcean,
                                    shadows: [
                                      Shadow(
                                        color: isDarkMode
                                            ? OceanColors.neonCyan
                                            : OceanColors.oceanBlue,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 16),

                                // Subtitle
                                Text(
                                  '${context.l10n.enterCodeSentTo}\n${widget.data['phoneNumber'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : OceanColors.deepOcean.withValues(alpha: 
                                            0.7,
                                          ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 40),

                                // OTP Input
                                _buildOTPInput(isDarkMode),

                                const SizedBox(height: 32),

                                // Verify Button
                                _buildVerifyButton(isDarkMode, isArabic),

                                const SizedBox(height: 32),

                                // Resend Section
                                _buildResendSection(isDarkMode, isArabic),
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

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
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
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDarkMode
                ? OceanColors.neonCyan.withValues(alpha: 0.3)
                : OceanColors.oceanBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
        ),
      ),
    );
  }

  Widget _buildGlassIcon(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
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
                  : OceanColors.oceanBlue.withValues(alpha: 
                      0.5 * _glowAnimation.value,
                    ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? OceanColors.neonCyan.withValues(alpha: 
                        0.3 * _glowAnimation.value,
                      )
                    : OceanColors.oceanBlue.withValues(alpha: 
                        0.3 * _glowAnimation.value,
                      ),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.sms_outlined,
            size: 50,
            color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
          ),
        );
      },
    );
  }

  Widget _buildOTPInput(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]
              : [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? OceanColors.neonCyan.withValues(alpha: 0.2)
              : OceanColors.oceanBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 6,
        style: TextStyle(
          color: isDarkMode ? Colors.white : OceanColors.deepOcean,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 8,
        ),
        decoration: const InputDecoration(
          hintText: '000000',
          hintStyle: TextStyle(color: Colors.white38, letterSpacing: 8),
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.all(20),
        ),
        onChanged: (value) {
          // Auto-verify when 6 digits are entered and valid
          if (value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value)) {
            _verifyOTP();
          }
        },
      ),
    );
  }

  Widget _buildVerifyButton(bool isDarkMode, bool isArabic) {
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
            border: Border.all(
              color: isDarkMode
                  ? OceanColors.neonCyan.withValues(alpha: 
                      _isLoading ? 0.3 : 0.5 * _glowAnimation.value,
                    )
                  : OceanColors.oceanBlue.withValues(alpha: 
                      _isLoading ? 0.3 : 0.5 * _glowAnimation.value,
                    ),
              width: 2,
            ),
            boxShadow: _isLoading
                ? []
                : [
                    BoxShadow(
                      color: isDarkMode
                          ? OceanColors.neonCyan.withValues(alpha: 
                              0.5 * _glowAnimation.value,
                            )
                          : OceanColors.oceanBlue.withValues(alpha: 
                              0.5 * _glowAnimation.value,
                            ),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOTP,
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
                    context.l10n.verify,
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

  Widget _buildResendSection(bool isDarkMode, bool isArabic) {
    if (_canResend) {
      return TextButton(
        onPressed: _resendOTP,
        child: Text(
          context.l10n.resendCodeText,
          style: TextStyle(
            color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Text(
        '${context.l10n.canResendAfter} $_countdown ${context.l10n.secondsText}',
        style: TextStyle(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.6)
              : OceanColors.deepOcean.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      );
    }
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
