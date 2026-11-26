import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/authentication/domain/repositories/auth_repository.dart';
import 'package:wua_mobile/features/authentication/presentation/widgets/auth_text_field.dart';
import 'package:wua_mobile/features/authentication/presentation/widgets/wrd_brand_header.dart';

enum _ForgotPasswordStep { enterMobile, verifyOtp, newPassword }

/// OTP-based Forgot Password flow for Farmers / Sabhasads & WUA Officials.
///
/// Mirrors the 3-step backend/frontend flow:
/// 1. Request OTP via `POST /api/generate-OTP`
/// 2. Verify 6-digit OTP via `POST /api/verify-OTP` (2-minute expiry)
/// 3. Set new password via `POST /api/change-password`
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _ForgotPasswordStep _step = _ForgotPasswordStep.enterMobile;
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Timer? _otpTimer;
  int _secondsRemaining = 120;

  @override
  void dispose() {
    _otpTimer?.cancel();
    _mobileController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _normalizedMobile {
    final trimmed = _mobileController.text.trim();
    if (RegExp(r'^0\d{10}$').hasMatch(trimmed)) {
      return trimmed.substring(1);
    }
    return trimmed;
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() => _secondsRemaining = 120);
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _formattedTimer {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final result = await sl<AuthRepository>().forgotPassword(
      email: _normalizedMobile,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold((failure) => context.showErrorSnackBar(failure.message), (_) {
      context.showSuccessSnackBar(
        context.isMarathi
            ? 'तुमच्या मोबाईल नंबरवर OTP पाठवला आहे.'
            : 'OTP sent to your registered mobile number.',
      );
      setState(() => _step = _ForgotPasswordStep.verifyOtp);
      _startOtpTimer();
    });
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final result = await sl<AuthRepository>().verifyOtp(
      email: _normalizedMobile,
      otp: _otpController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold((failure) => context.showErrorSnackBar(failure.message), (_) {
      _otpTimer?.cancel();
      context.showSuccessSnackBar(
        context.isMarathi
            ? 'OTP यशस्वीरित्या पडताळला गेला.'
            : 'OTP verified successfully.',
      );
      setState(() => _step = _ForgotPasswordStep.newPassword);
    });
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final result = await sl<AuthRepository>().resetPassword(
      email: _normalizedMobile,
      otp: _otpController.text.trim(),
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold((failure) => context.showErrorSnackBar(failure.message), (_) {
      context.showSuccessSnackBar(
        context.isMarathi
            ? 'पासवर्ड यशस्वीरित्या बदलला गेला! कृपया लॉगिन करा.'
            : 'Password updated successfully! Please login.',
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMarathi = context.isMarathi;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: _isLoading
              ? null
              : () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/login');
                  }
                },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TextButton.icon(
              onPressed: () => context.toggleLocale(),
              icon: Icon(
                Icons.translate_rounded,
                size: 18,
                color: isDark ? AppColors.waterCyan : AppColors.primary,
              ),
              label: Text(
                isMarathi ? 'English' : 'मराठी',
                style: context.labelMedium.semiBold.withColor(
                  isDark ? AppColors.waterCyan : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WrdBrandHeader(),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: AppRadius.borderRadiusLg,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _stepTitle(isMarathi),
                            style: context.titleMedium.bold.withColor(
                              isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _stepSubtitle(isMarathi),
                            style: context.bodySmall.withColor(
                              isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_step == _ForgotPasswordStep.enterMobile) ...[
                            AuthTextField(
                              key: const Key('forgot_mobile_field'),
                              controller: _mobileController,
                              label: isMarathi
                                  ? 'नोंदणीकृत मोबाईल नंबर'
                                  : 'Registered Mobile Number',
                              hintText: '9876543210',
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              enabled: !_isLoading,
                              prefixIcon: const Icon(
                                Icons.phone_android_rounded,
                              ),
                              validator: (val) {
                                final t = val?.trim() ?? '';
                                final norm = RegExp(r'^0\d{10}$').hasMatch(t)
                                    ? t.substring(1)
                                    : t;
                                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(norm)) {
                                  return isMarathi
                                      ? 'कृपया वैध १० अंकी मोबाईल नंबर प्रविष्ट करा.'
                                      : 'Please enter a valid 10-digit mobile number.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _sendOtp(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _SubmitButton(
                              key: const Key('send_otp_button'),
                              label: isMarathi ? 'OTP पाठवा' : 'Send OTP',
                              isLoading: _isLoading,
                              onPressed: _sendOtp,
                            ),
                          ] else if (_step ==
                              _ForgotPasswordStep.verifyOtp) ...[
                            AuthTextField(
                              key: const Key('forgot_otp_field'),
                              controller: _otpController,
                              label: isMarathi ? '६ अंकी OTP' : '6-Digit OTP',
                              hintText: '123456',
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              enabled: !_isLoading,
                              prefixIcon: const Icon(Icons.pin_outlined),
                              validator: (val) {
                                final t = val?.trim() ?? '';
                                if (!RegExp(r'^\d{6}$').hasMatch(t)) {
                                  return isMarathi
                                      ? 'कृपया ६ अंकी OTP प्रविष्ट करा.'
                                      : 'Please enter a valid 6-digit OTP.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _verifyOtp(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _secondsRemaining > 0
                                      ? (isMarathi
                                            ? 'कालावधी: $_formattedTimer'
                                            : 'Expires in $_formattedTimer')
                                      : (isMarathi
                                            ? 'OTP कालबाह्य झाला'
                                            : 'OTP expired'),
                                  style: context.caption.withColor(
                                    _secondsRemaining > 0
                                        ? (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary)
                                        : AppColors.error,
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      (_isLoading || _secondsRemaining > 0)
                                      ? null
                                      : _sendOtp,
                                  child: Text(
                                    isMarathi
                                        ? 'पुन्हा OTP पाठवा'
                                        : 'Resend OTP',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _SubmitButton(
                              key: const Key('verify_otp_button'),
                              label: isMarathi ? 'OTP पडताळा' : 'Verify OTP',
                              isLoading: _isLoading,
                              onPressed: _verifyOtp,
                            ),
                          ] else ...[
                            AuthTextField(
                              key: const Key('forgot_new_password_field'),
                              controller: _newPasswordController,
                              label: isMarathi
                                  ? 'नवीन पासवर्ड'
                                  : 'New Password',
                              hintText: '••••••',
                              obscureText: _obscureNew,
                              textInputAction: TextInputAction.next,
                              enabled: !_isLoading,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),
                              validator: (val) {
                                if (val == null || val.length < 6) {
                                  return isMarathi
                                      ? 'पासवर्ड किमान ६ अक्षरांचा असावा.'
                                      : 'Password must be at least 6 characters.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              key: const Key('forgot_confirm_password_field'),
                              controller: _confirmPasswordController,
                              label: isMarathi
                                  ? 'पासवर्डची पुष्टी करा'
                                  : 'Confirm Password',
                              hintText: '••••••',
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              enabled: !_isLoading,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                              validator: (val) {
                                if (val != _newPasswordController.text) {
                                  return isMarathi
                                      ? 'पासवर्ड जुळत नाही.'
                                      : 'Passwords do not match.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _resetPassword(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _SubmitButton(
                              key: const Key('reset_password_button'),
                              label: isMarathi
                                  ? 'पासवर्ड बदला'
                                  : 'Reset Password',
                              isLoading: _isLoading,
                              onPressed: _resetPassword,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _stepTitle(bool isMarathi) {
    switch (_step) {
      case _ForgotPasswordStep.enterMobile:
        return isMarathi ? 'पासवर्ड विसरलात?' : 'Forgot Password?';
      case _ForgotPasswordStep.verifyOtp:
        return isMarathi ? 'OTP पडताळणी' : 'Verify OTP';
      case _ForgotPasswordStep.newPassword:
        return isMarathi ? 'नवीन पासवर्ड सेट करा' : 'Set New Password';
    }
  }

  String _stepSubtitle(bool isMarathi) {
    switch (_step) {
      case _ForgotPasswordStep.enterMobile:
        return isMarathi
            ? 'OTP मिळवण्यासाठी तुमचा नोंदणीकृत १० अंकी मोबाईल नंबर प्रविष्ट करा.'
            : 'Enter your registered 10-digit mobile number to receive an OTP.';
      case _ForgotPasswordStep.verifyOtp:
        return isMarathi
            ? '$_normalizedMobile वर पाठवलेला ६ अंकी OTP प्रविष्ट करा.'
            : 'Enter the 6-digit OTP sent to $_normalizedMobile.';
      case _ForgotPasswordStep.newPassword:
        return isMarathi
            ? 'तुमच्या खात्यासाठी नवीन पासवर्ड प्रविष्ट करा.'
            : 'Enter a new password for your account.';
    }
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label, style: context.buttonText.white),
      ),
    );
  }
}
