import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/logger_service.dart';

class PhotoPermissionService {
  static final ImagePicker _picker = ImagePicker();

  /// رفع صورة من الكاميرا مع طلب الصلاحية تلقائياً
  static Future<File?> pickFromCamera(BuildContext context) async {
    try {
      LoggerService.info('محاولة الوصول للكاميرا');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        LoggerService.info('تم اختيار صورة من الكاميرا بنجاح');
        return File(image.path);
      } else {
        LoggerService.info('لم يتم اختيار صورة من الكاميرا');
        return null;
      }
    } catch (e) {
      LoggerService.error('خطأ في الوصول للكاميرا: $e');
      if (context.mounted) {
        _showPermissionError(context, 'الكاميرا', 'التقاط الصور');
      }
      return null;
    }
  }

  /// رفع صورة من الاستوديو مع طلب الصلاحية تلقائياً
  static Future<File?> pickFromGallery(BuildContext context) async {
    try {
      LoggerService.info('محاولة الوصول لمكتبة الصور');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        LoggerService.info('تم اختيار صورة من المكتبة بنجاح');
        return File(image.path);
      } else {
        LoggerService.info('لم يتم اختيار صورة من المكتبة');
        return null;
      }
    } catch (e) {
      LoggerService.error('خطأ في الوصول لمكتبة الصور: $e');
      if (context.mounted) {
        _showPermissionError(context, 'مكتبة الصور', 'اختيار الصور');
      }
      return null;
    }
  }

  /// عرض رسالة خطأ بسيطة عند رفض الصلاحية
  static void _showPermissionError(BuildContext context, String source, String action) {
    if (!context.mounted) return;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'صلاحية مطلوبة',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'نحتاج إلى صلاحية الوصول إلى $source لتتمكن من $action.\n\nيمكنك تفعيل الصلاحية من إعدادات الجهاز.',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'حسناً',
              style: TextStyle(
                color: Color(0xFF667eea),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}