import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/get_payment_by_id_usecase.dart';
import 'package:wua_mobile/features/payments/domain/usecases/get_payments_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  PaymentsBloc({
    required this.getPaymentsUseCase,
    required this.getPaymentByIdUseCase,
  }) : super(const PaymentsInitial()) {
    on<LoadPaymentsEvent>(_onLoadPayments);
    on<FilterPaymentsByStatusEvent>(_onFilterPaymentsByStatus);
    on<FilterPaymentsByFiscalYearEvent>(_onFilterPaymentsByFiscalYear);
    on<FilterPaymentsBySeasonEvent>(_onFilterPaymentsBySeason);
    on<FilterPaymentsByModeEvent>(_onFilterPaymentsByMode);
    on<SortPaymentsEvent>(_onSortPayments);
    on<ApplyPaymentFiltersEvent>(_onApplyPaymentFilters);
    on<SearchPaymentsEvent>(_onSearchPayments);
    on<ClearPaymentFiltersEvent>(_onClearPaymentFilters);
    on<LoadPaymentDetailEvent>(_onLoadPaymentDetail);
    on<RecordPaymentEvent>(_onRecordPayment);
  }

  final GetPaymentsUseCase getPaymentsUseCase;
  final GetPaymentByIdUseCase getPaymentByIdUseCase;

  List<PaymentEntity> _cachedPayments = [];
  String _activeStatus = 'ALL';
  String _activeFiscalYear = 'ALL';
  String _activeSeason = 'ALL';
  String _activePaymentMode = 'ALL';
  PaymentSortOption _activeSort = PaymentSortOption.newestFirst;
  String _activeQuery = '';

  List<PaymentEntity> get _currentAllPayments => state is PaymentsLoaded
      ? (state as PaymentsLoaded).allPayments
      : _cachedPayments;

  void _emitFiltered(
    Emitter<PaymentsState> emit, {
    List<PaymentEntity>? allPayments,
  }) {
    final source = allPayments ?? _currentAllPayments;
    final filtered = _applyFilters(
      payments: source,
      status: _activeStatus,
      fiscalYear: _activeFiscalYear,
      season: _activeSeason,
      paymentMode: _activePaymentMode,
      sortOption: _activeSort,
      query: _activeQuery,
    );
    emit(
      PaymentsLoaded(
        allPayments: source,
        filteredPayments: filtered,
        selectedStatus: _activeStatus,
        selectedFiscalYear: _activeFiscalYear,
        selectedSeason: _activeSeason,
        selectedPaymentMode: _activePaymentMode,
        sortOption: _activeSort,
        searchQuery: _activeQuery,
      ),
    );
  }

  Future<void> _onLoadPayments(
    LoadPaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    if (!event.refresh && state is! PaymentsLoaded) {
      emit(const PaymentsLoading());
    }

    AppLogger.bloc(
      '⚡ [PAYMENTS BLOC] Loading payments (refresh: ${event.refresh})',
    );

    final result = await getPaymentsUseCase(
      GetPaymentsParams(consumerId: event.consumerId),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          '❌ [PAYMENTS BLOC] Error loading payments: ${failure.message}',
        );
        emit(PaymentsError(failure.message));
      },
      (payments) {
        _cachedPayments = payments;
        _emitFiltered(emit, allPayments: _cachedPayments);
      },
    );
  }

  void _onFilterPaymentsByStatus(
    FilterPaymentsByStatusEvent event,
    Emitter<PaymentsState> emit,
  ) {
    _activeStatus = event.status;
    _emitFiltered(emit);
  }

  void _onFilterPaymentsByFiscalYear(
    FilterPaymentsByFiscalYearEvent event,
    Emitter<PaymentsState> emit,
  ) {
    _activeFiscalYear = event.fiscalYear;
    _emitFiltered(emit);
  }

  void _onFilterPaymentsBySeason(
    FilterPaymentsBySeasonEvent event,
    Emitter<PaymentsState> emit,
  ) {
    _activeSeason = event.season;
    _emitFiltered(emit);
  }

  void _onFilterPaymentsByMode(
    FilterPaymentsByModeEvent event,
    Emitter<PaymentsState> emit,
  ) {
    _activePaymentMode = event.paymentMode;
    _emitFiltered(emit);
  }

  void _onSortPayments(SortPaymentsEvent event, Emitter<PaymentsState> emit) {
    _activeSort = event.sortOption;
    _emitFiltered(emit);
  }

  void _onApplyPaymentFilters(
    ApplyPaymentFiltersEvent event,
    Emitter<PaymentsState> emit,
  ) {
    if (event.status != null) _activeStatus = event.status!;
    if (event.fiscalYear != null) _activeFiscalYear = event.fiscalYear!;
    if (event.season != null) _activeSeason = event.season!;
    if (event.paymentMode != null) _activePaymentMode = event.paymentMode!;
    if (event.sortOption != null) _activeSort = event.sortOption!;
    _emitFiltered(emit);
  }

  void _onSearchPayments(
    SearchPaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) {
    _activeQuery = event.query;
    _emitFiltered(emit);
  }

  void _onClearPaymentFilters(
    ClearPaymentFiltersEvent event,
    Emitter<PaymentsState> emit,
  ) {
    _activeStatus = 'ALL';
    _activeFiscalYear = 'ALL';
    _activeSeason = 'ALL';
    _activePaymentMode = 'ALL';
    _activeSort = PaymentSortOption.newestFirst;
    _activeQuery = '';
    _emitFiltered(emit);
  }

  Future<void> _onLoadPaymentDetail(
    LoadPaymentDetailEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(const PaymentDetailLoading());
    AppLogger.bloc(
      '⚡ [PAYMENTS BLOC] Loading payment detail for id: ${event.paymentId}',
    );

    final cached = _cachedPayments
        .where(
          (p) => p.id == event.paymentId || p.paymentNumber == event.paymentId,
        )
        .firstOrNull;

    if (cached != null) {
      emit(PaymentDetailLoaded(cached));
      return;
    }

    final result = await getPaymentByIdUseCase(event.paymentId);
    result.fold(
      (failure) => emit(PaymentDetailError(failure.message)),
      (payment) => emit(PaymentDetailLoaded(payment)),
    );
  }

  List<PaymentEntity> _applyFilters({
    required List<PaymentEntity> payments,
    required String status,
    required String fiscalYear,
    required String season,
    required String paymentMode,
    required PaymentSortOption sortOption,
    required String query,
  }) {
    var list = List<PaymentEntity>.from(payments);

    if (status.toUpperCase() != 'ALL') {
      final s = status.toUpperCase();
      list = list.where((p) => p.status.toUpperCase() == s).toList();
    }

    if (fiscalYear.toUpperCase() != 'ALL') {
      final fy = fiscalYear.trim().toLowerCase();
      list = list
          .where((p) => p.effectiveFiscalYear.trim().toLowerCase() == fy)
          .toList();
    }

    if (season.toUpperCase() != 'ALL') {
      final targetSeason = season.trim().toLowerCase();
      list = list
          .where((p) => p.season.trim().toLowerCase() == targetSeason)
          .toList();
    }

    if (paymentMode.toUpperCase() != 'ALL') {
      final targetMode = paymentMode.trim().toLowerCase();
      list = list
          .where((p) => p.paymentMode.trim().toLowerCase() == targetMode)
          .toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) {
        return p.paymentNumber.toLowerCase().contains(q) ||
            p.season.toLowerCase().contains(q) ||
            p.cropType.toLowerCase().contains(q) ||
            p.effectiveFiscalYear.toLowerCase().contains(q) ||
            (p.gatewayTransactionId?.toLowerCase().contains(q) ?? false) ||
            (p.bankReference?.toLowerCase().contains(q) ?? false) ||
            (p.billNumber?.toLowerCase().contains(q) ?? false) ||
            p.paymentMode.toLowerCase().contains(q);
      }).toList();
    }

    switch (sortOption) {
      case PaymentSortOption.newestFirst:
        list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      case PaymentSortOption.oldestFirst:
        list.sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
      case PaymentSortOption.amountHighToLow:
        list.sort((a, b) {
          final cmp = b.amount.compareTo(a.amount);
          return cmp != 0 ? cmp : b.paymentDate.compareTo(a.paymentDate);
        });
      case PaymentSortOption.amountLowToHigh:
        list.sort((a, b) {
          final cmp = a.amount.compareTo(b.amount);
          return cmp != 0 ? cmp : b.paymentDate.compareTo(a.paymentDate);
        });
    }

    return list;
  }

  void _onRecordPayment(RecordPaymentEvent event, Emitter<PaymentsState> emit) {
    _cachedPayments = [event.payment, ..._cachedPayments];
    _emitFiltered(emit, allPayments: _cachedPayments);
  }
}
