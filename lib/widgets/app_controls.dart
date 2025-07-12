import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../utils/app_localizations.dart';

class AppControls extends StatelessWidget {
  final bool showBackground;
  
  const AppControls({
    super.key,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: showBackground ? BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeButton(context),
          const SizedBox(width: 8),
          _buildLanguageButton(context),
        ],
      ),
    );
  }

  Widget _buildThemeButton(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return GestureDetector(
          onTap: () => _toggleTheme(themeService),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              themeService.themeMode == ThemeMode.dark 
                  ? Icons.nightlight_round 
                  : Icons.wb_sunny,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return GestureDetector(
          onTap: () => _toggleLanguage(context, themeService),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  void _toggleTheme(ThemeService themeService) {
    if (themeService.themeMode == ThemeMode.light) {
      themeService.setThemeMode(ThemeMode.dark);
    } else {
      themeService.setThemeMode(ThemeMode.light);
    }
  }

  void _toggleLanguage(BuildContext context, ThemeService themeService) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text('🇸🇦'),
              title: Text(context.l10n.arabic),
              onTap: () {
                themeService.setLanguage('ar');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Text('🇺🇸'),
              title: Text(context.l10n.english),
              onTap: () {
                themeService.setLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}