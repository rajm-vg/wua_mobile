import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';
import 'package:wua_mobile/features/water_usage/domain/usecases/get_water_usage_usecase.dart';
import 'package:wua_mobile/features/water_usage/domain/usecases/request_turn_swap_usecase.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_bloc.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_event.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_state.dart';

class MockGetWaterUsageUseCase extends Mock implements GetWaterUsageUseCase {}

class MockRequestTurnSwapUseCase extends Mock
    implements RequestTurnSwapUseCase {}

void main() {
  late MockGetWaterUsageUseCase mockGetWaterUsageUseCase;
  late MockRequestTurnSwapUseCase mockRequestTurnSwapUseCase;
  late WaterUsageBloc bloc;

  setUpAll(() {
    registerFallbackValue(const GetWaterUsageParams());
    registerFallbackValue(
      RequestTurnSwapParams(
        turnId: 'turn_1',
        preferredDate: DateTime(2026, 11, 2),
        reason: 'Reason',
      ),
    );
  });

  setUp(() {
    mockGetWaterUsageUseCase = MockGetWaterUsageUseCase();
    mockRequestTurnSwapUseCase = MockRequestTurnSwapUseCase();
    bloc = WaterUsageBloc(
      getWaterUsageUseCase: mockGetWaterUsageUseCase,
      requestTurnSwapUseCase: mockRequestTurnSwapUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tTurn1 = IrrigationTurnEntity(
    id: 'turn_1',
    turnNumber: 1,
    season: 'Rabi 2024-25',
    status: TurnStatus.completed,
    scheduledStartTime: DateTime(2026, 9, 18, 8, 0),
    scheduledEndTime: DateTime(2026, 9, 18, 18, 0),
    durationHours: 10.0,
    outletNo: 'Outlet 12',
    gateNo: 'Gate #4',
    dischargeCusecs: 50.0,
    waterDeliveredHaCm: 3.5,
    crop: 'Wheat',
    fieldParcel: 'Survey 42/1A',
  );

  final tTurn2 = IrrigationTurnEntity(
    id: 'turn_2',
    turnNumber: 2,
    season: 'Rabi 2024-25',
    status: TurnStatus.upcoming,
    scheduledStartTime: DateTime(2026, 10, 31, 8, 0),
    scheduledEndTime: DateTime(2026, 10, 31, 20, 0),
    durationHours: 12.0,
    outletNo: 'Outlet 12',
    gateNo: 'Gate #4',
    dischargeCusecs: 50.0,
    waterDeliveredHaCm: 3.8,
    crop: 'Wheat',
    fieldParcel: 'Survey 42/1A',
  );

  const tQuota = WaterQuotaEntity(
    season: 'Rabi 2024-25',
    totalQuotaHaCm: 20.0,
    usedQuotaHaCm: 14.2,
    remainingQuotaHaCm: 5.8,
    percentageUsed: 71.0,
    canalName: 'Minor-3',
    canalStatus: 'Active',
    currentFlowCusecs: 125.0,
    outletNumber: 'Outlet 12',
    wuaSocietyName: 'Society',
    farmerName: 'Ramesh',
    totalTurnsCount: 5,
    completedTurnsCount: 3,
    cropBreakdown: [],
  );

  final tSummary = WaterUsageSummaryEntity(
    quota: tQuota,
    nextTurn: tTurn2,
    allTurns: [tTurn1, tTurn2],
  );

  test('initial state should be WaterUsageInitial', () {
    expect(bloc.state, equals(const WaterUsageInitial()));
  });

  blocTest<WaterUsageBloc, WaterUsageState>(
    'emits [WaterUsageLoading, WaterUsageLoaded] on successful LoadWaterUsageEvent',
    build: () {
      when(() => mockGetWaterUsageUseCase(any()))
          .thenAnswer((_) async => Right(tSummary));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadWaterUsageEvent()),
    expect: () => [
      const WaterUsageLoading(),
      WaterUsageLoaded(
        summary: tSummary,
        filteredTurns: [tTurn1, tTurn2],
        selectedStatusFilter: 'ALL',
      ),
    ],
  );

  blocTest<WaterUsageBloc, WaterUsageState>(
    'emits [WaterUsageLoading, WaterUsageError] on failed LoadWaterUsageEvent',
    build: () {
      when(() => mockGetWaterUsageUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server unreachable')),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadWaterUsageEvent()),
    expect: () => [
      const WaterUsageLoading(),
      const WaterUsageError('Server unreachable'),
    ],
  );

  blocTest<WaterUsageBloc, WaterUsageState>(
    'filters turns by status correctly when FilterTurnsByStatusEvent is added',
    build: () {
      when(() => mockGetWaterUsageUseCase(any()))
          .thenAnswer((_) async => Right(tSummary));
      return bloc;
    },
    seed: () => WaterUsageLoaded(
      summary: tSummary,
      filteredTurns: [tTurn1, tTurn2],
      selectedStatusFilter: 'ALL',
    ),
    act: (bloc) => bloc.add(const FilterTurnsByStatusEvent('COMPLETED')),
    expect: () => [
      WaterUsageLoaded(
        summary: tSummary,
        filteredTurns: [tTurn1],
        selectedStatusFilter: 'COMPLETED',
      ),
    ],
  );
}
