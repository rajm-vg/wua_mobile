import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';

void main() {
  group('AppLoggerAnsi', () {
    test('colorize formats text with escape code and reset', () {
      final colored = AppLoggerAnsi.colorize(
        'Hello',
        AppLoggerAnsi.brightGreen,
      );
      expect(colored, '\x1B[92mHello\x1B[0m');
    });

    test('color helpers apply expected ANSI escape codes', () {
      expect(AppLoggerAnsi.redText('Error'), contains('\x1B[91mError\x1B[0m'));
      expect(AppLoggerAnsi.greenText('Info'), contains('\x1B[92mInfo\x1B[0m'));
      expect(
        AppLoggerAnsi.purpleText('Debug'),
        contains('\x1B[95mDebug\x1B[0m'),
      );
      expect(AppLoggerAnsi.yellowText('Warn'), contains('\x1B[93mWarn\x1B[0m'));
      expect(AppLoggerAnsi.cyanText('Net'), contains('\x1B[96mNet\x1B[0m'));
      expect(AppLoggerAnsi.blueText('Nav'), contains('\x1B[94mNav\x1B[0m'));
    });
  });

  group('AppLogger', () {
    test('logging methods execute without error', () {
      expect(() => AppLogger.debug('Debug message'), returnsNormally);
      expect(() => AppLogger.info('Info message'), returnsNormally);
      expect(() => AppLogger.warning('Warning message'), returnsNormally);
      expect(() => AppLogger.error('Error message'), returnsNormally);
      expect(() => AppLogger.network('GET /api/v1/bills'), returnsNormally);
      expect(() => AppLogger.bloc('Event dispatched'), returnsNormally);
      expect(
        () => AppLogger.navigation('Navigating to /home'),
        returnsNormally,
      );
      expect(() => AppLogger.repository('Fetching user'), returnsNormally);
    });
  });
}
