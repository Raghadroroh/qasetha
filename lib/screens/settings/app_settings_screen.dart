import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/locale_service.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/app_controls.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF0A0E21),
                    const Color(0xFF1A1B3A),
                    const Color(0xFF2D1B69),
                    const Color(0xFF0A192F),
                  ]
                : [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB),
                    const Color(0xFF90CAF9),
                    const Color(0xFF64B5F6),
                  ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // أزرار التحكم
              Positioned(
                top: 16,
                right: 16,
                child: const AppControls(),
              ),
              
              // زر الرجوع
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
              
              // المحتوى الرئيسي
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        // العنوان
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF3A7BD5), Colors.white],
                          ).createShader(bounds),
                          child: Text(
                            context.l10n.language,
                            style: GoogleFonts.tajawal(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // قسم الثيم
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: Theme.of(context).brightness == Brightness.dark
                                  ? [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ]
                                  : [
                                      Colors.white.withOpacity(0.9),
                                      Colors.white.withOpacity(0.7),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.palette_outlined,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Theme',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.titleLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'الثيم يتبدل تلقائياً حسب إعدادات الجهاز',
                                style: GoogleFonts.tajawal(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}