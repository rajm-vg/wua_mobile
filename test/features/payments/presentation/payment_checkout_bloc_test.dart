import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class MockProcessPaymentUseCase extends Mock implements ProcessPaymentUseCase {}

class FakeProcessPaymentParams extends Fake implements ProcessPaymentParams {}

void main() {
  late MockProcessPaymentUseCase mockProcessPaymentUseCase;
  late PaymentCheckoutBloc bloc;

  const tBill = BillEntity(
    id: 'bill_rabi_01',
    billNumber: 'WUA/PANI/2024/001',
    status: BillStatus.pending,
    totalAmount: 1240.0,
    outstandingAmount: 1240.0,
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
    paymentDate: DateTime(2026, 11, 16),
    billId: 'bill_rabi_01',
    billNumber: 'WUA/PANI/2024/001',
  );

  const baseState = PaymentCheckoutState(
    bill: tBill,
    selectedMethod: PaymentMethodType.upi,
  );

  setUpAll(() {
    registerFallbackValue(FakeProcessPaymentParams());
  });

  setUp(() {
    mockProcessPaymentUseCase = MockProcessPaymentUseCase();
    bloc = PaymentCheckoutBloc(
      processPaymentUseCase: mockProcessPaymentUseCase,
      initialBill: tBill,
      initialMethod: 'upi',
      delayDuration: Duration.zero, // Instant for fast tests
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should have bill and methodSelection step', () {
    expect(bloc.state.bill, equals(tBill));
    expect(bloc.state.step, equals(PaymentCheckoutStep.methodSelection));
    expect(bloc.state.selectedMethod, equals(PaymentMethodType.upi));
    expect(bloc.state.upiSubMode, equals(UpiSubMode.apps));
  });

  blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
    'switches payment methods correctly',
    build: () => bloc,
    act: (bloc) {
      bloc.add(const SelectPaymentMethodEvent(PaymentMethodType.netBanking));
      bloc.add(const SelectPaymentMethodEvent(PaymentMethodType.card));
    },
    expect: () => [
      baseState.copyWith(selectedMethod: PaymentMethodType.netBanking),
      baseState.copyWith(selectedMethod: PaymentMethodType.card),
    ],
  );

  blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
    'switches UPI sub-modes and selects UPI apps',
    build: () => bloc,
    act: (bloc) {
      bloc.add(const SelectUpiSubModeEvent(UpiSubMode.vpa));
      bloc.add(const SelectUpiAppEvent('PhonePe'));
    },
    expect: () => [
      baseState.copyWith(upiSubMode: UpiSubMode.vpa),
      baseState.copyWith(
        upiSubMode: UpiSubMode.vpa,
        selectedUpiApp: 'PhonePe',
      ),
    ],
  );

  blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
    'verifies valid UPI VPA and rejects invalid VPA',
    build: () => bloc,
    act: (bloc) {
      bloc.add(const VerifyUpiVpaEvent('ramesh@oksbi'));
      bloc.add(const VerifyUpiVpaEvent('invalid_vpa'));
    },
    expect: () => [
      baseState.copyWith(
        upiVpa: 'ramesh@oksbi',
        isVpaVerified: true,
        vpaVerifiedName: 'Ramesh D. Patil',
      ),
      baseState.copyWith(
        upiVpa: 'invalid_vpa',
        isVpaVerified: false,
        vpaVerifiedName: null,
      ),
    ],
  );

  blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
    'updates bank selection and card details',
    build: () => bloc,
    act: (bloc) {
      bloc.add(const SelectBankEvent('HDFC Bank'));
      bloc.add(const UpdateCardDetailsEvent(
        cardNumber: '5085 0241 8920 4120',
        cardHolder: 'RAMESH PATIL',
      ));
    },
    expect: () => [
      baseState.copyWith(selectedBank: 'HDFC Bank'),
      baseState.copyWith(
        selectedBank: 'HDFC Bank',
        cardNumber: '5085 0241 8920 4120',
        cardHolder: 'RAMESH PATIL',
      ),
    ],
    verify: (bloc) {
      expect(bloc.state.detectedCardBrand, contains('RuPay'));
    },
  );

  blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
    'successfully completes payment execution flow',
    build: () {
      when(() => mockProcessPaymentUseCase(any()))
          .thenAnswer((_) async => Right(tPayment));
      return bloc;
    },
    act: (bloc) => bloc.add(const ExecutePaymentEvent()),
    expect: () => [
      baseState.copyWith(
        step: PaymentCheckoutStep.processing,
        processingStage: 1,
        errorMessage: null,
      ),
      baseState.copyWith(
        step: PaymentCheckoutStep.processing,
        processingStage: 2,
        errorMessage: null,
      ),
      baseState.copyWith(
        step: PaymentCheckoutStep.processing,
        processingStage: 3,
        errorMessage: null,
      ),
      baseState.copyWith(
        step: PaymentCheckoutStep.success,
        processingStage: 3,
        completedPayment: tPayment,
      ),
    ],
    verify: (_) {
      verify(() => mockProcessPaymentUseCase(any())).called(1);
    },
  );

  blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
    'handles simulated payment gateway failure',
    build: () => bloc,
    act: (bloc) {
      bloc.add(const ToggleSimulateFailureEvent(true));
      bloc.add(const ExecutePaymentEvent());
    },
    expect: () => [
      baseState.copyWith(simulateFailure: true),
      baseState.copyWith(
        simulateFailure: true,
        step: PaymentCheckoutStep.processing,
        processingStage: 1,
        errorMessage: null,
      ),
      baseState.copyWith(
        simulateFailure: true,
        step: PaymentCheckoutStep.processing,
        processingStage: 2,
        errorMessage: null,
      ),
      baseState.copyWith(
        simulateFailure: true,
        step: PaymentCheckoutStep.processing,
        processingStage: 3,
        errorMessage: null,
      ),
      baseState.copyWith(
        simulateFailure: true,
        step: PaymentCheckoutStep.failure,
        processingStage: 3,
        errorMessage:
            'Bank gateway response timed out (ERR_NPCI_TIMED_OUT). No funds were deducted.',
      ),
    ],
  );

  blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
    'resets from failure state back to method selection',
    build: () => bloc,
    seed: () => baseState.copyWith(
      step: PaymentCheckoutStep.failure,
      errorMessage: 'Sample failure',
    ),
    act: (bloc) => bloc.add(const ResetPaymentCheckoutEvent()),
    expect: () => [
      baseState.copyWith(
        step: PaymentCheckoutStep.methodSelection,
        processingStage: 1,
        errorMessage: null,
      ),
    ],
  );
}
