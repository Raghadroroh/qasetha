import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/otp_service.dart';
import '../../utils/validators.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;
  
  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _otpController = TextEditingController();
  final _authService = FirebaseAuthService();
  final _otpService = OTPService();
  
  bool _isLoading = false;
  bool _isEmailVerified = false;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _checkEmailVerification();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      // TODO: سيتم تفعيل إرسال OTP بعد تهيئة Firebase
      // await _otpService.sendEmailOTP(widget.email);
      _startCountdown();
      _showSnackBar('تم إرسال رمز التحقق (وهمي)');
    } catch (e) {
      _showSnackBar(AppStrings.error, isError: true);
    }
  }

  Future<void> _checkEmailVerification() async {
    while (mounted && !_isEmailVerified) {
      await Future.delayed(const Duration(seconds: 3));
      final user = _authService.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          setState(() => _isEmailVerified = true);
          _navigateToHome();
          break;
        }
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      _showSnackBar(AppStrings.otpRequired, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: سيتم تفعيل تحقق OTP بعد تهيئة Firebase
      _showSnackBar('Firebase غير مهيأ بعد', isError: true);
      
      // final result = await _otpService.verifyOTP(_otpController.text.trim());
      // if (result.isSuccess) {
      //   _showSnackBar(AppStrings.emailVerified);
      //   _navigateToHome();
      // } else {
      //   _showSnackBar(result.message, isError: true);
      // }
    } catch (e) {
      _showSnackBar(AppStrings.error, isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    if (_remainingSeconds > 0) return;

    setState(() => _isLoading = true);

    try {
      // TODO: سيتم تفعيل إعادة إرسال OTP بعد تهيئة Firebase
      // await _otpService.sendEmailOTP(widget.email);
      _startCountdown();
      _showSnackBar('تم إعادة الإرسال (وهمي)');
    } catch (e) {
      _showSnackBar(AppStrings.error, isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startCountdown() async {
    // TODO: سيتم تفعيل العد التنازلي بعد تهيئة Firebase
    _remainingSeconds = 60; // قيمة وهمية مؤقتة
    
    while (_remainingSeconds > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _remainingSeconds--);
      }
    }
  }

  void _navigateToHome() {
    if (mounted) context.go('/home');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.emailVerification,
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // أيقونة الإيميل
                Container(
                  height: 120,
                  width: 120,
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                // العنوان
                Text(
                  AppStrings.emailVerification,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // الوصف
                Text(
                  'تم إرسال رمز التحقق إلى:\n${widget.email}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // حقل OTP
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.whiteTransparent20),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: GoogleFonts.cairo(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: GoogleFonts.cairo(
                        color: AppColors.textHint,
                        fontSize: 24,
                        letterSpacing: 8,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // زر التحقق
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppStrings.verifyOtp,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // إعادة الإرسال
                if (_remainingSeconds > 0)
                  Text(
                    'يمكنك إعادة الإرسال خلال $_remainingSeconds ثانية',
                    style: GoogleFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  TextButton(
                    onPressed: _resendOTP,
                    child: Text(
                      AppStrings.resendOtp,
                      style: GoogleFonts.cairo(
                        color: AppColors.primary,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                
                const Spacer(),
                
                // رابط تسجيل الدخول
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'العودة لتسجيل الدخول',
                    style: GoogleFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}