import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

/// Modal bottom sheet allowing a farmer to request an irrigation turn swap or reschedule.
class RequestTurnSwapSheet extends StatefulWidget {
  const RequestTurnSwapSheet({
    super.key,
    required this.turn,
    required this.onSubmit,
    this.isLoading = false,
  });

  final IrrigationTurnEntity turn;
  final Function({
    required String turnId,
    required DateTime preferredDate,
    required String reason,
    String? swappedWithFarmer,
  }) onSubmit;
  final bool isLoading;

  @override
  State<RequestTurnSwapSheet> createState() => _RequestTurnSwapSheetState();
}

class _RequestTurnSwapSheetState extends State<RequestTurnSwapSheet> {
  late DateTime _selectedDate;
  String _selectedReason = 'Mutual Neighbor Swap / शेतकऱ्यांशी अदलाबदल';
  final TextEditingController _neighborController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _reasons = [
    'Mutual Neighbor Swap / शेतकऱ्यांशी अदलाबदल',
    'Delayed Sowing / उशिरा पेरणी',
    'Power Outage / वीज खंडित',
    'Sub-minor Channel Blockage / चारी अडथळा',
    'Emergency / कौटुंबिक अडचण',
  ];

  @override
  void initState() {
    super.initState();
    // Default preferred date: 3 days after original
    _selectedDate = widget.turn.scheduledStartTime.add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _neighborController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          widget.turn.scheduledStartTime.hour,
          widget.turn.scheduledStartTime.minute,
        );
      });
    }
  }

  void _submit() {
    widget.onSubmit(
      turnId: widget.turn.id,
      preferredDate: _selectedDate,
      reason: _selectedReason,
      swappedWithFarmer: _neighborController.text.trim().isNotEmpty
          ? _neighborController.text.trim()
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Drag Handle ───────────────────────────────────────
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

              // ─── Title & Turn Info ─────────────────────────────────
              Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, color: colors.canalGreen),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'REQUEST TURN SWAP • वारी बदल',
                    style: context.titleMedium.bold.withColor(colors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Submit an alternate turn date for Turn #${widget.turn.turnNumber}. Requires approval from Canal Inspector / WUA committee.',
                style: context.caption.withColor(colors.textSecondary),
              ),

              const SizedBox(height: AppSpacing.md),

              // ─── Current Turn Summary ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: colors.canalGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current: ${widget.turn.formattedDate} (${widget.turn.formattedTimeRange})',
                        style: context.caption.bold.withColor(colors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ─── Preferred Date Picker ─────────────────────────────
              Text(
                'PREFERRED ALTERNATE DATE (पर्यायी तारीख)',
                style: context.caption.bold.withColor(colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.cardBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                        style: context.bodyMedium.bold.withColor(colors.textPrimary),
                      ),
                      Icon(Icons.calendar_month_rounded, color: colors.canalGreen),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ─── Reason Dropdown ───────────────────────────────────
              Text(
                'REASON FOR RESCHEDULING (बदलीचे कारण)',
                style: context.caption.bold.withColor(colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.cardBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedReason,
                    items: _reasons.map((r) {
                      return DropdownMenuItem<String>(
                        value: r,
                        child: Text(
                          r,
                          style: context.bodySmall.medium.withColor(colors.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedReason = val);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ─── Neighbor Farmer Name (Optional) ───────────────────
              Text(
                'SWAP PARTNER FARMER (अदलाबदल करणारा शेतकरी - ऐच्छिक)',
                style: context.caption.bold.withColor(colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _neighborController,
                decoration: InputDecoration(
                  hintText: 'e.g. Tukaram Shinde (Survey #43/2)',
                  hintStyle: context.caption.withColor(colors.textHint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.cardBorder),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ─── Submit Button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.canalGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Submit Swap Request (अर्ज सादर करा)',
                          style: context.labelMedium.bold.white,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

