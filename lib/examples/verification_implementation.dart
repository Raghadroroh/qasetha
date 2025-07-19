import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/verification_checker.dart';
import '../services/logger_service.dart';

/// Best practices for implementing email verification checks in a real Flutter app
class VerificationImplementation {

  // =============================================================================
  // BEST PLACES TO CALL THE VERIFICATION FUNCTION
  // =============================================================================

  /// 1. AFTER LOGIN - Call immediately after successful login
  static Future<void> handlePostLogin(BuildContext context) async {
    LoggerService.info('✅ POST-LOGIN: Checking email verification...');
    
    final bool wasUpdated = await VerificationChecker.checkAndUpdateEmailVerification(
      context: context,
      showSnackBar: true,
    );
    
    if (wasUpdated) {
      LoggerService.info('✅ Email verified and Firestore updated');
      // Navigate to main app
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      LoggerService.info('❌ Email not verified, staying on verification screen');
      // Navigate to verification screen
      Navigator.of(context).pushReplacementNamed('/verify-email');
    }
  }

  /// 2. FROM "CHECK VERIFICATION" BUTTON - Manual check by user
  static Future<void> handleManualCheck(BuildContext context) async {
    LoggerService.info('🔄 MANUAL CHECK: User clicked verification button...');
    
    final bool wasUpdated = await VerificationChecker.checkAndUpdateEmailVerification(
      context: context,
      showSnackBar: true,
    );
    
    if (wasUpdated) {
      LoggerService.info('✅ Verification successful!');
      // Navigate to main app
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
    // If not verified, snackbar will inform user
  }

  /// 3. ON APP RESUME - When app comes back from background
  static Future<void> handleAppResume(BuildContext context) async {
    LoggerService.info('📱 APP RESUME: Checking verification status...');
    
    // Silent check without snackbar (user might have verified in email app)
    final bool wasUpdated = await VerificationChecker.checkAndUpdateEmailVerification(
      context: context,
      showSnackBar: false,
    );
    
    if (wasUpdated) {
      LoggerService.info('✅ Email verified while app was in background');
      // Could trigger a state update or navigation
    }
  }

  /// 4. PERIODIC CHECK - For real-time verification screen
  static Future<bool> handlePeriodicCheck() async {
    LoggerService.info('⏰ PERIODIC CHECK: Checking verification status...');
    
    // Silent check for periodic updates
    return await VerificationChecker.checkAndUpdateEmailVerification(
      showSnackBar: false,
    );
  }
}

// =============================================================================
// EXAMPLE WIDGETS SHOWING REAL USAGE
// =============================================================================

/// Example 1: Login Screen Integration
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      // Step 1: Firebase Auth login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Step 2: Check email verification immediately after login
      if (mounted) {
        await VerificationImplementation.handlePostLogin(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// Example 2: Email Verification Screen with Manual Check Button
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> 
    with WidgetsBindingObserver {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when app resumes from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check verification when user returns from email app
      VerificationImplementation.handleAppResume(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        automaticallyImplyLeading: false,
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
              'Verify Your Email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a verification link to:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 5),
            Text(
              user?.email ?? 'your email',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            
            // MAIN VERIFICATION CHECK BUTTON
            SizedBox(
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
                  : const Text(
                      'I\'ve Verified My Email',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Resend email button
            TextButton(
              onPressed: _resendVerificationEmail,
              child: const Text('Resend verification email'),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'After clicking the link in your email, come back and click "I\'ve Verified My Email"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// This is the main function call - triggered by user button
  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    try {
      // CALL THE VERIFICATION FUNCTION
      await VerificationImplementation.handleManualCheck(context);
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email sent!'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Example 3: Main App Screen with Auto-Check on Build
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {

  @override
  void initState() {
    super.initState();
    // Silent check when main app loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _silentVerificationCheck();
    });
  }

  Future<void> _silentVerificationCheck() async {
    // Silent check without UI feedback
    await VerificationChecker.checkAndUpdateEmailVerification(
      showSnackBar: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main App')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 100),
            Text('Welcome to the App!'),
          ],
        ),
      ),
    );
  }
}

/// Example 4: Advanced - Periodic Check for Real-time Updates
class RealTimeVerificationWidget extends StatefulWidget {
  const RealTimeVerificationWidget({super.key});

  @override
  State<RealTimeVerificationWidget> createState() => _RealTimeVerificationWidgetState();
}

class _RealTimeVerificationWidgetState extends State<RealTimeVerificationWidget> {
  bool _isVerified = false;
  
  @override
  void initState() {
    super.initState();
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    // Check every 5 seconds for demo (in production, maybe every 30 seconds)
    Stream.periodic(const Duration(seconds: 5)).listen((_) async {
      if (mounted) {
        final wasUpdated = await VerificationImplementation.handlePeriodicCheck();
        if (wasUpdated && mounted) {
          setState(() => _isVerified = true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            _isVerified ? Icons.verified : Icons.pending,
            color: _isVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(_isVerified ? 'Verified' : 'Pending'),
        ],
      ),
    );
  }
}