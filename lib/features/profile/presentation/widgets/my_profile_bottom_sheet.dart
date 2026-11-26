import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:wua_mobile/shared/widgets/wua_bottom_sheet.dart';

/// Modal bottom sheet displaying detailed farmer/member profile information.
class MyProfileBottomSheet extends StatelessWidget {
  const MyProfileBottomSheet({super.key, this.user});

  final UserEntity? user;

  static Future<void> show(BuildContext context, {UserEntity? user}) {
    return showWuaBottomSheet<void>(
      context: context,
      builder: (context) => MyProfileBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final currentUser = user;
    final userName = currentUser?.name.isNotEmpty == true ? currentUser!.name : 'N/A';
    final userPhone = currentUser?.phone.isNotEmpty == true ? currentUser!.phone : 'N/A';
    final memberId = currentUser?.id.isNotEmpty == true
        ? 'WUA-${currentUser!.id.substring(0, currentUser.id.length > 5 ? 5 : currentUser.id.length)}'
        : 'N/A';
    final designation = currentUser != null
        ? (currentUser.roles.isNotEmpty
              ? currentUser.roles.first
              : currentUser.role.name.toUpperCase())
        : 'N/A';
    final surveyText =
        currentUser?.surveyNo != null && currentUser!.surveyNo!.isNotEmpty
        ? currentUser.surveyNo!
        : null;
    final landHolding = currentUser?.farmArea != null
        ? '${currentUser!.farmArea} Acres${surveyText != null ? ' ($surveyText)' : ''}'
        : (surveyText != null ? 'Survey $surveyText' : 'N/A');
    final organization =
        currentUser?.village != null && currentUser!.village!.isNotEmpty
        ? '${currentUser.village!} WUA${currentUser.societyId != null ? ' (#${currentUser.societyId})' : ''}'
        : (currentUser?.societyId != null
              ? 'WUA Society #${currentUser!.societyId}'
              : 'N/A');

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom:
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            24,
      ),
      child: SingleChildScrollView(
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
                _ProfileDetailRow(
                  label: 'Designation',
                  value: designation,
                ),
                const _RowDivider(),
                _ProfileDetailRow(
                  label: 'Land Holding',
                  value: landHolding,
                ),
                if (user?.village != null && user!.village!.isNotEmpty) ...[
                  const _RowDivider(),
                  _ProfileDetailRow(
                    label: 'Village',
                    value: user!.village!,
                  ),
                ],
                if (user?.typeOfCrop != null && user!.typeOfCrop!.isNotEmpty) ...[
                  const _RowDivider(),
                  _ProfileDetailRow(
                    label: 'Primary Crop',
                    value: user!.typeOfCrop!,
                  ),
                ],
                const _RowDivider(),
                _ProfileDetailRow(
                  label: 'Organization',
                  value: organization,
                ),
              ],
            ),
          ),
        ],
        ),
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
