import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/app_localizations.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_state_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEmailMode = true;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authStateProvider.notifier);

    if (_isEmailMode) {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        Fluttertoast.showToast(
          msg: 'البريد الإلكتروني مطلوب',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }
      
      final success = await authNotifier.sendPasswordResetEmail(
        email: email,
        context: context,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _emailSent = true;
        });
        Fluttertoast.showToast(
          msg: context.l10n.resetLinkSent,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        final error = ref.read(authStateProvider).error;
        Fluttertoast.showToast(
          msg: error ?? context.l10n.unexpectedError,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      // إرسال OTP للهاتف
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        Fluttertoast.showToast(
          msg: 'رقم الهاتف مطلوب',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }
      
      final success = await authNotifier.sendOTP(
        phoneNumber: phone,
        context: context,
      );

      if (!mounted) return;

      if (success) {
        context.push(
          '/otp-verify',
          extra: {
            'phoneNumber': phone,
            'source': 'forgot-password',
          },
        );
      } else {
        final error = ref.read(authStateProvider).error;
        Fluttertoast.showToast(
          msg: error ?? 'حدث خطأ في إرسال رمز التحقق',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
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

                  if (!_emailSent) ...[
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
                      context.l10n.forgotPassword,
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
                      context.l10n.forgotPasswordDesc,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // تبديل نوع الاسترداد
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isEmailMode = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _isEmailMode
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  context.l10n.emailMode,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: _isEmailMode
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isEmailMode = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isEmailMode
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  context.l10n.phoneMode,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: !_isEmailMode
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // حقل البريد الإلكتروني أو الهاتف
                    if (_isEmailMode)
                      CustomTextField(
                        label: context.l10n.email,
                        hint: 'example@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => ValidationHelper.validateEmail(
                          value ?? '',
                          context,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      )
                    else
                      CustomTextField(
                        label: context.l10n.phone,
                        hint: '+962 7X XXX XXXX',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            ValidationHelper.validatePhoneNumber(
                              value ?? '',
                              context,
                            ),
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // زر الإرسال
                    Consumer(
                      builder: (context, ref, child) {
                        final authState = ref.watch(authStateProvider);
                        return CustomButton(
                          text: _isEmailMode
                              ? context.l10n.sendResetLink
                              : context.l10n.continueButton,
                          onPressed: _handleSendReset,
                          isLoading: authState.isLoading,
                          backgroundColor: const Color(0xFF00E5FF),
                        );
                      },
                    ),
                  ] else ...[
                    // شاشة تأكيد الإرسال
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      context.l10n.emailSent,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      context.l10n.emailSentDesc,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _emailController.text.trim(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00E5FF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        context.l10n.checkInboxSpam,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // زر إعادة الإرسال
                    CustomButton(
                      text: context.l10n.sendAgain,
                      onPressed: () => setState(() => _emailSent = false),
                      isOutlined: true,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      textColor: Colors.white,
                    ),
                  ],

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
