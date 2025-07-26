import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_storage_service.dart';
import 'logger_service.dart';

class ProfileImageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorageService _storageService = FirebaseStorageService();

  /// Upload profile image with comprehensive error handling and debugging
  static Future<String> uploadProfileImage(
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.uid;
      LoggerService.info('Starting profile image upload for user: $userId');

      // Check if user is anonymous (guest)
      if (currentUser.isAnonymous) {
        throw Exception('Profile photos are not available for guest users');
      }

      // Upload image to Firebase Storage
      LoggerService.info('Uploading image to Firebase Storage...');
      final imageUrl = await _storageService.uploadProfileImage(
        userId,
        imageFile,
        onProgress: onProgress,
      );

      LoggerService.info('Profile image uploaded successfully: $imageUrl');
      
      // Update the profile image URL in Firestore separately for better error handling
      await updateProfileImageUrl(userId, imageUrl);
      
      return imageUrl;

    } catch (e) {
      LoggerService.error('Profile image upload failed: $e');
      rethrow;
    }
  }

  /// Update user profile image URL with detailed error handling
  static Future<void> updateProfileImageUrl(String userId, String imageUrl) async {
    try {
      LoggerService.info('Updating profile image URL for user: $userId');

      // Check current user authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw Exception('Authentication mismatch');
      }

      // Try to get current user document to understand its structure
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        LoggerService.info('User document exists, updating profileImage field');
        final userData = userDoc.data() as Map<String, dynamic>;
        LoggerService.info('Current user data keys: ${userData.keys.toList()}');
        
        // Update existing document
        await _firestore.collection('users').doc(userId).update({
          'profileImage': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        LoggerService.info('Successfully updated profileImage in existing user document');
      } else {
        LoggerService.info('User document does not exist, creating with profileImage');
        
        // Create new document with minimal required fields
        await _firestore.collection('users').doc(userId).set({
          'id': userId,
          'email': currentUser.email ?? '',
          'name': currentUser.displayName ?? '',
          'profileImage': imageUrl,
          'emailVerified': currentUser.emailVerified,
          'phoneVerified': currentUser.phoneNumber != null,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        LoggerService.info('Successfully created new user document with profileImage');
      }

    } catch (e) {
      LoggerService.error('Failed to update profile image URL: $e');
      
      // Provide more specific error information
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied: You do not have permission to update your profile image. Please check your account status.');
      } else if (e.toString().contains('not-found')) {
        throw Exception('User document not found. Please try logging out and logging back in.');
      } else {
        throw Exception('Failed to save profile image: ${e.toString()}');
      }
    }
  }

  /// Delete profile image with proper cleanup
  static Future<void> deleteProfileImage(String userId) async {
    try {
      LoggerService.info('Deleting profile image for user: $userId');

      // Get current profile image URL
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final currentImageUrl = userData['profileImage'] as String?;
        
        if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
          // Delete from Firebase Storage
          await _storageService.deleteProfileImage(currentImageUrl);
          LoggerService.info('Deleted image from Firebase Storage');
        }

        // Update Firestore document
        await _firestore.collection('users').doc(userId).update({
          'profileImage': '',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        LoggerService.info('Successfully removed profileImage from user document');
      }

    } catch (e) {
      LoggerService.error('Failed to delete profile image: $e');
      rethrow;
    }
  }

  /// Get current user's profile image URL
  static Future<String?> getCurrentProfileImageUrl() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['profileImage'] as String?;
      }

      return null;
    } catch (e) {
      LoggerService.error('Failed to get current profile image URL: $e');
      return null;
    }
  }
}