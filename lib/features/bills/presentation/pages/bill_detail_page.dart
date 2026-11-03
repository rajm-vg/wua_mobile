import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_event.dart';
import 'package:wua_mobile/features/bills/presentation/bloc/bills_state.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_receipt_sheet.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Detailed view for a specific WUA Pani Patti Bill.
/// Supports both mobile phone viewports and responsive tablet/desktop web layouts.
class BillDetailPage extends StatelessWidget {
  const BillDetailPage({super.key, required this.billId, this.initialBill});

  final String billId;
  final BillEntity? initialBill;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillsBloc>(
      create: (context) {
        final bloc = sl<BillsBloc>();
        if (initialBill == null) {
          bloc.add(LoadBillDetailEvent(billId));
        }
        return bloc;
      },
      child: _BillDetailPageView(billId: billId, initialBill: initialBill),
    );
  }
}

class _BillDetailPageView extends StatelessWidget {
  const _BillDetailPageView({required this.billId, this.initialBill});

  final String billId;
  final BillEntity? initialBill;

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillsBloc, BillsState>(
      builder: (context, state) {
        BillEntity? activeBill = initialBill;
        bool isLoading = false;
        String? errorMessage;

        if (state is BillDetailLoading && activeBill == null) {
          isLoading = true;
        } else if (state is BillDetailLoaded) {
          activeBill = state.bill;
        } else if (state is BillDetailError && activeBill == null) {
          errorMessage = state.message;
        }

        return WuaScaffold(
          title: 'Bill Details',
          subtitle: activeBill != null
              ? activeBill.billNumber
              : 'Invoice #$billId',
          showBackButton: true,
          scrollable: true,
          padding: EdgeInsets.zero,
          enableMaxConstraint: true,
          maxWidth: 960.0, // Responsive web & desktop canvas
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRetry: () {
            context.read<BillsBloc>().add(LoadBillDetailEvent(billId));
          },
          actions: activeBill != null
              ? [
                  IconButton(
                    tooltip: 'Share Bill',
                    icon: const Icon(Icons.share_rounded),
                    onPressed: () {
                      context.showInfoSnackBar(
                        'Sharing bill ${activeBill!.billNumber}...',
                      );
                    },
                  ),
                  if (activeBill.isPaid)
                    IconButton(
                      tooltip: 'View Official Receipt',
                      icon: const Icon(Icons.receipt_long_rounded),
                      onPressed: () {
                        BillReceiptSheet.show(context, bill: activeBill!);
                      },
                    ),
                ]
              : null,
          body: activeBill == null
              ? const SizedBox.shrink()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideWeb = constraints.maxWidth >= 720;

                    if (isWideWeb) {
                      // Two-column responsive web layout
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Particulars & Water Metrics
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildHeroStatusCard(context, activeBill!),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildFarmerParticularsCard(
                                    context,
                                    activeBill,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildWaterConsumptionCard(
                                    context,
                                    activeBill,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),

                            // Right Column: Cost Breakdown & Payment CTA
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildBreakdownCard(context, activeBill),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildActionPanel(context, activeBill),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Mobile single-column layout
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeroStatusCard(context, activeBill!),
                          const SizedBox(height: AppSpacing.md),
                          _buildFarmerParticularsCard(context, activeBill),
                          const SizedBox(height: AppSpacing.md),
                          _buildWaterConsumptionCard(context, activeBill),
                          const SizedBox(height: AppSpacing.md),
                          _buildBreakdownCard(context, activeBill),
                          const SizedBox(height: AppSpacing.md),
                          _buildActionPanel(context, activeBill),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  // ─── 1. Hero Status Card ─────────────────────────────────────

  Widget _buildHeroStatusCard(BuildContext context, BillEntity bill) {
    final colors = context.colors;

    Color badgeBg;
    Color badgeFg;
    String badgeTitle;
    IconData badgeIcon;

    if (bill.isPaid) {
      badgeBg = AppColors.success.withValues(alpha: 0.12);
      badgeFg = AppColors.success;
      badgeTitle = 'PAID IN FULL';
      badgeIcon = Icons.check_circle_rounded;
    } else if (bill.isOverdue) {
      badgeBg = AppColors.error.withValues(alpha: 0.12);
      badgeFg = AppColors.error;
      badgeTitle = 'OVERDUE';
      badgeIcon = Icons.warning_amber_rounded;
    } else {
      badgeBg = colors.billBadgeBg;
      badgeFg = colors.billBadgeText;
      badgeTitle = 'DUE BY ${bill.formattedDueDate.toUpperCase()}';
      badgeIcon = Icons.schedule_rounded;
    }

    final displayAmount = bill.isPaid
        ? bill.paidAmount
        : (bill.outstandingAmount > 0
              ? bill.outstandingAmount
              : bill.totalAmount);

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: bill.isOverdue
              ? AppColors.error.withValues(alpha: 0.3)
              : colors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Bill Number & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bill.season,
                  style: context.titleMedium.bold.withColor(colors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 14, color: badgeFg),
                    const SizedBox(width: 5),
                    Text(
                      badgeTitle,
                      style: context.labelSmall.bold.withColor(badgeFg),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Large Amount Banner
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(displayAmount),
                style: context.displaySmall.bold
                    .withColor(colors.textPrimary)
                    .withSize(36),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  bill.isPaid ? 'Settled' : 'Total Payable',
                  style: context.caption.medium,
                ),
              ),
            ],
          ),

          if (bill.notes != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: bill.isOverdue
                    ? AppColors.error.withValues(alpha: 0.08)
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    bill.isOverdue
                        ? Icons.info_outline_rounded
                        : Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: bill.isOverdue
                        ? AppColors.error
                        : colors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bill.notes!,
                      style: context.caption
                          .withSize(11.5)
                          .withColor(
                            bill.isOverdue
                                ? AppColors.error
                                : colors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 2. Farmer & Command Area Particulars Card ───────────────

  Widget _buildFarmerParticularsCard(BuildContext context, BillEntity bill) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_rounded,
                size: 20,
                color: AppColors.headerTeal,
              ),
              const SizedBox(width: 8),
              Text(
                'Farmer & Command Area Details',
                style: context.sectionTitle.bold,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.billDivider, height: 1),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Farmer Name',
            bill.consumerName ?? 'Ramesh Patil',
            context,
          ),
          _buildInfoRow(
            'Kisan / Consumer ID',
            bill.consumerId ?? 'KISAN-MH-41201',
            context,
          ),
          _buildInfoRow(
            'WUA Society',
            bill.wuaSocietyName ?? 'Ganga-Godavari WUA #12',
            context,
          ),
          _buildInfoRow(
            'Canal Section',
            bill.canalSection ?? 'Minor-3 (Outlet 4B)',
            context,
          ),
          _buildInfoRow('Crop Cultivated', bill.cropType, context),
          _buildInfoRow(
            'Command Land Area',
            '${bill.landAreaAcres} Acres',
            context,
          ),
          _buildInfoRow('Bill Issue Date', bill.formattedBillDate, context),
          _buildInfoRow('Payment Due Date', bill.formattedDueDate, context),
        ],
      ),
    );
  }

  // ─── 3. Water Consumption Metrics Card ───────────────────────

  Widget _buildWaterConsumptionCard(BuildContext context, BillEntity bill) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_rounded,
                size: 20,
                color: AppColors.waterCyan,
              ),
              const SizedBox(width: 8),
              Text(
                'Water Consumption Metrics',
                style: context.sectionTitle.bold,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.billDivider, height: 1),
          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricTile(
                context,
                title: 'Total Volume',
                value:
                    '${NumberFormat('#,###').format(bill.waterQuantityLiters)} L',
                subtitle: 'Gauged discharge',
              ),
              Container(width: 1, height: 40, color: colors.billDivider),
              _buildMetricTile(
                context,
                title: 'Rotations / Wari',
                value: '${bill.rotationsCount} Turns',
                subtitle: 'Completed cycles',
              ),
              Container(width: 1, height: 40, color: colors.billDivider),
              _buildMetricTile(
                context,
                title: 'Water Rate',
                value:
                    '₹ ${(bill.subtotal / (bill.landAreaAcres > 0 ? bill.landAreaAcres : 1)).toStringAsFixed(0)} / ac',
                subtitle: 'Govt canal tariff',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Column(
      children: [
        Text(title, style: context.caption.withSize(11)),
        const SizedBox(height: 3),
        Text(
          value,
          style: context.titleSmall.bold.withColor(context.colors.textPrimary),
        ),
        const SizedBox(height: 1),
        Text(subtitle, style: context.caption.withSize(10)),
      ],
    );
  }

  // ─── 4. Itemized Cost Breakdown Card ─────────────────────────

  Widget _buildBreakdownCard(BuildContext context, BillEntity bill) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_rounded,
                size: 20,
                color: AppColors.harvestAmber,
              ),
              const SizedBox(width: 8),
              Text(
                'Pani Patti Tariff Breakdown',
                style: context.sectionTitle.bold,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.billDivider, height: 1),
          const SizedBox(height: AppSpacing.sm),

          _buildBreakdownRow(
            'Base Water Tariff (पाणी पट्टी)',
            bill.subtotal,
            context,
          ),
          _buildBreakdownRow(
            'Government Water Cess & Taxes',
            bill.taxes,
            context,
          ),
          _buildBreakdownRow(
            'WUA Infrastructure Maintenance',
            bill.maintenanceCess,
            context,
          ),

          if (bill.penalties > 0)
            _buildBreakdownRow(
              'Late Overdue Penalty',
              bill.penalties,
              context,
              isWarning: true,
            ),

          if (bill.discounts > 0)
            _buildBreakdownRow(
              'Early Settlement Rebate',
              -bill.discounts,
              context,
              isPositive: true,
            ),

          const SizedBox(height: 8),
          Divider(color: colors.billDivider),
          const SizedBox(height: 6),

          // Total Bill Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gross Bill Amount',
                style: context.bodyMedium.bold.withColor(colors.textPrimary),
              ),
              Text(
                _formatCurrency(bill.totalAmount),
                style: context.bodyMedium.bold.withColor(colors.textPrimary),
              ),
            ],
          ),

          if (bill.paidAmount > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount Paid',
                  style: context.bodySmall.withColor(AppColors.success),
                ),
                Text(
                  '- ${_formatCurrency(bill.paidAmount)}',
                  style: context.bodySmall.bold.withColor(AppColors.success),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Total Outstanding Highlight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Outstanding Balance',
                  style: context.titleSmall.bold.withColor(colors.textPrimary),
                ),
                Text(
                  _formatCurrency(bill.isPaid ? 0.0 : bill.outstandingAmount),
                  style: context.titleMedium.bold.withColor(
                    bill.isPaid
                        ? AppColors.success
                        : (bill.isOverdue ? AppColors.error : colors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 5. Action Panel ─────────────────────────────────────────

  Widget _buildActionPanel(BuildContext context, BillEntity bill) {
    final colors = context.colors;

    if (bill.isPaid) {
      return Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Completed',
                        style: context.labelMedium.bold.withColor(
                          AppColors.success,
                        ),
                      ),
                      Text(
                        'Ref: ${bill.paymentReference ?? 'UPI/WRD/894123'}',
                        style: context.caption.withSize(11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                BillReceiptSheet.show(context, bill: bill);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.headerTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('View Official E-Receipt'),
            ),
          ],
        ),
      );
    }

    // Unpaid / Payable Flow
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              context.showInfoSnackBar(
                'Launching UPI payment for ${_formatCurrency(bill.outstandingAmount)}...',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.billCtaBg,
              foregroundColor: colors.billCtaText,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.payment_rounded, size: 18),
            label: Text(
              'Pay ${_formatCurrency(bill.outstandingAmount)} via UPI',
              style: context.buttonText.bold.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () {
              context.showInfoSnackBar(
                'Redirecting to Net Banking / Debit Card gateway...',
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: colors.cardBorder),
            ),
            icon: const Icon(Icons.account_balance_rounded, size: 16),
            label: const Text('Net Banking / Debit Card'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: AppColors.canalGreen,
              ),
              const SizedBox(width: 4),
              Text(
                'Secured via WRD Government Payment Gateway',
                style: context.caption.withSize(10.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.bodySmall.withColor(colors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.bodySmall.medium.withColor(colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    double amount,
    BuildContext context, {
    bool isWarning = false,
    bool isPositive = false,
  }) {
    final colors = context.colors;
    final color = isWarning
        ? AppColors.error
        : (isPositive ? AppColors.success : colors.textPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.bodySmall.withColor(colors.textSecondary)),
          Text(
            _formatCurrency(amount),
            style: context.bodySmall.medium.withColor(color),
          ),
        ],
      ),
    );
  }
}
