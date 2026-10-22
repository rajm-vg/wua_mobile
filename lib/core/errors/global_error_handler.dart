import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/theme/colors.dart';

/// Contract for third-party crash reporting services (e.g., Firebase Crashlytics, Sentry).
typedef CrashReporter = void Function(
  Object error,
  StackTrace? stackTrace, {
  bool fatal,
});

/// Enterprise-grade global error handling service.
///
/// Captures:
/// 1. Synchronous Flutter framework errors (widget builds, rendering, layout).
/// 2. Asynchronous unhandled errors (root isolate futures, timers, microtasks).
/// 3. Replaces red/grey screen of death with a resilient fallback widget in release mode.
/// 4. Provides a single plug-in point for telemetry/crash-reporting services.
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static CrashReporter? _crashReporter;

  /// Registers an optional crash reporting sink (e.g., FirebaseCrashlytics.instance.recordError).
  static void setCrashReporter(CrashReporter reporter) {
    _crashReporter = reporter;
  }

  /// Initializes all global exception and crash hooks.
  /// Must be called right after [WidgetsFlutterBinding.ensureInitialized].
  static void initialize({CrashReporter? crashReporter}) {
    if (crashReporter != null) {
      _crashReporter = crashReporter;
    }

    // ── 1. Flutter Framework Errors (Widget Tree, Rendering) ───────────
    FlutterError.onError = _handleFlutterError;

    // ── 2. Platform / Asynchronous Root Isolate Errors ──────────────────
    PlatformDispatcher.instance.onError = _handlePlatformError;

    // ── 3. Production Fallback UI for Unhandled Widget Failures ─────────
    _configureErrorWidget();
  }

  /// Handles Flutter framework errors.
  static void _handleFlutterError(FlutterErrorDetails details) {
    // Preserve Flutter's standard DevTools console format in debug/profile mode
    if (kDebugMode) {
      FlutterError.presentError(details);
    }

    AppLogger.error(
      'Flutter Framework Exception: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );

    // Forward to remote crash telemetry
    _crashReporter?.call(
      details.exception,
      details.stack,
      fatal: true,
    );
  }

  /// Handles uncaught asynchronous errors from the root isolate.
  static bool _handlePlatformError(Object error, StackTrace stack) {
    AppLogger.error('Uncaught Asynchronous Exception: $error', error, stack);

    // Forward to remote crash telemetry
    _crashReporter?.call(
      error,
      stack,
      fatal: true,
    );

    // Return true to prevent the error from escalating and crashing the app process
    return true;
  }

  /// Configures [ErrorWidget.builder] to ensure users never see raw stack traces.
  static void _configureErrorWidget() {
    final originalBuilder = ErrorWidget.builder;

    ErrorWidget.builder = (FlutterErrorDetails details) {
      // In debug mode, preserve the standard detailed error widget for developer ergonomics
      if (kDebugMode) {
        return originalBuilder(details);
      }

      // In release/profile mode, render a secure, polished, branded recovery UI
      return GlobalErrorFallbackWidget(details: details);
    };
  }
}

/// Polished, user-friendly fallback widget shown when an unhandled build error occurs.
/// Prevents exposing sensitive internal stack traces or database info to users.
class GlobalErrorFallbackWidget extends StatelessWidget {
  const GlobalErrorFallbackWidget({
    super.key,
    required this.details,
  });

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundLight,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackgroundLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'An unexpected issue occurred. We have logged this error and our team is looking into it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Triggers navigation or rebuild attempt
                    final navigator = Navigator.maybeOf(context);
                    if (navigator != null && navigator.canPop()) {
                      navigator.pop();
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
