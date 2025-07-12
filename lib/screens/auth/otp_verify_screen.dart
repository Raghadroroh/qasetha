import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OtpVerifyScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        _startCountdown();
      }
    });
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length < 6) {
      _showSnackBar('أدخل رمز التحقق كاملاً', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('التحقق من OTP: $_otpCode');
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        context.go('/success');
      }
    } catch (e) {
      print('خطأ في التحقق من OTP: $e');
      if (mounted) {
        _showSnackBar('رمز التحقق غير صحيح', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_remainingSeconds > 0) return;
    
    setState(() {
      _isLoading = true;
      _remainingSeconds = 60;
    });

    try {
      print('إعادة إرسال OTP إلى: ${widget.phoneNumber}');
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showSnackBar('تم إعادة إرسال رمز التحقق');
        _startCountdown();
      }
    } catch (e) {
      print('خطأ في إعادة الإرسال: $e');
      if (mounted) {
        _showSnackBar('خطأ في إعادة الإرسال', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.whiteTransparent20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
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
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // أيقونة الحماية
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                      ),
                      child: const Icon(
                        Icons.security,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    
                    // العنوان
                    Text(
                      'رمز التحقق',
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'أدخل الرمز المرسل إلى\n${widget.phoneNumber}',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // حقول OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.whiteTransparent20),
                          ),
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: GoogleFonts.cairo(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            onChanged: (value) => _onOtpChanged(index, value),
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // زر التحقق
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade700],
                        ),
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
                                'تأكيد الرمز',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
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
                        'لم تستلم الرمز؟ يمكنك إعادة الإرسال خلال $_remainingSeconds ثانية',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لم تستلم الرمز؟ ',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: _resendOTP,
                            child: Text(
                              'إعادة الإرسال',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}