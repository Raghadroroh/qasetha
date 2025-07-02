import 'dart:developer' as developer;

class LoggerService {
  static const String _appName = 'Qasetha';

  static void info(String message, {String? name, Object? error}) {
    developer.log(
      message,
      name: name ?? _appName,
      level: 800,
      error: error,
    );
  }

  static void warning(String message, {String? name, Object? error}) {
    developer.log(
      message,
      name: name ?? _appName,
      level: 900,
      error: error,
    );
  }

  static void error(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: name ?? _appName,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message, {String? name, Object? error}) {
    developer.log(
      message,
      name: name ?? _appName,
      level: 700,
      error: error,
    );
  }
}