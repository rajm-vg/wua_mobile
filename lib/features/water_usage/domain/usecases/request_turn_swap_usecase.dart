import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/water_usage/domain/repositories/water_usage_repository.dart';

class RequestTurnSwapParams extends Equatable {
  const RequestTurnSwapParams({
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

class RequestTurnSwapUseCase extends UseCase<bool, RequestTurnSwapParams> {
  RequestTurnSwapUseCase(this._repository);

  final WaterUsageRepository _repository;

  @override
  Future<Either<Failure, bool>> call(RequestTurnSwapParams params) {
    return _repository.requestTurnSwap(
      turnId: params.turnId,
      preferredDate: params.preferredDate,
      reason: params.reason,
      swappedWithFarmer: params.swappedWithFarmer,
    );
  }
}

