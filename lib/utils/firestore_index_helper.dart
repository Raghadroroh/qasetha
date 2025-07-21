import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper class for Firestore index-related functionality
class FirestoreIndexHelper {
  /// Shows a dialog with instructions to create the required Firestore index
  static void showIndexCreationDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مطلوب إنشاء فهرس'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'يحتاج التطبيق إلى إنشاء فهرس في Firestore لعرض التصنيفات بشكل صحيح.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'يمكنك إنشاء الفهرس بالنقر على الرابط أدناه:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchIndexCreationUrl(errorMessage),
              child: Text(
                'إنشاء فهرس Firestore',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  /// Extracts and launches the index creation URL from a Firestore error message
  static Future<void> _launchIndexCreationUrl(String errorMessage) async {
    // Extract the URL from the error message
    final RegExp urlRegex = RegExp(r'https://console\.firebase\.google\.com/[^\s\)]+');
    final match = urlRegex.firstMatch(errorMessage);
    
    if (match != null) {
      final url = match.group(0)!;
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  /// Checks if an error is a Firestore index error
  static bool isIndexError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('failed-precondition') && 
           errorString.contains('index') &&
           errorString.contains('firebase');
  }
}