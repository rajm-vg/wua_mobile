import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/constants/env_config.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/utils/validators.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_event.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_state.dart';
import 'package:wua_mobile/features/authentication/presentation/widgets/auth_text_field.dart';
import 'package:wua_mobile/features/authentication/presentation/widgets/farmer_help_card.dart';
import 'package:wua_mobile/features/authentication/presentation/widgets/wrd_brand_header.dart';

/// Registration page for new farmers, WUA members, and water users.
///
/// Shares the same executive government design language, color palette,
/// dark mode support, and bilingual (English / मराठी) support as [LoginPage].
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: const _RegisterPageView(),
    );
  }
}

class _RegisterPageView extends StatefulWidget {
  const _RegisterPageView();

  @override
  State<_RegisterPageView> createState() => _RegisterPageViewState();
}

class _RegisterPageViewState extends State<_RegisterPageView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onRegisterSubmitted() {
    FocusScope.of(context).unfocus();

    if (!_acceptTerms) {
      context.showErrorSnackBar(
        context.isMarathi
            ? 'कृपया नोंदणीसाठी नियम आणि अटी मान्य करा.'
            : 'Please accept the terms and conditions to register.',
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final emailValue = _emailController.text.trim();
      final phoneValue = _phoneController.text.trim();

      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          name: _nameController.text.trim(),
          email: emailValue.isNotEmpty ? emailValue : '$phoneValue@wua.gov.in',
          phone: phoneValue,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _quickFillDemo() {
    setState(() {
      _nameController.text = 'आनंद रामदास पाटील (Anand Patil)';
      _phoneController.text = '9822334455';
      _emailController.text = 'anand.patil@wua.gov.in';
      _passwordController.text = 'Farmer@123';
      _confirmPasswordController.text = 'Farmer@123';
      _acceptTerms = true;
    });
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return context.isMarathi
          ? 'कृपया आपले पूर्ण नाव प्रविष्ट करा.'
          : 'Please enter your full name.';
    }
    if (trimmed.length < 3) {
      return context.isMarathi
          ? 'नाव किमान ३ अक्षरांचे असावे.'
          : 'Name must be at least 3 characters.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return context.isMarathi
          ? 'कृपया १० अंकी मोबाईल नंबर प्रविष्ट करा.'
          : 'Please enter your 10-digit mobile number.';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
      return context.isMarathi
          ? 'वैध १० अंकी मोबाईल नंबर प्रविष्ट करा.'
          : 'Please enter a valid 10-digit mobile number.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null; // Email is optional for farmers
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return context.isMarathi
          ? 'कृपया वैध ईमेल पत्ता प्रविष्ट करा.'
          : 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return context.isMarathi
          ? 'कृपया पासवर्डची पुष्टी करा.'
          : 'Please confirm your password.';
    }
    if (value != _passwordController.text) {
      return context.isMarathi
          ? 'पासवर्ड जुळत नाही.'
          : 'Passwords do not match.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMarathi = context.isMarathi;
    final l10n = context.l10n;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          context.showErrorSnackBar(state.message);
        } else if (state is AuthAuthenticated) {
          context.showSuccessSnackBar(
            isMarathi
                ? 'नोंदणी यशस्वी झाली! WUA पोर्टलमध्ये आपले स्वागत आहे.'
                : 'Registration successful! Welcome to WUA Mobile.',
          );
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
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/login');
                }
              },
            ),
            actions: [
              // Language Switcher Button (English / मराठी)
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
                        const SizedBox(height: AppSpacing.md),

                        // Dev Demo Mode Badge (if enabled)
                        if (EnvConfig.enableDemoFallback) ...[
                          Center(
                            child: Container(
                              key: const Key('dev_demo_fallback_badge'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.sproutGreen.withValues(alpha: 0.15)
                                    : AppColors.sproutGreen.withValues(alpha: 0.10),
                                borderRadius: AppRadius.borderRadiusFull,
                                border: Border.all(
                                  color: AppColors.sproutGreen.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.sproutGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'DEV • Offline Demo Fallback Ready',
                                    style: context.caption.semiBold.withColor(
                                      isDark
                                          ? AppColors.sproutGreen
                                          : AppColors.canalGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ] else
                          const SizedBox(height: AppSpacing.md),

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
                              // Form Title
                              Text(
                                isMarathi
                                    ? 'नवीन खाते नोंदणी'
                                    : 'Create Member Account',
                                style: context.titleMedium.bold.withColor(
                                  isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                isMarathi
                                    ? 'पाणी वापर संस्था (WUA) सेवा, पाणी वाटप व पाणीपट्टीसाठी नोंदणी करा'
                                    : 'Register for irrigation rotations, water shares & digital bills',
                                style: context.bodySmall.withColor(
                                  isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // 1. Full Name Field
                              AuthTextField(
                                key: const Key('register_name_field'),
                                controller: _nameController,
                                focusNode: _nameFocusNode,
                                label: isMarathi ? 'पूर्ण नाव' : 'Full Name',
                                hintText: isMarathi
                                    ? 'उदा. रमेश ज्ञानोबा पाटील'
                                    : 'Enter full name (e.g. Ramesh Patil)',
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                ),
                                suffixIcon: _nameController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                setState(
                                                  _nameController.clear,
                                                );
                                              },
                                      )
                                    : null,
                                onChanged: (_) => setState(() {}),
                                validator: _validateName,
                                autofillHints: const [AutofillHints.name],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 2. Mobile Number Field
                              AuthTextField(
                                key: const Key('register_phone_field'),
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                label: isMarathi
                                    ? 'मोबाईल नंबर'
                                    : 'Mobile Number',
                                hintText: isMarathi
                                    ? '१० अंकी मोबाईल नंबर प्रविष्ट करा'
                                    : 'Enter 10-digit mobile number',
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                                prefixIcon: const Icon(
                                  Icons.phone_android_rounded,
                                ),
                                suffixIcon: _phoneController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                setState(
                                                  _phoneController.clear,
                                                );
                                              },
                                      )
                                    : null,
                                onChanged: (_) => setState(() {}),
                                validator: _validatePhone,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 3. Email Field (Optional)
                              AuthTextField(
                                key: const Key('register_email_field'),
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                label: isMarathi
                                    ? 'ईमेल पत्ता (पर्यायी)'
                                    : 'Email Address (Optional)',
                                hintText: isMarathi
                                    ? 'उदा. farmer@wua.gov.in'
                                    : 'e.g. farmer@wua.gov.in',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                                prefixIcon: const Icon(
                                  Icons.mail_outline_rounded,
                                ),
                                suffixIcon: _emailController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                setState(
                                                  _emailController.clear,
                                                );
                                              },
                                      )
                                    : null,
                                onChanged: (_) => setState(() {}),
                                validator: _validateEmail,
                                autofillHints: const [AutofillHints.email],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 4. Password Field
                              AuthTextField(
                                key: const Key('register_password_field'),
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                label: l10n.password,
                                hintText: isMarathi
                                    ? 'किमान ८ अक्षरे (उदा. Kisan@123)'
                                    : 'Create secure password (min. 8 chars)',
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                enabled: !isLoading,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  key: const Key(
                                    'toggle_register_password_visibility',
                                  ),
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
                                validator: Validators.password,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 5. Confirm Password Field
                              AuthTextField(
                                key: const Key(
                                  'register_confirm_password_field',
                                ),
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocusNode,
                                label: isMarathi
                                    ? 'पासवर्डची पुष्टी करा'
                                    : 'Confirm Password',
                                hintText: isMarathi
                                    ? 'पासवर्ड पुन्हा प्रविष्ट करा'
                                    : 'Re-enter your password',
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                enabled: !isLoading,
                                prefixIcon: const Icon(
                                  Icons.lock_reset_rounded,
                                ),
                                suffixIcon: IconButton(
                                  key: const Key(
                                    'toggle_register_confirm_password_visibility',
                                  ),
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                onFieldSubmitted: (_) =>
                                    _onRegisterSubmitted(),
                                validator: _validateConfirmPassword,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // 6. Terms & Conditions Checkbox
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      key: const Key('register_terms_checkbox'),
                                      value: _acceptTerms,
                                      onChanged: isLoading
                                          ? null
                                          : (val) {
                                              setState(() {
                                                _acceptTerms = val ?? false;
                                              });
                                            },
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: isLoading
                                          ? null
                                          : () {
                                              setState(() {
                                                _acceptTerms = !_acceptTerms;
                                              });
                                            },
                                      child: Text(
                                        isMarathi
                                            ? 'मी जलसंपदा विभाग व पाणी वापर संस्था नियमावली आणि अटी मान्य करतो.'
                                            : 'I agree to the WRD Irrigation Water Governance terms & privacy policies.',
                                        style: context.caption.withColor(
                                          isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // 7. Submit Register Button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  key: const Key('register_submit_button'),
                                  onPressed: isLoading
                                      ? null
                                      : _onRegisterSubmitted,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor: AppColors.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          AppRadius.borderRadiusMd,
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
                                              isMarathi
                                                  ? 'नोंदणी करा'
                                                  : 'Create Account',
                                              style:
                                                  context.buttonText.white,
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.xs,
                                            ),
                                            const Icon(
                                              Icons.how_to_reg_rounded,
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

                        // Quick Fill Demo Chip for instant dev testing
                        Center(
                          child: ActionChip(
                            key: const Key('register_quick_fill_chip'),
                            label: Text(
                              isMarathi
                                  ? 'डेमो माहिती भरा (Quick Demo Fill)'
                                  : 'Quick Demo Fill',
                              style: context.labelSmall.semiBold,
                            ),
                            avatar: const Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: AppColors.sproutGreen,
                            ),
                            onPressed: isLoading ? null : _quickFillDemo,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Back to Login Link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              isMarathi
                                  ? 'आधीच खाते आहे?'
                                  : 'Already have an account?',
                              style: context.bodySmall.withColor(
                                isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              key: const Key('login_nav_button'),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      } else {
                                        context.go(RouteNames.login);
                                      }
                                    },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                ),
                              ),
                              child: Text(
                                isMarathi ? 'येथे लॉगिन करा' : 'Login Here',
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
