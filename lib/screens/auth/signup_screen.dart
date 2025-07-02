import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../utils/password_validator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Logger _logger = Logger();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _showPasswordRequirements = false;
  bool _acceptTerms = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يجب الموافقة على الشروط والأحكام',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEmail) {
        // Email signup
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Update display name
        await credential.user?.updateDisplayName(_nameController.text.trim());

        // Store additional user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user?.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        _logger.i('User created with email: ${_emailController.text}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إنشاء الحساب بنجاح',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/home');
      } else {
        // Phone signup with OTP
        final phoneNumber = '+962${_phoneController.text.trim()}';
        
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
              
              // Update display name
              await userCredential.user?.updateDisplayName(_nameController.text.trim());

              // Store additional user data in Firestore
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user?.uid)
                  .set({
                'name': _nameController.text.trim(),
                'phone': phoneNumber,
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (!mounted) return;

              _logger.i('User created with phone: $phoneNumber');
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
              'from': 'signup',
              'userData': {
                'name': _nameController.text.trim(),
                'phone': phoneNumber,
              }
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Timeout
          },
        );
      }
    } catch (e) {
      _logger.e('Signup error: $e');
      
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
                  vertical: 20.0,
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
                        const SizedBox(height: 40),
                        _buildSignupForm(),
                        const SizedBox(height: 40),
                        _buildLoginButton(),
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
          child: const Icon(Icons.person_add, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 30),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFFFFFFFF)],
          ).createShader(bounds),
          child: Text(
            'إنشاء حساب جديد',
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
          'انضم إلينا وابدأ رحلتك',
          style: GoogleFonts.tajawal(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
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
            // Signup method selection
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
              controller: _nameController,
              label: 'الاسم الكامل',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الاسم مطلوب';
                }
                if (value.length < 2) {
                  return 'الاسم يجب أن يكون حرفين على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (_isEmail) ...[
              _buildModernInputField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'البريد الإلكتروني مطلوب';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'البريد الإلكتروني غير صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildModernInputField(
                controller: _passwordController,
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscurePassword,
                onObscureToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: PasswordValidator.validate,
                onChanged: (value) {
                  setState(() {
                    _passwordRequirements = PasswordValidator.checkRequirements(value);
                    _showPasswordRequirements = value.isNotEmpty;
                  });
                },
              ),
              if (_showPasswordRequirements) ...[
                const SizedBox(height: 16),
                _buildPasswordRequirements(),
              ],
              const SizedBox(height: 24),
              _buildModernInputField(
                controller: _confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onObscureToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'تأكيد كلمة المرور مطلوب';
                  }
                  if (value != _passwordController.text) {
                    return 'كلمة المرور غير متطابقة';
                  }
                  return null;
                },
              ),
            ] else ...[
              _buildModernInputField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رقم الهاتف مطلوب';
                  }
                  if (!RegExp(r'^[0-9]{8,9}$').hasMatch(value)) {
                    return 'رقم الهاتف غير صحيح';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            _buildTermsCheckbox(),
            const SizedBox(height: 32),
            _buildModernSignupButton(),
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
              color: isValid
                  ? const Color(0xFF00E5FF)
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _acceptTerms = !_acceptTerms),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _acceptTerms ? const Color(0xFF00E5FF) : Colors.white30,
                width: 2,
              ),
              color: _acceptTerms
                  ? const Color(0xFF00E5FF)
                  : Colors.transparent,
            ),
            child: _acceptTerms
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.tajawal(fontSize: 14, color: Colors.white70),
              children: [
                const TextSpan(text: 'أوافق على '),
                TextSpan(
                  text: 'الشروط والأحكام',
                  style: GoogleFonts.tajawal(
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' و '),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: GoogleFonts.tajawal(
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onObscureToggle,
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
        obscureText: obscureText,
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
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  onPressed: onObscureToggle,
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

  Widget _buildModernSignupButton() {
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
        onPressed: (_isLoading || !_acceptTerms) ? null : _handleSignup,
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
                    'إنشاء الحساب',
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

  Widget _buildLoginButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'لديك حساب بالفعل؟ ',
            style: GoogleFonts.tajawal(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              'تسجيل الدخول',
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