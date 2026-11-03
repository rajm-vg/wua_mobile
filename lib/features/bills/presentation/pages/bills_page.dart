import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_event.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_state.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_card.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_card_skeleton.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bills_summary_card.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Comprehensive Pani Patti Bills List screen supporting mobile and responsive web layouts.
class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillsBloc>(
      create: (context) => sl<BillsBloc>()..add(const LoadBillsEvent()),
      child: const _BillsPageView(),
    );
  }
}

class _BillsPageView extends StatefulWidget {
  const _BillsPageView();

  @override
  State<_BillsPageView> createState() => _BillsPageViewState();
}

class _BillsPageViewState extends State<_BillsPageView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<BillsBloc>().add(const LoadBillsEvent(refresh: true));
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return WuaScaffold(
      title: l10n.paniPattiBills,
      subtitle: l10n.wuaSubtitle,
      showBackButton: true,
      scrollable: false,
      padding: EdgeInsets.zero,
      enableMaxConstraint: true,
      maxWidth: 850.0, // Optimized for responsive tablet/desktop web display
      actions: [
        IconButton(
          tooltip: l10n.refresh,
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => _onRefresh(context),
        ),
      ],
      body: BlocBuilder<BillsBloc, BillsState>(
        builder: (context, state) {
          if (state is BillsInitial || state is BillsLoading) {
            return _buildLoadingState(context);
          }

          if (state is BillsError) {
            return _buildErrorState(context, state.message);
          }

          if (state is BillsLoaded) {
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
        BillCardSkeleton(),
        BillCardSkeleton(),
        BillCardSkeleton(),
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
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load bills',
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, BillsLoaded state) {
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
              child: BillsSummaryCard(
                totalOutstanding: state.totalOutstandingAmount,
                pendingCount: state.pendingCount,
                overdueCount: state.overdueCount,
                paidCount: state.paidCount,
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

                  // Search Text Field
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
                        hintText: 'Search by bill no, season, or crop...',
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
                                  context.read<BillsBloc>().add(
                                    const SearchBillsEvent(''),
                                  );
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onChanged: (query) {
                        context.read<BillsBloc>().add(SearchBillsEvent(query));
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
                          label: 'All (${state.allBills.length})',
                          statusKey: 'ALL',
                          isSelected: state.selectedStatus == 'ALL',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Due / Pending (${state.pendingCount})',
                          statusKey: 'PENDING',
                          isSelected: state.selectedStatus == 'PENDING',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Overdue (${state.overdueCount})',
                          statusKey: 'OVERDUE',
                          isSelected: state.selectedStatus == 'OVERDUE',
                          isDanger: true,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          label: 'Paid (${state.paidCount})',
                          statusKey: 'PAID',
                          isSelected: state.selectedStatus == 'PAID',
                          isSuccess: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bill Cards List or Empty State
          if (state.filteredBills.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(context, state),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final bill = state.filteredBills[index];
                  return BillCard(key: ValueKey(bill.id), bill: bill);
                }, childCount: state.filteredBills.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 60)),
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
      } else {
        bg = AppColors.headerTeal;
        fg = Colors.white;
      }
      border = BorderSide.none;
    } else {
      bg = colors.cardBackground;
      fg = isDanger
          ? AppColors.error
          : (isSuccess ? AppColors.success : colors.textSecondary);
      border = BorderSide(color: colors.cardBorder);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        context.read<BillsBloc>().add(FilterBillsByStatusEvent(statusKey));
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

  Widget _buildEmptyState(BuildContext context, BillsLoaded state) {
    final colors = context.colors;
    final isFiltered =
        state.selectedStatus != 'ALL' || state.searchQuery.isNotEmpty;

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
              child: Icon(
                Icons.receipt_long_outlined,
                size: 32,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isFiltered ? 'No bills match your filter' : 'No bills found',
              style: context.titleMedium.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'Try selecting a different status or clear your search query.'
                  : 'You have no recorded irrigation water bills at this time.',
              textAlign: TextAlign.center,
              style: context.caption,
            ),
            if (isFiltered) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  context.read<BillsBloc>().add(const ClearBillFiltersEvent());
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
