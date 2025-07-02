import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _contactController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Logger _logger = Logger();
  bool _isLoading = false;
  bool _isEmail = true;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final contact = _contactController.text.trim();

      if (_isEmail) {
        // Send password reset email
        await FirebaseAuth.instance.sendPasswordResetEmail(email: contact);
        
        if (!mounted) return;
        
        _logger.i('Password reset email sent to: $contact');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        context.go('/login');
      } else {
        // Send OTP for phone
        final phoneNumber = '+962$contact';
        
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto verification completed
          },
          verificationFailed: (FirebaseAuthException e) {
            if (!mounted) return;
            throw e.message ?? 'فشل في إرسال رمز التحقق';
          },
          codeSent: (String verificationId, int? resendToken) {
            if (!mounted) return;
            
            _logger.i('OTP sent to: $phoneNumber');
            
            context.go('/otp', extra: {
              'verificationId': verificationId,
              'from': 'forgot-password'
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Timeout
          },
        );
      }
    } catch (e) {
      _logger.e('Forgot password error: $e');
      
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

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 20),
                    Text(
                      'نسيت كلمة السر',
                      style: GoogleFonts.tajawal(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isEmail = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _isEmail ? const Color(0xFF00E5FF) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: Text(
                                      'بريد إلكتروني',
                                      style: GoogleFonts.tajawal(
                                        color: _isEmail ? Colors.white : Colors.white70,
                                        fontWeight: _isEmail ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isEmail = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_isEmail ? const Color(0xFF00E5FF) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: Text(
                                      'رقم هاتف',
                                      style: GoogleFonts.tajawal(
                                        color: !_isEmail ? Colors.white : Colors.white70,
                                        fontWeight: !_isEmail ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _contactController,
                            keyboardType: _isEmail ? TextInputType.emailAddress : TextInputType.phone,
                            style: GoogleFonts.tajawal(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: _isEmail ? 'البريد الإلكتروني' : 'رقم الهاتف',
                              labelStyle: GoogleFonts.tajawal(color: Colors.white70),
                              hintText: !_isEmail ? '7xxxxxxxx' : null,
                              hintStyle: !_isEmail ? GoogleFonts.tajawal(color: Colors.white38) : null,
                              prefixIcon: _isEmail
                                  ? const Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFF00E5FF),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                                      ),
                                      child: Text(
                                        '+962',
                                        style: GoogleFonts.tajawal(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF00E5FF),
                                        ),
                                      ),
                                    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _isEmail ? 'البريد الإلكتروني مطلوب' : 'رقم الهاتف مطلوب';
                              }
                              if (_isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'البريد الإلكتروني غير صحيح';
                              }
                              if (!_isEmail && !RegExp(r'^[0-9]{8,9}$').hasMatch(value)) {
                                return 'رقم الهاتف غير صحيح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleForgotPassword,
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
                                      _isEmail ? 'إرسال رابط الإعادة' : 'إرسال رمز التحقق',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
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
      ),
    );
  }
}