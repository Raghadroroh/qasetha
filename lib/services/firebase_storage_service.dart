import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final String fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final Reference storageRef = _storage.ref().child(
        'profile_images/$fileName',
      );

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
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
