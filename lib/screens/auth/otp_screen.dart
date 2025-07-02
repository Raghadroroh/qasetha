import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final Logger _logger = Logger();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCooldown = 60;
  String? _verificationId;
  Map<String, dynamic>? _userData;
  String? _from;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null) {
        _verificationId = extra['verificationId'] as String?;
        _from = extra['from'] as String?;
        _userData = extra['userData'] as Map<String, dynamic>?;
      }
      _startResendTimer();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    if (_resendCooldown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _resendCooldown--;
            if (_resendCooldown == 0) {
              _canResend = true;
            } else {
              _startResendTimer();
            }
          });
        }
      });
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    
    try {
      String otpCode = _controllers.map((controller) => controller.text).join();
      
      if (otpCode.length != 6) {
        throw 'أدخل رمز التحقق كاملاً';
      }
      
      if (_verificationId == null) {
        throw 'خطأ في بيانات التحقق';
      }
      
      // Create phone credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );
      
      // Sign in with credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (!mounted) return;

      // Store user data in Firestore if from signup
      if (_from == 'signup' && _userData != null) {
        await userCredential.user?.updateDisplayName(_userData!['name']);
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'name': _userData!['name'],
          'phone': _userData!['phone'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      _logger.i('OTP verified successfully for: ${_userData?['phone'] ?? 'unknown'}');
      
      // Navigate based on source
      if (_from == 'forgot-password') {
        if (mounted) context.go('/reset-password');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _from == 'signup' ? 'تم إنشاء الحساب بنجاح' : 'تم تسجيل الدخول بنجاح',
                style: GoogleFonts.tajawal(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      _logger.e('OTP verification error: $e');
      
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend || _userData?['phone'] == null) return;

    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    try {
      // Clear current OTP fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();

      // Resend OTP
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _userData!['phone'],
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto verification
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          throw e.message ?? 'فشل في إعادة إرسال رمز التحقق';
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          
          _verificationId = verificationId;
          _logger.i('OTP resent to: ${_userData!['phone']}');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم إعادة إرسال رمز التحقق',
                  style: GoogleFonts.tajawal(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout
        },
      );

      _startResendTimer();
    } catch (e) {
      _logger.e('Resend OTP error: $e');
      
      setState(() {
        _canResend = true;
        _resendCooldown = 0;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في إعادة الإرسال، حاول مرة أخرى',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.red,
        ),
      );
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
                            Icons.security,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'رمز التحقق',
                          style: GoogleFonts.tajawal(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'أدخل الرمز المرسل إلى هاتفك',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_userData?['phone'] != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _userData!['phone'],
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              color: const Color(0xFF00E5FF),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 60),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) => _buildOtpField(index)),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
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
                                    'تأكيد الرمز',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _canResend ? _resendOtp : null,
                          child: Text(
                            _canResend 
                                ? 'إعادة إرسال الرمز'
                                : 'إعادة الإرسال خلال $_resendCooldown ثانية',
                            style: GoogleFonts.tajawal(
                              color: _canResend ? const Color(0xFF00E5FF) : Colors.white38,
                              fontSize: 16,
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

  Widget _buildOtpField(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.tajawal(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          
          // Auto-verify when all fields are filled
          if (index == 5 && value.isNotEmpty) {
            bool allFilled = _controllers.every((controller) => controller.text.isNotEmpty);
            if (allFilled && !_isLoading) {
              _verifyOtp();
            }
          }
        },
      ),
    );
  }
}