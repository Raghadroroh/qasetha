class SimpleLogger {
  static void info(String message) {
    print('ℹ️ INFO: $message');
  }
  
  static void error(String message) {
    print('❌ ERROR: $message');
  }
  
  static void warning(String message) {
    print('⚠️ WARNING: $message');
  }
  
  static void debug(String message) {
    print('🐛 DEBUG: $message');
  }
}