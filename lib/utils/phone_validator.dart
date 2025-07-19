import 'constants.dart';

class PhoneValidator {
  /// Format Jordanian phone number to international format
  static String formatJordanianPhone(String phone) {
    // Remove all non-digit characters except +
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Handle different input formats
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

    return cleanPhone;
  }

  /// Validate if phone number is a valid Jordanian mobile number
  static bool isValidJordanianPhone(String phone) {
    String formatted = formatJordanianPhone(phone);

    // Must start with +962
    if (!formatted.startsWith(AuthConstants.jordanCountryCode)) {
      return false;
    }

    // Extract the mobile part (after +962)
    String mobilePart = formatted.substring(4);

    // Must be exactly 9 digits
    if (mobilePart.length != 9) {
      return false;
    }

    // Must start with valid prefix (77, 78, or 79)
    String prefix = mobilePart.substring(0, 2);
    if (!AuthConstants.validJordanPrefixes.contains(prefix)) {
      return false;
    }

    // Must be all digits
    return RegExp(r'^\d{9}$').hasMatch(mobilePart);
  }

  /// Get validation error message for phone number
  static String? getPhoneValidationError(String phone, bool isArabic) {
    if (phone.trim().isEmpty) {
      return isArabic ? 'رقم الهاتف مطلوب' : 'Phone number is required';
    }

    String formatted = formatJordanianPhone(phone);

    if (!formatted.startsWith(AuthConstants.jordanCountryCode)) {
      return isArabic
          ? AuthConstants.phoneValidationAr['not_jordanian']
          : AuthConstants.phoneValidationEn['not_jordanian'];
    }

    String mobilePart = formatted.substring(4);

    if (mobilePart.length != 9) {
      return isArabic
          ? AuthConstants.phoneValidationAr['invalid_format']
          : AuthConstants.phoneValidationEn['invalid_format'];
    }

    String prefix = mobilePart.substring(0, 2);
    if (!AuthConstants.validJordanPrefixes.contains(prefix)) {
      return isArabic
          ? AuthConstants.phoneValidationAr['invalid_prefix']
          : AuthConstants.phoneValidationEn['invalid_prefix'];
    }

    if (!RegExp(r'^\d{9}$').hasMatch(mobilePart)) {
      return isArabic
          ? AuthConstants.phoneValidationAr['invalid_format']
          : AuthConstants.phoneValidationEn['invalid_format'];
    }

    return null; // Valid
  }

  /// Format phone number for display (with spaces)
  static String formatForDisplay(String phone) {
    String formatted = formatJordanianPhone(phone);
    if (formatted.startsWith('+962') && formatted.length == 13) {
      // +962 7X XXX XXXX
      return '+962 ${formatted.substring(4, 6)} ${formatted.substring(6, 9)} ${formatted.substring(9)}';
    }
    return formatted;
  }

  /// Extract country code and mobile number separately
  static Map<String, String> parsePhoneNumber(String phone) {
    String formatted = formatJordanianPhone(phone);
    if (formatted.startsWith('+962')) {
      return {
        'countryCode': '+962',
        'mobileNumber': formatted.substring(4),
        'displayFormat': formatForDisplay(formatted),
      };
    }
    return {'countryCode': '', 'mobileNumber': phone, 'displayFormat': phone};
  }
}
