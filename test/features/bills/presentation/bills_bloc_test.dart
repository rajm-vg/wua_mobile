import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/domain/usecases/get_bill_by_id_usecase.dart';
import 'package:wua_mobile/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_event.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_state.dart';

class MockGetBillsUseCase extends Mock implements GetBillsUseCase {}

class MockGetBillByIdUseCase extends Mock implements GetBillByIdUseCase {}

void main() {
  late MockGetBillsUseCase mockGetBillsUseCase;
  late MockGetBillByIdUseCase mockGetBillByIdUseCase;
  late BillsBloc bloc;

  setUpAll(() {
    registerFallbackValue(const GetBillsParams());
  });

  setUp(() {
    mockGetBillsUseCase = MockGetBillsUseCase();
    mockGetBillByIdUseCase = MockGetBillByIdUseCase();
    bloc = BillsBloc(
      getBillsUseCase: mockGetBillsUseCase,
      getBillByIdUseCase: mockGetBillByIdUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tBill1 = BillEntity(
    id: 'bill_1',
    billNumber: 'WUA/001',
    status: BillStatus.pending,
    season: 'Rabi Season (2024-25)',
    cropType: 'Wheat',
    totalAmount: 1240,
    outstandingAmount: 1240,
  );

  const tBill2 = BillEntity(
    id: 'bill_2',
    billNumber: 'WUA/002',
    status: BillStatus.paid,
    season: 'Kharif Season (2024-25)',
    cropType: 'Sugarcane',
    totalAmount: 2360,
    paidAmount: 2360,
    outstandingAmount: 0,
  );

  final tBills = [tBill1, tBill2];

  test('initial state should be BillsInitial', () {
    expect(bloc.state, equals(const BillsInitial()));
  });

  blocTest<BillsBloc, BillsState>(
    'emits [BillsLoading, BillsLoaded] on successful LoadBillsEvent',
    build: () {
      when(() => mockGetBillsUseCase(any()))
          .thenAnswer((_) async => Right(tBills));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadBillsEvent()),
    expect: () => [
      const BillsLoading(),
      BillsLoaded(
        allBills: tBills,
        filteredBills: tBills,
        selectedStatus: 'ALL',
        searchQuery: '',
      ),
    ],
  );

  blocTest<BillsBloc, BillsState>(
    'emits [BillsLoading, BillsError] on failed LoadBillsEvent',
    build: () {
      when(() => mockGetBillsUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server unreachable')),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadBillsEvent()),
    expect: () => [
      const BillsLoading(),
      const BillsError('Server unreachable'),
    ],
  );

  blocTest<BillsBloc, BillsState>(
    'filters bills by status correctly when FilterBillsByStatusEvent is added',
    build: () {
      when(() => mockGetBillsUseCase(any()))
          .thenAnswer((_) async => Right(tBills));
      return bloc;
    },
    seed: () => BillsLoaded(
      allBills: tBills,
      filteredBills: tBills,
      selectedStatus: 'ALL',
      searchQuery: '',
    ),
    act: (bloc) => bloc.add(const FilterBillsByStatusEvent('PAID')),
    expect: () => [
      BillsLoaded(
        allBills: tBills,
        filteredBills: const [tBill2],
        selectedStatus: 'PAID',
        searchQuery: '',
      ),
    ],
  );
}
