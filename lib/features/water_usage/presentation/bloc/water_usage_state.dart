import 'package:equatable/equatable.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

abstract class WaterUsageState extends Equatable {
  const WaterUsageState();

  @override
  List<Object?> get props => [];
}

class WaterUsageInitial extends WaterUsageState {
  const WaterUsageInitial();
}

class WaterUsageLoading extends WaterUsageState {
  const WaterUsageLoading();
}

class WaterUsageLoaded extends WaterUsageState {
  const WaterUsageLoaded({
    required this.summary,
    required this.filteredTurns,
    this.selectedStatusFilter = 'ALL',
    this.isSubmittingSwap = false,
    this.swapSuccessMessage,
  });

  final WaterUsageSummaryEntity summary;
  final List<IrrigationTurnEntity> filteredTurns;
  final String selectedStatusFilter;
  final bool isSubmittingSwap;
  final String? swapSuccessMessage;

  WaterQuotaEntity get quota => summary.quota;
  IrrigationTurnEntity? get nextTurn => summary.nextTurn;
  List<IrrigationTurnEntity> get allTurns => summary.allTurns;

  WaterUsageLoaded copyWith({
    WaterUsageSummaryEntity? summary,
    List<IrrigationTurnEntity>? filteredTurns,
    String? selectedStatusFilter,
    bool? isSubmittingSwap,
    String? swapSuccessMessage,
    bool clearSwapMessage = false,
  }) {
    return WaterUsageLoaded(
      summary: summary ?? this.summary,
      filteredTurns: filteredTurns ?? this.filteredTurns,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      isSubmittingSwap: isSubmittingSwap ?? this.isSubmittingSwap,
      swapSuccessMessage: clearSwapMessage
          ? null
          : (swapSuccessMessage ?? this.swapSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        summary,
        filteredTurns,
        selectedStatusFilter,
        isSubmittingSwap,
        swapSuccessMessage,
      ];
}

class WaterUsageError extends WaterUsageState {
  const WaterUsageError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

