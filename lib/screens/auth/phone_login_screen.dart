import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_state_provider.dart';
import '../../utils/phone_validator.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      _showSnackBar('رقم الهاتف مطلوب', isError: true);
      return;
    }

    // Validate phone number
    final validationError = PhoneValidator.getPhoneValidationError(phoneNumber, true);
    if (validationError != null) {
      _showSnackBar(validationError, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authStateProvider.notifier).sendOTP(
        phoneNumber: phoneNumber,
        context: context,
      );

      if (!mounted) return;

      if (success) {
        context.push(
          '/otp-verify',
          extra: {
            'phoneNumber': phoneNumber,
            'source': 'phone-login',
          },
        );
      } else {
        final authState = ref.read(authStateProvider);
        _showSnackBar(
          authState.error ?? 'خطأ في إرسال رمز التحقق',
          isError: true,
        );
      }
    } catch (e) {
      // Error sending OTP
      if (mounted) {
        _showSnackBar('خطأ في إرسال رمز التحقق', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/login');
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A192F), Color(0xFF112240)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E293B).withValues(alpha: 0.8),
                        const Color(0xFF334155).withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // زر العودة
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => context.go('/login'),
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // أيقونة الهاتف
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF667eea).withValues(alpha: 0.8),
                              const Color(0xFF764ba2).withValues(alpha: 0.9),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withValues(alpha: 0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),

                      // العنوان
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFF00E5FF)],
                        ).createShader(bounds),
                        child: Text(
                          'رقم الهاتف',
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'سنرسل لك رمز التحقق',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // حقل رقم الهاتف الأردني
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            // رمز الدولة
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '🇯🇴',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+962',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // حقل الإدخال
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 9,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: '79 123 4567',
                                  hintStyle: GoogleFonts.cairo(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  border: InputBorder.none,
                                  counterText: '',
                                  contentPadding: const EdgeInsets.all(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'أدخل رقم هاتفك الأردني بدون الصفر',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.right,
                      ),

                      const SizedBox(height: 32),

                      // زر إرسال رمز التحقق
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF667eea).withValues(alpha: 0.8),
                              const Color(0xFF764ba2).withValues(alpha: 0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOTP,
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
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'إرسال رمز التحقق',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // رابط العودة لتسجيل الدخول بالبريد
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'العودة لتسجيل الدخول بالبريد الإلكتروني',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF00E5FF),
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}