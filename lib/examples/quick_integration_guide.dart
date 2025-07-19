import 'package:flutter/material.dart';
import '../services/verification_checker.dart';
import '../services/logger_service.dart';

/// QUICK INTEGRATION GUIDE
/// Copy and paste these code snippets into your existing app

class QuickIntegrationGuide {
  
  // =============================================================================
  // 🎯 MOST COMMON USE CASE: "Check Verification" Button
  // =============================================================================
  
  /// Just add this to any button's onPressed in your verification screen
  static Future<void> checkVerificationButtonPressed(BuildContext context) async {
    // This is ALL you need to call!
    final bool wasUpdated = await VerificationChecker.checkAndUpdateEmailVerification(
      context: context,
      showSnackBar: true,
    );
    
    if (wasUpdated) {
      // Email was verified and Firestore updated - navigate to main app
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
    // If not verified, user will see snackbar message automatically
  }

  // =============================================================================
  // 🚀 INTEGRATION EXAMPLES FOR YOUR EXISTING WIDGETS
  // =============================================================================

  /// Example: Add to your existing login success handler
  static Future<void> addToLoginSuccess(BuildContext context) async {
    // After successful FirebaseAuth.signInWithEmailAndPassword:
    
    final bool wasUpdated = await VerificationChecker.checkAndUpdateEmailVerification(
      context: context,
      showSnackBar: true,
    );
    
    if (wasUpdated) {
      // User is verified, go to main app
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // User needs to verify email
      Navigator.pushReplacementNamed(context, '/verify-email');
    }
  }

  /// Example: Add to your existing app initialization
  static Future<void> addToAppInit() async {
    // In your main.dart or app startup:
    
    // Silent check - no UI feedback needed at startup
    await VerificationChecker.checkAndUpdateEmailVerification(
      showSnackBar: false,
    );
  }
}

// =============================================================================
// 📱 READY-TO-USE BUTTON WIDGET
// =============================================================================

/// Drop this widget anywhere in your app for instant verification checking
class VerificationCheckButton extends StatefulWidget {
  final VoidCallback? onVerified;
  final String? buttonText;
  
  const VerificationCheckButton({
    super.key,
    this.onVerified,
    this.buttonText,
  });

  @override
  State<VerificationCheckButton> createState() => _VerificationCheckButtonState();
}

class _VerificationCheckButtonState extends State<VerificationCheckButton> {
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isChecking ? null : _checkVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: _isChecking
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              widget.buttonText ?? 'Check Email Verification',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
      ),
    );
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    try {
      // THE MAIN FUNCTION CALL
      final bool wasUpdated = await VerificationChecker.checkAndUpdateEmailVerification(
        context: context,
        showSnackBar: true,
      );

      if (wasUpdated) {
        // Success! Call the callback if provided
        widget.onVerified?.call();
        
        // Or navigate directly
        if (Navigator.canPop(context)) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }
}

// =============================================================================
// 🔥 SUPER SIMPLE USAGE EXAMPLES
// =============================================================================

/// Example 1: Minimal usage in any screen
class MinimalExample extends StatelessWidget {
  const MinimalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: VerificationCheckButton(
          buttonText: 'I\'ve Verified My Email',
          onVerified: () {
            LoggerService.info('Email verified successfully!');
          },
        ),
      ),
    );
  }
}

/// Example 2: In your existing verification screen
class ExistingScreenExample extends StatelessWidget {
  const ExistingScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Please verify your email address'),
            const SizedBox(height: 20),
            
            // Just add this button to your existing screen!
            VerificationCheckButton(
              buttonText: 'I\'ve Verified My Email',
              onVerified: () {
                // This will be called when verification succeeds
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
            
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Your existing resend email logic
              },
              child: const Text('Resend verification email'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 📋 COPY-PASTE SNIPPETS FOR QUICK INTEGRATION
// =============================================================================

/*

🔥 QUICKEST INTEGRATION - Just add this to any button:

```dart
onPressed: () async {
  final verified = await VerificationChecker.checkAndUpdateEmailVerification(
    context: context,
    showSnackBar: true,
  );
  if (verified) {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
}
```

🚀 FOR LOGIN SUCCESS:

```dart
// After successful login
final verified = await VerificationChecker.checkAndUpdateEmailVerification(
  context: context,
  showSnackBar: true,
);
if (verified) {
  Navigator.pushReplacementNamed(context, '/dashboard');
} else {
  Navigator.pushReplacementNamed(context, '/verify-email');
}
```

⚡ FOR APP STARTUP:

```dart
// In main.dart or app init
await VerificationChecker.checkAndUpdateEmailVerification(showSnackBar: false);
```

🎯 SILENT CHECK (no UI):

```dart
final isVerified = await VerificationChecker.isEmailVerified();
```

*/