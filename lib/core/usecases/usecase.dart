import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:wua_mobile/core/errors/failures.dart';

/// Base UseCase contract enforcing single-responsibility.
/// Each use case encapsulates exactly one business action.
///
/// [Type] is the return type on success.
/// [Params] is the input parameter type.
///
/// Usage:
/// ```dart
/// class GetBillsUseCase extends UseCase<List<Bill>, GetBillsParams> {
///   @override
///   Future<Either<Failure, List<Bill>>> call(GetBillsParams params) { ... }
/// }
/// ```
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// For use cases that require no parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Base class for paginated request parameters.
class PaginationParams extends Equatable {
  const PaginationParams({this.page = 1, this.limit = 20});
  final int page;
  final int limit;

  @override
  List<Object?> get props => [page, limit];
}
