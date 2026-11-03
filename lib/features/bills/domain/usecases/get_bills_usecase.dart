import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/domain/repositories/bill_repository.dart';

/// Parameters for querying the list of bills.
class GetBillsParams extends Equatable {
  const GetBillsParams({this.consumerId, this.status, this.query});

  final String? consumerId;
  final String? status;
  final String? query;

  @override
  List<Object?> get props => [consumerId, status, query];
}

/// Retrieves list of bills matching given parameters.
class GetBillsUseCase extends UseCase<List<BillEntity>, GetBillsParams> {
  GetBillsUseCase(this._repository);

  final BillRepository _repository;

  @override
  Future<Either<Failure, List<BillEntity>>> call(GetBillsParams params) {
    return _repository.getBills(
      consumerId: params.consumerId,
      status: params.status,
      query: params.query,
    );
  }
}
