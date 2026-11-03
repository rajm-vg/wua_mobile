import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/shared/widgets/widgets.dart';

/// Shimmer skeleton card displayed while payments are loading.
class PaymentCardSkeleton extends StatelessWidget {
  const PaymentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      borderRadius: BorderRadius.circular(20),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerContainer(
                width: 130,
                height: 16,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              ShimmerContainer(
                width: 80,
                height: 22,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerContainer(
                    width: 90,
                    height: 26,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  SizedBox(height: 6),
                  ShimmerContainer(
                    width: 150,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ],
              ),
              ShimmerContainer(
                width: 90,
                height: 36,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
