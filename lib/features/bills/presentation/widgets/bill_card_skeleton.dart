import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/shared/widgets/widgets.dart';

/// Shimmer skeleton card displayed while bills are loading.
class BillCardSkeleton extends StatelessWidget {
  const BillCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ShimmerCard(
      borderRadius: BorderRadius.circular(20),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerContainer(
                width: 140,
                height: 18,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              ShimmerContainer(
                width: 70,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Middle Amount Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerContainer(
                    width: 100,
                    height: 28,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  SizedBox(height: 6),
                  ShimmerContainer(
                    width: 180,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ],
              ),
              ShimmerContainer(
                width: 90,
                height: 38,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Bottom Breakdown Skeleton
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ShimmerContainer(
                width: 70,
                height: 16,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              ShimmerContainer(
                width: 70,
                height: 16,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              ShimmerContainer(
                width: 70,
                height: 16,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
