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
    season: 'Kharif',
    fiscalYear: '2026-2027',
    paymentMode: 'Online',
  );

  final tPayment2 = PaymentEntity(
    id: 'pay_2',
    paymentNumber: 'REC/002',
    status: PaymentStatus.failed,
    amount: 380,
    paymentDate: DateTime(2026, 10, 20),
    season: 'Rabi',
    fiscalYear: '2026-2027',
    paymentMode: 'UPI',
  );

  final tPayment3 = PaymentEntity(
    id: 'pay_3',
    paymentNumber: 'REC/003',
    status: PaymentStatus.success,
    amount: 1200,
    paymentDate: DateTime(2026, 2, 10),
    season: 'Rabi',
    fiscalYear: '2025-2026',
    paymentMode: 'Online',
  );

  final tPayments = [tPayment1, tPayment2, tPayment3];

  test('initial state should be PaymentsInitial', () {
    expect(bloc.state, equals(const PaymentsInitial()));
  });

  blocTest<PaymentsBloc, PaymentsState>(
    'emits [PaymentsLoading, PaymentsLoaded] sorted newest-first on LoadPaymentsEvent',
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
        filteredPayments: [tPayment2, tPayment1, tPayment3],
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
      filteredPayments: [tPayment2, tPayment1, tPayment3],
    ),
    act: (bloc) => bloc.add(const FilterPaymentsByStatusEvent('SUCCESS')),
    expect: () => [
      PaymentsLoaded(
        allPayments: tPayments,
        filteredPayments: [tPayment1, tPayment3],
        selectedStatus: 'SUCCESS',
      ),
    ],
  );

  blocTest<PaymentsBloc, PaymentsState>(
    'filters payments by fiscal year correctly',
    build: () => bloc,
    seed: () => PaymentsLoaded(
      allPayments: tPayments,
      filteredPayments: [tPayment2, tPayment1, tPayment3],
    ),
    act: (bloc) => bloc.add(const FilterPaymentsByFiscalYearEvent('2025-2026')),
    expect: () => [
      PaymentsLoaded(
        allPayments: tPayments,
        filteredPayments: [tPayment3],
        selectedFiscalYear: '2025-2026',
      ),
    ],
  );

  blocTest<PaymentsBloc, PaymentsState>(
    'sorts payments by amountHighToLow and oldestFirst',
    build: () => bloc,
    seed: () => PaymentsLoaded(
      allPayments: tPayments,
      filteredPayments: [tPayment2, tPayment1, tPayment3],
    ),
    act: (bloc) {
      bloc.add(const SortPaymentsEvent(PaymentSortOption.amountHighToLow));
      bloc.add(const SortPaymentsEvent(PaymentSortOption.oldestFirst));
    },
    expect: () => [
      PaymentsLoaded(
        allPayments: tPayments,
        filteredPayments: [tPayment1, tPayment3, tPayment2],
        sortOption: PaymentSortOption.amountHighToLow,
      ),
      PaymentsLoaded(
        allPayments: tPayments,
        filteredPayments: [tPayment3, tPayment1, tPayment2],
        sortOption: PaymentSortOption.oldestFirst,
      ),
    ],
  );

  blocTest<PaymentsBloc, PaymentsState>(
    'applies combined filters (season + mode) and resets cleanly',
    build: () => bloc,
    seed: () => PaymentsLoaded(
      allPayments: tPayments,
      filteredPayments: [tPayment2, tPayment1, tPayment3],
    ),
    act: (bloc) {
      bloc.add(
        const ApplyPaymentFiltersEvent(
          season: 'Rabi',
          paymentMode: 'Online',
          sortOption: PaymentSortOption.amountLowToHigh,
        ),
      );
      bloc.add(const ClearPaymentFiltersEvent());
    },
    expect: () => [
      PaymentsLoaded(
        allPayments: tPayments,
        filteredPayments: [tPayment3],
        selectedSeason: 'Rabi',
        selectedPaymentMode: 'Online',
        sortOption: PaymentSortOption.amountLowToHigh,
      ),
      PaymentsLoaded(
        allPayments: tPayments,
        filteredPayments: [tPayment2, tPayment1, tPayment3],
      ),
    ],
  );
}
