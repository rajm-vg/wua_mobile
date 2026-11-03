import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

void main() {
  group('PaymentEntity Tests', () {
    test('should properly calculate status flags', () {
      final successPayment = PaymentEntity(
        id: 'pay_1',
        paymentNumber: 'REC/001',
        status: PaymentStatus.success,
        amount: 2360,
        paymentDate: DateTime(2026, 8, 14),
      );

      final failedPayment = PaymentEntity(
        id: 'pay_2',
        paymentNumber: 'REC/002',
        status: PaymentStatus.failed,
        amount: 380,
        paymentDate: DateTime(2026, 10, 20),
      );

      expect(successPayment.isSuccess, isTrue);
      expect(successPayment.isFailed, isFalse);
      expect(failedPayment.isSuccess, isFalse);
      expect(failedPayment.isFailed, isTrue);
    });

    test('should format PaymentStatus labels correctly', () {
      expect(PaymentStatus.toLabel('SUCCESS'), equals('Successful'));
      expect(PaymentStatus.toLabel('PENDING'), equals('Processing / Pending'));
      expect(PaymentStatus.toLabel('FAILED'), equals('Failed'));
      expect(PaymentStatus.toLabel('REFUNDED'), equals('Refunded'));
    });
  });
}
