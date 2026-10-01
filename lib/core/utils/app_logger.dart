/// Central production-safe application event boundary.
///
/// Routine application events intentionally produce no console/debug output.
/// Fatal and recoverable application errors remain owned by ErrorHandler.
class AppLogger {
  AppLogger._();

  static void info(String message) {}
  static void success(String message) {}
  static void warning(String message) {}

  static void error(String message, [Object? error, StackTrace? stackTrace]) {}

  static void debug(String message) {}
  static void performance(String message) {}
  static void ai(String message) {}
  static void auth(String message) {}
  static void sync(String message) {}
  static void notification(String message) {}
  static void navigation(String message) {}
  static void memory(String message) {}
  static void system(String message) {}
  static void cycle(String message) {}
  static void analytics(String message) {}
  static void security(String message) {}
  static void clinical(String message) {}
}
