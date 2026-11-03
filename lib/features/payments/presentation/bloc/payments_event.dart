import 'package:equatable/equatable.dart';

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

