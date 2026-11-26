import 'dart:convert';
import 'package:easebuzz_flutter/easebuzz_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/features/payments/data/datasources/easebuzz_sdk_service.dart';

class MockEasebuzzFlutter extends Mock implements EasebuzzFlutter {}

void main() {
  late MockEasebuzzFlutter mockPlugin;
  late EasebuzzSdkServiceImpl service;

  setUp(() {
    mockPlugin = MockEasebuzzFlutter();
    service = EasebuzzSdkServiceImpl(easebuzzPlugin: mockPlugin);
  });

  group('EasebuzzSdkService', () {
    test('returns success when SDK returns payment_successed', () async {
      final successPayload = jsonEncode({
        'result': 'payment_successed',
        'payment_response': {
          'txnid': 'TXN_EASE_001',
          'easepayid': 'EP_99999',
          'amount': '1240.0',
          'hash': 'sig_hash_123',
          'status': 'success',
        },
      });

      when(() => mockPlugin.payWithEasebuzz('access_key_123', 'test'))
          .thenAnswer((_) async => successPayload);

      final result = await service.payWithEasebuzz(
        accessKey: 'access_key_123',
        payMode: 'test',
      );

      expect(result.isSuccess, isTrue);
      expect(result.status, equals(EasebuzzPaymentStatus.success));
      expect(result.transactionId, equals('TXN_EASE_001'));
      expect(result.paymentId, equals('EP_99999'));
      expect(result.amount, equals(1240.0));
      expect(result.signature, equals('sig_hash_123'));
    });

    test('returns cancelled when SDK returns user_cancelled', () async {
      final cancelPayload = jsonEncode({
        'result': 'user_cancelled',
        'payment_response': <String, dynamic>{},
      });

      when(() => mockPlugin.payWithEasebuzz('access_key_123', 'test'))
          .thenAnswer((_) async => cancelPayload);

      final result = await service.payWithEasebuzz(
        accessKey: 'access_key_123',
        payMode: 'test',
      );

      expect(result.isCancelled, isTrue);
      expect(result.status, equals(EasebuzzPaymentStatus.cancelled));
      expect(result.errorMessage, contains('cancelled'));
    });

    test('returns failed when SDK returns payment_failed', () async {
      final failedPayload = jsonEncode({
        'result': 'payment_failed',
        'payment_response': {
          'error_Message': 'Card declined by issuing bank',
        },
      });

      when(() => mockPlugin.payWithEasebuzz('access_key_123', 'test'))
          .thenAnswer((_) async => failedPayload);

      final result = await service.payWithEasebuzz(
        accessKey: 'access_key_123',
        payMode: 'test',
      );

      expect(result.isFailed, isTrue);
      expect(result.status, equals(EasebuzzPaymentStatus.failed));
      expect(result.errorMessage, equals('Card declined by issuing bank'));
    });

    test('extracts message field when SDK returns trxn_not_allowed', () async {
      final failedPayload = jsonEncode({
        'result': 'trxn_not_allowed',
        'payment_response': {
          'success': false,
          'message': 'Access Key should be a valid alphanumeric string.',
        },
      });

      when(() => mockPlugin.payWithEasebuzz('invalid_key', 'test'))
          .thenAnswer((_) async => failedPayload);

      final result = await service.payWithEasebuzz(
        accessKey: 'invalid_key',
        payMode: 'test',
      );

      expect(result.isFailed, isTrue);
      expect(
        result.errorMessage,
        equals('Access Key should be a valid alphanumeric string.'),
      );
    });

    test('returns success when payment_response status is success or message is Transaction is successful', () async {
      final successPayload = jsonEncode({
        'result': 'payment_successfull',
        'payment_response': {
          'txnid': 'TXN_EASE_002',
          'easepayid': 'EP_88888',
          'amount': '11.00',
          'hash': 'sig_hash_456',
          'status': 'success',
          'error_Message': 'Transaction is successful',
        },
      });

      when(() => mockPlugin.payWithEasebuzz('accessKey456', 'test'))
          .thenAnswer((_) async => successPayload);

      final result = await service.payWithEasebuzz(
        accessKey: 'accessKey456',
        payMode: 'test',
      );

      expect(result.isSuccess, isTrue);
      expect(result.status, equals(EasebuzzPaymentStatus.success));
      expect(result.transactionId, equals('TXN_EASE_002'));
      expect(result.paymentId, equals('EP_88888'));
    });

    test('handles null or empty response gracefully', () async {
      when(() => mockPlugin.payWithEasebuzz('access_key_123', 'test'))
          .thenAnswer((_) async => null);

      final result = await service.payWithEasebuzz(
        accessKey: 'access_key_123',
        payMode: 'test',
      );

      expect(result.isCancelled, isTrue);
    });
  });
}
