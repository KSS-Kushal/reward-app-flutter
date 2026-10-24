import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../app/config/environment.dart';

enum LogLevel { debug, info, warning, error }

/// Central logger. Use instead of `print`.
///
/// The minimum level depends on the [Environment]: everything is logged in
/// development, while production only records warnings and errors.
///
/// Debug and profile builds print to the console, so logs appear in the
/// `flutter run` terminal, the VS Code Debug Console and `adb logcat`
/// (tag `flutter`). Release builds use `dart:developer` only.
abstract final class AppLogger {
  static LogLevel minLevel = switch (Environment.current) {
    Environment.development => LogLevel.debug,
    Environment.staging => LogLevel.info,
    Environment.production => LogLevel.warning,
  };

  static void debug(String message, {String tag = 'App'}) =>
      _log(LogLevel.debug, message, tag: tag);

  static void info(String message, {String tag = 'App'}) =>
      _log(LogLevel.info, message, tag: tag);

  static void warning(String message, {String tag = 'App', Object? error}) =>
      _log(LogLevel.warning, message, tag: tag, error: error);

  static void error(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) => _log(
    LogLevel.error,
    message,
    tag: tag,
    error: error,
    stackTrace: stackTrace,
  );

  /// Shortens secrets for logs: `eyJhbGciOi…x9Q (1187 chars)`.
  static String mask(String? value, {int keep = 10}) {
    if (value == null) return 'null';
    if (value.isEmpty) return '<empty>';
    if (value.length <= keep + 4) return '***';
    return '${value.substring(0, keep)}…'
        '${value.substring(value.length - 4)} (${value.length} chars)';
  }

  static void _log(
    LogLevel level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minLevel.index) return;

    if (kReleaseMode) {
      developer.log(
        '[${level.name.toUpperCase()}] $message',
        name: tag,
        level: _severity(level),
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    final buffer = StringBuffer('${_icon(level)} [$tag] $message');
    if (error != null) buffer.write('\n   ↳ error: $error');
    if (stackTrace != null) {
      final frames = stackTrace.toString().trim().split('\n').take(8);
      buffer.write('\n   ↳ stack:\n${frames.map((f) => '     $f').join('\n')}');
    }
    debugPrint(buffer.toString());
  }

  static String _icon(LogLevel level) => switch (level) {
    LogLevel.debug => '🐛',
    LogLevel.info => 'ℹ️',
    LogLevel.warning => '⚠️',
    LogLevel.error => '⛔',
  };

  static int _severity(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
