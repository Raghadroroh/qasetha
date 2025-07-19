// This file shows how to integrate the new AuthService with your existing screens
// Copy the relevant parts to your actual screen files

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/enhanced_auth_provider.dart';
import '../utils/validators.dart';

class AuthIntegrationExamples {
  /// Example: Login Screen Integration
  static Future<void> handleEmailLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    // Option 1: Using EnhancedAuthProvider (Recommended for state management)
    final authProvider = context.read<EnhancedAuthProvider>();

    final success = await authProvider.signInWithEmail(
      email: email,
      password: password,
      context: context,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل الدخول بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/dashboard');
    } else {
      // Handle different error types
      if (authProvider.state == AuthState.emailNotVerified) {
        context.go('/verify-email');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'حدث خطأ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Example: Phone Login Integration
  static Future<void> handlePhoneLogin({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    final authProvider = context.read<EnhancedAuthProvider>();

    // Validate phone number first
    String? phoneError = Validators.validatePhone(phoneNumber, context);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(phoneError), backgroundColor: Colors.red),
      );
      return;
    }

    final success = await authProvider.sendOTP(
      phoneNumber: phoneNumber,
      context: context,
    );

    if (!context.mounted) return;

    if (success) {
      context.push(
        '/otp-verify',
        extra: {'phoneNumber': phoneNumber, 'source': 'login'},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'فشل في إرسال رمز التحقق'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Example: OTP Verification Integration
  static Future<void> handleOTPVerification({
    required BuildContext context,
    required String otpCode,
    String? name, // For signup
  }) async {
    final authProvider = context.read<EnhancedAuthProvider>();

    // Validate OTP first
    String? otpError = Validators.validateOTP(otpCode, context);
    if (otpError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(otpError), backgroundColor: Colors.red),
      );
      return;
    }

    final success = await authProvider.verifyOTP(
      smsCode: otpCode,
      name: name,
      context: context,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم التحقق من الهاتف بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'رمز التحقق غير صحيح'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
