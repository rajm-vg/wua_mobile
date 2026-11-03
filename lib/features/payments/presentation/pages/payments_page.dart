import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_state.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/payment_card.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/payment_card_skeleton.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/payments_summary_card.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<PaymentsBloc>().add(const LoadPaymentsEvent(refresh: true));
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return WuaScaffold(
      title: 'Payment History',
      subtitle: 'Irrigation Dues & Transactions • भरणा इतिहास',
      showBackButton: false,
      scrollable: false,
      padding: EdgeInsets.zero,
      enableMaxConstraint: true,
      maxWidth: 850.0,
      actions: [
        IconButton(
          tooltip: 'Refresh Payments',
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
              'Failed to load payment history',
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
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, PaymentsLoaded state) {
    final colors = context.colors;

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

                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: context.bodyMedium.withColor(colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search by receipt no, mode, or season...',
                        hintStyle: context.caption,
                        prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<PaymentsBloc>().add(const SearchPaymentsEvent(''));
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (query) {
                        context.read<PaymentsBloc>().add(SearchPaymentsEvent(query));
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          context,
                          label: 'All (${state.allPayments.length})',
                          statusKey: 'ALL',
                          isSelected: state.selectedStatus == 'ALL',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Successful (${state.successCount})',
                          statusKey: 'SUCCESS',
                          isSelected: state.selectedStatus == 'SUCCESS',
                          isSuccess: true,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Pending (${state.pendingCount})',
                          statusKey: 'PENDING',
                          isSelected: state.selectedStatus == 'PENDING',
                          isWarning: true,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Failed (${state.failedCount})',
                          statusKey: 'FAILED',
                          isSelected: state.selectedStatus == 'FAILED',
                          isDanger: true,
                        ),
                      ],
                    ),
                  ),
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
        bg = AppColors.error;
        fg = Colors.white;
      } else if (isSuccess) {
        bg = AppColors.success;
        fg = Colors.white;
      } else if (isWarning) {
        bg = AppColors.warning;
        fg = Colors.white;
      } else {
        bg = AppColors.headerTeal;
        fg = Colors.white;
      }
      border = BorderSide.none;
    } else {
      bg = colors.cardBackground;
      fg = isDanger
          ? AppColors.error
          : (isSuccess
              ? AppColors.success
              : (isWarning ? AppColors.warning : colors.textSecondary));
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

  Widget _buildEmptyState(BuildContext context, PaymentsLoaded state) {
    final colors = context.colors;
    final isFiltered = state.selectedStatus != 'ALL' || state.searchQuery.isNotEmpty;

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
              isFiltered ? 'No transactions match your filter' : 'No payments found',
              style: context.titleMedium.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'Try changing your status filter or clearing your search term.'
                  : 'You have no recorded payments or dues transactions yet.',
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
                label: const Text('Reset Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

