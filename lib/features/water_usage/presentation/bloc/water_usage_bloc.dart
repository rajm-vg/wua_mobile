import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';
import 'package:wua_mobile/features/water_usage/domain/usecases/get_water_usage_usecase.dart';
import 'package:wua_mobile/features/water_usage/domain/usecases/request_turn_swap_usecase.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_event.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_state.dart';

class WaterUsageBloc extends Bloc<WaterUsageEvent, WaterUsageState> {
  WaterUsageBloc({
    required this.getWaterUsageUseCase,
    required this.requestTurnSwapUseCase,
  }) : super(const WaterUsageInitial()) {
    on<LoadWaterUsageEvent>(_onLoadWaterUsage);
    on<FilterTurnsByStatusEvent>(_onFilterTurnsByStatus);
    on<SubmitTurnSwapEvent>(_onSubmitTurnSwap);
  }

  final GetWaterUsageUseCase getWaterUsageUseCase;
  final RequestTurnSwapUseCase requestTurnSwapUseCase;

  WaterUsageSummaryEntity? _cachedSummary;
  String _activeStatus = 'ALL';

  Future<void> _onLoadWaterUsage(
    LoadWaterUsageEvent event,
    Emitter<WaterUsageState> emit,
  ) async {
    if (!event.refresh && state is! WaterUsageLoaded) {
      emit(const WaterUsageLoading());
    }

    AppLogger.bloc('⚡ [WATER USAGE BLOC] Loading summary (refresh: ${event.refresh})');

    final result = await getWaterUsageUseCase(
      GetWaterUsageParams(forceRefresh: event.refresh),
    );

    result.fold(
      (failure) {
        AppLogger.error('❌ [WATER USAGE BLOC] Error: ${failure.message}');
        emit(WaterUsageError(failure.message));
      },
      (summary) {
        _cachedSummary = summary;
        final filtered = _filterTurns(summary.allTurns, _activeStatus);
        emit(
          WaterUsageLoaded(
            summary: summary,
            filteredTurns: filtered,
            selectedStatusFilter: _activeStatus,
          ),
        );
      },
    );
  }

  void _onFilterTurnsByStatus(
    FilterTurnsByStatusEvent event,
    Emitter<WaterUsageState> emit,
  ) {
    _activeStatus = event.status;
    final currentState = state;
    if (currentState is WaterUsageLoaded) {
      final turns = _cachedSummary?.allTurns ?? currentState.allTurns;
      final filtered = _filterTurns(turns, event.status);
      emit(
        currentState.copyWith(
          selectedStatusFilter: event.status,
          filteredTurns: filtered,
        ),
      );
    }
  }

  Future<void> _onSubmitTurnSwap(
    SubmitTurnSwapEvent event,
    Emitter<WaterUsageState> emit,
  ) async {
    final currentState = state;
    if (currentState is WaterUsageLoaded) {
      emit(currentState.copyWith(isSubmittingSwap: true, clearSwapMessage: true));

      final result = await requestTurnSwapUseCase(
        RequestTurnSwapParams(
          turnId: event.turnId,
          preferredDate: event.preferredDate,
          reason: event.reason,
          swappedWithFarmer: event.swappedWithFarmer,
        ),
      );

      result.fold(
        (failure) {
          emit(
            currentState.copyWith(
              isSubmittingSwap: false,
              swapSuccessMessage: 'Failed: ${failure.message}',
            ),
          );
        },
        (success) {
          // Re-fetch fresh data after swap
          add(const LoadWaterUsageEvent(refresh: true));
        },
      );
    }
  }

  List<IrrigationTurnEntity> _filterTurns(
    List<IrrigationTurnEntity> turns,
    String status,
  ) {
    if (status == 'ALL') return turns;
    if (status == 'UPCOMING') {
      return turns.where((t) => t.isUpcoming || t.isActive).toList();
    }
    if (status == 'COMPLETED') {
      return turns.where((t) => t.isCompleted).toList();
    }
    return turns
        .where((t) => t.status.toUpperCase() == status.toUpperCase())
        .toList();
  }
}

