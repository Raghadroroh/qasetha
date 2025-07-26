import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:math' as math;

import '../../services/theme_service.dart';

import '../../utils/validators.dart';
import '../../widgets/app_controls.dart';
import '../../providers/auth_state_provider.dart';
import '../../widgets/universal_back_handler.dart';
import '../../widgets/universal_back_handler.dart';

class OceanColors {
  // Light theme colors
  static const Color lightBackground1 = Color(0xFFE8F4F8);
  static const Color lightBackground2 = Color(0xFFB8D4D9);
  static const Color lightAccent = Color(0xFF7FB3B3);
  static const Color oceanBlue = Color(0xFF2E7D8A);
  static const Color deepOcean = Color(0xFF1A4B52);

  // Dark theme colors
  static const Color darkBackground1 = Color(0xFF0A0E21);
  static const Color darkBackground2 = Color(0xFF1A1B3A);
  static const Color darkAccent = Color(0xFF2D1B69);
  static const Color darkBlue = Color(0xFF0A192F);
  static const Color neonCyan = Color(0xFF00E5FF);
}

class EnhancedLoginScreen extends ConsumerStatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  ConsumerState<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends ConsumerState<EnhancedLoginScreen> with TickerProviderStateMixin {
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isExpanded = false;
  bool _isEmailMode = true;
  
