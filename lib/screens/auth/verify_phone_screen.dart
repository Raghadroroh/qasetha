import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/otp_service.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String phoneNumber;
  const VerifyPhoneScreen({super.key, required this.phoneNumber});

  @override
  _VerifyPhoneScreenState createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final _otpController = TextEditingController();
  final _otpService = OTPService();

  bool _isLoading = false;
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendVerificationCode();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    setState(() => _isLoading = true);
    try {
      await _otpService.sendPhoneOTP(widget.phoneNumber);
      _startCountdown();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      _showSnackBar(AppStrings.otpCodeRequired, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _otpService.verifyOTP(_otpController.text.trim());
      _showSnackBar(AppStrings.phoneNumberVerified);
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    if (_remainingSeconds > 0) return;

    setState(() => _isLoading = true);
    try {
      await _otpService.sendPhoneOTP(widget.phoneNumber);
      _startCountdown();
      _showSnackBar(AppStrings.otpCodeResent);
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.verifyPhoneNumber)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(AppStrings.enterOtpCode),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(hintText: AppStrings.otpCodeHint),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              child: const Text(AppStrings.verifyCode),
            ),
            const SizedBox(height: 20),
            Text(
              _remainingSeconds > 0
                  ? '${AppStrings.resendInSeconds} $_remainingSeconds ${AppStrings.secondsUnit}'
                  : AppStrings.noCodeReceived,
            ),
            TextButton(
              onPressed: _remainingSeconds > 0 ? null : _resendOTP,
              child: const Text(AppStrings.resendCode),
            ),
          ],
        ),
      ),
    );
  }
}