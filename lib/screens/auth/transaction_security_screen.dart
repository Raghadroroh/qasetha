import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/biometric_auth_service.dart';
import '../../services/otp_service.dart';

class TransactionSecurityScreen extends StatefulWidget {
  final String transactionType;
  final String transactionDetails;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const TransactionSecurityScreen({
    super.key,
    required this.transactionType,
    required this.transactionDetails,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<TransactionSecurityScreen> createState() =>
      _TransactionSecurityScreenState();
}

class _TransactionSecurityScreenState extends State<TransactionSecurityScreen> {
  final _biometricService = BiometricAuthService();
  final _otpService = OTPService();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _showOtpInput = false;
  bool _otpSent = false;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _checkSecurityOptions();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _checkSecurityOptions() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    final isEnabled = await _biometricService.isBiometricEnabled();

    setState(() {
      _biometricAvailable = isAvailable && isEnabled;
    });

    if (!_biometricAvailable) {
      setState(() => _showOtpInput = true);
    }
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() => _isLoading = true);

    try {
      final result = await _biometricService.authenticateForTransaction(
        transactionType: widget.transactionType,
      );

      if (result.isSuccess) {
        _showSnackBar(AppStrings.transactionSecured);
        widget.onSuccess();
      } else if (result == BiometricAuthResult.cancelled) {
        // لا تظهر رسالة عند الإلغاء
      } else if (result.shouldShowFallback) {
        _showFallbackOptions();
      } else {
        _showSnackBar(result.message, isError: true);
      }
    } catch (e) {
      _showSnackBar(AppStrings.error, isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showFallbackOptions() {
    setState(() => _showOtpInput = true);
    _showSnackBar(AppStrings.fallbackToOtp);
  }

  Future<void> _sendOtpEmail() async {
    setState(() => _isLoading = true);

    try {
      const email = 'user@example.com';
      await _otpService.sendEmailOTP(email);

      setState(() => _otpSent = true);
      _showSnackBar(AppStrings.otpSentToEmail);
      _startCountdown();
    } catch (e) {
      _showSnackBar(AppStrings.error, isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtpSms() async {
    setState(() => _isLoading = true);

    try {
      const phone = '+962791234567';
      await _otpService.sendSMSOTP(phone);

      setState(() => _otpSent = true);
      _showSnackBar(AppStrings.otpSentToPhone);
      _startCountdown();
    } catch (e) {
      _showSnackBar(AppStrings.error, isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      _showSnackBar(AppStrings.otpRequired, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _otpService.verifyOTP(_otpController.text.trim());

      if (result.user != null) {
        _showSnackBar(AppStrings.transactionSecured);
        widget.onSuccess();
      } else {
        _showSnackBar('فشل التحقق من رمز OTP', isError: true);
      }
    } catch (e) {
      _showSnackBar(AppStrings.error, isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startCountdown() async {
    _remainingSeconds = 60;

    while (_remainingSeconds > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _remainingSeconds--);
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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.securityVerification,
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: widget.onCancel,
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
                Container(
                  height: 120,
                  width: 120,
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                Text(
                  AppStrings.verifyIdentity,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.whiteTransparent20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.transactionType,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.transactionDetails,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                if (_biometricAvailable && !_showOtpInput) ...[
                  _buildBiometricButton(),
                  const SizedBox(height: 16),
                  _buildFallbackButton(),
                ] else if (_showOtpInput) ...[
                  _buildOtpSection(),
                ],

                const Spacer(),

                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    AppStrings.cancel,
                    style: GoogleFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 16,
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

  Widget _buildBiometricButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _authenticateWithBiometric,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.fingerprint, color: Colors.white),
        label: Text(
          AppStrings.useBiometric,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackButton() {
    return TextButton(
      onPressed: () => setState(() => _showOtpInput = true),
      child: Text(
        AppStrings.otpFallback,
        style: GoogleFonts.cairo(
          color: AppColors.primary,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildOtpSection() {
    return Column(
      children: [
        if (!_otpSent) ...[
          Text(
            'اختر طريقة إرسال رمز التحقق:',
            style: GoogleFonts.cairo(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          _buildOtpMethodButton(
            icon: Icons.email_outlined,
            label: AppStrings.sendOtpEmail,
            onPressed: _sendOtpEmail,
          ),

          const SizedBox(height: 16),

          _buildOtpMethodButton(
            icon: Icons.sms_outlined,
            label: AppStrings.sendOtpSms,
            onPressed: _sendOtpSms,
          ),
        ] else ...[
          Text(
            'أدخل رمز التحقق المرسل:',
            style: GoogleFonts.cairo(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

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

          const SizedBox(height: 16),

          if (_remainingSeconds > 0)
            Text(
              'يمكنك إعادة الإرسال خلال $_remainingSeconds ثانية',
              style: GoogleFonts.cairo(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 24),

          Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
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
        ],
      ],
    );
  }

  Widget _buildOtpMethodButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.whiteTransparent20),
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, color: AppColors.primary),
        label: Text(
          label,
          style: GoogleFonts.cairo(fontSize: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
