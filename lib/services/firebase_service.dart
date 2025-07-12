import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_performance/firebase_performance.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../services/logger_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Firebase Core تم تهيئته بالفعل في main.dart
      
      // TODO: تفعيل App Check عند الحاجة
      // await _initializeAppCheck();
      
      // TODO: تفعيل Crashlytics عند الحاجة
      // await _initializeCrashlytics();
      
      // TODO: تفعيل Performance Monitoring عند الحاجة
      // await _initializePerformance();
      
      // TODO: تفعيل Analytics عند الحاجة
      // await _initializeAnalytics();

      _isInitialized = true;
      LoggerService.info('Firebase services initialized successfully');
    } catch (e) {
      LoggerService.error('Firebase services initialization failed', error: e);
      rethrow;
    }
  }

  // Future<void> _initializeAppCheck() async {
  //   try {
  //     await FirebaseAppCheck.instance.activate(
  //       androidProvider: AndroidProvider.debug,
  //       appleProvider: AppleProvider.debug,
  //     );
  //     LoggerService.info('Firebase App Check initialized');
  //   } catch (e) {
  //     LoggerService.warning('Firebase App Check initialization failed', error: e);
  //   }
  // }

  // Future<void> _initializeCrashlytics() async {
  //   try {
  //     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  //     PlatformDispatcher.instance.onError = (error, stack) {
  //       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //       return true;
  //     };
  //     LoggerService.info('Firebase Crashlytics initialized');
  //   } catch (e) {
  //     LoggerService.warning('Firebase Crashlytics initialization failed', error: e);
  //   }
  // }

  // Future<void> _initializePerformance() async {
  //   try {
  //     FirebasePerformance.instance;
  //     LoggerService.info('Firebase Performance initialized');
  //   } catch (e) {
  //     LoggerService.warning('Firebase Performance initialization failed', error: e);
  //   }
  // }

  // Future<void> _initializeAnalytics() async {
  //   try {
  //     FirebaseAnalytics.instance;
  //     LoggerService.info('Firebase Analytics initialized');
  //   } catch (e) {
  //     LoggerService.warning('Firebase Analytics initialization failed', error: e);
  //   }
  // }

  Future<void> dispose() async {
    _isInitialized = false;
    LoggerService.info('Firebase services disposed');
  }
}