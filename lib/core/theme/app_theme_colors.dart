import 'package:flutter/material.dart';

import 'package:wua_mobile/core/theme/colors.dart';

/// Semantic theme colors extension supporting both light and dark themes.
/// Eliminates imperative `isDark ? colorA : colorB` checks across UI widgets.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    // Surface & Background
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.cardBackground,
    required this.cardBorder,
    required this.cardShadow,
    required this.divider,

    // Text & Content
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textDisabled,

    // Header & Regional Brand
    required this.headerBackground,
    required this.headerText,
    required this.headerSubtitle,
    required this.headerActionBg,
    required this.headerToggleBg,

    // Next Canal Turn Card
    required this.turnCardBorder,
    required this.turnCardTitle,
    required this.turnCardBadgeBg,
    required this.turnCardBadgeText,
    required this.turnCardTimelineBorder,
    required this.turnCardTimelineText,

    // Current Pani Patti Bill Card
    required this.billBadgeBg,
    required this.billBadgeText,
    required this.billCtaBg,
    required this.billCtaText,
    required this.billDivider,

    // Water Metrics Row
    required this.waterProgressTrack,
    required this.waterProgressFill,
    required this.waterDropIconBg,
    required this.waterDropIconColor,
    required this.duesWarningBg,
    required this.duesWarningIcon,
    required this.duesSubtitle,

    // Farmer Services
    required this.serviceCardBg,
    required this.serviceCardBorder,
    required this.serviceCardShadow,
    required this.serviceTitle,

    // Recent Activity / Transactions
    required this.activityCheckBg,
    required this.activityCheckIcon,
    required this.activityPaidBadgeBg,
    required this.activityPaidBadgeText,

    // Floating Bottom Navigation
    required this.navBarBg,
    required this.navBarBorder,
    required this.navBarShadow,
    required this.navBarActive,
    required this.navBarInactive,

    // Semantic Brand & Status
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.canalGreen,
    required this.waterCyan,
    required this.harvestAmber,
  });

  // ─── Surface & Background ─────────────────────────────────────
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color cardBackground;
  final Color cardBorder;
  final Color cardShadow;
  final Color divider;

  // ─── Text & Content ───────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textDisabled;

  // ─── Header & Regional Brand ──────────────────────────────────
  final Color headerBackground;
  final Color headerText;
  final Color headerSubtitle;
  final Color headerActionBg;
  final Color headerToggleBg;

  // ─── Next Canal Turn Card ─────────────────────────────────────
  final Color turnCardBorder;
  final Color turnCardTitle;
  final Color turnCardBadgeBg;
  final Color turnCardBadgeText;
  final Color turnCardTimelineBorder;
  final Color turnCardTimelineText;

  // ─── Current Pani Patti Bill Card ─────────────────────────────
  final Color billBadgeBg;
  final Color billBadgeText;
  final Color billCtaBg;
  final Color billCtaText;
  final Color billDivider;

  // ─── Water Metrics Row ────────────────────────────────────────
  final Color waterProgressTrack;
  final Color waterProgressFill;
  final Color waterDropIconBg;
  final Color waterDropIconColor;
  final Color duesWarningBg;
  final Color duesWarningIcon;
  final Color duesSubtitle;

  // ─── Farmer Services ──────────────────────────────────────────
  final Color serviceCardBg;
  final Color serviceCardBorder;
  final Color serviceCardShadow;
  final Color serviceTitle;

  // ─── Recent Activity / Transactions ───────────────────────────
  final Color activityCheckBg;
  final Color activityCheckIcon;
  final Color activityPaidBadgeBg;
  final Color activityPaidBadgeText;

  // ─── Floating Bottom Navigation ───────────────────────────────
  final Color navBarBg;
  final Color navBarBorder;
  final Color navBarShadow;
  final Color navBarActive;
  final Color navBarInactive;

  // ─── Semantic Brand & Status ──────────────────────────────────
  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color canalGreen;
  final Color waterCyan;
  final Color harvestAmber;

  // ─── Light Palette Definition ─────────────────────────────────
  static const light = AppThemeColors(
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    surfaceVariant: AppColors.surfaceVariantLight,
    cardBackground: Colors.white,
    cardBorder: Color(0x0D000000), // black with 0.05 opacity
    cardShadow: Color(0x0A000000), // black with 0.04 opacity
    divider: AppColors.divider,

    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textHint: AppColors.textHint,
    textDisabled: AppColors.textDisabled,

    headerBackground: AppColors.headerTeal,
    headerText: Colors.white,
    headerSubtitle: AppColors.waterCyanLight,
    headerActionBg: Color(0x26FFFFFF), // white with 0.15 opacity
    headerToggleBg: Color(0x40000000), // black with 0.25 opacity

    turnCardBorder: AppColors.mintBorder,
    turnCardTitle: AppColors.canalGreen,
    turnCardBadgeBg: AppColors.canalGreen,
    turnCardBadgeText: Colors.white,
    turnCardTimelineBorder: AppColors.canalGreen,
    turnCardTimelineText: AppColors.canalGreen,

    billBadgeBg: AppColors.amberBadgeBg,
    billBadgeText: AppColors.amberBadgeText,
    billCtaBg: AppColors.headerTeal,
    billCtaText: Colors.white,
    billDivider: Color(0x0F000000), // black with 0.06 opacity

    waterProgressTrack: Color(0x0F000000),
    waterProgressFill: AppColors.canalGreen,
    waterDropIconBg: Color(0xFFE0F2F1),
    waterDropIconColor: AppColors.headerTeal,
    duesWarningBg: Color(0xFFFFF8E1),
    duesWarningIcon: Color(0xFFF57F17),
    duesSubtitle: Color(0xFF2E7D32),

    serviceCardBg: Colors.white,
    serviceCardBorder: Color(0x0D000000),
    serviceCardShadow: Color(0x08000000),
    serviceTitle: AppColors.textPrimary,

    activityCheckBg: Color(0xFFE8F5E9),
    activityCheckIcon: Color(0xFF2E7D32),
    activityPaidBadgeBg: Color(0xFFE8F5E9),
    activityPaidBadgeText: Color(0xFF2E7D32),

    navBarBg: Colors.white,
    navBarBorder: Color(0x0D000000),
    navBarShadow: Color(0x14000000),
    navBarActive: AppColors.headerTeal,
    navBarInactive: Color(0xFF78909C),

    primary: AppColors.primary,
    secondary: AppColors.secondary,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    canalGreen: AppColors.canalGreen,
    waterCyan: AppColors.waterCyan,
    harvestAmber: AppColors.harvestAmber,
  );

  // ─── Dark Palette Definition ──────────────────────────────────
  static const dark = AppThemeColors(
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceVariant: AppColors.surfaceVariantDark,
    cardBackground: Color(0xFF0F262C), // Rich nocturnal teal-slate
    cardBorder: Color(0x334DD0E1), // Luminescent cyan-mint rim glow
    cardShadow: Color(0x66000000), // Deep nocturnal shadow
    divider: Color(0x1F4DD0E1),

    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textHint: Color(0xFF64748B),
    textDisabled: Color(0xFF475569),

    headerBackground: AppColors.darkCanal, // Rich peacock teal
    headerText: Colors.white,
    headerSubtitle: Color(0xFF80DEEA), // Glowing cyan
    headerActionBg: Color(0x26FFFFFF),
    headerToggleBg: Color(0x40000000),

    turnCardBorder: Color(0x6626A69A), // Luminous emerald edge
    turnCardTitle: Color(0xFF26E6C8), // Luminous emerald-mint
    turnCardBadgeBg: Color(0xFF00897B), // Vibrant emerald badge
    turnCardBadgeText: Colors.white,
    turnCardTimelineBorder: Color(0xFF26E6C8),
    turnCardTimelineText: Color(0xFF26E6C8),

    billBadgeBg: Color(0x3DFFB300), // Warm glowing amber tint
    billBadgeText: Color(0xFFFBBF24), // Bright gold
    billCtaBg: Color(0xFF00897B), // Vibrant oceanic teal CTA
    billCtaText: Colors.white,
    billDivider: Color(0x1F4DD0E1),

    waterProgressTrack: Color(0xFF0A1F24),
    waterProgressFill: Color(0xFF26C6DA), // Glowing water cyan
    waterDropIconBg: Color(0x3326C6DA), // Soft luminous cyan halo
    waterDropIconColor: Color(0xFF4DD0E1),
    duesWarningBg: Color(0x33FFB300), // Warm amber halo
    duesWarningIcon: Color(0xFFFFB300),
    duesSubtitle: Color(0xFF4ADE80), // Vibrant sprout green

    serviceCardBg: Color(0xFF112930), // Elevated nocturnal slate
    serviceCardBorder: Color(0x264DD0E1),
    serviceCardShadow: Color(0x4D000000),
    serviceTitle: Color(0xFFF1F5F9),

    activityCheckBg: Color(0x2E00C853), // Glowing emerald halo
    activityCheckIcon: Color(0xFF4ADE80),
    activityPaidBadgeBg: Color(0x2E00C853),
    activityPaidBadgeText: Color(0xFF4ADE80),

    navBarBg: Color(0xFF0C242A), // Rich midnight teal pill
    navBarBorder: Color(0x334DD0E1), // Cyan rim glow
    navBarShadow: Color(0x80000000),
    navBarActive: Color(0xFF26E6C8), // Vibrant cyan active
    navBarInactive: Color(0xFF7E9CA4), // Soft nocturnal teal-gray

    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    error: AppColors.errorLight,
    info: Color(0xFF38BDF8),
    canalGreen: Color(0xFF26E6C8),
    waterCyan: Color(0xFF80DEEA),
    harvestAmber: Color(0xFFFFB300),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? cardBackground,
    Color? cardBorder,
    Color? cardShadow,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? textDisabled,
    Color? headerBackground,
    Color? headerText,
    Color? headerSubtitle,
    Color? headerActionBg,
    Color? headerToggleBg,
    Color? turnCardBorder,
    Color? turnCardTitle,
    Color? turnCardBadgeBg,
    Color? turnCardBadgeText,
    Color? turnCardTimelineBorder,
    Color? turnCardTimelineText,
    Color? billBadgeBg,
    Color? billBadgeText,
    Color? billCtaBg,
    Color? billCtaText,
    Color? billDivider,
    Color? waterProgressTrack,
    Color? waterProgressFill,
    Color? waterDropIconBg,
    Color? waterDropIconColor,
    Color? duesWarningBg,
    Color? duesWarningIcon,
    Color? duesSubtitle,
    Color? serviceCardBg,
    Color? serviceCardBorder,
    Color? serviceCardShadow,
    Color? serviceTitle,
    Color? activityCheckBg,
    Color? activityCheckIcon,
    Color? activityPaidBadgeBg,
    Color? activityPaidBadgeText,
    Color? navBarBg,
    Color? navBarBorder,
    Color? navBarShadow,
    Color? navBarActive,
    Color? navBarInactive,
    Color? primary,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? canalGreen,
    Color? waterCyan,
    Color? harvestAmber,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      textDisabled: textDisabled ?? this.textDisabled,
      headerBackground: headerBackground ?? this.headerBackground,
      headerText: headerText ?? this.headerText,
      headerSubtitle: headerSubtitle ?? this.headerSubtitle,
      headerActionBg: headerActionBg ?? this.headerActionBg,
      headerToggleBg: headerToggleBg ?? this.headerToggleBg,
      turnCardBorder: turnCardBorder ?? this.turnCardBorder,
      turnCardTitle: turnCardTitle ?? this.turnCardTitle,
      turnCardBadgeBg: turnCardBadgeBg ?? this.turnCardBadgeBg,
      turnCardBadgeText: turnCardBadgeText ?? this.turnCardBadgeText,
      turnCardTimelineBorder:
          turnCardTimelineBorder ?? this.turnCardTimelineBorder,
      turnCardTimelineText: turnCardTimelineText ?? this.turnCardTimelineText,
      billBadgeBg: billBadgeBg ?? this.billBadgeBg,
      billBadgeText: billBadgeText ?? this.billBadgeText,
      billCtaBg: billCtaBg ?? this.billCtaBg,
      billCtaText: billCtaText ?? this.billCtaText,
      billDivider: billDivider ?? this.billDivider,
      waterProgressTrack: waterProgressTrack ?? this.waterProgressTrack,
      waterProgressFill: waterProgressFill ?? this.waterProgressFill,
      waterDropIconBg: waterDropIconBg ?? this.waterDropIconBg,
      waterDropIconColor: waterDropIconColor ?? this.waterDropIconColor,
      duesWarningBg: duesWarningBg ?? this.duesWarningBg,
      duesWarningIcon: duesWarningIcon ?? this.duesWarningIcon,
      duesSubtitle: duesSubtitle ?? this.duesSubtitle,
      serviceCardBg: serviceCardBg ?? this.serviceCardBg,
      serviceCardBorder: serviceCardBorder ?? this.serviceCardBorder,
      serviceCardShadow: serviceCardShadow ?? this.serviceCardShadow,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      activityCheckBg: activityCheckBg ?? this.activityCheckBg,
      activityCheckIcon: activityCheckIcon ?? this.activityCheckIcon,
      activityPaidBadgeBg: activityPaidBadgeBg ?? this.activityPaidBadgeBg,
      activityPaidBadgeText:
          activityPaidBadgeText ?? this.activityPaidBadgeText,
      navBarBg: navBarBg ?? this.navBarBg,
      navBarBorder: navBarBorder ?? this.navBarBorder,
      navBarShadow: navBarShadow ?? this.navBarShadow,
      navBarActive: navBarActive ?? this.navBarActive,
      navBarInactive: navBarInactive ?? this.navBarInactive,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      canalGreen: canalGreen ?? this.canalGreen,
      waterCyan: waterCyan ?? this.waterCyan,
      harvestAmber: harvestAmber ?? this.harvestAmber,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      headerBackground:
          Color.lerp(headerBackground, other.headerBackground, t)!,
      headerText: Color.lerp(headerText, other.headerText, t)!,
      headerSubtitle: Color.lerp(headerSubtitle, other.headerSubtitle, t)!,
      headerActionBg: Color.lerp(headerActionBg, other.headerActionBg, t)!,
      headerToggleBg: Color.lerp(headerToggleBg, other.headerToggleBg, t)!,
      turnCardBorder: Color.lerp(turnCardBorder, other.turnCardBorder, t)!,
      turnCardTitle: Color.lerp(turnCardTitle, other.turnCardTitle, t)!,
      turnCardBadgeBg: Color.lerp(turnCardBadgeBg, other.turnCardBadgeBg, t)!,
      turnCardBadgeText:
          Color.lerp(turnCardBadgeText, other.turnCardBadgeText, t)!,
      turnCardTimelineBorder:
          Color.lerp(turnCardTimelineBorder, other.turnCardTimelineBorder, t)!,
      turnCardTimelineText:
          Color.lerp(turnCardTimelineText, other.turnCardTimelineText, t)!,
      billBadgeBg: Color.lerp(billBadgeBg, other.billBadgeBg, t)!,
      billBadgeText: Color.lerp(billBadgeText, other.billBadgeText, t)!,
      billCtaBg: Color.lerp(billCtaBg, other.billCtaBg, t)!,
      billCtaText: Color.lerp(billCtaText, other.billCtaText, t)!,
      billDivider: Color.lerp(billDivider, other.billDivider, t)!,
      waterProgressTrack:
          Color.lerp(waterProgressTrack, other.waterProgressTrack, t)!,
      waterProgressFill:
          Color.lerp(waterProgressFill, other.waterProgressFill, t)!,
      waterDropIconBg: Color.lerp(waterDropIconBg, other.waterDropIconBg, t)!,
      waterDropIconColor:
          Color.lerp(waterDropIconColor, other.waterDropIconColor, t)!,
      duesWarningBg: Color.lerp(duesWarningBg, other.duesWarningBg, t)!,
      duesWarningIcon: Color.lerp(duesWarningIcon, other.duesWarningIcon, t)!,
      duesSubtitle: Color.lerp(duesSubtitle, other.duesSubtitle, t)!,
      serviceCardBg: Color.lerp(serviceCardBg, other.serviceCardBg, t)!,
      serviceCardBorder:
          Color.lerp(serviceCardBorder, other.serviceCardBorder, t)!,
      serviceCardShadow:
          Color.lerp(serviceCardShadow, other.serviceCardShadow, t)!,
      serviceTitle: Color.lerp(serviceTitle, other.serviceTitle, t)!,
      activityCheckBg: Color.lerp(activityCheckBg, other.activityCheckBg, t)!,
      activityCheckIcon:
          Color.lerp(activityCheckIcon, other.activityCheckIcon, t)!,
      activityPaidBadgeBg:
          Color.lerp(activityPaidBadgeBg, other.activityPaidBadgeBg, t)!,
      activityPaidBadgeText:
          Color.lerp(activityPaidBadgeText, other.activityPaidBadgeText, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      navBarBorder: Color.lerp(navBarBorder, other.navBarBorder, t)!,
      navBarShadow: Color.lerp(navBarShadow, other.navBarShadow, t)!,
      navBarActive: Color.lerp(navBarActive, other.navBarActive, t)!,
      navBarInactive: Color.lerp(navBarInactive, other.navBarInactive, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      canalGreen: Color.lerp(canalGreen, other.canalGreen, t)!,
      waterCyan: Color.lerp(waterCyan, other.waterCyan, t)!,
      harvestAmber: Color.lerp(harvestAmber, other.harvestAmber, t)!,
    );
  }
}
