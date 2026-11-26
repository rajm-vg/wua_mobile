import 'package:flutter/material.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/authentication/domain/repositories/auth_repository.dart';
import 'package:wua_mobile/shared/widgets/wua_bottom_sheet.dart';

/// Modal bottom sheet for updating account password securely.
class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showWuaBottomSheet<void>(
      context: context,
      builder: (context) => const ChangePasswordBottomSheet(),
    );
  }

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || currentPassword.isEmpty) {
      context.showWarningSnackBar('Please enter all required fields');
      return;
    }

    if (newPassword.length < 4) {
      context.showWarningSnackBar(
        'New password must be at least 4 characters long',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      context.showErrorSnackBar('New passwords do not match');
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await sl<AuthRepository>().changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => context.showErrorSnackBar(failure.message),
      (_) {
        Navigator.of(context).pop();
        context.showSuccessSnackBar('Password updated successfully!');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                'Change Password',
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

          // Current Password Field
          _PasswordField(
            controller: _currentPasswordController,
            label: 'Current Password',
            obscureText: _obscureCurrent,
            onToggleVisibility: () =>
                setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 14),

          // New Password Field
          _PasswordField(
            controller: _newPasswordController,
            label: 'New Password',
            obscureText: _obscureNew,
            onToggleVisibility: () =>
                setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 14),

          // Confirm Password Field
          _PasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            obscureText: _obscureConfirm,
            onToggleVisibility: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.headerBackground,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Update Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
        filled: true,
        fillColor: colors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.textPrimary, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: colors.textSecondary,
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}
