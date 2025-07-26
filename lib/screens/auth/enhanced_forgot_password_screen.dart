import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../services/theme_service.dart';
import '../../services/enhanced_firebase_auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/app_controls.dart';
import '../../widgets/universal_back_handler.dart';
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

class EnhancedForgotPasswordScreen extends ConsumerStatefulWidget {
  const EnhancedForgotPasswordScreen({super.key});

  @override
  ConsumerState<EnhancedForgotPasswordScreen> createState() => 
      _EnhancedForgotPasswordScreenState();
}

class _EnhancedForgotPasswordScreenState 
    extends ConsumerState<EnhancedForgotPasswordScreen>
    with TickerProviderStateMixin {
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  // Animation controllers
  AnimationController? _fadeController;
  AnimationController? _slideController;
  AnimationController? _pulseController;
  AnimationController? _waveController;
  AnimationController? _neonController;
  
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _pulseAnimation;
  Animation<double>? _waveAnimation;
  Animation<double>? _neonAnimation;

  @override
  void initState() {
    super.initState();
    print('🔥 صفحة نسيان كلمة المرور تم تحميلها بنجاح!');
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _neonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeOutQuart,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController!,
      curve: Curves.linear,
    ));

    _neonAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _neonController!,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController!.forward();
    _slideController!.forward();
    _pulseController!.repeat(reverse: true);
    _waveController!.repeat();
    _neonController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _slideController?.dispose();
    _pulseController?.dispose();
    _waveController?.dispose();
    _neonController?.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.sendPasswordResetEmail(
        email: _emailController.text.trim(),
        context: context,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _emailSent = true;
        });
        _showSuccessMessage('تم إرسال رسالة إعادة تعيين كلمة المرور');
      } else {
        final error = ref.read(authStateProvider).error;
        setState(() {
          _errorMessage = error ?? 'حدث خطأ غير متوقع';
        });
        _showErrorMessage(_errorMessage!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
        });
        _showErrorMessage(_errorMessage!);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        return UniversalBackHandler(
          fallbackRoute: '/login',
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          OceanColors.darkBackground1,
                          OceanColors.darkBackground2,
                          OceanColors.darkAccent,
                        ]
                      : [
                          OceanColors.lightBackground1,
                          OceanColors.lightBackground2,
                          OceanColors.lightAccent,
                        ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Animated Wave Background
                    AnimatedBuilder(
                      animation: _waveAnimation!,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: EnhancedForgotPasswordPainter(_waveAnimation!.value, isDarkMode),
                          size: Size.infinite,
                        );
                      },
                    ),
                    
                    // Animated Background Elements
                    _buildAnimatedBackground(isDarkMode),
                    
                    // Back Button
                    Positioned(
                      top: 16,
                      left: isArabic ? null : 16,
                      right: isArabic ? 16 : null,
                      child: _buildBackButton(isDarkMode),
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildMainContent(isDarkMode, isArabic),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(_pulseAnimation!.value, isDarkMode),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildBackButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () => context.go('/login'),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.3),
          border: Border.all(
            color: isDarkMode 
                ? OceanColors.neonCyan.withValues(alpha: 0.3)
                : OceanColors.oceanBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          Icons.arrow_back,
          color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDarkMode, bool isArabic) {
    return FadeTransition(
      opacity: _fadeAnimation!,
      child: SlideTransition(
        position: _slideAnimation!,
        child: AnimatedBuilder(
          animation: _neonAnimation!,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.7),
                        ],
                ),
                border: Border.all(
                  color: isDarkMode
                      ? OceanColors.neonCyan.withValues(alpha: 0.3 * _neonAnimation!.value)
                      : OceanColors.oceanBlue.withValues(alpha: 0.3 * _neonAnimation!.value),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? OceanColors.neonCyan.withValues(alpha: 0.2 * _neonAnimation!.value)
                        : OceanColors.oceanBlue.withValues(alpha: 0.2 * _neonAnimation!.value),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _emailSent 
                  ? _buildSuccessContent(isDarkMode, isArabic)
                  : _buildFormContent(isDarkMode, isArabic),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormContent(bool isDarkMode, bool isArabic) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(isDarkMode),
          const SizedBox(height: 32),
          _buildTitle(isDarkMode, isArabic),
          const SizedBox(height: 40),
          _buildEmailField(isDarkMode, isArabic),
          const SizedBox(height: 32),
          _buildSendButton(isDarkMode, isArabic),
          const SizedBox(height: 24),
          _buildLoginLink(isDarkMode, isArabic),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(isDarkMode),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessContent(bool isDarkMode, bool isArabic) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSuccessIcon(isDarkMode),
        const SizedBox(height: 32),
        _buildSuccessTitle(isDarkMode, isArabic),
        const SizedBox(height: 16),
        _buildSuccessMessage(isDarkMode, isArabic),
        const SizedBox(height: 32),
        _buildResendButton(isDarkMode, isArabic),
        const SizedBox(height: 16),
        _buildBackToLoginButton(isDarkMode, isArabic),
      ],
    );
  }

  Widget _buildLogo(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation!.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [OceanColors.neonCyan, OceanColors.neonCyan.withValues(alpha: 0.7)]
                    : [OceanColors.oceanBlue, OceanColors.deepOcean],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? OceanColors.neonCyan.withValues(alpha: 0.5)
                      : OceanColors.oceanBlue.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.lock_reset,
              size: 40,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessIcon(bool isDarkMode) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.withValues(alpha: 0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.mark_email_read,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle(bool isDarkMode, bool isArabic) {
    return Column(
      children: [
        Text(
          isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : OceanColors.deepOcean,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isArabic 
              ? 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور'
              : 'Enter your email and we\'ll send you a password reset link',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.7)
                : OceanColors.deepOcean.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessTitle(bool isDarkMode, bool isArabic) {
    return Text(
      isArabic ? 'تم إرسال البريد!' : 'Email Sent!',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : OceanColors.deepOcean,
      ),
    );
  }

  Widget _buildSuccessMessage(bool isDarkMode, bool isArabic) {
    return Text(
      isArabic 
          ? 'تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة المرور'
          : 'Check your email and follow the instructions to reset your password',
      style: TextStyle(
        fontSize: 16,
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.8)
            : OceanColors.deepOcean.withValues(alpha: 0.8),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField(bool isDarkMode, bool isArabic) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) => Validators.validateEmail(value, context),
      style: TextStyle(
        color: isDarkMode ? Colors.white : OceanColors.deepOcean,
      ),
      decoration: InputDecoration(
        labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode 
                ? OceanColors.neonCyan.withValues(alpha: 0.5)
                : OceanColors.oceanBlue.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode 
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(bool isDarkMode, bool isArabic) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSendResetEmail,
        icon: _isLoading
            ? const SizedBox.shrink()
            : Icon(
                Icons.send,
                color: Colors.white,
              ),
        label: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isArabic ? 'إرسال رابط إعادة التعيين' : 'Send Reset Link',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildResendButton(bool isDarkMode, bool isArabic) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleSendResetEmail,
        icon: Icon(
          Icons.refresh,
          color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
        ),
        label: Text(
          isArabic ? 'إعادة الإرسال' : 'Resend Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton(bool isDarkMode, bool isArabic) {
    return TextButton.icon(
      onPressed: () {
        try {
          context.go('/login');
        } catch (e) {
          context.push('/login');
        }
      },
      icon: Icon(
        Icons.arrow_back,
        color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
      ),
      label: Text(
        isArabic ? 'العودة لتسجيل الدخول' : 'Back to Login',
        style: TextStyle(
          color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoginLink(bool isDarkMode, bool isArabic) {
    return TextButton(
      onPressed: () {
        try {
          context.go('/login');
        } catch (e) {
          context.push('/login');
        }
      },
      child: Text(
        isArabic ? 'العودة لتسجيل الدخول' : 'Back to Login',
        style: TextStyle(
          color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  BackgroundPainter(this.animationValue, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDarkMode
          ? OceanColors.neonCyan.withValues(alpha: 0.08 * animationValue)
          : OceanColors.oceanBlue.withValues(alpha: 0.08 * animationValue);

    // Draw animated circles
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.25 * animationValue;
    
    canvas.drawCircle(center, radius, paint);
    
    // Draw smaller circles
    for (int i = 0; i < 4; i++) {
      final angle = (animationValue * 2 * math.pi) + (i * math.pi / 2);
      final offset = Offset(
        center.dx + math.cos(angle) * 80,
        center.dy + math.sin(angle) * 80,
      );
      canvas.drawCircle(offset, 15 * animationValue, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EnhancedForgotPasswordPainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  EnhancedForgotPasswordPainter(this.animationValue, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw multiple wave layers
    _drawWaveLayer(canvas, size, 0.75, 25, 2.5, 0.08);
    _drawWaveLayer(canvas, size, 0.85, 15, 3.5, 0.05);
    
    // Draw floating particles
    _drawFloatingParticles(canvas, size);
    
    // Draw animated glow orbs
    _drawGlowOrbs(canvas, size);
  }

  void _drawWaveLayer(Canvas canvas, Size size, double heightRatio, double amplitude, double frequency, double opacity) {
    final paint = Paint()..style = PaintingStyle.fill;
    final path = Path();

    paint.color = isDarkMode
        ? OceanColors.neonCyan.withValues(alpha: opacity)
        : OceanColors.oceanBlue.withValues(alpha: opacity * 1.3);

    path.moveTo(0, size.height * heightRatio);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * heightRatio +
            amplitude * math.sin((i / size.width * frequency * math.pi) + (animationValue * frequency * math.pi)),
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawFloatingParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = isDarkMode
        ? OceanColors.neonCyan.withValues(alpha: 0.6)
        : OceanColors.oceanBlue.withValues(alpha: 0.7);

    for (int i = 0; i < 8; i++) {
      final angle = (animationValue * 1.5 * math.pi) + (i * math.pi / 4);
      final radius = 80 + (30 * math.sin(animationValue * 2 * math.pi + i));
      final x = size.width * 0.5 + radius * math.cos(angle) * 0.7;
      final y = size.height * 0.4 + radius * math.sin(angle) * 0.5;
      
      final particleRadius = 1.5 + (0.8 * math.sin(animationValue * 4 * math.pi + i));
      canvas.drawCircle(Offset(x, y), particleRadius, paint);
    }
  }

  void _drawGlowOrbs(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      final progress = (animationValue + (i * 0.33)) % 1.0;
      final x = size.width * (0.2 + (0.6 * progress));
      final y = size.height * (0.3 + (0.2 * math.sin(progress * 3 * math.pi)));
      
      paint.shader = RadialGradient(
        colors: [
          isDarkMode
              ? OceanColors.neonCyan.withValues(alpha: 0.4)
              : OceanColors.oceanBlue.withValues(alpha: 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 25));
      
      canvas.drawCircle(Offset(x, y), 12, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}