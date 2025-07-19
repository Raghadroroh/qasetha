import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Service for handling email verification status updates
class EmailVerificationService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  /// Updates the emailVerified field in Firestore after user confirms email
  /// 
  /// This function should be called:
  /// - Right after login
  /// - On app launch
  /// - When returning from email verification
  /// 
  /// Returns true if verification status was updated, false otherwise
  static Future<bool> updateEmailVerificationStatus({
    BuildContext? context,
    bool showSuccessMessage = false,
    bool showErrorMessage = true,
  }) async {
    try {
      // Check if user is logged in
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _logError('No user is currently logged in');
        return false;
      }

      _logInfo('Checking email verification status for user: ${currentUser.uid}');

      // Reload user data to get the latest verification status
      await currentUser.reload();
      
      // Get the refreshed user data
      final User? refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        _logError('User became null after reload');
        return false;
      }

      final bool isEmailVerified = refreshedUser.emailVerified;
      _logInfo('Current email verification status: $isEmailVerified');

      // Get the current Firestore document
      final DocumentSnapshot userDoc = await _firestore
          .collection(_usersCollection)
          .doc(refreshedUser.uid)
          .get();

      if (!userDoc.exists) {
        _logError('User document does not exist in Firestore');
        if (context != null && showErrorMessage) {
          _showSnackBar(
            context,
            'User profile not found. Please contact support.',
            isError: true,
          );
        }
        return false;
      }

      // Get current emailVerified status from Firestore
      final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      final bool firestoreEmailVerified = userData['emailVerified'] ?? false;

      // Only update if there's a difference
      if (isEmailVerified != firestoreEmailVerified) {
        _logInfo('Updating emailVerified status in Firestore from $firestoreEmailVerified to $isEmailVerified');

        // Update the emailVerified field in Firestore
        await _firestore.collection(_usersCollection).doc(refreshedUser.uid).update({
          'emailVerified': isEmailVerified,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _logInfo('Successfully updated emailVerified status in Firestore');

        // Show success message if requested
        if (context != null && showSuccessMessage && isEmailVerified) {
          _showSnackBar(
            context,
            'Email verification confirmed successfully!',
            isError: false,
          );
        }

        return true;
      } else {
        _logInfo('Email verification status is already up to date');
        return false;
      }

    } on FirebaseAuthException catch (e) {
      _logError('Firebase Auth error: ${e.code} - ${e.message}');
      if (context != null && showErrorMessage) {
        _showSnackBar(
          context,
          'Authentication error: ${_getReadableAuthError(e.code)}',
          isError: true,
        );
      }
      return false;
    } on FirebaseException catch (e) {
      _logError('Firestore error: ${e.code} - ${e.message}');
      if (context != null && showErrorMessage) {
        _showSnackBar(
          context,
          'Database error: ${e.message}',
          isError: true,
        );
      }
      return false;
    } catch (e) {
      _logError('Unexpected error: $e');
      if (context != null && showErrorMessage) {
        _showSnackBar(
          context,
          'An unexpected error occurred. Please try again.',
          isError: true,
        );
      }
      return false;
    }
  }

  /// Checks if the current user's email is verified without updating Firestore
  /// Useful for UI state management
  static Future<bool> isEmailVerified() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await currentUser.reload();
      final User? refreshedUser = _auth.currentUser;
      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      _logError('Error checking email verification: $e');
      return false;
    }
  }

  /// Forces a check and update of email verification status
  /// Useful when user returns from email verification
  static Future<bool> forceCheckEmailVerification({
    BuildContext? context,
    bool showSuccessMessage = true,
  }) async {
    _logInfo('Force checking email verification status');
    return await updateEmailVerificationStatus(
      context: context,
      showSuccessMessage: showSuccessMessage,
      showErrorMessage: true,
    );
  }

  /// Stream that listens to auth state changes and automatically updates verification status
  /// Useful for real-time updates
  static Stream<bool> emailVerificationStream() {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return false;
      
      try {
        await user.reload();
        final refreshedUser = _auth.currentUser;
        final isVerified = refreshedUser?.emailVerified ?? false;
        
        // Update Firestore in the background
        if (isVerified) {
          updateEmailVerificationStatus(showSuccessMessage: false, showErrorMessage: false);
        }
        
        return isVerified;
      } catch (e) {
        _logError('Error in email verification stream: $e');
        return false;
      }
    });
  }

  /// Helper method to show snackbar messages
  static void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  /// Helper method to get readable error messages
  static String _getReadableAuthError(String errorCode) {
    switch (errorCode) {
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'User account not found.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'An authentication error occurred.';
    }
  }

  /// Helper method for logging info messages
  static void _logInfo(String message) {
    print('[EmailVerificationService] INFO: $message');
  }

  /// Helper method for logging error messages
  static void _logError(String message) {
    print('[EmailVerificationService] ERROR: $message');
  }
}