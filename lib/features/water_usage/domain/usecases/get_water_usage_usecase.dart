import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';
import 'package:wua_mobile/features/water_usage/domain/repositories/water_usage_repository.dart';

class GetWaterUsageParams extends Equatable {
  const GetWaterUsageParams({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

class GetWaterUsageUseCase
    extends UseCase<WaterUsageSummaryEntity, GetWaterUsageParams> {
  GetWaterUsageUseCase(this._repository);

  final WaterUsageRepository _repository;

  @override
  Future<Either<Failure, WaterUsageSummaryEntity>> call(
    GetWaterUsageParams params,
  ) {
    return _repository.getWaterUsageSummary(
      forceRefresh: params.forceRefresh,
    );
  }
}

