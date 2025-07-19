import 'package:flutter/material.dart';
import 'phone_validator.dart';
import 'constants.dart';

class Validators {
  /// تحقق من الاسم الكامل
  static String? validateName(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }

    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    final nameRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'الاسم يجب أن يحتوي على أحرف عربية أو إنجليزية فقط';
    }

    return null;
  }

  /// تحقق من البريد الإلكتروني
  static String? validateEmail(String? value, [BuildContext? context]) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// تحقق من رقم الهاتف الأردني
  static String? validatePhone(String? value, [BuildContext? context]) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    bool isArabic = true;
    String? error = PhoneValidator.getPhoneValidationError(
      value.trim(),
      isArabic,
    );
    return error;
  }

  /// تحقق من رقم الهاتف الأردني (نسخة محسنة)
  static String? validateJordanianPhone(
    String? value, [
    BuildContext? context,
  ]) {
    return validatePhone(value, context);
  }

  /// تحقق من كلمة المرور
  static String? validatePassword(String? value, [BuildContext? context]) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < AuthConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'يجب أن تحتوي على رقم واحد على الأقل';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]'))) {
      return 'يجب أن تحتوي على رمز خاص واحد على الأقل';
    }

    return null;
  }

  /// فحص متطلبات كلمة المرور
  static Map<String, bool> checkPasswordRequirements(String password) {
    return {
      'minLength': password.length >= AuthConstants.minPasswordLength,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumber': password.contains(RegExp(r'[0-9]')),
      'hasSpecialChar': password.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]')),
    };
  }

  /// تحقق من تطابق كلمة المرور
  static String? validateConfirmPassword(
    String? value,
    String? password, [
    BuildContext? context,
  ]) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }

    return null;
  }

  /// تحقق من رمز OTP
  static String? validateOTP(String? value, [BuildContext? context]) {
    if (value == null || value.trim().isEmpty) {
      return 'رمز التحقق مطلوب';
    }

    if (value.trim().length != AuthConstants.otpLength) {
      return 'رمز التحقق يجب أن يكون ${AuthConstants.otpLength} أرقام';
    }

    final otpRegex = RegExp(r'^\d{6}$');
    if (!otpRegex.hasMatch(value.trim())) {
      return 'رمز التحقق غير صحيح';
    }

    return null;
  }
}
