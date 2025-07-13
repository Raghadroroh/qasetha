import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/app_controls.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isRTL = themeService.languageCode == 'ar';
        
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.background,
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.background,
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
            ),
            child: Stack(
              children: [
                // App Controls
                Positioned(
                  top: 16,
                  right: isRTL ? 16 : null,
                  left: isRTL ? null : 16,
                  child: SafeArea(
                    child: const AppControls(),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 16,
                  left: isRTL ? null : 16,
                  right: isRTL ? 16 : null,
                  child: SafeArea(
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        isRTL ? Icons.arrow_forward : Icons.arrow_back,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                // Content
                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            children: [
                              const SizedBox(height: 60),
                              // العنوان
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.language,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              
                              Text(
                                context.l10n.language,
                                style: GoogleFonts.tajawal(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // خيارات اللغة
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildLanguageOption(
                                      context,
                                      themeService,
                                      '🌐',
                                      isRTL ? 'لغة الجهاز' : 'System Language',
                                      'system',
                                      isRTL,
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    _buildLanguageOption(
                                      context,
                                      themeService,
                                      '🇸🇦',
                                      'العربية',
                                      'ar',
                                      isRTL,
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    _buildLanguageOption(
                                      context,
                                      themeService,
                                      '🇺🇸',
                                      'English',
                                      'en',
                                      isRTL,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    ThemeService themeService,
    String flag,
    String title,
    String languageCode,
    bool isRTL,
  ) {
    final isSelected = themeService.languageCode == languageCode;
    
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected ? LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ) : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await themeService.setLanguage(languageCode);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isRTL ? 'تم تغيير اللغة بنجاح' : 'Language changed successfully',
                    style: GoogleFonts.tajawal(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}