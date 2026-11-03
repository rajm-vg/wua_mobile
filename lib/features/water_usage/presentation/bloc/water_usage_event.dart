import 'package:equatable/equatable.dart';

abstract class WaterUsageEvent extends Equatable {
  const WaterUsageEvent();

  @override
  List<Object?> get props => [];
}

class LoadWaterUsageEvent extends WaterUsageEvent {
  const LoadWaterUsageEvent({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => [refresh];
}

class FilterTurnsByStatusEvent extends WaterUsageEvent {
  const FilterTurnsByStatusEvent(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}

class SubmitTurnSwapEvent extends WaterUsageEvent {
  const SubmitTurnSwapEvent({
    required this.turnId,
    required this.preferredDate,
    required this.reason,
    this.swappedWithFarmer,
  });

  final String turnId;
  final DateTime preferredDate;
  final String reason;
  final String? swappedWithFarmer;

  @override
  List<Object?> get props => [turnId, preferredDate, reason, swappedWithFarmer];
}

