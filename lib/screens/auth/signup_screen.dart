import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../services/theme_service.dart';
import '../../utils/validators.dart';
import '../../widgets/app_controls.dart';
import '../../providers/auth_state_provider.dart';
import '../../utils/simple_logger.dart';
import '../../utils/debug_helper.dart';

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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEmailMode = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  late AnimationController _glowController;
  late AnimationController _waveController;
  late Animation<double> _glowAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
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
    _glowController.dispose();
    _waveController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showErrorSnackBar('يجب الموافقة على الشروط والأحكام');
      return;
    }

    // التحقق من القيم قبل الإرسال
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackBar('الاسم مطلوب');
      return;
    }

    if (_isEmailMode) {
      if (email.isEmpty) {
        _showErrorSnackBar('البريد الإلكتروني مطلوب');
        return;
      }
      if (password.isEmpty) {
        _showErrorSnackBar('كلمة المرور مطلوبة');
        return;
      }
    } else {
      if (phone.isEmpty) {
        _showErrorSnackBar('رقم الهاتف مطلوب');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // فحص اتصال Firebase قبل المحاولة
      await DebugHelper.checkFirebaseConnection();
      DebugHelper.logSystemInfo();
      
      final authNotifier = ref.read(authStateProvider.notifier);
      
      // Log current auth state before signup
      final currentState = ref.read(authStateProvider);
      SimpleLogger.info('Current auth state before signup: ${currentState.status}');
      
      if (_isEmailMode) {
        SimpleLogger.info('محاولة إنشاء حساب بالبريد الإلكتروني: $email');
        
        final success = await authNotifier.signUpWithEmail(
          email: email,
          password: password,
          name: name,
          context: context,
        );

        if (!mounted) return;

        if (success) {
          // Log the auth state after successful signup
          final newState = ref.read(authStateProvider);
          SimpleLogger.info('Auth state after signup: ${newState.status}');
          SimpleLogger.info('User email verified: ${newState.user?.emailVerified}');
          SimpleLogger.info('نجح إنشاء الحساب، الانتقال لصفحة التحقق');
          
          // Add a small delay to ensure state is updated
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            SimpleLogger.info('Navigating to verify-email screen');
            try {
              context.go('/verify-email');
            } catch (navError) {
              SimpleLogger.error('Navigation error: $navError');
              // Fallback: show success message and manual navigation
              _showSuccessSnackBar('تم إنشاء الحساب بنجاح. اضغط هنا للمتابعة', () {
                context.go('/verify-email');
              });
            }
          }
        } else {
          final error = ref.read(authStateProvider).error;
          SimpleLogger.error('فشل إنشاء الحساب: $error');
          _showErrorSnackBar(error ?? 'حدث خطأ في إنشاء الحساب');
        }
      } else {
        SimpleLogger.info('محاولة إرسال OTP للهاتف: $phone');
        
        final success = await authNotifier.sendOTP(
          phoneNumber: phone,
          context: context,
        );

        if (!mounted) return;

        if (success) {
          SimpleLogger.info('نجح إرسال OTP، الانتقال لصفحة التحقق');
          // Add a small delay to ensure state is updated
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            context.push(
              '/otp-verify',
              extra: {
                'phoneNumber': phone,
                'name': name,
                'source': 'phone-signup',
              },
            );
          }
        } else {
          final error = ref.read(authStateProvider).error;
          SimpleLogger.error('فشل إرسال OTP: $error');
          _showErrorSnackBar(error ?? 'حدث خطأ في إرسال رمز التحقق');
        }
      }
    } catch (e, stackTrace) {
      SimpleLogger.error('Registration error: $e');
      SimpleLogger.error('Stack trace: $stackTrace');
      
      if (mounted) {
        String errorMessage = 'حدث خطأ غير متوقع';
        
        // تحديد نوع الخطأ لإعطاء رسالة أوضح
        if (e.toString().contains('network')) {
          errorMessage = 'خطأ في الاتصال. تحقق من الإنترنت';
        } else if (e.toString().contains('firebase')) {
          errorMessage = 'خطأ في الخادم. حاول مرة أخرى';
        } else if (e.toString().contains('GoException')) {
          errorMessage = 'خطأ في التنقل. حاول مرة أخرى';
        }
        
        // Also log the current auth state for debugging
        final currentState = ref.read(authStateProvider);
        SimpleLogger.error('Auth state during error: ${currentState.status}');
        SimpleLogger.error('Auth error: ${currentState.error}');
        
        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  void _showSuccessSnackBar(String message, VoidCallback? onTap) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: onTap,
          child: Text(message),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        action: onTap != null ? SnackBarAction(
          label: 'المتابعة',
          textColor: Colors.white,
          onPressed: onTap,
        ) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Watch auth state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      SimpleLogger.info('Auth state changed: ${previous?.status} -> ${next.status}');
      if (next.needsEmailVerification && previous?.status != AuthStatus.emailNotVerified) {
        SimpleLogger.info('Email verification needed, should navigate to verify-email');
      }
    });
    
    return provider.Consumer<ThemeService>(
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
                      onTap: () {
                        // Use GoRouter's pop which works with our GlobalBackHandler
                        context.pop();
                      },
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildMainContent(isDarkMode, isArabic),
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

  Widget _buildMainContent(bool isDarkMode, bool isArabic) {
    return AnimatedBuilder(
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
                  ? OceanColors.neonCyan.withValues(alpha: 0.3 * _glowAnimation.value)
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGlassLogo(isDarkMode),
                const SizedBox(height: 32),
                _buildTitle(isDarkMode, isArabic),
                const SizedBox(height: 40),
                _buildGlassModeToggle(isDarkMode, isArabic),
                const SizedBox(height: 24),
                _buildFormFields(isDarkMode, isArabic),
                const SizedBox(height: 24),
                _buildTermsCheckbox(isDarkMode, isArabic),
                const SizedBox(height: 32),
                _buildGlassSubmitButton(isDarkMode, isArabic),
                const SizedBox(height: 24),
                _buildLoginLink(isDarkMode, isArabic),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(bool isDarkMode, bool isArabic) {
    return Column(
      children: [
        Text(
          isArabic ? 'إنشاء حساب جديد' : 'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : OceanColors.deepOcean,
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
              ? 'انضم إلينا وابدأ رحلتك المالية'
              : 'Join us and start your financial journey',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.8)
                : OceanColors.deepOcean.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields(bool isDarkMode, bool isArabic) {
    return Column(
      children: [
        _buildGlassField(
          controller: _nameController,
          hint: isArabic ? 'الاسم الكامل' : 'Full Name',
          icon: Icons.person_outline,
          validator: (value) => Validators.validateName(value, context),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 20),
        if (_isEmailMode) ...[
          _buildGlassField(
            controller: _emailController,
            hint: isArabic ? 'البريد الإلكتروني' : 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => Validators.validateEmail(value),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          _buildGlassField(
            controller: _phoneController,
            hint: '+962',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) => Validators.validatePhone(value),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
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
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 20),
          _buildGlassField(
            controller: _confirmPasswordController,
            hint: isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            validator: (value) => Validators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
            isDarkMode: isDarkMode,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: isDarkMode
                    ? OceanColors.neonCyan.withValues(alpha: 0.8)
                    : OceanColors.oceanBlue.withValues(alpha: 0.8),
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
        ] else ...[
          _buildGlassField(
            controller: _phoneController,
            hint: '+962',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) => Validators.validatePhone(value),
            isDarkMode: isDarkMode,
          ),
        ],
      ],
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

  Widget _buildGlassLogo(bool isDarkMode) {
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
            Icons.person_add_outlined,
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

  Widget _buildTermsCheckbox(bool isDarkMode, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              ? OceanColors.neonCyan.withValues(alpha: 0.2)
              : OceanColors.oceanBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _acceptTerms,
            onChanged: (value) => setState(() => _acceptTerms = value ?? false),
            activeColor: isDarkMode
                ? OceanColors.neonCyan
                : OceanColors.oceanBlue,
            checkColor: Colors.white,
          ),
          Expanded(
            child: Text(
              isArabic
                  ? 'أوافق على الشروط والأحكام وسياسة الخصوصية'
                  : 'I agree to Terms & Conditions and Privacy Policy',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.9)
                    : OceanColors.deepOcean.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSubmitButton(bool isDarkMode, bool isArabic) {
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
            onPressed: _isLoading ? null : _handleSignup,
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
                    isArabic ? 'إنشاء الحساب' : 'Create Account',
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

  Widget _buildLoginLink(bool isDarkMode, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isArabic ? 'لديك حساب بالفعل؟ ' : 'Already have an account? ',
          style: TextStyle(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.8)
                : OceanColors.deepOcean.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            isArabic ? 'تسجيل الدخول' : 'Sign In',
            style: TextStyle(
              color: isDarkMode ? OceanColors.neonCyan : OceanColors.oceanBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
