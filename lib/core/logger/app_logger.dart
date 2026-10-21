import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// Centralized logging service.
///
/// Log levels: debug, info, warning, error.
/// All verbose logs are automatically suppressed in release builds.
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
    ),
    level: kReleaseMode ? Level.warning : Level.trace,
  );

  /// General debug output — suppressed in release.
  static void debug(String message, [String? tag]) {
    if (kReleaseMode) return;
    _logger.d(_format(message, tag));
  }

  /// Informational messages.
  static void info(String message, [String? tag]) {
    if (kReleaseMode) return;
    _logger.i(_format(message, tag));
  }

  /// Warnings (also written in release).
  static void warning(String message, [String? tag]) {
    _logger.w(_format(message, tag));
  }

  /// Errors (also written in release, includes optional stack trace).
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Network-specific logging.
  static void network(String message) {
    debug(message, 'NETWORK');
  }

  /// Bloc-specific logging.
  static void bloc(String message) {
    debug(message, 'BLOC');
  }

  /// Navigation-specific logging.
  static void navigation(String message) {
    debug(message, 'NAV');
  }

  /// Repository-specific logging.
  static void repository(String message) {
    debug(message, 'REPO');
  }

  static String _format(String message, String? tag) {
    return tag != null ? '[$tag] $message' : message;
  }
}

/// Custom [BlocObserver] that logs all Bloc/Cubit lifecycle events.
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
