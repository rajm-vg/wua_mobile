import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

/// Card for an individual canal irrigation turn in the rotational schedule.
class CanalTurnCard extends StatelessWidget {
  const CanalTurnCard({
    super.key,
    required this.turn,
    this.onTap,
    this.onRequestSwap,
  });

  final IrrigationTurnEntity turn;
  final VoidCallback? onTap;
  final VoidCallback? onRequestSwap;

  Color _getStatusColor(BuildContext context, String status) {
    final colors = context.colors;
    switch (status.toUpperCase()) {
      case TurnStatus.completed:
        return colors.success;
      case TurnStatus.active:
        return colors.canalGreen;
      case TurnStatus.upcoming:
        return AppColors.info;
      case TurnStatus.swapped:
        return AppColors.tertiary;
      case TurnStatus.cancelled:
        return colors.error;
      default:
        return colors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case TurnStatus.completed:
        return Icons.check_circle_rounded;
      case TurnStatus.active:
        return Icons.water_drop_rounded;
      case TurnStatus.upcoming:
        return Icons.schedule_rounded;
      case TurnStatus.swapped:
        return Icons.swap_horiz_rounded;
      case TurnStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final statusColor = _getStatusColor(context, turn.status);
    final statusIcon = _getStatusIcon(turn.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: turn.isActive ? colors.canalGreen : colors.cardBorder,
          width: turn.isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header: Turn # & Status Chip ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TURN #${turn.turnNumber}',
                            style: context.labelSmall.bold.withColor(
                              colors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          turn.crop,
                          style: context.bodySmall.medium.withColor(
                            colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            TurnStatus.toLabel(turn.status),
                            style: context.caption.bold.withColor(statusColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // ─── Date & Time ──────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      size: 16,
                      color: colors.canalGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      turn.formattedDate,
                      style: context.titleSmall.bold.withColor(
                        colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Text(
                    turn.formattedTimeRange,
                    style: context.caption.medium.withColor(colors.textSecondary),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),
                Divider(color: colors.divider, height: 1),
                const SizedBox(height: AppSpacing.sm),

                // ─── Metrics: Water volume & Gate ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${turn.waterDeliveredHaCm} ha-cm (${turn.dischargeCusecs} Cusecs)',
                          style: context.caption.bold.withColor(colors.textPrimary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${turn.gateNo} • ${turn.outletNo}',
                          style: context.caption.medium.withColor(
                            colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ─── Verification Badge / Swap Action ─────────────────
                if (turn.isVerified) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: colors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified by ${turn.inspectorName}',
                        style: context.caption.semiBold.withColor(
                          colors.success,
                        ),
                      ),
                    ],
                  ),
                ] else if (turn.isUpcoming && turn.canRequestSwap && onRequestSwap != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: onRequestSwap,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz_rounded,
                              size: 14,
                              color: colors.canalGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Request Swap (बारी बदली)',
                              style: context.caption.bold.withColor(
                                colors.canalGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

