import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';

/// Contract for Bills repository data operations.
abstract class BillRepository {
  /// Fetches all bills matching optional filters.
  Future<Either<Failure, List<BillEntity>>> getBills({
    String? consumerId,
    String? status,
    String? query,
  });

  /// Fetches a specific bill by its unique ID.
  Future<Either<Failure, BillEntity>> getBillById(String id);
}
