import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/data/datasources/easebuzz_sdk_service.dart';
import 'package:wua_mobile/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_order_model.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_verify_model.dart';
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
  late MockPaymentRemoteDataSource mockRemoteDataSource;
  late MockEasebuzzSdkService mockEasebuzzService;

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

  const baseState = PaymentCheckoutState(
    bill: tBill,
    selectedMethod: PaymentMethodType.upi,
  );

  setUpAll(() {
    registerFallbackValue(FakeProcessPaymentParams());
    registerFallbackValue(FakeEasebuzzOrderRequest());
    registerFallbackValue(FakeEasebuzzVerifyRequest());
  });

  setUp(() {
    mockRemoteDataSource = MockPaymentRemoteDataSource();
    mockEasebuzzService = MockEasebuzzSdkService();
  });

  PaymentCheckoutBloc buildBloc() {
    return PaymentCheckoutBloc(
      paymentRemoteDataSource: mockRemoteDataSource,
      easebuzzSdkService: mockEasebuzzService,
      initialBill: tBill,
      initialMethod: 'upi',
    );
  }

  test('initial state should have bill and methodSelection step', () {
    final bloc = buildBloc();
    expect(bloc.state.bill, equals(tBill));
    expect(bloc.state.step, equals(PaymentCheckoutStep.methodSelection));
    expect(bloc.state.selectedMethod, equals(PaymentMethodType.upi));
    expect(bloc.state.upiSubMode, equals(UpiSubMode.apps));
    bloc.close();
  });

  blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
    'switches payment methods correctly',
    build: buildBloc,
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
    build: buildBloc,
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
    build: buildBloc,
    act: (bloc) {
      bloc.add(const VerifyUpiVpaEvent('ramesh@oksbi'));
      bloc.add(const VerifyUpiVpaEvent('invalid_vpa'));
    },
    expect: () => [
      baseState.copyWith(
        upiVpa: 'ramesh@oksbi',
        isVpaVerified: true,
        vpaVerifiedName: 'ramesh@oksbi',
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
    build: buildBloc,
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
    'emits failure when Easebuzz is not configured',
    build: () => PaymentCheckoutBloc(
      initialBill: tBill,
      initialMethod: 'upi',
    ),
    act: (bloc) => bloc.add(const ExecutePaymentEvent()),
    expect: () => [
      baseState.copyWith(
        step: PaymentCheckoutStep.failure,
        errorMessage: 'Easebuzz payment gateway is not configured.',
      ),
    ],
  );

  blocTest<PaymentCheckoutBloc, PaymentCheckoutState>(
    'resets from failure state back to method selection',
    build: buildBloc,
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
