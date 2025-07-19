import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'logger_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize services in parallel for better performance
      await Future.wait([
        _initializeAppCheck(),
        _initializeCrashlytics(),
        _initializePerformance(),
        _initializeAnalytics(),
      ]);

      _isInitialized = true;
      LoggerService.info('Firebase services initialized successfully');
    } catch (e) {
      LoggerService.error('Firebase services initialization failed', error: e);
      // Don't rethrow - allow app to continue without optional services
      _isInitialized = true;
    }
  }

  Future<void> _initializeAppCheck() async {
    try {
      // Only initialize AppCheck in production or when explicitly enabled
      if (kDebugMode) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
      } else {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.appAttest,
        );
      }
    } catch (e) {
      LoggerService.error('AppCheck initialization failed', error: e);
    }
  }

  Future<void> _initializeCrashlytics() async {
    try {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // For non-fatal errors
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      LoggerService.error('Crashlytics initialization failed', error: e);
    }
  }

  Future<void> _initializePerformance() async {
    try {
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    } catch (e) {
      LoggerService.error('Performance initialization failed', error: e);
    }
  }

  Future<void> _initializeAnalytics() async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    } catch (e) {
      LoggerService.error('Analytics initialization failed', error: e);
    }
  }

  // Check if specific services are available
  bool get isAnalyticsEnabled {
    try {
      FirebaseAnalytics.instance;
      return true;
    } catch (e) {
      return false;
    }
  }

  bool get isPerformanceEnabled {
    try {
      FirebasePerformance.instance;
      return true;
    } catch (e) {
      return false;
    }
  }

  bool get isCrashlyticsEnabled {
    try {
      FirebaseCrashlytics.instance;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> dispose() async {
    _isInitialized = false;
    LoggerService.info('Firebase services disposed');
  }
}
