import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
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
import 'package:wua_mobile/shared/widgets/wua_bottom_sheet.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Comprehensive Water Usage, Crop Consumption & Canal Turn Screen.
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
    context.read<WaterUsageBloc>().add(
      const LoadWaterUsageEvent(refresh: true),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  void _openSwapSheet(BuildContext context, IrrigationTurnEntity turn) {
    showWuaBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<WaterUsageBloc>(),
          child: BlocConsumer<WaterUsageBloc, WaterUsageState>(
            listener: (context, state) {
              if (state is WaterUsageLoaded && !state.isSubmittingSwap) {
                Navigator.of(bottomSheetContext).pop();
                context.showSuccessSnackBar(
                  'Turn swap request submitted successfully! Pending Patkari verification.',
                );
              }
            },
            builder: (context, state) {
              final isSubmitting =
                  state is WaterUsageLoaded && state.isSubmittingSwap;

              return RequestTurnSwapSheet(
                turn: turn,
                isLoading: isSubmitting,
                onSubmit:
                    ({
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

  @override
  Widget build(BuildContext context) {
    return WuaScaffold(
      title: 'Water Usage',
      subtitle: 'Crop Irrigation & Water Used • पाणी वापर',
      showBackButton: true,
      scrollable: false,
      padding: EdgeInsets.zero,
      enableMaxConstraint: true,
      maxWidth: 850.0,
      actions: [
        IconButton(
          tooltip: context.l10n.refresh,
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

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: colors.canalGreen,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
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
                        Icons.water_drop_outlined,
                        size: 34,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No water usage records found',
                      style: context.titleMedium.bold.withColor(
                        colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recorded crop irrigation entries from your WUA society will appear here.',
                      textAlign: TextAlign.center,
                      style: context.caption.withColor(colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, WaterUsageLoaded state) {
    final colors = context.colors;
    final hasHaCmQuota =
        state.quota.totalQuotaHaCm > 0 || state.quota.usedQuotaHaCm > 0;
    final hasCrops = state.quota.cropBreakdown.isNotEmpty;
    final hasTurns = state.allTurns.isNotEmpty;

    if (!hasHaCmQuota && !hasCrops && !hasTurns) {
      return _buildEmptyState(context);
    }

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
                  // 1. Quota & Water Usage Overview
                  WaterQuotaHeroCard(quota: state.quota),
                  const SizedBox(height: AppSpacing.md),

                  // 2. Next Upcoming Canal Turn (only if turn data exists)
                  if (state.nextTurn != null) ...[
                    UpcomingCanalTurnCard(
                      turn: state.nextTurn!,
                      onRequestSwap: () =>
                          _openSwapSheet(context, state.nextTurn!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 3. Crop-wise Water Consumption Breakdown (only if crop entries exist)
                  if (hasCrops) ...[
                    CropWaterBreakdownCard(crops: state.quota.cropBreakdown),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // 4. Rotational Turns Header & Filter Chips (only if turn data exists)
                  if (hasTurns) ...[
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
                        context.read<WaterUsageBloc>().add(
                          FilterTurnsByStatusEvent(status),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          ),

          // 5. Turns List (only rendered when turns exist)
          if (hasTurns && state.filteredTurns.isEmpty)
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
          else if (hasTurns)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final turn = state.filteredTurns[index];
                  return CanalTurnCard(
                    turn: turn,
                    onRequestSwap: () => _openSwapSheet(context, turn),
                    onTap: () {},
                  );
                }, childCount: state.filteredTurns.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
