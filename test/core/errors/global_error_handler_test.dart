import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/errors/global_error_handler.dart';

void main() {
  group('GlobalErrorHandler', () {
    test('initialize registers FlutterError.onError and PlatformDispatcher.onError', () {
      Object? capturedError;
      StackTrace? capturedStack;
      bool? capturedFatal;

      GlobalErrorHandler.initialize(
        crashReporter: (error, stack, {fatal = false}) {
          capturedError = error;
          capturedStack = stack;
          capturedFatal = fatal;
        },
      );

      // Verify FlutterError.onError is assigned and triggers reporter
      final flutterDetails = FlutterErrorDetails(
        exception: Exception('Test Flutter framework exception'),
        stack: StackTrace.current,
      );
      FlutterError.onError?.call(flutterDetails);

      expect(capturedError, isNotNull);
      expect(
        capturedError.toString(),
        contains('Test Flutter framework exception'),
      );
      expect(capturedStack, isNotNull);
      expect(capturedFatal, isTrue);

      // Verify PlatformDispatcher.onError is assigned and triggers reporter
      final handled = PlatformDispatcher.instance.onError?.call(
        Exception('Test async exception'),
        StackTrace.current,
      );

      expect(handled, isTrue);
      expect(capturedError.toString(), contains('Test async exception'));
    });

    testWidgets('GlobalErrorFallbackWidget renders without error', (
      tester,
    ) async {
      final details = FlutterErrorDetails(
        exception: Exception('Widget build failure'),
      );

      await tester.pumpWidget(
        MaterialApp(home: GlobalErrorFallbackWidget(details: details)),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
