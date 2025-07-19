import 'package:flutter/material.dart';
import 'app_localizations.dart';

class ValidationHelper {
  // التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  // التحقق من صحة كلمة المرور
  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]'));
  }

  // التحقق من صحة رقم الهاتف الأردني
  static bool isValidPhoneNumber(String phone) {
    String cleanPhone = phone.trim().replaceAll(' ', '').replaceAll('-', '');

    if (cleanPhone.startsWith('+962')) {
      cleanPhone = cleanPhone.substring(4);
    } else if (cleanPhone.startsWith('00962')) {
      cleanPhone = cleanPhone.substring(5);
    } else if (cleanPhone.startsWith('962')) {
      cleanPhone = cleanPhone.substring(3);
    } else if (cleanPhone.startsWith('07')) {
      cleanPhone = cleanPhone.substring(1);
    }

    final jordanianPhoneRegex = RegExp(r'^7[789]\d{7}$');
    return jordanianPhoneRegex.hasMatch(cleanPhone);
  }

  // التحقق من البريد الإلكتروني مع رسالة خطأ
  static String? validateEmail(String email, [BuildContext? context]) {
    if (email.trim().isEmpty) {
      return context?.l10n.fieldRequired ?? 'البريد الإلكتروني مطلوب';
    }

    if (!isValidEmail(email)) {
      return context?.l10n.invalidEmail ?? 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  // التحقق من كلمة المرور مع رسالة خطأ
  static String? validatePassword(String password, [BuildContext? context]) {
    if (password.isEmpty) {
      return context?.l10n.passwordRequired ?? 'كلمة المرور مطلوبة';
    }

    if (password.length < 8) {
      return context?.l10n.passwordMinLength ??
          'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return context?.l10n.passwordNeedsUppercase ??
          'يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return context?.l10n.passwordNeedsLowercase ??
          'يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return context?.l10n.passwordNeedsNumber ??
          'يجب أن تحتوي على رقم واحد على الأقل';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]'))) {
      return context?.l10n.passwordNeedsSpecialChar ??
          'يجب أن تحتوي على رمز خاص واحد على الأقل';
    }

    return null;
  }

  // التحقق من رقم الهاتف مع رسالة خطأ
  static String? validatePhoneNumber(String phone, [BuildContext? context]) {
    if (phone.trim().isEmpty) {
      return context?.l10n.fieldRequired ?? 'رقم الهاتف مطلوب';
    }

    if (!isValidPhoneNumber(phone)) {
      return context?.l10n.locale.languageCode == 'ar'
          ? 'رقم الهاتف الأردني غير صحيح'
          : 'Invalid Jordanian phone number';
    }

    return null;
  }

  // التحقق من الاسم
  static String? validateName(String name, [BuildContext? context]) {
    if (name.trim().isEmpty) {
      return context?.l10n.fieldRequired ?? 'الاسم مطلوب';
    }

    if (name.trim().length < 2) {
      return context?.l10n.locale.languageCode == 'ar'
          ? 'الاسم يجب أن يكون حرفين على الأقل'
          : 'Name must be at least 2 characters';
    }

    final nameRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    if (!nameRegex.hasMatch(name.trim())) {
      return context?.l10n.locale.languageCode == 'ar'
          ? 'الاسم يجب أن يحتوي على أحرف عربية أو إنجليزية فقط'
          : 'Name must contain only Arabic or English letters';
    }

    return null;
  }

  // التحقق من تطابق كلمة المرور
  static String? validateConfirmPassword(
    String password,
    String confirmPassword, [
    BuildContext? context,
  ]) {
    if (confirmPassword.isEmpty) {
      return context?.l10n.confirmPasswordRequired ?? 'تأكيد كلمة المرور مطلوب';
    }

    if (password != confirmPassword) {
      return context?.l10n.passwordsDoNotMatch ?? 'كلمات المرور غير متطابقة';
    }

    return null;
  }

  // التحقق من رمز OTP
  static String? validateOTP(String otp, [BuildContext? context]) {
    if (otp.trim().isEmpty) {
      return context?.l10n.otpRequired ?? 'رمز التحقق مطلوب';
    }

    if (otp.trim().length != 6) {
      return context?.l10n.locale.languageCode == 'ar'
          ? 'رمز التحقق يجب أن يكون 6 أرقام'
          : 'Verification code must be 6 digits';
    }

    final otpRegex = RegExp(r'^\d{6}$');
    if (!otpRegex.hasMatch(otp.trim())) {
      return context?.l10n.otpInvalid ?? 'رمز التحقق غير صحيح';
    }

    return null;
  }

  // الحصول على متطلبات كلمة المرور
  static Map<String, bool> getPasswordRequirements(String password) {
    return {
      'minLength': password.length >= 8,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumber': password.contains(RegExp(r'[0-9]')),
      'hasSpecialChar': password.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]')),
    };
  }

  // تنسيق رقم الهاتف الأردني للعرض
  static String formatJordanianPhoneForDisplay(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.startsWith('962')) {
      cleanPhone = cleanPhone.substring(3);
    }

    if (cleanPhone.length == 9 && cleanPhone.startsWith('7')) {
      return '+962 ${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5)}';
    }

    return phone;
  }

  // تنسيق رقم الهاتف للإرسال
  static String formatJordanianPhoneForSending(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanPhone.startsWith('+962')) {
      return cleanPhone;
    } else if (cleanPhone.startsWith('00962')) {
      return '+${cleanPhone.substring(2)}';
    } else if (cleanPhone.startsWith('962')) {
      return '+$cleanPhone';
    } else if (cleanPhone.startsWith('07')) {
      return '+962${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('7')) {
      return '+962$cleanPhone';
    }

    return cleanPhone;
  }
}
