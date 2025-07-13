import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../utils/app_localizations.dart';

class SettingsDialog {
  static void showLanguageDialog(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              textDirection: context.textDirection,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.chooseLanguage,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textDirection: context.textDirection,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(
                  context,
                  themeService,
                  '🌐',
                  context.l10n.systemLanguage,
                  'system',
                  Icons.phone_android,
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  themeService,
                  '🇯🇴',
                  context.l10n.arabic,
                  'ar',
                  Icons.language,
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  themeService,
                  '🇺🇸',
                  context.l10n.english,
                  'en',
                  Icons.language,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.l10n.cancel,
                  style: GoogleFonts.tajawal(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: context.textDirection,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showThemeDialog(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              textDirection: context.textDirection,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    themeService.themeIcon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.chooseTheme,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textDirection: context.textDirection,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(
                  context,
                  themeService,
                  Icons.wb_sunny,
                  context.l10n.lightTheme,
                  ThemeMode.light,
                ),
                const SizedBox(height: 12),
                _buildThemeOption(
                  context,
                  themeService,
                  Icons.nightlight_round,
                  context.l10n.darkTheme,
                  ThemeMode.dark,
                ),
                const SizedBox(height: 12),
                _buildThemeOption(
                  context,
                  themeService,
                  Icons.brightness_auto,
                  context.l10n.systemTheme,
                  ThemeMode.system,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.l10n.cancel,
                  style: GoogleFonts.tajawal(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: context.textDirection,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildLanguageOption(
    BuildContext context,
    ThemeService themeService,
    String flag,
    String title,
    String languageCode,
    IconData icon,
  ) {
    final isSelected = themeService.savedLanguageCode == languageCode;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
          textDirection: context.textDirection,
        ),
        trailing: isSelected 
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () async {
          await themeService.setLanguage(languageCode);
          if (context.mounted) {
            Navigator.of(context).pop();
            _showSuccessSnackBar(context, context.l10n.languageChangedSuccessfully);
          }
        },
      ),
    );
  }

  static Widget _buildThemeOption(
    BuildContext context,
    ThemeService themeService,
    IconData icon,
    String title,
    ThemeMode themeMode,
  ) {
    final isSelected = themeService.themeMode == themeMode;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
          textDirection: context.textDirection,
        ),
        trailing: isSelected 
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () async {
          await themeService.setThemeMode(themeMode);
          if (context.mounted) {
            Navigator.of(context).pop();
            _showSuccessSnackBar(context, context.l10n.themeChangedSuccessfully);
          }
        },
      ),
    );
  }

  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textDirection: context.textDirection,
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}