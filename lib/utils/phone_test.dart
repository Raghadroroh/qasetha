// Test file for Jordan phone number validation
// Run this to verify phone validation works correctly

import 'phone_validator.dart';

void main() {
  print('🇯🇴 Jordan Phone Number Validation Test\n');

  List<Map<String, dynamic>> testCases = [
    // Valid formats
    {
      'phone': '+962791234567',
      'expected': true,
      'description': 'International format',
    },
    {
      'phone': '0791234567',
      'expected': true,
      'description': 'Local format with 0',
    },
    {
      'phone': '791234567',
      'expected': true,
      'description': 'Without leading 0',
    },
    {
      'phone': '962791234567',
      'expected': true,
      'description': 'Country code without +',
    },
    {
      'phone': '00962791234567',
      'expected': true,
      'description': 'International prefix 00',
    },
    {
      'phone': '+962781234567',
      'expected': true,
      'description': 'Orange network (78)',
    },
    {
      'phone': '+962771234567',
      'expected': true,
      'description': 'Zain network (77)',
    },

    // Invalid formats
    {
      'phone': '+962761234567',
      'expected': false,
      'description': 'Invalid prefix (76)',
    },
    {
      'phone': '+962691234567',
      'expected': false,
      'description': 'Invalid prefix (69)',
    },
    {'phone': '+96279123456', 'expected': false, 'description': 'Too short'},
    {'phone': '+9627912345678', 'expected': false, 'description': 'Too long'},
    {
      'phone': '+963791234567',
      'expected': false,
      'description': 'Wrong country code',
    },
    {'phone': '1234567890', 'expected': false, 'description': 'Random number'},
    {'phone': '', 'expected': false, 'description': 'Empty string'},
    {
      'phone': '+962 79 123 4567',
      'expected': true,
      'description': 'With spaces',
    },
    {
      'phone': '+962-79-123-4567',
      'expected': true,
      'description': 'With dashes',
    },
  ];

  int passed = 0;
  int failed = 0;

  for (var testCase in testCases) {
    String phone = testCase['phone'];
    bool expected = testCase['expected'];
    String description = testCase['description'];

    bool result = PhoneValidator.isValidJordanianPhone(phone);
    String formatted = PhoneValidator.formatJordanianPhone(phone);
    String display = PhoneValidator.formatForDisplay(phone);

    bool testPassed = result == expected;

    if (testPassed) {
      passed++;
      print('✅ PASS: $description');
    } else {
      failed++;
      print('❌ FAIL: $description');
    }

    print('   Input: "$phone"');
    print('   Valid: $result (expected: $expected)');
    print('   Formatted: "$formatted"');
    print('   Display: "$display"');
    print('');
  }

  print('📊 Test Results:');
  print('   Passed: $passed');
  print('   Failed: $failed');
  print('   Total: ${passed + failed}');

  if (failed == 0) {
    print('🎉 All tests passed! Phone validation is working correctly.');
  } else {
    print('⚠️  Some tests failed. Please check the implementation.');
  }

  // Test error messages
  print('\n📝 Error Message Tests:');

  List<String> invalidPhones = [
    '',
    '+963791234567',
    '+962761234567',
    '1234567890',
  ];

  for (String phone in invalidPhones) {
    String? errorAr = PhoneValidator.getPhoneValidationError(phone, true);
    String? errorEn = PhoneValidator.getPhoneValidationError(phone, false);

    print('Phone: "$phone"');
    print('  Arabic Error: $errorAr');
    print('  English Error: $errorEn');
    print('');
  }
}
