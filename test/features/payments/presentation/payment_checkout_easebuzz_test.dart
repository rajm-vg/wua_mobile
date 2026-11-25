import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/data/datasources/easebuzz_sdk_service.dart';
import 'package:wua_mobile/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_order_model.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_verify_model.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class MockProcessPaymentUseCase extends Mock implements ProcessPaymentUseCase {}

class MockPaymentRemoteDataSource extends Mock
    implements PaymentRemoteDataSource {}

class MockEasebuzzSdkService extends Mock implements EasebuzzSdkService {}

class FakeProcessPaymentParams extends Fake implements ProcessPaymentParams {}

class FakeEasebuzzOrderRequest extends Fake implements EasebuzzOrderRequest {}

class FakeEasebuzzVerifyRequest extends Fake implements EasebuzzVerifyRequest {}

void main() {
  late MockProcessPaymentUseCase mockProcessPaymentUseCase;
  late MockPaymentRemoteDataSource mockRemoteDataSource;
  late MockEasebuzzSdkService mockEasebuzzService;

  const tBill = BillEntity(
    id: '105',
    billNumber: 'WUA/PANI/2024/105',
    status: BillStatus.pending,
    totalAmount: 1240.0,
    outstandingAmount: 1240.0,
    consumerId: '501',
    consumerName: 'Ramesh Patil',
    wuaSocietyName: 'Ganga-Godavari WUA #12',
    season: 'Rabi Season (2024-25)',
    cropType: 'Wheat',
  );

  final tPayment = PaymentEntity(
    id: 'pay_001',
    paymentNumber: 'REC/WUA/2026/001',
    status: PaymentStatus.success,
    amount: 1240.0,
    paymentDate: DateTime(2026, 11, 25),
    billId: '105',
    billNumber: 'WUA/PANI/2024/105',
  );

  setUpAll(() {
    registerFallbackValue(FakeProcessPaymentParams());
    registerFallbackValue(FakeEasebuzzOrderRequest());
    registerFallbackValue(FakeEasebuzzVerifyRequest());
  });

  setUp(() {
    mockProcessPaymentUseCase = MockProcessPaymentUseCase();
    mockRemoteDataSource = MockPaymentRemoteDataSource();
    mockEasebuzzService = MockEasebuzzSdkService();
  });

  PaymentCheckoutBloc buildBloc() {
    return PaymentCheckoutBloc(
      processPaymentUseCase: mockProcessPaymentUseCase,
      paymentRemoteDataSource: mockRemoteDataSource,
      easebuzzSdkService: mockEasebuzzService,
      initialBill: tBill,
    );
  }

  group('PaymentCheckoutBloc with Easebuzz SDK', () {
    const orderResponse = EasebuzzOrderResponse(
      transactionId: 'TXN_EASE_105',
      orderId: 'ORD_EASE_105',
      amount: 1240.0,
      currency: 'INR',
      accessKey: 'accessKey105',
    );

    final sdkResult = EasebuzzSdkResult.success(
      rawResponse: '{"status":"success"}',
      paymentResponse: const {
        'txnid': 'TXN_EASE_105',
        'easepayid': 'EP_105',
        'amount': '1240.0',
        'hash': 'sig_105',
      },
    );

    const verifyResponse = EasebuzzVerifyResponse(
      verified: true,
      transactionId: 'TXN_EASE_105',
      paymentId: 'EP_105',
      status: 'SUCCESS',
    );

    final cancelResult = EasebuzzSdkResult.cancelled(
      message: 'Payment cancelled by user.',
    );

    blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
      'executes successful Easebuzz order, checkout, and verification',
      build: () {
        when(() => mockRemoteDataSource.createPaymentOrder(any()))
            .thenAnswer((_) async => orderResponse);
        when(() => mockEasebuzzService.payWithEasebuzz(
              accessKey: 'accessKey105',
              payMode: any(named: 'payMode'),
            )).thenAnswer((_) async => sdkResult);
        when(() => mockRemoteDataSource.verifyPaymentOrder(any()))
            .thenAnswer((_) async => verifyResponse);
        when(
          () => mockRemoteDataSource.postReceiptEntry(
            amount: any(named: 'amount'),
            transactionRefNo: any(named: 'transactionRefNo'),
            farmerMemberId: any(named: 'farmerMemberId'),
            societyId: any(named: 'societyId'),
            fiscalYear: any(named: 'fiscalYear'),
            season: any(named: 'season'),
            remarks: any(named: 'remarks'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockProcessPaymentUseCase(any()))
            .thenAnswer((_) async => Right(tPayment));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ExecutePaymentEvent()),
      expect: () => [
        isA<PaymentCheckoutState>()
            .having((s) => s.step, 'step', PaymentCheckoutStep.processing)
            .having((s) => s.processingStage, 'stage', 1),
        isA<PaymentCheckoutState>()
            .having((s) => s.step, 'step', PaymentCheckoutStep.processing)
            .having((s) => s.processingStage, 'stage', 2),
        isA<PaymentCheckoutState>()
            .having((s) => s.step, 'step', PaymentCheckoutStep.processing)
            .having((s) => s.processingStage, 'stage', 3),
        isA<PaymentCheckoutState>()
            .having((s) => s.step, 'step', PaymentCheckoutStep.success),
      ],
      verify: (_) {
        verify(() => mockRemoteDataSource.createPaymentOrder(any())).called(1);
        verify(() => mockEasebuzzService.payWithEasebuzz(
              accessKey: 'accessKey105',
              payMode: any(named: 'payMode'),
            )).called(1);
        verify(() => mockRemoteDataSource.verifyPaymentOrder(any())).called(1);
        verify(
          () => mockRemoteDataSource.postReceiptEntry(
            amount: 1240.0,
            transactionRefNo: 'EP_105',
            farmerMemberId: 501,
            societyId: any(named: 'societyId'),
            fiscalYear: any(named: 'fiscalYear'),
            season: 'Rabi Season (2024-25)',
            remarks: any(named: 'remarks'),
          ),
        ).called(1);
      },
    );

    blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
      'reverts to methodSelection when user cancels Easebuzz payment',
      build: () {
        when(() => mockRemoteDataSource.createPaymentOrder(any()))
            .thenAnswer((_) async => orderResponse);
        when(() => mockEasebuzzService.payWithEasebuzz(
              accessKey: 'accessKey105',
              payMode: any(named: 'payMode'),
            )).thenAnswer((_) async => cancelResult);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ExecutePaymentEvent()),
      expect: () => [
        isA<PaymentCheckoutState>()
            .having((s) => s.step, 'step', PaymentCheckoutStep.processing)
            .having((s) => s.processingStage, 'stage', 1),
        isA<PaymentCheckoutState>()
            .having((s) => s.step, 'step', PaymentCheckoutStep.processing)
            .having((s) => s.processingStage, 'stage', 2),
        isA<PaymentCheckoutState>()
            .having((s) => s.step, 'step', PaymentCheckoutStep.methodSelection)
            .having((s) => s.errorMessage, 'msg', contains('cancelled')),
      ],
    );
  });
}
