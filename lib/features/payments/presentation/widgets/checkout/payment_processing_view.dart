import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class PaymentProcessingView extends StatelessWidget {
  const PaymentProcessingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<PaymentCheckoutBloc, PaymentCheckoutState>(
      builder: (context, state) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Water Ripple Spinner
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.primary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.shield_rounded,
                      size: 34,
                      color: AppColors.canalGreen,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Main Title
                Text(
                  'Processing Secure Payment',
                  style: context.titleLarge.bold.withColor(colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please do not close the app or tap the back button',
                  style: context.caption.withColor(colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3-Stage Verification Steps
                _buildStageRow(
                  context,
                  stageNumber: 1,
                  currentStage: state.processingStage,
                  title: 'Routing to MahaGov WRD Gateway',
                  subtitle: state.paymentModeDisplay,
                ),
                const SizedBox(height: 12),
                _buildStageRow(
                  context,
                  stageNumber: 2,
                  currentStage: state.processingStage,
                  title: 'Authorizing with NPCI & Banking Network',
                  subtitle: 'Consumer ID: ${state.bill.consumerId ?? "KISAN-MH-41201"}',
                ),
                const SizedBox(height: 12),
                _buildStageRow(
                  context,
                  stageNumber: 3,
                  currentStage: state.processingStage,
                  title: 'Generating Water User E-Receipt',
                  subtitle: state.bill.wuaSocietyName ?? 'WUA Society #12',
                ),
                const SizedBox(height: AppSpacing.lg),

                // Security badges
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        size: 14,
                        color: AppColors.canalGreen,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '256-Bit SSL Encrypted • NPCI Certified',
                          style: context.caption.withSize(11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStageRow(
    BuildContext context, {
    required int stageNumber,
    required int currentStage,
    required String title,
    required String subtitle,
  }) {
    final colors = context.colors;
    final isDone = currentStage > stageNumber;
    final isCurrent = currentStage == stageNumber;

    Color iconBg;
    Widget iconWidget;

    if (isDone) {
      iconBg = AppColors.success.withValues(alpha: 0.15);
      iconWidget = const Icon(
        Icons.check_rounded,
        size: 16,
        color: AppColors.success,
      );
    } else if (isCurrent) {
      iconBg = colors.primary.withValues(alpha: 0.15);
      iconWidget = SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
        ),
      );
    } else {
      iconBg = colors.surfaceVariant;
      iconWidget = Text(
        '$stageNumber',
        style: context.caption.bold.withColor(colors.textHint),
      );
    }

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodySmall.bold.withColor(
                  isDone || isCurrent ? colors.textPrimary : colors.textHint,
                ),
              ),
              Text(
                subtitle,
                style: context.caption.withSize(11).withColor(
                      isDone || isCurrent
                          ? colors.textSecondary
                          : colors.textHint,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
