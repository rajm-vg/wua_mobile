import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';

/// Modal bottom sheet displaying detailed farmer/member profile information.
class MyProfileBottomSheet extends StatelessWidget {
  const MyProfileBottomSheet({super.key, this.user});

  final UserEntity? user;

  static Future<void> show(BuildContext context, {UserEntity? user}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MyProfileBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final userName = user?.name.isNotEmpty == true ? user!.name : 'Ramesh Patil';
    final userPhone = user?.phone.isNotEmpty == true ? user!.phone : '9876543210';
    final memberId = user?.id.isNotEmpty == true ? 'WUA-${user!.id.substring(0, user!.id.length > 5 ? 5 : user!.id.length)}' : 'WUA-10245';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header row with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Profile',
                style: context.titleLarge.bold.withColor(colors.textPrimary),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Details Card
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _ProfileDetailRow(
                  label: 'User',
                  value: userName,
                ),
                const _RowDivider(),
                _ProfileDetailRow(
                  label: 'Mobile',
                  value: userPhone,
                ),
                const _RowDivider(),
                _ProfileDetailRow(
                  label: 'Member ID',
                  value: memberId,
                ),
                const _RowDivider(),
                const _ProfileDetailRow(
                  label: 'Designation',
                  value: 'FARMER_IRRIGATOR',
                ),
                const _RowDivider(),
                const _ProfileDetailRow(
                  label: 'Land Holding',
                  value: '4.5 Acres (Survey 142/2A & 142/2B)',
                ),
                const _RowDivider(),
                const _ProfileDetailRow(
                  label: 'Organization',
                  value: 'Mulshi Water User Association',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: context.bodyMedium.medium.withColor(
                colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.bodyMedium.semiBold.withColor(
                colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Divider(
      height: 1,
      thickness: 1,
      color: colors.divider.withValues(alpha: 0.5),
    );
  }
}
