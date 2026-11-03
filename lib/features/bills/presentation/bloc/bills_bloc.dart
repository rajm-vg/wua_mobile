import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/domain/usecases/get_bill_by_id_usecase.dart';
import 'package:wua_mobile/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_event.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_state.dart';

/// Business logic component for managing Irrigation Bills list, filtering, and details.
class BillsBloc extends Bloc<BillsEvent, BillsState> {
  BillsBloc({required this.getBillsUseCase, required this.getBillByIdUseCase})
    : super(const BillsInitial()) {
    on<LoadBillsEvent>(_onLoadBills);
    on<FilterBillsByStatusEvent>(_onFilterBillsByStatus);
    on<SearchBillsEvent>(_onSearchBills);
    on<ClearBillFiltersEvent>(_onClearBillFilters);
    on<LoadBillDetailEvent>(_onLoadBillDetail);
  }

  final GetBillsUseCase getBillsUseCase;
  final GetBillByIdUseCase getBillByIdUseCase;

  List<BillEntity> _cachedBills = [];
  String _activeStatus = 'ALL';
  String _activeQuery = '';

  Future<void> _onLoadBills(
    LoadBillsEvent event,
    Emitter<BillsState> emit,
  ) async {
    if (!event.refresh && state is! BillsLoaded) {
      emit(const BillsLoading());
    }

    AppLogger.bloc('⚡ [BILLS BLOC] Loading bills (refresh: ${event.refresh})');

    final result = await getBillsUseCase(
      GetBillsParams(consumerId: event.consumerId),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          '❌ [BILLS BLOC] Error loading bills: ${failure.message}',
        );
        emit(BillsError(failure.message));
      },
      (bills) {
        _cachedBills = bills;
        final filtered = _applyFilters(
          bills: _cachedBills,
          status: _activeStatus,
          query: _activeQuery,
        );
        emit(
          BillsLoaded(
            allBills: _cachedBills,
            filteredBills: filtered,
            selectedStatus: _activeStatus,
            searchQuery: _activeQuery,
          ),
        );
      },
    );
  }

  void _onFilterBillsByStatus(
    FilterBillsByStatusEvent event,
    Emitter<BillsState> emit,
  ) {
    final allBills = state is BillsLoaded
        ? (state as BillsLoaded).allBills
        : _cachedBills;
    _activeStatus = event.status;
    final currentFiltered = _applyFilters(
      bills: allBills,
      status: _activeStatus,
      query: _activeQuery,
    );

    emit(
      BillsLoaded(
        allBills: allBills,
        filteredBills: currentFiltered,
        selectedStatus: _activeStatus,
        searchQuery: _activeQuery,
      ),
    );
  }

  void _onSearchBills(SearchBillsEvent event, Emitter<BillsState> emit) {
    final allBills = state is BillsLoaded
        ? (state as BillsLoaded).allBills
        : _cachedBills;
    _activeQuery = event.query;
    final currentFiltered = _applyFilters(
      bills: allBills,
      status: _activeStatus,
      query: _activeQuery,
    );

    emit(
      BillsLoaded(
        allBills: allBills,
        filteredBills: currentFiltered,
        selectedStatus: _activeStatus,
        searchQuery: _activeQuery,
      ),
    );
  }

  void _onClearBillFilters(
    ClearBillFiltersEvent event,
    Emitter<BillsState> emit,
  ) {
    final allBills = state is BillsLoaded
        ? (state as BillsLoaded).allBills
        : _cachedBills;
    _activeStatus = 'ALL';
    _activeQuery = '';
    emit(
      BillsLoaded(
        allBills: allBills,
        filteredBills: allBills,
        selectedStatus: 'ALL',
        searchQuery: '',
      ),
    );
  }

  Future<void> _onLoadBillDetail(
    LoadBillDetailEvent event,
    Emitter<BillsState> emit,
  ) async {
    emit(const BillDetailLoading());
    AppLogger.bloc(
      '⚡ [BILLS BLOC] Loading bill detail for id: ${event.billId}',
    );

    // First check in-memory cache for instant response
    final cached = _cachedBills
        .where((b) => b.id == event.billId || b.billNumber == event.billId)
        .firstOrNull;
    if (cached != null) {
      emit(BillDetailLoaded(cached));
      return;
    }

    final result = await getBillByIdUseCase(event.billId);
    result.fold(
      (failure) => emit(BillDetailError(failure.message)),
      (bill) => emit(BillDetailLoaded(bill)),
    );
  }

  List<BillEntity> _applyFilters({
    required List<BillEntity> bills,
    required String status,
    required String query,
  }) {
    var list = bills;

    if (status.toUpperCase() != 'ALL') {
      final s = status.toUpperCase();
      if (s == 'DUE' || s == 'PENDING') {
        list = list.where((b) => !b.isPaid && !b.isOverdue).toList();
      } else if (s == 'OVERDUE') {
        list = list.where((b) => b.isOverdue).toList();
      } else if (s == 'PAID') {
        list = list.where((b) => b.isPaid).toList();
      }
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((b) {
        return b.billNumber.toLowerCase().contains(q) ||
            b.season.toLowerCase().contains(q) ||
            b.cropType.toLowerCase().contains(q) ||
            (b.wuaSocietyName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return list;
  }
}
