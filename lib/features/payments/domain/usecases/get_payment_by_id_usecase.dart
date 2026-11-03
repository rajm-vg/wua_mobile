import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/repositories/payment_repository.dart';

class GetPaymentByIdUseCase extends UseCase<PaymentEntity, String> {
  GetPaymentByIdUseCase(this._repository);

  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaymentEntity>> call(String paymentId) {
    return _repository.getPaymentById(paymentId);
  }
}

