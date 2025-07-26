import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'routes/enhanced_app_router.dart';
import 'utils/theme.dart';
import 'utils/firebase_options.dart';
import 'services/theme_service.dart';
import 'services/firebase_service.dart';
import 'services/logger_service.dart';
import 'services/guest_service.dart';
import 'utils/app_localizations.dart';
import 'widgets/global_back_handler.dart';

// Setup periodic cleanup of expired guest sessions
void _setupGuestSessionCleanup() {
  // Clean up expired guest sessions every hour
  Timer.periodic(const Duration(hours: 1), (timer) async {
    try {
      await GuestService.cleanupExpiredGuestSessions();
    } catch (e) {
      LoggerService.error('Error cleaning up guest sessions: $e');
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Services
    await FirebaseService().initialize();

    final themeService = ThemeService();
    await themeService.loadSettings();

    // Set default theme to dark
    if (themeService.themeMode == ThemeMode.system) {
      await themeService.setThemeMode(ThemeMode.dark);
    }

    // Initialize guest session cleanup
    _setupGuestSessionCleanup();

    runApp(ProviderScope(
      child: QasethaApp(themeService: themeService),
    ));
  } catch (e) {
    LoggerService.error('Error initializing app: $e');
    // Run app even if Firebase fails to initialize
    final themeService = ThemeService();
    await themeService.loadSettings();
    runApp(ProviderScope(
      child: QasethaApp(themeService: themeService),
    ));
  }
}

class QasethaApp extends ConsumerStatefulWidget {
  final ThemeService themeService;

  const QasethaApp({super.key, required this.themeService});

  @override
  ConsumerState<QasethaApp> createState() => _QasethaAppState();
}

class _QasethaAppState extends ConsumerState<QasethaApp> with WidgetsBindingObserver {
  Timer? _guestSessionTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startGuestSessionTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _guestSessionTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _startGuestSessionTracking();
        break;
      case AppLifecycleState.paused:
        _pauseGuestSessionTracking();
        break;
      case AppLifecycleState.detached:
        _cleanupGuestSession();
        break;
      default:
        break;
    }
  }

  void _startGuestSessionTracking() {
    _guestSessionTimer?.cancel();
    _guestSessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      try {
        final session = await GuestService.getCurrentGuestSession();
        if (session != null) {
          final updatedSession = session.copyWith(
            lastActivity: DateTime.now(),
          );
          await GuestService.updateGuestSession(updatedSession);
        }
      } catch (e) {
        LoggerService.error('Error updating guest session: $e');
      }
    });
  }

  void _pauseGuestSessionTracking() {
    _guestSessionTimer?.cancel();
  }

  void _cleanupGuestSession() {
    _guestSessionTimer?.cancel();
    // The cleanup will be handled by the periodic timer in main()
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(enhancedAppRouterProvider);
    
    return provider_package.ChangeNotifierProvider.value(
      value: widget.themeService,
      child: provider_package.Consumer<ThemeService>(
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
                if (locale != null &&
                    supportedLocales.any(
                      (l) => l.languageCode == locale.languageCode,
                    )) {
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
              return GlobalBackHandler(
                child: Directionality(
                  textDirection: themeService.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    child: child!,
                  ),
                ),
              );
            },
            routerConfig: router,
          );
        },
      ),
    );
  }
}
