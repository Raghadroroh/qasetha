import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/router.dart';
import 'utils/theme.dart';
import 'utils/firebase_options.dart';
import 'services/theme_service.dart';
import 'utils/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final themeService = ThemeService();
  await themeService.loadSettings();
  
  runApp(QasethaApp(themeService: themeService));
}

class QasethaApp extends StatefulWidget {
  final ThemeService themeService;
  
  const QasethaApp({super.key, required this.themeService});

  @override
  State<QasethaApp> createState() => _QasethaAppState();
}

class _QasethaAppState extends State<QasethaApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeLanguageSelection();
    });
  }

  void _checkFirstTimeLanguageSelection() {
    if (widget.themeService.isFirstTimeLanguageSelection) {
      // التوجه لشاشة اختيار اللغة
      appRouter.go('/language-selection');
    } else {
      // التوجه للشاشة العادية
      appRouter.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'قسطها',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            locale: Locale(themeService.languageCode),
            localeResolutionCallback: (locale, supportedLocales) {
              if (themeService.savedLanguageCode == 'system') {
                if (locale != null && supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
                  return locale;
                }
                return const Locale('ar');
              }
              return Locale(themeService.languageCode);
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              return Directionality(
                textDirection: themeService.languageCode == 'ar' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                ),
              );
            },
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}