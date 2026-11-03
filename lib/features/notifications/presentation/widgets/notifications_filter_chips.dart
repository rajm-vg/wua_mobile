import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Horizontal category filter chips for Notifications screen.
class NotificationsFilterChips extends StatelessWidget {
  const NotificationsFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.unreadCount = 0,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final filters = [
      {'key': 'ALL', 'label': 'All (सर्व)'},
      {
        'key': 'UNREAD',
        'label': unreadCount > 0 ? 'Unread ($unreadCount)' : 'Unread (नवीन)'
      },
      {'key': 'BILLS', 'label': 'Bills (पाणीपट्टी)'},
      {'key': 'PAYMENTS', 'label': 'Payments (भरणा)'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((item) {
          final isSelected = selectedFilter == item['key'];

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FilterChip(
              selected: isSelected,
              label: Text(item['label']!),
              labelStyle: (isSelected
                      ? context.labelSmall.bold
                      : context.labelSmall.medium)
                  .withColor(
                isSelected ? Colors.white : colors.textSecondary,
              ),
              backgroundColor: colors.surfaceVariant,
              selectedColor: colors.canalGreen,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? colors.canalGreen : colors.cardBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusFull,
              ),
              onSelected: (_) => onFilterChanged(item['key']!),
            ),
          );
        }).toList(),
      ),
    );
  }
}

