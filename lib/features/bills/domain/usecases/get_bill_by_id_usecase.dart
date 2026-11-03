import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/domain/repositories/bill_repository.dart';

/// Retrieves a single bill by its unique ID.
class GetBillByIdUseCase extends UseCase<BillEntity, String> {
  GetBillByIdUseCase(this._repository);

  final BillRepository _repository;

  @override
  Future<Either<Failure, BillEntity>> call(String billId) {
    return _repository.getBillById(billId);
  }
}
