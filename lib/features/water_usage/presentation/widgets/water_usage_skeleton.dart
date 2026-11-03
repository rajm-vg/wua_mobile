import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/shared/widgets/widgets.dart';

/// Shimmer skeleton loading placeholder for the Water Usage view.
class WaterUsageSkeleton extends StatelessWidget {
  const WaterUsageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Quota Hero Skeleton
        ShimmerCard(
          borderRadius: BorderRadius.circular(20),
          child: const SizedBox(
            height: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerContainer(
                      width: 140,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    ShimmerContainer(
                      width: 90,
                      height: 22,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ShimmerContainer(
                  width: 120,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                SizedBox(height: 12),
                ShimmerContainer(
                  height: 10,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                Spacer(),
                ShimmerContainer(
                  height: 48,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Next Turn Skeleton
        ShimmerCard(
          borderRadius: BorderRadius.circular(20),
          child: const SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(
                  width: 100,
                  height: 18,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(height: 16),
                ShimmerContainer(
                  width: 200,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ShimmerContainer(
                        height: 38,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ShimmerContainer(
                        height: 38,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Turns List Item Skeletons
        ...List.generate(
          2,
          (index) => ShimmerCard(
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              height: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerContainer(
                    width: 80,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  SizedBox(height: 8),
                  ShimmerContainer(
                    width: 160,
                    height: 18,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
