import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../utils/password_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Logger _logger = Logger();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _showPasswordRequirements = false;
  bool _isEmail = true;
  Map<String, bool> _passwordRequirements = {};

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isEmail) {
        // Email login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (!mounted) return;
        
        _logger.i('User logged in with email: $email');
        context.go('/home');
      } else {
        // Phone login with OTP
        final phoneNumber = '+962$email'; // Treating email field as phone for this case
        
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              await FirebaseAuth.instance.signInWithCredential(credential);
              
              if (!mounted) return;
              
              _logger.i('User logged in with phone: $phoneNumber');
              context.go('/home');
            } catch (e) {
              _logger.e('Phone verification completed error: $e');
            }
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
              'from': 'login'
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Timeout
          },
        );
        return;
      }
    } catch (e) {
      _logger.e('Login error: $e');
      
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

  Future<void> _handleForgotPassword() async {
    context.go('/forgot-password');
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => context.go('/onboarding'),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBackButton(),
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 60),
                        _buildLoginForm(),
                        const SizedBox(height: 60),
                        _buildSignupButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
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
            Icons.account_circle,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFFFFFFFF)],
          ).createShader(bounds),
          child: Text(
            'أهلاً بك مرة أخرى',
            style: GoogleFonts.tajawal(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'سجل دخولك للمتابعة',
          style: GoogleFonts.tajawal(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Login method selection
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: _isEmail ? Colors.white : Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'بريد إلكتروني',
                            style: GoogleFonts.tajawal(
                              color: _isEmail ? Colors.white : Colors.white70,
                              fontWeight: _isEmail ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: !_isEmail ? Colors.white : Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'رقم هاتف',
                            style: GoogleFonts.tajawal(
                              color: !_isEmail ? Colors.white : Colors.white70,
                              fontWeight: !_isEmail ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildModernInputField(
              controller: _emailController,
              label: _isEmail ? 'البريد الإلكتروني' : 'رقم الهاتف',
              icon: _isEmail ? Icons.email_outlined : Icons.phone_outlined,
              keyboardType: _isEmail ? TextInputType.emailAddress : TextInputType.phone,
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
            if (_isEmail) ...[
              const SizedBox(height: 24),
              _buildModernInputField(
                controller: _passwordController,
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: PasswordValidator.validate,
                onChanged: (value) {
                  setState(() {
                    _passwordRequirements = PasswordValidator.checkRequirements(value);
                    _showPasswordRequirements = value.isNotEmpty;
                  });
                },
              ),
            ],
            if (_showPasswordRequirements) ...[
              const SizedBox(height: 16),
              _buildPasswordRequirements(),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _handleForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'نسيت كلمة المرور؟',
                  style: GoogleFonts.tajawal(
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildModernLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'متطلبات كلمة المرور:',
            style: GoogleFonts.tajawal(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement('8 أحرف على الأقل', 'length'),
          _buildRequirement('حرف كبير واحد (A-Z)', 'uppercase'),
          _buildRequirement('حرف صغير واحد (a-z)', 'lowercase'),
          _buildRequirement('رقم واحد (0-9)', 'number'),
          _buildRequirement('رمز خاص (!@#\$%^&*)', 'special'),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, String key) {
    final isValid = _passwordRequirements[key] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isValid ? const Color(0xFF00E5FF) : Colors.white30,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.tajawal(
              color: isValid ? const Color(0xFF00E5FF) : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        keyboardType: keyboardType,
        style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16),
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: false,
          labelText: label,
          labelStyle: GoogleFonts.tajawal(color: Colors.white70, fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  const Color(0xFF0099CC).withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(icon, color: const Color(0xFF00E5FF), size: 20),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildModernLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00E5FF), Color(0xFF0099CC)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تسجيل الدخول',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ليس لديك حساب؟ ',
            style: GoogleFonts.tajawal(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          TextButton(
            onPressed: () {
              context.go('/signup');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              'إنشاء حساب جديد',
              style: GoogleFonts.tajawal(
                color: const Color(0xFF00E5FF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}