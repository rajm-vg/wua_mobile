import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/events/app_refresh_notifier.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_state.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/payment_card.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/payment_card_skeleton.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/payment_filters_sheet.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/payments_summary_card.dart';
import 'package:wua_mobile/shared/widgets/wua_bottom_sheet.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Payments history and settlement tracking screen.
/// Supports both mobile phone and responsive web/desktop layouts.
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentsBloc>(
      create: (context) => sl<PaymentsBloc>()..add(const LoadPaymentsEvent()),
      child: const _PaymentsPageView(),
    );
  }
}

class _PaymentsPageView extends StatefulWidget {
  const _PaymentsPageView();

  @override
  State<_PaymentsPageView> createState() => _PaymentsPageViewState();
}

class _PaymentsPageViewState extends State<_PaymentsPageView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    paymentRefreshNotifier.addListener(_onPaymentSettled);
  }

  @override
  void dispose() {
    paymentRefreshNotifier.removeListener(_onPaymentSettled);
    _searchController.dispose();
    super.dispose();
  }

  void _onPaymentSettled() {
    if (!mounted) return;
    context.read<PaymentsBloc>().add(const LoadPaymentsEvent(refresh: true));
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<PaymentsBloc>().add(const LoadPaymentsEvent(refresh: true));
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _openFiltersSheet(BuildContext context, PaymentsLoaded state) async {
    final bloc = context.read<PaymentsBloc>();
    final selection = await showWuaBottomSheet<PaymentFilterSelection>(
      context: context,
      builder: (_) => PaymentFiltersSheet(state: state),
    );
    if (selection == null || !mounted) return;
    bloc.add(
      ApplyPaymentFiltersEvent(
        sortOption: selection.sortOption,
        fiscalYear: selection.fiscalYear,
        season: selection.season,
        paymentMode: selection.paymentMode,
      ),
    );
  }

  String _sortLabel(BuildContext context, PaymentSortOption option) {
    final l10n = context.l10n;
    return switch (option) {
      PaymentSortOption.newestFirst => l10n.newestFirst,
      PaymentSortOption.oldestFirst => l10n.oldestFirst,
      PaymentSortOption.amountHighToLow => l10n.amountHighToLow,
      PaymentSortOption.amountLowToHigh => l10n.amountLowToHigh,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return WuaScaffold(
      title: l10n.paymentHistory,
      subtitle: l10n.paymentSubtitle,
      showBackButton: false,
      scrollable: false,
      padding: EdgeInsets.zero,
      enableMaxConstraint: true,
      maxWidth: 850.0,
      actions: [
        IconButton(
          tooltip: l10n.refresh,
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => _onRefresh(context),
        ),
      ],
      body: BlocBuilder<PaymentsBloc, PaymentsState>(
        builder: (context, state) {
          if (state is PaymentsInitial || state is PaymentsLoading) {
            return _buildLoadingState(context);
          }

          if (state is PaymentsError) {
            return _buildErrorState(context, state.message);
          }

          if (state is PaymentsLoaded) {
            return _buildLoadedContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        PaymentCardSkeleton(),
        PaymentCardSkeleton(),
        PaymentCardSkeleton(),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 36, color: colors.error),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.failedToLoadPayments,
              style: context.titleMedium.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: context.caption),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _onRefresh(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.headerTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, PaymentsLoaded state) {
    final colors = context.colors;
    final l10n = context.l10n;

    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: AppColors.headerTeal,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Top Summary Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
              ),
              child: PaymentsSummaryCard(
                totalAmountPaid: state.totalSuccessfulAmount,
                successCount: state.successCount,
                pendingCount: state.pendingCount,
                failedCount: state.failedCount,
              ),
            ),
          ),

          // 2. Search & Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xs),

                  // Search Field + Sort & Filter Button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: context.bodyMedium.withColor(colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: l10n.searchPaymentsHint,
                              hintStyle: context.caption,
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: colors.textSecondary,
                                size: 20,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<PaymentsBloc>().add(
                                          const SearchPaymentsEvent(''),
                                        );
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (query) {
                              context.read<PaymentsBloc>().add(
                                SearchPaymentsEvent(query),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildSortFilterButton(context, state),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          context,
                          label: '${l10n.filterAll} (${state.allPayments.length})',
                          statusKey: 'ALL',
                          isSelected: state.selectedStatus == 'ALL',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: '${l10n.successful} (${state.successCount})',
                          statusKey: 'SUCCESS',
                          isSelected: state.selectedStatus == 'SUCCESS',
                          isSuccess: true,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: '${l10n.filterPending} (${state.pendingCount})',
                          statusKey: 'PENDING',
                          isSelected: state.selectedStatus == 'PENDING',
                          isWarning: true,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: '${l10n.failed} (${state.failedCount})',
                          statusKey: 'FAILED',
                          isSelected: state.selectedStatus == 'FAILED',
                          isDanger: true,
                        ),
                      ],
                    ),
                  ),

                  // Quick Fiscal Year Filter Chips
                  if (state.availableFiscalYears.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFiscalYearChip(
                            context,
                            label: l10n.allFiscalYears,
                            fiscalYearKey: 'ALL',
                            isSelected: state.selectedFiscalYear == 'ALL',
                          ),
                          for (final fy in state.availableFiscalYears) ...[
                            const SizedBox(width: 8),
                            _buildFiscalYearChip(
                              context,
                              label: 'FY $fy',
                              fiscalYearKey: fy,
                              isSelected: state.selectedFiscalYear == fy,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Active Filter / Sort Summary Strip
                  if (state.hasActiveFilters) ...[
                    const SizedBox(height: 8),
                    _buildActiveSummaryStrip(context, state),
                  ],
                ],
              ),
            ),
          ),

          // 3. Payments List or Empty State
          if (state.filteredPayments.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(context, state),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final payment = state.filteredPayments[index];
                    return PaymentCard(
                      key: ValueKey(payment.id),
                      payment: payment,
                    );
                  },
                  childCount: state.filteredPayments.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 96), // Extra bottom padding for floating bottom nav
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String statusKey,
    required bool isSelected,
    bool isDanger = false,
    bool isSuccess = false,
    bool isWarning = false,
  }) {
    final colors = context.colors;

    Color bg;
    Color fg;
    BorderSide border;

    if (isSelected) {
      if (isDanger) {
        bg = colors.error;
        fg = Colors.white;
      } else if (isSuccess) {
        bg = colors.billCtaBg;
        fg = Colors.white;
      } else if (isWarning) {
        bg = AppColors.warning;
        fg = Colors.white;
      } else {
        bg = colors.billCtaBg;
        fg = Colors.white;
      }
      border = BorderSide.none;
    } else {
      bg = colors.cardBackground;
      fg = isDanger
          ? colors.error
          : (isSuccess
              ? colors.success
              : (isWarning ? colors.warning : colors.textSecondary));
      border = BorderSide(color: colors.cardBorder);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        context.read<PaymentsBloc>().add(FilterPaymentsByStatusEvent(statusKey));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.fromBorderSide(border),
        ),
        child: Text(label, style: context.labelSmall.bold.withColor(fg)),
      ),
    );
  }

  Widget _buildSortFilterButton(BuildContext context, PaymentsLoaded state) {
    final colors = context.colors;
    final l10n = context.l10n;
    final extraFilterCount = (state.selectedFiscalYear != 'ALL' ? 1 : 0) +
        (state.selectedSeason != 'ALL' ? 1 : 0) +
        (state.selectedPaymentMode != 'ALL' ? 1 : 0);
    final isHighlighted =
        extraFilterCount > 0 || state.sortOption != PaymentSortOption.newestFirst;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openFiltersSheet(context, state),
      child: Tooltip(
        message: l10n.sortAndFilter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isHighlighted
                ? colors.canalGreen.withValues(alpha: 0.14)
                : colors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted ? colors.canalGreen : colors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 20,
                color: isHighlighted ? colors.canalGreen : colors.textSecondary,
              ),
              if (extraFilterCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.billCtaBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$extraFilterCount',
                    style: context.labelSmall.bold.withColor(Colors.white).withSize(10.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiscalYearChip(
    BuildContext context, {
    required String label,
    required String fiscalYearKey,
    required bool isSelected,
  }) {
    final colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        context.read<PaymentsBloc>().add(
          FilterPaymentsByFiscalYearEvent(fiscalYearKey),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.canalGreen.withValues(alpha: 0.14)
              : colors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? colors.canalGreen : colors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 12,
              color: isSelected ? colors.canalGreen : colors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: context.labelSmall.bold.withColor(
                isSelected ? colors.canalGreen : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSummaryStrip(BuildContext context, PaymentsLoaded state) {
    final colors = context.colors;
    final l10n = context.l10n;
    final formattedFilteredTotal = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: state.filteredSuccessfulAmount.truncateToDouble() ==
              state.filteredSuccessfulAmount
          ? 0
          : 2,
    ).format(state.filteredSuccessfulAmount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.showingCountOfTotal(
                    state.filteredPayments.length,
                    state.allPayments.length,
                  ),
                  style: context.labelSmall.bold.withColor(colors.textPrimary),
                ),
                if (state.sortOption != PaymentSortOption.newestFirst)
                  Text(
                    '• ${_sortLabel(context, state.sortOption)}',
                    style: context.caption.withColor(colors.canalGreen),
                  ),
                if (state.filteredSuccessfulAmount > 0)
                  Text(
                    '• $formattedFilteredTotal',
                    style: context.caption.bold.withColor(colors.success),
                  ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              _searchController.clear();
              context.read<PaymentsBloc>().add(const ClearPaymentFiltersEvent());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                l10n.resetFilters,
                style: context.labelSmall.bold.withColor(colors.canalGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, PaymentsLoaded state) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isFiltered = state.hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_outlined, size: 32, color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isFiltered ? l10n.noMatchingTransactions : l10n.noPaymentsFound,
              style: context.titleMedium.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? l10n.adjustPaymentFiltersHint
                  : l10n.noPaymentsRecordedHint,
              textAlign: TextAlign.center,
              style: context.caption,
            ),
            if (isFiltered) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  context.read<PaymentsBloc>().add(const ClearPaymentFiltersEvent());
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: Text(l10n.resetFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

