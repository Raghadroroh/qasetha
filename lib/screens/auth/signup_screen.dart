import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_localizations.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firebase_service.dart';
import '../../utils/validators.dart';

import '../../widgets/app_controls.dart';
import '../../widgets/back_button_handler.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = FirebaseAuthService();
  final _firebaseService = FirebaseService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isEmailMode = true;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.fastOutSlowIn,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await FirebaseAuthService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (mounted) {
        if (result.success) {
          _showSnackBar(context.l10n.accountCreated);
          context.go('/verify-email');
        } else {
          _showSnackBar(result.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('${context.l10n.error}: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signupWithPhone() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (mounted) {
      context.go('/otp-verify', extra: {
        'phoneNumber': _phoneController.text.trim(),
        'name': _nameController.text.trim(),
        'source': 'signup'
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal(color: Colors.white)),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler(
      fallbackRoute: '/login',
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  ),
          ),
          child: Stack(
            children: [
              // Shimmer Background Effect
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + 2.0 * _shimmerController.value, -1.0),
                        end: Alignment(1.0 + 2.0 * _shimmerController.value, 1.0),
                        colors: [
                          Colors.transparent,
                          Theme.of(context).colorScheme.primary.withOpacity(0.03),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.02),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
              // App Controls
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: const AppControls(),
                ),
              ),
              // Content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            children: [
                              // Logo/Icon Container
                              Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(bottom: 32),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_add_outlined,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                              // Main Form Container
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Theme.of(context).colorScheme.surface.withOpacity(0.9)
                                      : Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // العنوان
                                    Text(
                                      context.l10n.welcome,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(context).colorScheme.onSurface,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      context.l10n.signup,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 32),
                                    // Toggle Buttons
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(() => _isEmailMode = true),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: _isEmailMode 
                                                      ? Theme.of(context).colorScheme.primary
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  'البريد الإلكتروني',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.tajawal(
                                                    color: _isEmailMode 
                                                        ? Colors.white 
                                                        : Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(() => _isEmailMode = false),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: !_isEmailMode 
                                                      ? Theme.of(context).colorScheme.primary
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  'رقم الهاتف',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.tajawal(
                                                    color: !_isEmailMode 
                                                        ? Colors.white 
                                                        : Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // نموذج التسجيل
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          _buildModernTextField(
                                            controller: _nameController,
                                            label: context.l10n.name,
                                            icon: Icons.person_outline,
                                            validator: (value) {
                                              if (value?.isEmpty ?? true) {
                                                return context.l10n.fieldRequired;
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          if (_isEmailMode) ...[
                                            _buildModernTextField(
                                              controller: _emailController,
                                              label: context.l10n.email,
                                              icon: Icons.email_outlined,
                                              keyboardType: TextInputType.emailAddress,
                                              validator: Validators.validateEmail,
                                            ),
                                            const SizedBox(height: 20),
                                            _buildModernTextField(
                                              controller: _passwordController,
                                              label: context.l10n.password,
                                              icon: Icons.lock_outline,
                                              obscureText: _obscurePassword,
                                              validator: Validators.validatePassword,
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_off_outlined
                                                      : Icons.visibility_outlined,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                onPressed: () => setState(
                                                  () => _obscurePassword = !_obscurePassword,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            _buildModernTextField(
                                              controller: _confirmPasswordController,
                                              label: context.l10n.confirmPassword,
                                              icon: Icons.lock_outline,
                                              obscureText: _obscureConfirmPassword,
                                              validator: (value) {
                                                if (value != _passwordController.text) {
                                                  return context.l10n.passwordsDoNotMatch;
                                                }
                                                return null;
                                              },
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureConfirmPassword
                                                      ? Icons.visibility_off_outlined
                                                      : Icons.visibility_outlined,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                onPressed: () => setState(
                                                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                                                ),
                                              ),
                                            ),
                                          ] else ...[
                                            _buildModernTextField(
                                              controller: _phoneController,
                                              label: 'رقم الهاتف',
                                              icon: Icons.phone_outlined,
                                              keyboardType: TextInputType.phone,
                                              validator: (value) {
                                                if (value?.isEmpty ?? true) {
                                                  return 'يرجى إدخال رقم الهاتف';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                          const SizedBox(height: 32),
                                          _buildModernButton(
                                            onPressed: _isLoading ? null : (_isEmailMode ? _signup : _signupWithPhone),
                                            text: context.l10n.signup,
                                            isLoading: _isLoading,
                                            isPrimary: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // رابط تسجيل الدخول
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.l10n.alreadyHaveAccount,
                                          style: GoogleFonts.tajawal(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: () => context.go('/login'),
                                          child: Text(
                                            context.l10n.login,
                                            style: GoogleFonts.tajawal(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.primary.withOpacity(0.02),
            Theme.of(context).colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.tajawal(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textDirection: context.textDirection,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.tajawal(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required VoidCallback? onPressed,
    required String text,
    IconData? icon,
    bool isLoading = false,
    bool isPrimary = true,
  }) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: isPrimary ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ) : null,
        color: isPrimary ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary ? null : Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isPrimary ? Colors.white : Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isPrimary ? Colors.white : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}