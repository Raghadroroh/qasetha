import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'logger_service.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload profile image with validation and optimization
  Future<String> uploadProfileImage(
    String userId, 
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    try {
      // Validate image file
      await _validateImageFile(imageFile);
      
      // Optimize image
      final optimizedImageBytes = await _optimizeImage(imageFile);
      
      // Delete old profile image first
      await _deleteOldProfileImage(userId);
      
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(
        'profiles/$userId/$fileName',
      );

      final UploadTask uploadTask = storageRef.putData(
        optimizedImageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      // Track upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final TaskSnapshot snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();
      
      LoggerService.info('Profile image uploaded successfully for user: $userId');
      return downloadURL;
    } catch (e) {
      LoggerService.error('Failed to upload profile image: $e');
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  // Validate image file
  Future<void> _validateImageFile(File imageFile) async {
    // Check file size (max 5MB)
    final fileSizeInBytes = await imageFile.length();
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    
    if (fileSizeInBytes > maxSizeInBytes) {
      throw Exception('Image size must be less than 5MB');
    }
    
    // Check file extension
    final extension = path.extension(imageFile.path).toLowerCase();
    const allowedExtensions = ['.jpg', '.jpeg', '.png'];
    
    if (!allowedExtensions.contains(extension)) {
      throw Exception('Only JPG, JPEG, and PNG files are allowed');
    }
    
    // Verify it's actually an image by trying to decode it
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Invalid image file');
      }
    } catch (e) {
      throw Exception('Invalid or corrupted image file');
    }
  }
  
  // Optimize image (compress and resize)
  Future<Uint8List> _optimizeImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Resize image if it's too large (max 800x800)
      const maxDimension = 800;
      if (image.width > maxDimension || image.height > maxDimension) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? maxDimension : null,
          height: image.height > image.width ? maxDimension : null,
        );
      }
      
      // Compress as JPEG with 85% quality
      final compressedBytes = img.encodeJpg(image, quality: 85);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      LoggerService.error('Failed to optimize image: $e');
      throw Exception('Failed to optimize image');
    }
  }
  
  // Delete old profile image
  Future<void> _deleteOldProfileImage(String userId) async {
    try {
      // Get current profile image URL from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final oldImageUrl = userData['profileImage'] as String?;
        
        if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
          await deleteProfileImage(oldImageUrl);
        }
      }
    } catch (e) {
      LoggerService.warning('Failed to delete old profile image: $e');
      // Don't throw error, just log warning as this is cleanup
    }
  }
  
  // Update user profile image URL in Firestore
  Future<void> updateUserProfileImage(String userId, String imageUrl) async {
    try {
      // Try to update the main users collection
      try {
        await _firestore.collection('users').doc(userId).update({
          'profileImage': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        LoggerService.info('Updated profileImage in users collection');
      } catch (e) {
        LoggerService.warning('Failed to update users collection, trying set instead: $e');
        
        // If update fails, try to set with merge
        await _firestore.collection('users').doc(userId).set({
          'profileImage': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        LoggerService.info('Set profileImage in users collection with merge');
      }
      
      // Also try to update in userProfiles collection if it exists
      try {
        final profileDoc = _firestore.collection('userProfiles').doc(userId);
        final profileSnapshot = await profileDoc.get();
        
        if (profileSnapshot.exists) {
          await profileDoc.update({
            'profileImage': imageUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          LoggerService.info('Updated profileImage in userProfiles collection');
        }
      } catch (e) {
        LoggerService.warning('Failed to update userProfiles collection (this is okay if it doesn\'t exist): $e');
        // Don't throw error here as userProfiles might not be used
      }
      
    } catch (e) {
      LoggerService.error('Failed to update user profile image in Firestore: $e');
      throw Exception('Failed to update profile image');
    }
  }
  
  // Delete profile image
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
      LoggerService.info('Profile image deleted successfully');
    } catch (e) {
      LoggerService.error('Failed to delete profile image: $e');
      throw Exception('Failed to delete profile image: ${e.toString()}');
    }
  }

  // Upload document
  Future<String> uploadDocument(
    String userId,
    File documentFile,
    String documentType,
  ) async {
    try {
      final String fileName =
          '${documentType}_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(documentFile.path)}';
      final Reference storageRef = _storage.ref().child(
        'documents/$userId/$fileName',
      );

      final UploadTask uploadTask = storageRef.putFile(documentFile);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(documentUrl);
      await storageRef.delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // Get download URL
  Future<String> getDownloadURL(String filePath) async {
    try {
      final Reference storageRef = _storage.ref().child(filePath);
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  // Upload with progress tracking
  Future<String> uploadFileWithProgress(
    String userId,
    File file,
    String folder,
    Function(double progress) onProgress,
  ) async {
    try {
      final String fileName =
          '${folder}_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final Reference storageRef = _storage.ref().child('$folder/$fileName');

      final UploadTask uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file with progress: $e');
    }
  }

  // List files in directory
  Future<List<String>> listFiles(String directory) async {
    try {
      final Reference storageRef = _storage.ref().child(directory);
      final ListResult result = await storageRef.listAll();

      List<String> urls = [];
      for (Reference ref in result.items) {
        urls.add(await ref.getDownloadURL());
      }

      return urls;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(fileUrl);
      return await storageRef.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  // Update file metadata
  Future<void> updateFileMetadata(
    String fileUrl,
    Map<String, String> customMetadata,
  ) async {
    try {
      final Reference storageRef = _storage.refFromURL(fileUrl);
      final SettableMetadata metadata = SettableMetadata(
        customMetadata: customMetadata,
      );
      await storageRef.updateMetadata(metadata);
    } catch (e) {
      throw Exception('Failed to update file metadata: $e');
    }
  }
}
