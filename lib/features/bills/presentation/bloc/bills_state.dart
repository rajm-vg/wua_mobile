import 'package:equatable/equatable.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';

abstract class BillsState extends Equatable {
  const BillsState();

  @override
  List<Object?> get props => [];
}

class BillsInitial extends BillsState {
  const BillsInitial();
}

class BillsLoading extends BillsState {
  const BillsLoading();
}

class BillsLoaded extends BillsState {
  const BillsLoaded({
    required this.allBills,
    required this.filteredBills,
    this.selectedStatus = 'ALL',
    this.searchQuery = '',
  });

  final List<BillEntity> allBills;
  final List<BillEntity> filteredBills;
  final String selectedStatus;
  final String searchQuery;

  /// Total sum of all outstanding dues across pending and overdue bills.
  double get totalOutstandingAmount {
    return allBills
        .where((b) => !b.isPaid)
        .fold(0.0, (sum, b) => sum + b.outstandingAmount);
  }

  /// Total sum of all paid bills in history.
  double get totalPaidAmount {
    return allBills
        .where((b) => b.isPaid)
        .fold(0.0, (sum, b) => sum + b.paidAmount);
  }

  int get pendingCount =>
      allBills.where((b) => !b.isPaid && !b.isOverdue).length;

  int get overdueCount => allBills.where((b) => b.isOverdue).length;

  int get paidCount => allBills.where((b) => b.isPaid).length;

  BillsLoaded copyWith({
    List<BillEntity>? allBills,
    List<BillEntity>? filteredBills,
    String? selectedStatus,
    String? searchQuery,
  }) {
    return BillsLoaded(
      allBills: allBills ?? this.allBills,
      filteredBills: filteredBills ?? this.filteredBills,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    allBills,
    filteredBills,
    selectedStatus,
    searchQuery,
  ];
}

class BillsError extends BillsState {
  const BillsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ─── Individual Bill Detail States ────────────────────────────

class BillDetailLoading extends BillsState {
  const BillDetailLoading();
}

class BillDetailLoaded extends BillsState {
  const BillDetailLoaded(this.bill);

  final BillEntity bill;

  @override
  List<Object?> get props => [bill];
}

class BillDetailError extends BillsState {
  const BillDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
