import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_provider.dart';
import '../../utils/app_localizations.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/password_requirements.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPasswordRequirements = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (password.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(
        msg: 'جميع الحقول مطلوبة',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    
    if (password != confirmPassword) {
      Fluttertoast.showToast(
        msg: 'كلمة المرور غير متطابقة',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.updatePassword(
      newPassword: password,
      context: context,
    );

    if (!mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: context.l10n.passwordResetSuccess,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      context.go(
        '/success',
        extra: {
          'title': context.l10n.successTitle,
          'message': context.l10n.passwordResetSuccess,
          'nextRoute': '/dashboard',
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: authProvider.errorMessage ?? context.l10n.unexpectedError,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1A1B3A),
              Color(0xFF2D1B69),
              Color(0xFF0A192F),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // زر الرجوع
                  Align(
                    alignment: context.isRTL
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        context.isRTL ? Icons.arrow_forward : Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // أيقونة القفل
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: Color(0xFF00E5FF),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // العنوان
                  Text(
                    context.l10n.resetPassword,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // الوصف
                  Text(
                    context.l10n.locale.languageCode == 'ar'
                        ? 'أدخل كلمة المرور الجديدة لحسابك'
                        : 'Enter your new password for your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // حقل كلمة المرور الجديدة
                  CustomTextField(
                    label: context.l10n.newPassword,
                    hint: '••••••••',
                    controller: _passwordController,
                    obscureText: true,
                    showPasswordToggle: true,
                    validator: (value) =>
                        ValidationHelper.validatePassword(value ?? '', context),
                    onChanged: (value) {
                      setState(() {
                        _showPasswordRequirements = value.isNotEmpty;
                      });
                    },
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  // متطلبات كلمة المرور
                  PasswordRequirements(
                    password: _passwordController.text,
                    showRequirements: _showPasswordRequirements,
                  ),

                  const SizedBox(height: 20),

                  // تأكيد كلمة المرور
                  CustomTextField(
                    label: context.l10n.confirmNewPassword,
                    hint: '••••••••',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    showPasswordToggle: true,
                    validator: (value) =>
                        ValidationHelper.validateConfirmPassword(
                          _passwordController.text,
                          value ?? '',
                          context,
                        ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // زر إعادة تعيين كلمة المرور
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: context.l10n.resetPassword,
                        onPressed: _handleResetPassword,
                        isLoading: authProvider.isLoading,
                        backgroundColor: const Color(0xFF00E5FF),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // معلومات الأمان
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.locale.languageCode == 'ar'
                              ? 'كلمة المرور الجديدة ستكون مشفرة وآمنة تماماً'
                              : 'Your new password will be encrypted and completely secure',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // زر العودة لتسجيل الدخول
                  CustomButton(
                    text: context.l10n.backToLogin,
                    onPressed: () => context.go('/login'),
                    isOutlined: true,
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
