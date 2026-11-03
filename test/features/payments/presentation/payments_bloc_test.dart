import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/get_payment_by_id_usecase.dart';
import 'package:wua_mobile/features/payments/domain/usecases/get_payments_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_state.dart';

class MockGetPaymentsUseCase extends Mock implements GetPaymentsUseCase {}

class MockGetPaymentByIdUseCase extends Mock implements GetPaymentByIdUseCase {}

void main() {
  late MockGetPaymentsUseCase mockGetPaymentsUseCase;
  late MockGetPaymentByIdUseCase mockGetPaymentByIdUseCase;
  late PaymentsBloc bloc;

  setUpAll(() {
    registerFallbackValue(const GetPaymentsParams());
  });

  setUp(() {
    mockGetPaymentsUseCase = MockGetPaymentsUseCase();
    mockGetPaymentByIdUseCase = MockGetPaymentByIdUseCase();
    bloc = PaymentsBloc(
      getPaymentsUseCase: mockGetPaymentsUseCase,
      getPaymentByIdUseCase: mockGetPaymentByIdUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tPayment1 = PaymentEntity(
    id: 'pay_1',
    paymentNumber: 'REC/001',
    status: PaymentStatus.success,
    amount: 2360,
    paymentDate: DateTime(2026, 8, 14),
    season: 'Kharif Season (2024-25)',
  );

  final tPayment2 = PaymentEntity(
    id: 'pay_2',
    paymentNumber: 'REC/002',
    status: PaymentStatus.failed,
    amount: 380,
    paymentDate: DateTime(2026, 10, 20),
    season: 'Annual Maintenance Cess',
  );

  final tPayments = [tPayment1, tPayment2];

  test('initial state should be PaymentsInitial', () {
    expect(bloc.state, equals(const PaymentsInitial()));
  });

  blocTest<PaymentsBloc, PaymentsState>(
    'emits [PaymentsLoading, PaymentsLoaded] on successful LoadPaymentsEvent',
    build: () {
      when(() => mockGetPaymentsUseCase(any())).thenAnswer(
        (_) async => Right(tPayments),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadPaymentsEvent()),
    expect: () => [
      const PaymentsLoading(),
      PaymentsLoaded(
        allPayments: tPayments,
        filteredPayments: tPayments,
        selectedStatus: 'ALL',
        searchQuery: '',
      ),
    ],
  );

  blocTest<PaymentsBloc, PaymentsState>(
    'emits [PaymentsLoading, PaymentsError] on failed LoadPaymentsEvent',
    build: () {
      when(() => mockGetPaymentsUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Payment gateway down')),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadPaymentsEvent()),
    expect: () => [
      const PaymentsLoading(),
      const PaymentsError('Payment gateway down'),
    ],
  );

  blocTest<PaymentsBloc, PaymentsState>(
    'filters payments by status correctly when FilterPaymentsByStatusEvent is added',
    build: () => bloc,
    seed: () => PaymentsLoaded(
      allPayments: tPayments,
      filteredPayments: tPayments,
      selectedStatus: 'ALL',
      searchQuery: '',
    ),
    act: (bloc) => bloc.add(const FilterPaymentsByStatusEvent('SUCCESS')),
    expect: () => [
      PaymentsLoaded(
        allPayments: tPayments,
        filteredPayments: [tPayment1],
        selectedStatus: 'SUCCESS',
        searchQuery: '',
      ),
    ],
  );
}

