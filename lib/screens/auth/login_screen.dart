import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../services/theme_service.dart';
import '../../utils/validators.dart';
import '../../widgets/app_controls.dart';
// No longer needed: import '../../widgets/back_button_widget.dart';

import '../../providers/auth_state_provider.dart';

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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailMode = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  AnimationController? _glowController;
  AnimationController? _waveController;
  Animation<double>? _glowAnimation;
  Animation<double>? _waveAnimation;
  
  bool _animationsStarted = false;
  Widget? _cachedWaveBackground;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Defer animation initialization to improve initial performance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimations();
    });
  }

  void _initializeAnimations() {
    if (_animationsStarted || !mounted) return;
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _waveController!, curve: Curves.linear));

    // Only start animations when visible
    _startAnimations();
    _animationsStarted = true;
  }

  void _startAnimations() {
    if (_glowController?.isAnimating != true) {
      _glowController?.repeat(reverse: true);
    }
    if (_waveController?.isAnimating != true) {
      _waveController?.repeat();
    }
  }


  @override
  void dispose() {
    _glowController?.dispose();
    _waveController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('جميع الحقول مطلوبة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.signInWithEmail(
        email: email,
        password: password,
        context: context,
      );

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar('تم تسجيل الدخول بنجاح');
        
        // Small delay to ensure state propagation
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (mounted) {
          // Force navigation to dashboard
          context.go('/dashboard');
        }
      } else {
        final error = ref.read(authStateProvider).error;
        _showErrorSnackBar(error ?? 'حدث خطأ في تسجيل الدخول');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('حدث خطأ غير متوقع');
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
      print('🔵 Starting guest login...');
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.signInAsGuest(context);

      if (!mounted) return;

      print('🔵 Guest login result: $success');
      if (success) {
        _showSuccessSnackBar('تم تسجيل الدخول كضيف بنجاح');
        
        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (mounted) {
          // Force navigation to dashboard to ensure immediate redirect
          context.go('/dashboard');
          print('🔵 Navigated to dashboard after guest login');
        }
      } else {
        final error = ref.read(authStateProvider).error;
        _showErrorSnackBar(error ?? 'حدث خطأ في تسجيل الدخول كضيف');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('حدث خطأ غير متوقع');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    final isDarkMode = provider.Provider.of<ThemeService>(context, listen: false).isDarkMode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDarkMode
            ? OceanColors.neonCyan
            : OceanColors.oceanBlue,
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

  Widget _buildOptimizedWaveBackground(bool isDarkMode) {
    if (_waveAnimation == null) return const SizedBox();
    
    return _cachedWaveBackground ??= RepaintBoundary(
      child: AnimatedBuilder(
        animation: _waveAnimation!,
        builder: (context, child) {
          return CustomPaint(
            painter: OptimizedWavePainter(_waveAnimation!.value, isDarkMode),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 400), // Reduced duration
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
                  // Optimized Wave Background
                  _buildOptimizedWaveBackground(isDarkMode),

                  // Back Button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  
                  // App Controls
                  const Positioned(top: 16, right: 16, child: AppControls()),

                  // Main Content
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _glowAnimation != null 
                        ? AnimatedBuilder(
                            animation: _glowAnimation!,
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
                                        0.3 * _glowAnimation!.value,
                                      )
                                    : OceanColors.oceanBlue.withValues(alpha: 
                                        0.3 * _glowAnimation!.value,
                                      ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? OceanColors.neonCyan.withValues(alpha: 
                                          0.2 * _glowAnimation!.value,
                                        )
                                      : OceanColors.oceanBlue.withValues(alpha: 
                                          0.2 * _glowAnimation!.value,
                                        ),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: -5,
                                  offset: const Offset(0, -10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo with Glass Effect
                                  _buildGlassLogo(isDarkMode),

                                  const SizedBox(height: 32),

                                  // Title
                                  Text(
                                    isArabic
                                        ? 'أهلاً بك مرة أخرى'
                                        : 'Welcome Back',
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

                                  const SizedBox(height: 8),

                                  Text(
                                    isArabic
                                        ? 'سجل دخولك للمتابعة'
                                        : 'Sign in to continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : OceanColors.deepOcean.withValues(alpha: 
                                              0.8,
                                            ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 40),

                                  // Mode Toggle with Glass Effect
                                  _buildGlassModeToggle(isDarkMode, isArabic),

                                  const SizedBox(height: 32),

                                  // Email/Phone Field
                                  _buildGlassField(
                                    controller: _emailController,
                                    hint: _isEmailMode
                                        ? (isArabic
                                              ? 'البريد الإلكتروني'
                                              : 'Email')
                                        : '+962',
                                    icon: _isEmailMode
                                        ? Icons.email_outlined
                                        : Icons.phone_outlined,
                                    keyboardType: _isEmailMode
                                        ? TextInputType.emailAddress
                                        : TextInputType.phone,
                                    validator: _isEmailMode
                                        ? (value) =>
                                              Validators.validateEmail(value)
                                        : (value) =>
                                              Validators.validatePhone(value),
                                    isDarkMode: isDarkMode,
                                  ),

                                  const SizedBox(height: 20),

                                  // Password Field (Email mode only)
                                  if (_isEmailMode) ...[
                                    _buildGlassField(
                                      controller: _passwordController,
                                      hint: isArabic
                                          ? 'كلمة المرور'
                                          : 'Password',
                                      icon: Icons.lock_outline,
                                      obscureText: _obscurePassword,
                                      validator: (value) =>
                                          Validators.validatePassword(value),
                                      isDarkMode: isDarkMode,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: isDarkMode
                                              ? OceanColors.neonCyan
                                                    .withValues(alpha: 0.8)
                                              : OceanColors.oceanBlue
                                                    .withValues(alpha: 0.8),
                                        ),
                                        onPressed: () {
                                          setState(() => _obscurePassword = !_obscurePassword);
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Forgot Password
                                    Align(
                                      alignment: isArabic
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: TextButton(
                                        onPressed: () =>
                                            context.push('/forgot-password'),
                                        child: Text(
                                          isArabic
                                              ? 'نسيت كلمة المرور؟'
                                              : 'Forgot Password?',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? OceanColors.neonCyan
                                                      .withValues(alpha: 0.8)
                                                : OceanColors.oceanBlue
                                                      .withValues(alpha: 0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 32),

                                  // Login Button with Glass Effect
                                  _buildGlassSubmitButton(isDarkMode, isArabic),

                                  const SizedBox(height: 24),

                                  // Guest Login Button
                                  _buildGuestLoginButton(isDarkMode, isArabic),

                                  const SizedBox(height: 16),

                                  // OR Divider
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: isDarkMode
                                              ? Colors.white.withValues(alpha: 0.3)
                                              : OceanColors.deepOcean.withValues(alpha: 0.3),
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          isArabic ? 'أو' : 'OR',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? Colors.white.withValues(alpha: 0.6)
                                                : OceanColors.deepOcean.withValues(alpha: 0.6),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: isDarkMode
                                              ? Colors.white.withValues(alpha: 0.3)
                                              : OceanColors.deepOcean.withValues(alpha: 0.3),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Sign Up Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isArabic
                                            ? 'ليس لديك حساب؟ '
                                            : "Don't have an account? ",
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white.withValues(alpha: 0.8)
                                              : OceanColors.deepOcean
                                                    .withValues(alpha: 0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            context.push('/signup'),
                                        child: Text(
                                          isArabic
                                              ? 'إنشاء حساب جديد'
                                              : 'Sign Up',
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? OceanColors.neonCyan
                                                : OceanColors.oceanBlue,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                      : _buildStaticLoginForm(isDarkMode, isArabic),
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

  Widget _buildGlassLogo(bool isDarkMode) {
    if (_glowAnimation == null) {
      return _buildStaticLogo(isDarkMode);
    }
    
    return AnimatedBuilder(
      animation: _glowAnimation!,
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
                  ? OceanColors.neonCyan.withValues(alpha: 0.5 * _glowAnimation!.value)
                  : OceanColors.oceanBlue.withValues(alpha: 
                      0.5 * _glowAnimation!.value,
                    ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? OceanColors.neonCyan.withValues(alpha: 
                        0.3 * _glowAnimation!.value,
                      )
                    : OceanColors.oceanBlue.withValues(alpha: 
                        0.3 * _glowAnimation!.value,
                      ),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            size: 40,
            color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
          ),
        );
      },
    );
  }

  Widget _buildGlassModeToggle(bool isDarkMode, bool isArabic) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]
              : [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDarkMode
              ? OceanColors.neonCyan.withValues(alpha: 0.2)
              : OceanColors.oceanBlue.withValues(alpha: 0.2),
          width: 1,
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
                        ? [
                            OceanColors.neonCyan.withValues(alpha: 0.3),
                            OceanColors.neonCyan.withValues(alpha: 0.1),
                          ]
                        : [
                            OceanColors.oceanBlue.withValues(alpha: 0.3),
                            OceanColors.oceanBlue.withValues(alpha: 0.1),
                          ],
                  )
                : null,
            border: isSelected
                ? Border.all(
                    color: isDarkMode
                        ? OceanColors.neonCyan.withValues(alpha: 0.5)
                        : OceanColors.oceanBlue.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDarkMode
                          ? OceanColors.neonCyan.withValues(alpha: 0.3)
                          : OceanColors.oceanBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
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

  Widget _buildGlassField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    required bool isDarkMode,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]
              : [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? OceanColors.neonCyan.withValues(alpha: 0.3)
              : OceanColors.oceanBlue.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? OceanColors.neonCyan.withValues(alpha: 0.1)
                : OceanColors.oceanBlue.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          color: isDarkMode ? Colors.white : OceanColors.deepOcean,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.6)
                : OceanColors.deepOcean.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            icon,
            color: isDarkMode
                ? OceanColors.neonCyan.withValues(alpha: 0.8)
                : OceanColors.oceanBlue.withValues(alpha: 0.8),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassSubmitButton(bool isDarkMode, bool isArabic) {
    if (_glowAnimation == null) {
      return _buildStaticSubmitButton(isDarkMode, isArabic);
    }
    
    return AnimatedBuilder(
      animation: _glowAnimation!,
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
                      _isLoading ? 0.3 : 0.5 * (_glowAnimation?.value ?? 0.5),
                    )
                  : OceanColors.oceanBlue.withValues(alpha: 
                      _isLoading ? 0.3 : 0.5 * (_glowAnimation?.value ?? 0.5),
                    ),
              width: 2,
            ),
            boxShadow: _isLoading
                ? []
                : [
                    BoxShadow(
                      color: isDarkMode
                          ? OceanColors.neonCyan.withValues(alpha: 
                              0.5 * (_glowAnimation?.value ?? 0.5),
                            )
                          : OceanColors.oceanBlue.withValues(alpha: 
                              0.5 * (_glowAnimation?.value ?? 0.5),
                            ),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
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
                    _isEmailMode
                        ? (isArabic ? 'تسجيل الدخول' : 'Sign In')
                        : (isArabic ? 'إرسال رمز التحقق' : 'Send OTP'),
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

    // First wave
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

    // Second wave
    paint.color = isDarkMode
        ? OceanColors.neonCyan.withValues(alpha: 0.05)
        : OceanColors.lightAccent.withValues(alpha: 0.35);

    final Path path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.8 +
            20 *
                math.sin(
                  (i / size.width * 3 * math.pi) +
                      (animationValue * 3 * math.pi),
                ),
      );
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OptimizedWavePainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;
  
  OptimizedWavePainter(this.animationValue, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDarkMode 
          ? OceanColors.neonCyan.withValues(alpha: 0.05)
          : OceanColors.oceanBlue.withValues(alpha: 0.1);

    final path = Path();
    final waveHeight = size.height * 0.2;
    
    // Simplified wave calculation
    path.moveTo(0, size.height * 0.7);
    
    // Use fewer control points for better performance
    final points = [
      Offset(size.width * 0.25, size.height * 0.7 - waveHeight * math.sin(animationValue * 2 * math.pi)),
      Offset(size.width * 0.5, size.height * 0.7 + waveHeight * math.sin(animationValue * 2 * math.pi + math.pi / 2)),
      Offset(size.width * 0.75, size.height * 0.7 - waveHeight * math.sin(animationValue * 2 * math.pi + math.pi)),
      Offset(size.width, size.height * 0.7 + waveHeight * math.sin(animationValue * 2 * math.pi + 3 * math.pi / 2)),
    ];
    
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final cp = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(p1.dx, p1.dy, cp.dx, cp.dy);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(OptimizedWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.isDarkMode != isDarkMode;
  }
}

extension on _LoginScreenState {
  Widget _buildGuestLoginButton(bool isDarkMode, bool isArabic) {
    if (_glowAnimation == null) {
      return _buildStaticGuestButton(isDarkMode, isArabic);
    }
    
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _glowAnimation!,
        builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 56,
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.3 * _glowAnimation!.value)
                  : OceanColors.deepOcean.withValues(alpha: 0.3 * _glowAnimation!.value),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1 * _glowAnimation!.value)
                    : OceanColors.deepOcean.withValues(alpha: 0.1 * _glowAnimation!.value),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleGuestLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.white : OceanColors.deepOcean,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.8)
                            : OceanColors.deepOcean.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'متابعة كضيف' : 'Continue as Guest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.8)
                              : OceanColors.deepOcean.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
          ),
        );
        },
      ),
    );
  }
  
  Widget _buildStaticGuestButton(bool isDarkMode, bool isArabic) {
    return Container(
      width: double.infinity,
      height: 56,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : OceanColors.deepOcean.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleGuestLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? Colors.white : OceanColors.deepOcean,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 20,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.8)
                        : OceanColors.deepOcean.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'متابعة كضيف' : 'Continue as Guest',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.8)
                          : OceanColors.deepOcean.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStaticLoginForm(bool isDarkMode, bool isArabic) {
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
              ? OceanColors.neonCyan.withValues(alpha: 0.3)
              : OceanColors.oceanBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Static Logo
            _buildStaticLogo(isDarkMode),
            const SizedBox(height: 32),

            // Title
            Text(
              isArabic ? 'أهلاً بك مرة أخرى' : 'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : OceanColors.deepOcean,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              isArabic ? 'سجل دخولك للمتابعة' : 'Sign in to continue',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.8)
                    : OceanColors.deepOcean.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Mode Toggle
            _buildGlassModeToggle(isDarkMode, isArabic),

            const SizedBox(height: 32),

            // Email/Phone Field
            _buildGlassField(
              controller: _emailController,
              hint: _isEmailMode
                  ? (isArabic ? 'البريد الإلكتروني' : 'Email')
                  : '+962',
              icon: _isEmailMode ? Icons.email_outlined : Icons.phone_outlined,
              keyboardType: _isEmailMode
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              validator: _isEmailMode
                  ? (value) => Validators.validateEmail(value)
                  : (value) => Validators.validatePhone(value),
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 20),

            // Password Field (Email mode only)
            if (_isEmailMode) ...[
              _buildGlassField(
                controller: _passwordController,
                hint: isArabic ? 'كلمة المرور' : 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                validator: (value) => Validators.validatePassword(value),
                isDarkMode: isDarkMode,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: isDarkMode
                        ? OceanColors.neonCyan.withValues(alpha: 0.8)
                        : OceanColors.oceanBlue.withValues(alpha: 0.8),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Forgot Password
              Align(
                alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                    style: TextStyle(
                      color: isDarkMode
                          ? OceanColors.neonCyan.withValues(alpha: 0.8)
                          : OceanColors.oceanBlue.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Static Login Button
            _buildStaticSubmitButton(isDarkMode, isArabic),

            const SizedBox(height: 24),

            // Guest Login Button
            _buildGuestLoginButton(isDarkMode, isArabic),

            const SizedBox(height: 16),

            // OR Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.3)
                        : OceanColors.deepOcean.withValues(alpha: 0.3),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    isArabic ? 'أو' : 'OR',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.6)
                          : OceanColors.deepOcean.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.3)
                        : OceanColors.deepOcean.withValues(alpha: 0.3),
                    thickness: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isArabic ? 'ليس لديك حساب؟ ' : "Don't have an account? ",
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.8)
                        : OceanColors.deepOcean.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: Text(
                    isArabic ? 'إنشاء حساب جديد' : 'Sign Up',
                    style: TextStyle(
                      color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticLogo(bool isDarkMode) {
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
              ? OceanColors.neonCyan.withValues(alpha: 0.3)
              : OceanColors.oceanBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.account_balance_wallet_outlined,
        size: 40,
        color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
      ),
    );
  }

  Widget _buildStaticSubmitButton(bool isDarkMode, bool isArabic) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [OceanColors.neonCyan, OceanColors.darkAccent]
              : [OceanColors.oceanBlue, OceanColors.deepOcean],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? OceanColors.neonCyan.withValues(alpha: 0.3)
              : OceanColors.oceanBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isEmailMode
                    ? (isArabic ? 'تسجيل الدخول' : 'Sign In')
                    : (isArabic ? 'متابعة' : 'Continue'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}