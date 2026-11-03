import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_bloc.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_event.dart';
import 'package:wua_mobile/features/water_usage/presentation/bloc/water_usage_state.dart';
import 'package:wua_mobile/features/water_usage/presentation/widgets/canal_turn_card.dart';
import 'package:wua_mobile/features/water_usage/presentation/widgets/crop_water_breakdown_card.dart';
import 'package:wua_mobile/features/water_usage/presentation/widgets/request_turn_swap_sheet.dart';
import 'package:wua_mobile/features/water_usage/presentation/widgets/upcoming_canal_turn_card.dart';
import 'package:wua_mobile/features/water_usage/presentation/widgets/water_quota_hero_card.dart';
import 'package:wua_mobile/features/water_usage/presentation/widgets/water_usage_filter_chips.dart';
import 'package:wua_mobile/features/water_usage/presentation/widgets/water_usage_skeleton.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Comprehensive Water Usage, Canal Quota & Rotational Wari Scheduling Screen.
class WaterUsagePage extends StatelessWidget {
  const WaterUsagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WaterUsageBloc>(
      create: (context) =>
          sl<WaterUsageBloc>()..add(const LoadWaterUsageEvent()),
      child: const _WaterUsagePageView(),
    );
  }
}

class _WaterUsagePageView extends StatelessWidget {
  const _WaterUsagePageView();

  Future<void> _onRefresh(BuildContext context) async {
    context.read<WaterUsageBloc>().add(const LoadWaterUsageEvent(refresh: true));
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  void _openSwapSheet(BuildContext context, IrrigationTurnEntity turn) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<WaterUsageBloc>(),
          child: BlocConsumer<WaterUsageBloc, WaterUsageState>(
            listener: (context, state) {
              if (state is WaterUsageLoaded && !state.isSubmittingSwap) {
                Navigator.of(bottomSheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Turn swap request submitted successfully! Pending Patkari verification.',
                    ),
                    backgroundColor: AppColors.canalGreen,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isSubmitting =
                  state is WaterUsageLoaded && state.isSubmittingSwap;

              return RequestTurnSwapSheet(
                turn: turn,
                isLoading: isSubmitting,
                onSubmit: ({
                  required String turnId,
                  required DateTime preferredDate,
                  required String reason,
                  String? swappedWithFarmer,
                }) {
                  context.read<WaterUsageBloc>().add(
                        SubmitTurnSwapEvent(
                          turnId: turnId,
                          preferredDate: preferredDate,
                          reason: reason,
                          swappedWithFarmer: swappedWithFarmer,
                        ),
                      );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showHelpModal(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.support_agent_rounded, color: colors.canalGreen),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.canalHelpline,
                  style: context.titleMedium.bold.withColor(colors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'For canal gate operations, desilting issues, or turn dispute redressal:',
              style: context.bodySmall.withColor(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.canalGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.phone_in_talk_rounded, color: colors.canalGreen),
              ),
              title: Text('Kisan Toll-Free Helpline', style: context.bodySmall.bold),
              subtitle: Text('1800-180-1551 (24x7 WRD Support)', style: context.caption),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_pin_rounded, color: AppColors.info),
              ),
              title: Text('S. K. Deshmukh (Patkari)', style: context.bodySmall.bold),
              subtitle: Text('+91 98220 12345 • Minor-3 In-charge', style: context.caption),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WuaScaffold(
      title: 'Water Usage',
      subtitle: 'Canal Wari & Quota Monitoring • पाणी वापर',
      showBackButton: true,
      scrollable: false,
      padding: EdgeInsets.zero,
      enableMaxConstraint: true,
      maxWidth: 850.0,
      actions: [
        IconButton(
          tooltip: 'Canal Helpline',
          icon: const Icon(Icons.help_outline_rounded),
          onPressed: () => _showHelpModal(context),
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => _onRefresh(context),
        ),
      ],
      body: BlocBuilder<WaterUsageBloc, WaterUsageState>(
        builder: (context, state) {
          if (state is WaterUsageInitial || state is WaterUsageLoading) {
            return const WaterUsageSkeleton();
          }

          if (state is WaterUsageError) {
            return _buildErrorState(context, state.message);
          }

          if (state is WaterUsageLoaded) {
            return _buildLoadedContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
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
              context.l10n.failedToLoadWater,
              style: context.titleMedium.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.caption.withColor(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _onRefresh(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.canalGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, WaterUsageLoaded state) {
    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: colors.canalGreen,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Quota & Live Canal Status Hero
                  WaterQuotaHeroCard(quota: state.quota),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Next Upcoming Canal Turn (Wari)
                  if (state.nextTurn != null) ...[
                    UpcomingCanalTurnCard(
                      turn: state.nextTurn!,
                      onRequestSwap: () => _openSwapSheet(context, state.nextTurn!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 3. Crop-wise Water Consumption Breakdown
                  if (state.quota.cropBreakdown.isNotEmpty) ...[
                    CropWaterBreakdownCard(crops: state.quota.cropBreakdown),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // 4. Rotational Turns Header & Filter Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.rotationalCanalTurns,
                        style: context.caption.bold.withColor(
                          colors.textSecondary,
                        ),
                      ),
                      Text(
                        '${state.filteredTurns.length} Turns',
                        style: context.caption.semiBold.withColor(
                          colors.canalGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  WaterUsageFilterChips(
                    selectedFilter: state.selectedStatusFilter,
                    onFilterChanged: (status) {
                      context
                          .read<WaterUsageBloc>()
                          .add(FilterTurnsByStatusEvent(status));
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),

          // 5. Turns List
          if (state.filteredTurns.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xl,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 48,
                        color: colors.textSecondary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.l10n.noTurnsFound,
                        style: context.bodyMedium.medium.withColor(
                          colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final turn = state.filteredTurns[index];
                    return CanalTurnCard(
                      turn: turn,
                      onRequestSwap: () => _openSwapSheet(context, turn),
                      onTap: () {
                        // Show brief turn details modal
                      },
                    );
                  },
                  childCount: state.filteredTurns.length,
                ),
              ),
            ),

          // 6. Canal Advisory & Bottom Info Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 22,
                      color: colors.canalGreen,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WUA Canal Roster Regulations',
                            style: context.bodySmall.bold.withColor(
                              colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Water delivery operates on a strict rotational basis (Wari). Unauthorized tampering with sluice gates or canal banks is prohibited under Irrigation Act Sec. 58.',
                            style: context.caption.withColor(colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}

