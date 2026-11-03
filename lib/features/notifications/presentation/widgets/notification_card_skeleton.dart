import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/shared/widgets/widgets.dart';

/// Shimmer placeholder skeleton for the notifications list.
class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: itemCount,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemBuilder: (context, index) {
        return const ShimmerCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar / Category Icon
              ShimmerCircle(size: 44),
              SizedBox(width: AppSpacing.sm),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title line
                    ShimmerText(width: 140, height: 16),
                    SizedBox(height: 8),

                    // Message lines
                    ShimmerText(width: double.infinity, height: 12),
                    SizedBox(height: 6),
                    ShimmerText(width: 180, height: 12),
                    SizedBox(height: 10),

                    // Timestamp / Chip line
                    ShimmerContainer(
                      width: 90,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
