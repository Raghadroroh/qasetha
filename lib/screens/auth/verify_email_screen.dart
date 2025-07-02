import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/logger_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  bool _canResend = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  void _checkEmailVerification() {
    // Check email verification status periodically
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        FirebaseAuthService.currentUser?.reload().then((_) {
          if (FirebaseAuthService.isEmailVerified && mounted) {
            context.go('/home');
          } else {
            _checkEmailVerification();
          }
        });
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend || _isLoading) return;

    setState(() {
      _isLoading = true;
      _canResend = false;
      _resendCooldown = 60;
    });

    try {
      await FirebaseAuthService.sendEmailVerification();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إرسال بريد التحقق بنجاح',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.green,
        ),
      );

      _startCooldownTimer();
    } catch (e) {
      LoggerService.error('Resend verification email failed', error: e);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _canResend = true;
        _resendCooldown = 0;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startCooldownTimer() {
    if (_resendCooldown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _resendCooldown--;
            if (_resendCooldown == 0) {
              _canResend = true;
            } else {
              _startCooldownTimer();
            }
          });
        }
      });
    }
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GestureDetector(
          onTap: () => context.go('/login'),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildBackButton(),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF00E5FF), Color(0xFF0099CC)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'تأكيد البريد الإلكتروني',
                          style: GoogleFonts.tajawal(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'تم إرسال رابط التأكيد إلى بريدك الإلكتروني\nيرجى فتح البريد والضغط على الرابط للمتابعة',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (FirebaseAuthService.currentUser?.email != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            FirebaseAuthService.currentUser!.email!,
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              color: const Color(0xFF00E5FF),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 60),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _canResend && !_isLoading ? _resendVerificationEmail : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
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
                                    _canResend 
                                        ? 'إعادة إرسال البريد'
                                        : 'إعادة الإرسال خلال $_resendCooldown ثانية',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            FirebaseAuthService.signOut();
                            context.go('/login');
                          },
                          child: Text(
                            'تسجيل الدخول بحساب آخر',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              color: Colors.white70,
                              decoration: TextDecoration.underline,
                            ),
                          ),
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
    );
  }
}