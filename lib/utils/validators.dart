

/// مدققات البيانات - جميع عمليات التحقق مركزة هنا
import '../constants/app_strings.dart';

class Validators {
  /// تحقق من الاسم الكامل
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    
    if (value.trim().length < 2) {
      return AppStrings.nameMinLength;
    }
    
    // التحقق من وجود أحرف عربية أو إنجليزية فقط
    final nameRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'الاسم يجب أن يحتوي على أحرف عربية أو إنجليزية فقط';
    }
    
    return null;
  }
  
  /// تحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired;
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.emailInvalid;
    }
    
    return null;
  }
  
  /// تحقق من رقم الهاتف
  static String? validatePhone(String? value) {
    return validateJordanianPhone(value);
  }

  /// تحقق من رقم الهاتف الأردني
  static String? validateJordanianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.phoneRequired;
    }
    
    String phone = value.trim().replaceAll(' ', '').replaceAll('-', '');
    
    // إزالة الرمز الدولي إذا كان موجوداً
    if (phone.startsWith('+962')) {
      phone = phone.substring(4);
    } else if (phone.startsWith('00962')) {
      phone = phone.substring(5);
    } else if (phone.startsWith('962')) {
      phone = phone.substring(3);
    }
    
    // التحقق من صيغة الرقم الأردني
    final jordanianPhoneRegex = RegExp(r'^7[789]\d{7}$');
    
    if (!jordanianPhoneRegex.hasMatch(phone)) {
      return AppStrings.phoneInvalid;
    }
    
    return null;
  }
  
  /// تحقق من كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (value.length < 8) {
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
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'يجب أن تحتوي على رمز خاص واحد على الأقل';
    }
    
    return null;
  }
  
  /// تحقق من تطابق كلمة المرور
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    
    if (value != password) {
      return AppStrings.passwordMismatch;
    }
    
    return null;
  }
  
  /// تحقق من رمز OTP
  static String? validateOTP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.otpRequired;
    }
    
    if (value.trim().length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }
    
    final otpRegex = RegExp(r'^\d{6}$');
    if (!otpRegex.hasMatch(value.trim())) {
      return AppStrings.otpInvalid;
    }
    
    return null;
  }
  
  /// تنسيق رقم الهاتف الأردني للعرض
  static String formatJordanianPhone(String phone) {
    String cleanPhone = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    
    // إزالة الرمز الدولي إذا كان موجوداً
    if (cleanPhone.startsWith('+962')) {
      cleanPhone = cleanPhone.substring(4);
    } else if (cleanPhone.startsWith('00962')) {
      cleanPhone = cleanPhone.substring(5);
    } else if (cleanPhone.startsWith('962')) {
      cleanPhone = cleanPhone.substring(3);
    }
    
    // تنسيق الرقم: 07X XXX XXXX
    if (cleanPhone.length == 9 && cleanPhone.startsWith('7')) {
      return '0${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5)}';
    }
    
    return phone; // إرجاع الرقم كما هو إذا لم يكن بالصيغة الصحيحة
  }
  
  /// تحويل رقم الهاتف الأردني للصيغة الدولية
  static String formatJordanianPhoneInternational(String phone) {
    String cleanPhone = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    
    // إزالة الرمز الدولي إذا كان موجوداً
    if (cleanPhone.startsWith('+962')) {
      return cleanPhone;
    } else if (cleanPhone.startsWith('00962')) {
      return '+${cleanPhone.substring(2)}';
    } else if (cleanPhone.startsWith('962')) {
      return '+$cleanPhone';
    } else if (cleanPhone.startsWith('07')) {
      return '+962${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('7') && cleanPhone.length == 9) {
      return '+962$cleanPhone';
    }
    
    return phone;
  }
  
  /// التحقق من قوة كلمة المرور (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }
  
  /// الحصول على وصف قوة كلمة المرور
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'ضعيفة جداً';
      case 2:
        return 'ضعيفة';
      case 3:
        return 'متوسطة';
      case 4:
        return 'قوية';
      case 5:
        return 'قوية جداً';
      default:
        return 'غير محددة';
    }
  }
}