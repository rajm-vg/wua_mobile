import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_order_model.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_verify_model.dart';

void main() {
  group('EasebuzzOrderRequest & EasebuzzOrderResponse', () {
    test('EasebuzzOrderRequest toJson formats data correctly', () {
      const request = EasebuzzOrderRequest(
        amount: 1240.50,
        currency: 'INR',
        description: 'Pani Patti Bill',
        provider: 'EASEBUZZ',
        billId: 101,
        memberId: 501,
        societyId: 1503,
      );

      final json = request.toJson();
      expect(json['amount'], equals(1240.50));
      expect(json['currency'], equals('INR'));
      expect(json['provider'], equals('EASEBUZZ'));
      expect(json['billId'], equals(101));
      expect(json['memberId'], equals(501));
      expect(json['societyId'], equals(1503));
      expect(json['receipt'], isNotEmpty);
    });

    test('EasebuzzOrderResponse fromJson parses backend response', () {
      final json = {
        'transactionId': 'TXN_EASE_123',
        'orderId': 'ORD_EASE_123',
        'amount': 1240.0,
        'currency': 'INR',
        'accessKey': 'access_key_abc',
        'keyId': '0TRH2I0OF',
        'provider': 'EASEBUZZ',
        'status': 'PENDING',
      };

      final response = EasebuzzOrderResponse.fromJson(json);
      expect(response.transactionId, equals('TXN_EASE_123'));
      expect(response.orderId, equals('ORD_EASE_123'));
      expect(response.amount, equals(1240.0));
      expect(response.accessKey, equals('access_key_abc'));
      expect(response.keyId, equals('0TRH2I0OF'));
      expect(response.provider, equals('EASEBUZZ'));
      expect(response.status, equals('PENDING'));
    });
  });

  group('EasebuzzVerifyRequest & EasebuzzVerifyResponse', () {
    test('EasebuzzVerifyRequest toJson formats data correctly', () {
      const request = EasebuzzVerifyRequest(
        transactionId: 'TXN_EASE_123',
        orderId: 'ORD_EASE_123',
        paymentId: 'EP123456',
        signature: 'hash_signature_xyz',
        amount: 1240.0,
        payload: '{"status":"success"}',
      );

      final json = request.toJson();
      expect(json['transactionId'], equals('TXN_EASE_123'));
      expect(json['orderId'], equals('ORD_EASE_123'));
      expect(json['paymentId'], equals('EP123456'));
      expect(json['signature'], equals('hash_signature_xyz'));
      expect(json['amount'], equals(1240.0));
      expect(json['payload'], equals('{"status":"success"}'));
    });

    test('EasebuzzVerifyResponse fromJson parses successful response', () {
      final json = {
        'verified': true,
        'transactionId': 'TXN_EASE_123',
        'paymentId': 'EP123456',
        'status': 'SUCCESS',
        'message': 'Easebuzz payment verified successfully',
      };

      final response = EasebuzzVerifyResponse.fromJson(json);
      expect(response.verified, isTrue);
      expect(response.transactionId, equals('TXN_EASE_123'));
      expect(response.paymentId, equals('EP123456'));
      expect(response.status, equals('SUCCESS'));
    });
  });
}
