import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/domain/repositories/bill_repository.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/repositories/payment_repository.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockBillRepository extends Mock implements BillRepository {}

class FakePaymentEntity extends Fake implements PaymentEntity {}

class FakeBillEntity extends Fake implements BillEntity {}

void main() {
  late MockPaymentRepository mockPaymentRepository;
  late MockBillRepository mockBillRepository;
  late ProcessPaymentUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakePaymentEntity());
    registerFallbackValue(FakeBillEntity());
  });

  setUp(() {
    mockPaymentRepository = MockPaymentRepository();
    mockBillRepository = MockBillRepository();
    useCase = ProcessPaymentUseCase(
      paymentRepository: mockPaymentRepository,
      billRepository: mockBillRepository,
    );
  });

  final tPayment = PaymentEntity(
    id: 'pay_test_01',
    paymentNumber: 'REC/WUA/2026/001',
    status: PaymentStatus.success,
    amount: 1240.0,
    paymentDate: DateTime(2026, 11, 16),
    billId: 'bill_01',
    billNumber: 'WUA/01',
    paymentMode: 'Google Pay (UPI)',
  );

  const tBill = BillEntity(
    id: 'bill_01',
    billNumber: 'WUA/01',
    status: BillStatus.pending,
    totalAmount: 1240.0,
    outstandingAmount: 1240.0,
  );

  test('should process payment and mark bill as paid on success', () async {
    // Arrange
    when(() => mockPaymentRepository.processPayment(any()))
        .thenAnswer((_) async => Right(tPayment));
    when(() => mockBillRepository.markBillAsPaid(
          any(),
          paymentReference: any(named: 'paymentReference'),
          paymentMethod: any(named: 'paymentMethod'),
          paidAmount: any(named: 'paidAmount'),
        )).thenAnswer((_) async => Right(tBill));

    // Act
    // ignore: prefer_const_constructors
    final result = await useCase(ProcessPaymentParams(
      payment: tPayment,
      bill: tBill,
    ));

    // Assert
    expect(result, equals(Right<Failure, PaymentEntity>(tPayment)));
    verify(() => mockPaymentRepository.processPayment(tPayment)).called(1);
    verify(() => mockBillRepository.markBillAsPaid(
          'bill_01',
          paymentReference: tPayment.paymentNumber,
          paymentMethod: tPayment.paymentMode,
          paidAmount: tPayment.amount,
        )).called(1);
  });

  test('should return failure when payment processing fails', () async {
    // Arrange
    when(() => mockPaymentRepository.processPayment(any()))
        .thenAnswer((_) async => const Left(ServerFailure(message: 'Gateway error')));

    // Act
    // ignore: prefer_const_constructors
    final result = await useCase(ProcessPaymentParams(
      payment: tPayment,
      bill: tBill,
    ));

    // Assert
    expect(result, equals(const Left<Failure, PaymentEntity>(ServerFailure(message: 'Gateway error'))));
    verify(() => mockPaymentRepository.processPayment(tPayment)).called(1);
    verifyNever(() => mockBillRepository.markBillAsPaid(
          any(),
          paymentReference: any(named: 'paymentReference'),
          paymentMethod: any(named: 'paymentMethod'),
          paidAmount: any(named: 'paidAmount'),
        ));
  });
}
