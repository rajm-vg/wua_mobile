import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/errors/failures.dart';

/// Unit tests for the Failure hierarchy.
/// Verifies Equatable props and default messages.
void main() {
  group('ServerFailure', () {
    test('should have correct message and code', () {
      const failure = ServerFailure(message: 'Server error', code: 500);
      expect(failure.message, 'Server error');
      expect(failure.code, 500);
    });

    test('two failures with same props should be equal', () {
      const failure1 = ServerFailure(message: 'Error', code: 500);
      const failure2 = ServerFailure(message: 'Error', code: 500);
      expect(failure1, equals(failure2));
    });
  });

  group('NetworkFailure', () {
    test('should have default message', () {
      const failure = NetworkFailure();
      expect(failure.message, contains('No internet'));
    });
  });

  group('CacheFailure', () {
    test('should have default message', () {
      const failure = CacheFailure();
      expect(failure.message, contains('local storage'));
    });
  });

  group('UnauthorizedFailure', () {
    test('should have default code 401', () {
      const failure = UnauthorizedFailure();
      expect(failure.code, 401);
    });
  });

  group('ValidationFailure', () {
    test('should include field errors in props', () {
      const failure1 = ValidationFailure(
        message: 'Validation error',
        fieldErrors: {'email': ['Invalid email']},
      );
      const failure2 = ValidationFailure(
        message: 'Validation error',
        fieldErrors: {'email': ['Invalid email']},
      );
      expect(failure1, equals(failure2));
    });
  });
}
