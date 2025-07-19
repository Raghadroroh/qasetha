import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../utils/validation_helper.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;
  final bool showRequirements;

  const PasswordRequirements({
    super.key,
    required this.password,
    this.showRequirements = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showRequirements) return const SizedBox.shrink();

    final requirements = ValidationHelper.getPasswordRequirements(password);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.locale.languageCode == 'ar'
                ? 'متطلبات كلمة المرور:'
                : 'Password Requirements:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement(
            context,
            context.l10n.passwordMinLength,
            requirements['minLength']!,
          ),
          _buildRequirement(
            context,
            context.l10n.passwordNeedsUppercase,
            requirements['hasUppercase']!,
          ),
          _buildRequirement(
            context,
            context.l10n.passwordNeedsLowercase,
            requirements['hasLowercase']!,
          ),
          _buildRequirement(
            context,
            context.l10n.passwordNeedsNumber,
            requirements['hasNumber']!,
          ),
          _buildRequirement(
            context,
            context.l10n.passwordNeedsSpecialChar,
            requirements['hasSpecialChar']!,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(BuildContext context, String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet
                ? Colors.green
                : Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: isMet
                    ? Colors.green
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
