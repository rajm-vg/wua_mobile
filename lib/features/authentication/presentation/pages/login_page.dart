import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/core/utils/validators.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_event.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_state.dart';
import 'package:wua_mobile/features/authentication/presentation/widgets/auth_text_field.dart';
import 'package:wua_mobile/features/authentication/presentation/widgets/farmer_help_card.dart';
import 'package:wua_mobile/features/authentication/presentation/widgets/wrd_brand_header.dart';

/// Production-ready executive login page for the WUA Mobile app.
///
/// Designed for Water Resources Department officials, WUA committee members,
/// and farmers across both light and dark modes with complete i18n support.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: const _LoginPageView(),
    );
  }
}

class _LoginPageView extends StatefulWidget {
  const _LoginPageView();

  @override
  State<_LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<_LoginPageView> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  final _identifierFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _identifierFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onLoginSubmitted() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              identifier: _identifierController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _quickFill(String identifier, String password) {
    setState(() {
      _identifierController.text = identifier;
      _passwordController.text = password;
    });
  }

  String? _validateIdentifier(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter your mobile number or email.';
    }

    final isNumeric = RegExp(r'^\d+$').hasMatch(trimmed);
    if (isNumeric) {
      if (trimmed.length != 10) {
        return 'Please enter a valid 10-digit mobile number.';
      }
      return null;
    }

    if (trimmed.contains('@')) {
      return Validators.email(trimmed);
    }

    return 'Please enter a valid 10-digit mobile number or email.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = context.l10n;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      state.message,
                      style: context.bodySmall.white.medium,
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusMd,
              ),
              margin: const EdgeInsets.all(AppSpacing.md),
            ),
          );
        } else if (state is AuthAuthenticated) {
          context.go('/');
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              // Language Switcher Button (English / हिन्दी)
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
                    context.isHindi ? 'English' : 'हिन्दी',
                    style: context.labelMedium.semiBold.withColor(
                      isDark ? AppColors.waterCyan : AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.waterCyan.withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusFull,
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Department Brand Header
                        const WrdBrandHeader(),
                        const SizedBox(height: AppSpacing.xl),

                        // Form Container Card
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.35 : 0.05,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Identifier input
                              AuthTextField(
                                key: const Key('login_identifier_field'),
                                controller: _identifierController,
                                focusNode: _identifierFocusNode,
                                label: l10n.identifierLabel,
                                hintText: l10n.identifierHint,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                                prefixIcon: const Icon(
                                  Icons.account_circle_outlined,
                                ),
                                suffixIcon: _identifierController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                setState(_identifierController.clear);
                                              },
                                      )
                                    : null,
                                onChanged: (_) => setState(() {}),
                                validator: _validateIdentifier,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.telephoneNumber,
                                  AutofillHints.email,
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Password input
                              AuthTextField(
                                key: const Key('login_password_field'),
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                label: l10n.password,
                                hintText: l10n.passwordHint,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                enabled: !isLoading,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  key: const Key('toggle_password_visibility'),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                onFieldSubmitted: (_) => _onLoginSubmitted(),
                                validator: (val) =>
                                    Validators.required(val, l10n.password),
                                autofillHints: const [AutofillHints.password],
                              ),
                              const SizedBox(height: AppSpacing.xs),

                              // Remember Me & Forgot Password Row
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      key: const Key('remember_me_checkbox'),
                                      value: _rememberMe,
                                      onChanged: isLoading
                                          ? null
                                          : (val) {
                                              setState(() {
                                                _rememberMe = val ?? false;
                                              });
                                            },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _rememberMe = !_rememberMe;
                                            });
                                          },
                                    child: Text(
                                      l10n.rememberMe,
                                      style: context.bodySmall.medium.withColor(
                                        isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    key: const Key('forgot_password_button'),
                                    onPressed: isLoading
                                        ? null
                                        : () => context.push(
                                              RouteNames.forgotPassword,
                                            ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      l10n.forgotPassword,
                                      style: context.caption.semiBold.withColor(
                                        isDark
                                            ? AppColors.waterCyan
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Submit Button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  key: const Key('login_submit_button'),
                                  onPressed:
                                      isLoading ? null : _onLoginSubmitted,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor:
                                        AppColors.primary.withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.borderRadiusMd,
                                    ),
                                    disabledBackgroundColor: AppColors.primary
                                        .withValues(alpha: 0.6),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              l10n.login,
                                              style: context.buttonText.white,
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.xs,
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Quick Role Test Chips (Executive Demo Helper)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'QUICK ROLE DEMO',
                                style: context.badgeText.withColor(
                                  isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                alignment: WrapAlignment.center,
                                children: [
                                  ActionChip(
                                    label: Text(
                                      l10n.roleFarmer,
                                      style: context.labelSmall.semiBold,
                                    ),
                                    avatar: const Icon(
                                      Icons.agriculture_rounded,
                                      size: 16,
                                      color: AppColors.sproutGreen,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () => _quickFill(
                                              '9876543210',
                                              'Farmer@123',
                                            ),
                                  ),
                                  ActionChip(
                                    label: Text(
                                      l10n.roleOfficial,
                                      style: context.labelSmall.semiBold,
                                    ),
                                    avatar: const Icon(
                                      Icons.badge_rounded,
                                      size: 16,
                                      color: AppColors.primaryLight,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () => _quickFill(
                                              'official@wua.gov.in',
                                              'Official@123',
                                            ),
                                  ),
                                  ActionChip(
                                    label: Text(
                                      l10n.roleAdmin,
                                      style: context.labelSmall.semiBold,
                                    ),
                                    avatar: const Icon(
                                      Icons.admin_panel_settings_rounded,
                                      size: 16,
                                      color: AppColors.harvestAmber,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () => _quickFill(
                                              'admin@wrd.gov.in',
                                              'Admin@123',
                                            ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.dontHaveAccount,
                              style: context.bodySmall.withColor(
                                isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              key: const Key('register_nav_button'),
                              onPressed: isLoading
                                  ? null
                                  : () => context.push(RouteNames.register),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                ),
                              ),
                              child: Text(
                                l10n.register,
                                style: context.bodySmall.semiBold.withColor(
                                  isDark
                                      ? AppColors.waterCyan
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Toll Free Farmer Helpline Banner
                        const FarmerHelpCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
