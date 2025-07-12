import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الإعدادات',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(
              Theme.of(context).brightness == Brightness.dark 
                  ? Icons.dark_mode 
                  : Icons.light_mode,
            ),
            title: Text(
              'الثيم يتبدل تلقائياً',
              style: GoogleFonts.tajawal(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              'العربية',
              style: GoogleFonts.tajawal(),
            ),
          ),
        ],
      ),
    );
  }
}