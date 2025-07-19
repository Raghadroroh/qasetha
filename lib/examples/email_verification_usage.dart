import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/email_verification_service.dart';
import '../services/logger_service.dart';
import '../utils/auth_extensions.dart';

/// Example implementations showing how to use EmailVerificationService
/// in different scenarios throughout your Flutter app

class EmailVerificationUsageExamples {
  
  /// Example 1: Call after successful login
  static Future<void> handlePostLogin(BuildContext context) async {
    LoggerService.info('User logged in successfully, checking email verification...');
    
    // Update email verification status and show success message if verified
    final bool wasUpdated = await EmailVerificationService.updateEmailVerificationStatus(
      context: context,
      showSuccessMessage: true,
      showErrorMessage: true,
    );
    
    if (wasUpdated) {
      LoggerService.info('Email verification status was updated in Firestore');
    }
  }

  /// Example 2: Call on app launch/initialization
  static Future<void> handleAppLaunch() async {
    LoggerService.info('App launched, checking email verification status...');
    
    // Silent check without showing messages to user
    await EmailVerificationService.updateEmailVerificationStatus(
      showSuccessMessage: false,
      showErrorMessage: false,
    );
  }

  /// Example 3: Call when user returns from email verification
  static Future<void> handleReturnFromEmailVerification(BuildContext context) async {
    LoggerService.info('User returned from email verification, force checking...');
    
    // Force check with success message
    final bool isNowVerified = await EmailVerificationService.forceCheckEmailVerification(
      context: context,
      showSuccessMessage: true,
    );
    
    if (isNowVerified) {
      // Navigate to main app or update UI
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  /// Example 4: Using extensions for cleaner code
  static Future<void> handleWithExtensions(BuildContext context) async {
    // Using context extension
    await context.updateEmailVerification(showSuccessMessage: true);
    
    // Using user extension
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateEmailVerificationInFirestore(
        context: context,
        showSuccessMessage: true,
      );
    }
  }

  /// Example 5: Using the stream for real-time updates
  static StreamBuilder<bool> buildEmailVerificationListener() {
    return StreamBuilder<bool>(
      stream: EmailVerificationService.emailVerificationStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        
        final bool isVerified = snapshot.data ?? false;
        
        if (isVerified) {
          return const Column(
            children: [
              Icon(Icons.verified, color: Colors.green, size: 50),
              Text('Email Verified ✓', style: TextStyle(color: Colors.green)),
            ],
          );
        } else {
          return Column(
            children: [
              const Icon(Icons.mark_email_unread, color: Colors.orange, size: 50),
              const Text('Email Not Verified', style: TextStyle(color: Colors.orange)),
              ElevatedButton(
                onPressed: () => _resendVerificationEmail(context),
                child: const Text('Resend Verification'),
              ),
            ],
          );
        }
      },
    );
  }

  /// Example 6: Check verification status for UI decisions
  static Future<Widget> buildConditionalContent() async {
    final bool isVerified = await EmailVerificationService.isEmailVerified();
    
    if (isVerified) {
      return const Text('Welcome! Your email is verified.');
    } else {
      return const Text('Please verify your email to continue.');
    }
  }

  /// Helper method to resend verification email
  static Future<void> _resendVerificationEmail(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Check your inbox.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending verification email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Example Widget: Email Verification Screen
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Please verify your email address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a verification link to ${FirebaseAuth.instance.currentUser?.email}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Check verification button
            ElevatedButton(
              onPressed: _isChecking ? null : _checkVerification,
              child: _isChecking 
                ? const CircularProgressIndicator()
                : const Text('I\'ve verified my email'),
            ),
            
            const SizedBox(height: 10),
            
            // Resend email button
            TextButton(
              onPressed: _resendVerificationEmail,
              child: const Text('Resend verification email'),
            ),
            
            const SizedBox(height: 20),
            
            // Real-time verification status
            EmailVerificationUsageExamples.buildEmailVerificationListener(),
          ],
        ),
      ),
    );
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    try {
      // Force check email verification
      final bool isVerified = await context.forceCheckEmailVerification(
        showSuccessMessage: true,
      );

      if (isVerified) {
        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not yet verified. Please check your inbox.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Check your inbox.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}