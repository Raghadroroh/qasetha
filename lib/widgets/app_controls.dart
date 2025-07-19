import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import 'settings_dialog.dart';

class AppControls extends StatelessWidget {
  final bool showBackground;

  const AppControls({super.key, this.showBackground = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isRTL = themeService.languageCode == 'ar';

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: showBackground
              ? BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              _buildThemeButton(context, themeService),
              const SizedBox(width: 8),
              _buildLanguageButton(context, themeService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeButton(BuildContext context, ThemeService themeService) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => SettingsDialog.showThemeDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            themeService.themeIcon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, ThemeService themeService) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => SettingsDialog.showLanguageDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.translate_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
