import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Production-ready service for checking and updating email verification status
class VerificationChecker {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Checks email verification and updates Firestore if verified
  /// 
  /// Returns:
  /// - true: If email was verified and Firestore was updated successfully
  /// - false: If email is not verified, user is null, or update failed
  /// 
  /// Usage:
  /// ```dart
  /// final wasUpdated = await VerificationChecker.checkAndUpdateEmailVerification();
  /// if (wasUpdated) {
  ///   print('Email verified and Firestore updated!');
  /// }
  /// ```
  static Future<bool> checkAndUpdateEmailVerification({
    BuildContext? context,
    bool showSnackBar = false,
  }) async {
    try {
      // Step 1: Get current user
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _logError('No user is currently signed in');
        if (context != null && showSnackBar) {
          _showErrorSnackBar(context, 'No user signed in');
        }
        return false;
      }

      _logInfo('Checking email verification for user: ${currentUser.uid}');

      // Step 2: Reload user to get latest verification status
      await currentUser.reload();
      
      // Get the refreshed user instance
      final User? refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        _logError('User became null after reload');
        if (context != null && showSnackBar) {
          _showErrorSnackBar(context, 'Authentication error occurred');
        }
        return false;
      }

      // Step 3: Check if email is verified
      final bool isEmailVerified = refreshedUser.emailVerified;
      _logInfo('Email verification status: $isEmailVerified');

      if (!isEmailVerified) {
        _logInfo('Email is not yet verified');
        if (context != null && showSnackBar) {
          _showWarningSnackBar(context, 'Email not yet verified. Please check your inbox.');
        }
        return false;
      }

      // Step 4: Update Firestore document
      _logInfo('Email is verified, updating Firestore...');
      
      await _firestore.collection('users').doc(refreshedUser.uid).update({
        'emailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logInfo('Successfully updated emailVerified field in Firestore');
      
      if (context != null && showSnackBar) {
        _showSuccessSnackBar(context, 'Email verification confirmed!');
      }

      return true;

    } on FirebaseAuthException catch (e) {
      _logError('Firebase Auth error: ${e.code} - ${e.message}');
      if (context != null && showSnackBar) {
        _showErrorSnackBar(context, 'Authentication error: ${_getAuthErrorMessage(e.code)}');
      }
      return false;
    } on FirebaseException catch (e) {
      _logError('Firestore error: ${e.code} - ${e.message}');
      if (context != null && showSnackBar) {
        _showErrorSnackBar(context, 'Database update failed: ${e.message}');
      }
      return false;
    } catch (e) {
      _logError('Unexpected error: $e');
      if (context != null && showSnackBar) {
        _showErrorSnackBar(context, 'An unexpected error occurred');
      }
      return false;
    }
  }

  /// Quick check without Firestore update - useful for UI state
  static Future<bool> isEmailVerified() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await currentUser.reload();
      final User? refreshedUser = _auth.currentUser;
      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      _logError('Error checking verification status: $e');
      return false;
    }
  }

  /// Helper method to show success snackbar
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Helper method to show warning snackbar
  static void _showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Helper method to show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Get user-friendly error messages for Firebase Auth errors
  static String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'User account not found.';
      case 'requires-recent-login':
        return 'Please log in again to continue.';
      default:
        return 'Authentication error occurred.';
    }
  }

  /// Log info messages with consistent formatting
  static void _logInfo(String message) {
    debugPrint('[VerificationChecker] INFO: $message');
  }

  /// Log error messages with consistent formatting
  static void _logError(String message) {
    debugPrint('[VerificationChecker] ERROR: $message');
  }
}