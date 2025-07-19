import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/email_verification_service.dart';

/// Extension methods for Firebase Auth User to make email verification easier
extension UserEmailVerification on User {
  /// Updates email verification status in Firestore for this user
  Future<bool> updateEmailVerificationInFirestore({
    BuildContext? context,
    bool showSuccessMessage = false,
    bool showErrorMessage = true,
  }) async {
    return await EmailVerificationService.updateEmailVerificationStatus(
      context: context,
      showSuccessMessage: showSuccessMessage,
      showErrorMessage: showErrorMessage,
    );
  }

  /// Forces a check and update of email verification status for this user
  Future<bool> forceCheckEmailVerification({
    BuildContext? context,
    bool showSuccessMessage = true,
  }) async {
    return await EmailVerificationService.forceCheckEmailVerification(
      context: context,
      showSuccessMessage: showSuccessMessage,
    );
  }
}

/// Extension methods for BuildContext to make email verification even easier
extension ContextEmailVerification on BuildContext {
  /// Quick method to update email verification from any widget
  Future<bool> updateEmailVerification({
    bool showSuccessMessage = false,
    bool showErrorMessage = true,
  }) async {
    return await EmailVerificationService.updateEmailVerificationStatus(
      context: this,
      showSuccessMessage: showSuccessMessage,
      showErrorMessage: showErrorMessage,
    );
  }

  /// Quick method to force check email verification from any widget
  Future<bool> forceCheckEmailVerification({
    bool showSuccessMessage = true,
  }) async {
    return await EmailVerificationService.forceCheckEmailVerification(
      context: this,
      showSuccessMessage: showSuccessMessage,
    );
  }
}