  AnimationController? _waveController;
  AnimationController? _pulseController;
  Animation<double>? _waveAnimation;
  Animation<double>? _pulseAnimation;



  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController!,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    ));

    _waveController!.repeat();
    _pulseController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController?.dispose();
    _pulseController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        context: context,
      );

      if (!mounted) return;

      if (success) {
        _showSuccessMessage('تم تسجيل الدخول بنجاح!');
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          final authState = ref.read(authStateProvider);
          if (authState.needsEmailVerification) {
            context.go('/verify-email');
          } else if (authState.isAuthenticated) {
            context.go('/dashboard');
          }
        }
      } else {
        final error = ref.read(authStateProvider).error;
        setState(() {
          _errorMessage = error;
        });
        _showErrorMessage(error ?? 'حدث خطأ غير متوقع');
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


  Future<void> _handleSendOTP() async {
    final phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      _showErrorMessage('يرجى إدخال رقم الهاتف');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.sendOTP(
        phoneNumber: '+962$phoneNumber',
        context: context,
      );

      if (!mounted) return;

      if (success) {
        _showSuccessMessage('تم إرسال رمز التحقق');
        context.push('/otp-verify', extra: {
          'phoneNumber': '+962$phoneNumber',
          'source': 'phone-login',
        });
      } else {
        final error = ref.read(authStateProvider).error;
        _showErrorMessage(error ?? 'حدث خطأ في إرسال الرمز');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('حدث خطأ غير متوقع');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.signInAsGuest(context);

      if (!mounted) return;

      if (success) {
        if (mounted) {
          _showSuccessMessage('تم تسجيل الدخول كضيف!');
          
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            context.go('/dashboard');
          }
        }
      } else {
        final error = ref.read(authStateProvider).error;
        setState(() {
          _errorMessage = error ?? 'حدث خطأ في تسجيل الدخول كضيف';
        });
        _showErrorMessage(_errorMessage!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع';
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
        duration: const Duration(seconds: 4),
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
          fallbackRoute: '/language-selection',
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
    if (_waveAnimation == null) return Container();
    
    return AnimatedBuilder(
      animation: _waveAnimation!,
      builder: (context, child) {
        return CustomPaint(
          painter: EnhancedBackgroundPainter(_waveAnimation!.value, isDarkMode),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent(bool isDarkMode, bool isArabic) {
    return AnimatedBuilder(
      animation: _pulseAnimation ?? const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
            ),
            border: Border.all(
              color: isDarkMode
                  ? OceanColors.neonCyan.withOpacity(0.3)
                  : OceanColors.oceanBlue.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? OceanColors.neonCyan.withOpacity(0.2)
                    : OceanColors.oceanBlue.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(isDarkMode),
                const SizedBox(height: 32),
                _buildTitle(isDarkMode, isArabic),
                const SizedBox(height: 16),
                _buildRemoteBanner(isDarkMode),
                const SizedBox(height: 24),
                _buildModeToggle(isDarkMode, isArabic),
                const SizedBox(height: 24),
                _buildFormFields(isDarkMode, isArabic),
                const SizedBox(height: 32),
                _buildLoginButton(isDarkMode, isArabic),
                const SizedBox(height: 24),
                _buildLoginLink(isDarkMode, isArabic),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(isDarkMode),
                ],
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildBackButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () => context.go('/language-selection'),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode 
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.3),
          border: Border.all(
            color: isDarkMode 
                ? OceanColors.neonCyan.withOpacity(0.3)
                : OceanColors.oceanBlue.withOpacity(0.3),
          ),
        ),
        child: Icon(
          Icons.arrow_back,
          color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDarkMode) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDarkMode
              ? [OceanColors.neonCyan, OceanColors.neonCyan.withOpacity(0.7)]
              : [OceanColors.oceanBlue, OceanColors.deepOcean],
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? OceanColors.neonCyan.withOpacity(0.5)
                : OceanColors.oceanBlue.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.login,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle(bool isDarkMode, bool isArabic) {
    return Column(
      children: [
        Text(
          isArabic ? 'تسجيل الدخول' : 'Sign In',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : OceanColors.deepOcean,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isArabic ? 'مرحباً بك مرة أخرى' : 'Welcome back',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode
                ? Colors.white.withOpacity(0.8)
                : OceanColors.deepOcean.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModeToggle(bool isDarkMode, bool isArabic) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.3),
        border: Border.all(
          color: isDarkMode
              ? OceanColors.neonCyan.withOpacity(0.2)
              : OceanColors.oceanBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildToggleOption(
            isArabic ? 'البريد الإلكتروني' : 'Email',
            true,
            isDarkMode,
          ),
          _buildToggleOption(
            isArabic ? 'رقم الهاتف' : 'Phone',
            false,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isEmailOption, bool isDarkMode) {
    final isSelected = _isEmailMode == isEmailOption;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isEmailMode = isEmailOption),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: isSelected
                ? LinearGradient(
                    colors: isDarkMode
                        ? [OceanColors.neonCyan.withOpacity(0.3), OceanColors.neonCyan.withOpacity(0.1)]
                        : [OceanColors.oceanBlue.withOpacity(0.3), OceanColors.oceanBlue.withOpacity(0.1)],
                  )
                : null,
            border: isSelected
                ? Border.all(
                    color: isDarkMode ? OceanColors.neonCyan.withOpacity(0.5) : OceanColors.oceanBlue.withOpacity(0.5),
                  )
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isDarkMode ? Colors.white : OceanColors.deepOcean,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(bool isDarkMode, bool isArabic) {
    return Column(
      children: [
        if (_isEmailMode) ...[
          _buildTextField(
            controller: _emailController,
            labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => Validators.validateEmail(value, context),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            labelText: isArabic ? 'كلمة المرور' : 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            validator: (value) => Validators.validatePassword(value, context),
            isDarkMode: isDarkMode,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  try {
                    context.go('/forgot-password');
                  } catch (e) {
                    context.push('/forgot-password');
                  }
                },
                child: Text(
                  isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                  style: TextStyle(
                    color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
                    fontSize: 14,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: _isLoading ? null : _handleGuestLogin,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
                  ),
                ),
                child: Text(
                  isArabic ? 'دخول كضيف' : 'Guest',
                  style: TextStyle(
                    color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          _buildTextField(
            controller: _phoneController,
            labelText: isArabic ? 'رقم الهاتف' : 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) => Validators.validatePhone(value, context),
            isDarkMode: isDarkMode,
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    required bool isDarkMode,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        color: isDarkMode ? Colors.white : OceanColors.deepOcean,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode 
                ? Colors.white.withOpacity(0.3)
                : Colors.grey.withOpacity(0.5),
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

  Widget _buildLoginButton(bool isDarkMode, bool isArabic) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : (_isEmailMode ? _handleLogin : _handleSendOTP),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
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
                _isEmailMode
                    ? (isArabic ? 'تسجيل الدخول' : 'Sign In')
                    : (isArabic ? 'إرسال الرمز' : 'Send OTP'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildRemoteBanner(bool isDarkMode) {
    final remoteConfig = FirebaseRemoteConfig.instance;
    String bannerText = remoteConfig.getString('login_banner');
    
    return Column(
      children: [
        if (bannerText.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              bannerText,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            await remoteConfig.fetchAndActivate();
            setState(() {});
          },
          child: Text('تحديث الريموت الآن'),
        ),
      ],
    );
  }

  Widget _buildLoginLink(bool isDarkMode, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isArabic ? 'ليس لديك حساب؟ ' : "Don't have an account? ",
          style: TextStyle(
            color: isDarkMode
                ? Colors.white.withOpacity(0.8)
                : OceanColors.deepOcean.withOpacity(0.8),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/signup'),
          child: Text(
            isArabic ? 'إنشاء حساب جديد' : 'Sign Up',
            style: TextStyle(
              color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
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

class EnhancedBackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  EnhancedBackgroundPainter(this.animationValue, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    // Wave layers
    _drawWaveLayer(canvas, size, 0.7, 30, 2, 0.1);
    _drawWaveLayer(canvas, size, 0.8, 20, 3, 0.05);
    _drawWaveLayer(canvas, size, 0.85, 15, 4, 0.03);
    
    // Animated particles
    _drawParticles(canvas, size);
    
    // Floating orbs
    _drawFloatingOrbs(canvas, size);
  }

  void _drawWaveLayer(Canvas canvas, Size size, double heightRatio, double amplitude, double frequency, double opacity) {
    final paint = Paint()..style = PaintingStyle.fill;
    final path = Path();

    paint.color = isDarkMode
        ? OceanColors.neonCyan.withOpacity(opacity)
        : OceanColors.oceanBlue.withOpacity(opacity * 1.5);

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

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = isDarkMode
        ? OceanColors.neonCyan.withOpacity(0.4)
        : OceanColors.oceanBlue.withOpacity(0.6);

    for (int i = 0; i < 12; i++) {
      final angle = (animationValue * 2 * math.pi) + (i * math.pi / 6);
      final radius = 100 + (50 * math.sin(animationValue * 2 * math.pi + i));
      final x = size.width * 0.5 + radius * math.cos(angle);
      final y = size.height * 0.3 + radius * math.sin(angle) * 0.3;
      
      final particleRadius = 2 + (1 * math.sin(animationValue * 3 * math.pi + i));
      canvas.drawCircle(Offset(x, y), particleRadius, paint);
    }
  }

  void _drawFloatingOrbs(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < 5; i++) {
      final progress = (animationValue + (i * 0.2)) % 1.0;
      final x = size.width * (0.1 + (0.8 * progress));
      final y = size.height * (0.2 + (0.3 * math.sin(progress * 2 * math.pi)));
      
      paint.shader = RadialGradient(
        colors: [
          isDarkMode
              ? OceanColors.neonCyan.withOpacity(0.3)
              : OceanColors.oceanBlue.withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 20));
      
      canvas.drawCircle(Offset(x, y), 15, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
