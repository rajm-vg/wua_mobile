import 'package:flutter/material.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_state.dart';

/// Result returned when the user applies or resets filters in [PaymentFiltersSheet].
class PaymentFilterSelection {
  const PaymentFilterSelection({
    required this.sortOption,
    required this.fiscalYear,
    required this.season,
    required this.paymentMode,
  });

  final PaymentSortOption sortOption;
  final String fiscalYear;
  final String season;
  final String paymentMode;
}

/// Bottom sheet for sorting and multi-faceted filtering of payment history
/// (Sort order, Fiscal Year, Season, and Payment Mode).
class PaymentFiltersSheet extends StatefulWidget {
  const PaymentFiltersSheet({
    super.key,
    required this.state,
  });

  final PaymentsLoaded state;

  @override
  State<PaymentFiltersSheet> createState() => _PaymentFiltersSheetState();
}

class _PaymentFiltersSheetState extends State<PaymentFiltersSheet> {
  late PaymentSortOption _sortOption;
  late String _fiscalYear;
  late String _season;
  late String _paymentMode;

  @override
  void initState() {
    super.initState();
    _sortOption = widget.state.sortOption;
    _fiscalYear = widget.state.selectedFiscalYear;
    _season = widget.state.selectedSeason;
    _paymentMode = widget.state.selectedPaymentMode;
  }

  bool get _hasDraftChanges =>
      _sortOption != PaymentSortOption.newestFirst ||
      _fiscalYear != 'ALL' ||
      _season != 'ALL' ||
      _paymentMode != 'ALL';

  void _resetDraft() {
    setState(() {
      _sortOption = PaymentSortOption.newestFirst;
      _fiscalYear = 'ALL';
      _season = 'ALL';
      _paymentMode = 'ALL';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final fiscalYears = widget.state.availableFiscalYears;
    final seasons = widget.state.availableSeasons;
    final modes = widget.state.availablePaymentModes;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.tune_rounded, size: 20, color: colors.canalGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.sortAndFilter,
                    style: context.titleMedium.bold.withColor(colors.textPrimary),
                  ),
                ),
                if (_hasDraftChanges)
                  TextButton(
                    onPressed: _resetDraft,
                    child: Text(
                      l10n.resetFilters,
                      style: context.labelSmall.bold.withColor(colors.error),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 16),

            // 1. Sort By
            _SectionHeader(title: l10n.sortBy),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SortOptionChip(
                  label: l10n.newestFirst,
                  icon: Icons.arrow_downward_rounded,
                  selected: _sortOption == PaymentSortOption.newestFirst,
                  onTap: () => setState(() => _sortOption = PaymentSortOption.newestFirst),
                ),
                _SortOptionChip(
                  label: l10n.oldestFirst,
                  icon: Icons.arrow_upward_rounded,
                  selected: _sortOption == PaymentSortOption.oldestFirst,
                  onTap: () => setState(() => _sortOption = PaymentSortOption.oldestFirst),
                ),
                _SortOptionChip(
                  label: l10n.amountHighToLow,
                  icon: Icons.trending_up_rounded,
                  selected: _sortOption == PaymentSortOption.amountHighToLow,
                  onTap: () => setState(() => _sortOption = PaymentSortOption.amountHighToLow),
                ),
                _SortOptionChip(
                  label: l10n.amountLowToHigh,
                  icon: Icons.trending_down_rounded,
                  selected: _sortOption == PaymentSortOption.amountLowToHigh,
                  onTap: () => setState(() => _sortOption = PaymentSortOption.amountLowToHigh),
                ),
              ],
            ),

            // 2. Fiscal Year
            if (fiscalYears.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _SectionHeader(title: l10n.fiscalYear),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChoiceChip(
                    label: l10n.allFiscalYears,
                    selected: _fiscalYear == 'ALL',
                    onTap: () => setState(() => _fiscalYear = 'ALL'),
                  ),
                  for (final fy in fiscalYears)
                    _ChoiceChip(
                      label: 'FY $fy',
                      selected: _fiscalYear == fy,
                      onTap: () => setState(() => _fiscalYear = fy),
                    ),
                ],
              ),
            ],

            // 3. Season
            if (seasons.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _SectionHeader(title: l10n.season),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChoiceChip(
                    label: l10n.allSeasons,
                    selected: _season == 'ALL',
                    onTap: () => setState(() => _season = 'ALL'),
                  ),
                  for (final s in seasons)
                    _ChoiceChip(
                      label: s,
                      selected: _season == s,
                      onTap: () => setState(() => _season = s),
                    ),
                ],
              ),
            ],

            // 4. Payment Mode
            if (modes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _SectionHeader(title: l10n.paymentMode),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChoiceChip(
                    label: l10n.allPaymentModes,
                    selected: _paymentMode == 'ALL',
                    onTap: () => setState(() => _paymentMode = 'ALL'),
                  ),
                  for (final m in modes)
                    _ChoiceChip(
                      label: m,
                      selected: _paymentMode == m,
                      onTap: () => setState(() => _paymentMode = m),
                    ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    PaymentFilterSelection(
                      sortOption: _sortOption,
                      fiscalYear: _fiscalYear,
                      season: _season,
                      paymentMode: _paymentMode,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.billCtaBg,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.applyFilters,
                  style: context.labelLarge.bold.withColor(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.labelMedium.bold.withColor(context.colors.textSecondary),
    );
  }
}

class _SortOptionChip extends StatelessWidget {
  const _SortOptionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? colors.canalGreen.withValues(alpha: 0.14) : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.canalGreen : colors.cardBorder,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? colors.canalGreen : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.labelSmall.bold.withColor(
                selected ? colors.canalGreen : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.billCtaBg : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colors.billCtaBg : colors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: context.labelSmall.bold.withColor(
            selected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
