import 'package:equatable/equatable.dart';

abstract class BillsEvent extends Equatable {
  const BillsEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load bills list, optionally refreshing from server.
class LoadBillsEvent extends BillsEvent {
  const LoadBillsEvent({this.refresh = false, this.consumerId});

  final bool refresh;
  final String? consumerId;

  @override
  List<Object?> get props => [refresh, consumerId];
}

/// Dispatched when the user switches status tabs (e.g. All, Due/Pending, Paid, Overdue).
class FilterBillsByStatusEvent extends BillsEvent {
  const FilterBillsByStatusEvent(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}

/// Dispatched when user types into the bills search box.
class SearchBillsEvent extends BillsEvent {
  const SearchBillsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Dispatched when user requests a specific bill's detailed information.
class LoadBillDetailEvent extends BillsEvent {
  const LoadBillDetailEvent(this.billId);

  final String billId;

  @override
  List<Object?> get props => [billId];
}

/// Dispatched to reset active search query and filter chips.
class ClearBillFiltersEvent extends BillsEvent {
  const ClearBillFiltersEvent();
}
