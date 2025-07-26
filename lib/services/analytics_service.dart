import 'package:firebase_analytics/firebase_analytics.dart';
import 'logger_service.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(analytics: _analytics);

  static FirebaseAnalyticsObserver get observer => _observer;

  // Log screen view (replaces deprecated setCurrentScreen)
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      LoggerService.info('Analytics: Screen view tracked - $screenName');
    } catch (e) {
      LoggerService.error('Analytics: Failed to log screen view - $e');
    }
  }

  // Log custom events
  static Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    try {
      // Filter out null values to match Firebase requirements
      final filteredParameters = parameters?.map((key, value) => 
        MapEntry(key, value ?? ''))
        .cast<String, Object>();
      
      await _analytics.logEvent(
        name: name,
        parameters: filteredParameters,
      );
      LoggerService.info('Analytics: Event logged - $name');
    } catch (e) {
      LoggerService.error('Analytics: Failed to log event $name - $e');
    }
  }

  // Predefined events
  static Future<void> logAppOpen() async {
    await logEvent(name: 'app_open');
  }

  static Future<void> logLogin({String? method}) async {
    await logEvent(
      name: 'login',
      parameters: method != null ? {'method': method} : {},
    );
  }

  static Future<void> logSignUp({String? method}) async {
    await logEvent(
      name: 'sign_up',
      parameters: method != null ? {'method': method} : {},
    );
  }

  static Future<void> logGuestModeEnter() async {
    await logEvent(name: 'guest_mode_enter');
  }

  static Future<void> logGuestModeExit() async {
    await logEvent(name: 'guest_mode_exit');
  }

  static Future<void> logLanguageChange({required String language}) async {
    await logEvent(
      name: 'language_change',
      parameters: {'language': language},
    );
  }

  static Future<void> logThemeChange({required String theme}) async {
    await logEvent(
      name: 'theme_change',
      parameters: {'theme': theme},
    );
  }

  // Set user properties
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      LoggerService.info('Analytics: User property set - $name: $value');
    } catch (e) {
      LoggerService.error('Analytics: Failed to set user property $name - $e');
    }
  }

  // Set user ID
  static Future<void> setUserId(String? userId) async {
    try {
      // Firebase Analytics setUserId accepts null to clear the user ID
      await _analytics.setUserId(id: userId);
      LoggerService.info('Analytics: User ID set - $userId');
    } catch (e) {
      LoggerService.error('Analytics: Failed to set user ID - $e');
    }
  }
}