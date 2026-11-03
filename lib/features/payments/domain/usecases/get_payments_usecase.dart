import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/repositories/payment_repository.dart';

class GetPaymentsParams extends Equatable {
  const GetPaymentsParams({
    this.consumerId,
    this.status,
    this.query,
  });

  final String? consumerId;
  final String? status;
  final String? query;

  @override
  List<Object?> get props => [consumerId, status, query];
}

class GetPaymentsUseCase extends UseCase<List<PaymentEntity>, GetPaymentsParams> {
  GetPaymentsUseCase(this._repository);

  final PaymentRepository _repository;

  @override
  Future<Either<Failure, List<PaymentEntity>>> call(GetPaymentsParams params) {
    return _repository.getPayments(
      consumerId: params.consumerId,
      status: params.status,
      query: params.query,
    );
  }
}

