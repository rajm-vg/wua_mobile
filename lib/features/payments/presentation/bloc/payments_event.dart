import 'package:equatable/equatable.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

/// Sort orders supported on the Payments History screen.
enum PaymentSortOption {
  newestFirst,
  oldestFirst,
  amountHighToLow,
  amountLowToHigh,
}

abstract class PaymentsEvent extends Equatable {
  const PaymentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentsEvent extends PaymentsEvent {
  const LoadPaymentsEvent({this.refresh = false, this.consumerId});

  final bool refresh;
  final String? consumerId;

  @override
  List<Object?> get props => [refresh, consumerId];
}

class FilterPaymentsByStatusEvent extends PaymentsEvent {
  const FilterPaymentsByStatusEvent(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}

class FilterPaymentsByFiscalYearEvent extends PaymentsEvent {
  const FilterPaymentsByFiscalYearEvent(this.fiscalYear);

  final String fiscalYear;

  @override
  List<Object?> get props => [fiscalYear];
}

class FilterPaymentsBySeasonEvent extends PaymentsEvent {
  const FilterPaymentsBySeasonEvent(this.season);

  final String season;

  @override
  List<Object?> get props => [season];
}

class FilterPaymentsByModeEvent extends PaymentsEvent {
  const FilterPaymentsByModeEvent(this.paymentMode);

  final String paymentMode;

  @override
  List<Object?> get props => [paymentMode];
}

class SortPaymentsEvent extends PaymentsEvent {
  const SortPaymentsEvent(this.sortOption);

  final PaymentSortOption sortOption;

  @override
  List<Object?> get props => [sortOption];
}

class ApplyPaymentFiltersEvent extends PaymentsEvent {
  const ApplyPaymentFiltersEvent({
    this.status,
    this.fiscalYear,
    this.season,
    this.paymentMode,
    this.sortOption,
  });

  final String? status;
  final String? fiscalYear;
  final String? season;
  final String? paymentMode;
  final PaymentSortOption? sortOption;

  @override
  List<Object?> get props => [
    status,
    fiscalYear,
    season,
    paymentMode,
    sortOption,
  ];
}

class SearchPaymentsEvent extends PaymentsEvent {
  const SearchPaymentsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ClearPaymentFiltersEvent extends PaymentsEvent {
  const ClearPaymentFiltersEvent();
}

class LoadPaymentDetailEvent extends PaymentsEvent {
  const LoadPaymentDetailEvent(this.paymentId);

  final String paymentId;

  @override
  List<Object?> get props => [paymentId];
}

class RecordPaymentEvent extends PaymentsEvent {
  const RecordPaymentEvent(this.payment);

  final PaymentEntity payment;

  @override
  List<Object?> get props => [payment];
}
