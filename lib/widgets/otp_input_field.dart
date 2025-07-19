import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../utils/app_localizations.dart';

class OTPInputField extends StatelessWidget {
  final Function(String) onCompleted;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final bool hasError;
  final String? errorText;

  const OTPInputField({
    super.key,
    required this.onCompleted,
    required this.onChanged,
    this.controller,
    this.hasError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = context.l10n.locale.languageCode == 'ar';

    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.ltr, // OTP دائماً LTR
          child: PinCodeTextField(
            appContext: context,
            length: 6,
            controller: controller,
            keyboardType: TextInputType.number,
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: 56,
              fieldWidth: 48,
              activeFillColor: hasError
                  ? Colors.red.withValues(alpha: 0.1)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              inactiveFillColor: Theme.of(context).cardColor,
              selectedFillColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              activeColor: hasError
                  ? Colors.red
                  : Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).dividerColor,
              selectedColor: Theme.of(context).primaryColor,
              borderWidth: 2,
            ),
            enableActiveFill: true,
            onCompleted: (value) {
              // Validate before calling onCompleted
              if (RegExp(r'^\d{6}$').hasMatch(value)) {
                onCompleted(value);
              }
            },
            onChanged: (value) {
              // Clean the value (remove non-digits)
              final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
              onChanged(cleanValue);
            },
            beforeTextPaste: (text) {
              // Allow pasting only if it's exactly 6 digits
              if (text == null || text.isEmpty) return false;

              // Remove any whitespace
              final cleanText = text.replaceAll(RegExp(r'\s+'), '');

              // Check if it's exactly 6 digits
              return RegExp(r'^\d{6}$').hasMatch(cleanText);
            },
            animationType: AnimationType.fade,
            animationDuration: const Duration(milliseconds: 300),
            cursorColor: Theme.of(context).primaryColor,
            enablePinAutofill: true,
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
        ],
      ],
    );
  }
}
