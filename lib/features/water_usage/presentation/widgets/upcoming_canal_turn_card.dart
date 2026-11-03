import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

/// Card spotlighting the next upcoming or active canal irrigation turn (Wari).
class UpcomingCanalTurnCard extends StatelessWidget {
  const UpcomingCanalTurnCard({
    super.key,
    required this.turn,
    required this.onRequestSwap,
  });

  final IrrigationTurnEntity turn;
  final VoidCallback onRequestSwap;

  void _showPassModal(BuildContext context) {
    final colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
                Icon(Icons.verified_user_rounded, color: colors.canalGreen),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'CANAL WARI PASS • वारी पास',
                  style: context.titleMedium.bold.withColor(colors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Official authorized irrigation turn slip issued by WRD / WUA Society.',
              style: context.caption.withColor(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            _PassRow(label: 'Turn Number', value: 'Turn #${turn.turnNumber} (Wari)'),
            _PassRow(label: 'Date', value: turn.formattedDate),
            _PassRow(label: 'Time Slot', value: turn.formattedTimeRange),
            _PassRow(label: 'Sluice Gate & Outlet', value: '${turn.gateNo} • ${turn.outletNo}'),
            _PassRow(label: 'Discharge Quota', value: '${turn.dischargeCusecs} Cusecs (~${turn.waterDeliveredHaCm} ha-cm)'),
            _PassRow(label: 'Crop & Land Parcel', value: '${turn.crop} • ${turn.fieldParcel}'),
            _PassRow(label: 'Supervising Patkari', value: turn.inspectorName),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.canalGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Close Pass'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.turnCardBorder,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: Turn # + Status Badge ─────────────────────
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
                      color: colors.canalGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'TURN #${turn.turnNumber} • WARI',
                      style: context.labelSmall.extraBold.withColor(
                        colors.canalGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Next Schedule',
                    style: context.caption.semiBold.withColor(
                      colors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.turnCardBadgeBg,
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'In 2 Days',
                      style: context.labelSmall.bold.withColor(
                        colors.turnCardBadgeText,
                      ).withSize(11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ─── Scheduled Date & Time ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16343C) : const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: colors.canalGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turn.formattedDate,
                      style: context.titleMedium.bold.withColor(
                        colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      turn.formattedTimeRange,
                      style: context.bodyMedium.medium.withColor(
                        colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ─── Field, Gate & Discharge Specs ──────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF11252B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SpecTile(
                      label: 'GATE & OUTLET',
                      value: '${turn.gateNo} • ${turn.outletNo}',
                      icon: Icons.meeting_room_rounded,
                    ),
                    _SpecTile(
                      label: 'DISCHARGE FLOW',
                      value: '${turn.dischargeCusecs} Cusecs',
                      icon: Icons.speed_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Divider(color: colors.divider, height: 1),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SpecTile(
                      label: 'CROP',
                      value: turn.crop,
                      icon: Icons.grass_rounded,
                    ),
                    _SpecTile(
                      label: 'LAND PARCEL',
                      value: turn.fieldParcel,
                      icon: Icons.landscape_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (turn.notes != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.harvestAmber,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    turn.notes!,
                    style: context.caption.withColor(colors.textSecondary),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // ─── Action Buttons: Request Swap & Wari Pass ────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRequestSwap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.canalGreen, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: Icon(
                    Icons.swap_horiz_rounded,
                    size: 18,
                    color: colors.canalGreen,
                  ),
                  label: Text(
                    'Swap Turn (बदली)',
                    style: context.labelSmall.bold.withColor(colors.canalGreen),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showPassModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.canalGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: Text(
                    'Wari Pass (पास)',
                    style: context.labelSmall.bold.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: colors.canalGreen),
              const SizedBox(width: 4),
              Text(
                label,
                style: context.caption.bold.withColor(colors.textSecondary).withSize(9.5),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.labelMedium.bold.withColor(colors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PassRow extends StatelessWidget {
  const _PassRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.bodySmall.withColor(colors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.bodySmall.bold.withColor(colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

