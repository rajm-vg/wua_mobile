import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// ANSI escape codes for vibrant, consistent terminal and debug console logging.
class AppLoggerAnsi {
  AppLoggerAnsi._();

  // Reset & Styles
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';
  static const String dim = '\x1B[2m';
  static const String italic = '\x1B[3m';
  static const String underline = '\x1B[4m';

  // Standard Colors
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m'; // Error
  static const String green = '\x1B[32m'; // Info
  static const String yellow = '\x1B[33m'; // Warning
  static const String blue = '\x1B[34m'; // Navigation
  static const String purple = '\x1B[35m'; // Bloc / State
  static const String cyan = '\x1B[36m'; // Network
  static const String white = '\x1B[37m';

  // High-Intensity / Bright Colors
  static const String brightGray = '\x1B[90m'; // Debug / Trace
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightBlue = '\x1B[94m';
  static const String brightPurple = '\x1B[95m';
  static const String brightCyan = '\x1B[96m';
  static const String brightWhite = '\x1B[97m';

  // Extended Colors (ANSI 256)
  static const String orange = '\x1B[38;5;208m'; // Repository / Storage

  /// Wraps [text] in the given [ansiCode] and appends [reset].
  static String colorize(String text, String ansiCode) =>
      '$ansiCode$text$reset';

  /// Shortcut helpers
  static String redText(String text) => colorize(text, brightRed);
  static String greenText(String text) => colorize(text, brightGreen);
  static String purpleText(String text) => colorize(text, brightPurple);
  static String yellowText(String text) => colorize(text, brightYellow);
  static String cyanText(String text) => colorize(text, brightCyan);
  static String blueText(String text) => colorize(text, brightBlue);
  static String grayText(String text) => colorize(text, brightGray);
  static String orangeText(String text) => colorize(text, orange);
}

/// Centralized logging service with custom ANSI colorized levels and tags.
///
/// Log Levels & Colors:
/// • [error]      -> 🔴 Red (ANSI 196 / bright red)
/// • [warning]    -> 🟡 Yellow (ANSI 214 / amber)
/// • [info]       -> 🟢 Green (ANSI 40 / bright green)
/// • [debug]      -> ⚙️ Gray (ANSI 90 / bright gray)
/// • [bloc]       -> ⚡ Purple (ANSI 95 / vibrant purple)
/// • [network]    -> 🌐 Cyan (ANSI 96 / bright cyan)
/// • [navigation] -> 🧭 Blue (ANSI 94 / bright blue)
/// • [repository] -> 📦 Orange (ANSI 208 / warm amber orange)
///
/// All verbose debug logs are automatically suppressed in release builds.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      levelColors: {
        Level.trace: const AnsiColor.fg(8), // Dim gray
        Level.debug: const AnsiColor.fg(245), // Subtle gray
        Level.info: const AnsiColor.fg(40), // Bright Green
        Level.warning: const AnsiColor.fg(214), // Amber / Yellow
        Level.error: const AnsiColor.fg(196), // Vibrant Red
        Level.fatal: const AnsiColor.fg(199), // Deep Red / Magenta
      },
      levelEmojis: {
        Level.trace: '🔍 ',
        Level.debug: '⚙️ ',
        Level.info: '🟢 ',
        Level.warning: '🟡 ',
        Level.error: '🔴 ',
        Level.fatal: '🚨 ',
      },
    ),
    level: kReleaseMode ? Level.warning : Level.trace,
  );

  /// General debug output (Gray ⚙️) — suppressed in release.
  static void debug(String message, [String? tag]) {
    if (kReleaseMode) return;
    _logger.d(_format(message, tag, AppLoggerAnsi.brightGray));
  }

  /// Informational messages (Green 🟢) — suppressed in release.
  static void info(String message, [String? tag]) {
    if (kReleaseMode) return;
    _logger.i(_format(message, tag, AppLoggerAnsi.brightGreen));
  }

  /// Warnings (Yellow 🟡) — written in release as well.
  static void warning(String message, [String? tag]) {
    _logger.w(_format(message, tag, AppLoggerAnsi.brightYellow));
  }

  /// Errors (Red 🔴) — written in release with optional stack trace.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(
      _format(message, null, AppLoggerAnsi.brightRed),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Network-specific logging (Cyan 🌐) — suppressed in release.
  static void network(String message) {
    if (kReleaseMode) return;
    _logger.d(_format(message, 'NETWORK', AppLoggerAnsi.brightCyan));
  }

  /// Bloc-specific logging (Purple ⚡) — suppressed in release.
  static void bloc(String message) {
    if (kReleaseMode) return;
    _logger.d(_format(message, 'BLOC', AppLoggerAnsi.brightPurple));
  }

  /// Navigation-specific logging (Blue 🧭) — suppressed in release.
  static void navigation(String message) {
    if (kReleaseMode) return;
    _logger.d(_format(message, 'NAV', AppLoggerAnsi.brightBlue));
  }

  /// Repository-specific logging (Orange 📦) — suppressed in release.
  static void repository(String message) {
    if (kReleaseMode) return;
    _logger.d(_format(message, 'REPO', AppLoggerAnsi.orange));
  }

  static String _format(String message, String? tag, [String? tagAnsiColor]) {
    if (tag != null) {
      final color = tagAnsiColor ?? AppLoggerAnsi.brightGray;
      return '${AppLoggerAnsi.bold}$color[$tag]${AppLoggerAnsi.reset} $message';
    }
    return message;
  }
}

/// Custom [BlocObserver] that logs all Bloc/Cubit lifecycle events with ANSI styling.
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    AppLogger.bloc('Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.bloc('Event: ${bloc.runtimeType} → $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.bloc(
      'Change: ${bloc.runtimeType}\n'
      '  Current: ${change.currentState}\n'
      '  Next:    ${change.nextState}',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    AppLogger.bloc(
      'Transition: ${bloc.runtimeType}\n'
      '  Event:   ${transition.event}\n'
      '  Current: ${transition.currentState}\n'
      '  Next:    ${transition.nextState}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppLogger.error('Bloc Error: ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    AppLogger.bloc('Closed: ${bloc.runtimeType}');
  }
}
