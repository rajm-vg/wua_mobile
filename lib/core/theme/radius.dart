import 'package:flutter/material.dart';

/// Design token: border radius scale.
class AppRadius {
  AppRadius._();

  /// 0dp
  static const double none = 0;

  /// 4dp
  static const double xs = 4;

  /// 8dp
  static const double sm = 8;

  /// 12dp
  static const double md = 12;

  /// 16dp
  static const double lg = 16;

  /// 20dp
  static const double xl = 20;

  /// 24dp
  static const double xxl = 24;

  /// 28dp
  static const double xxxl = 28;

  /// Fully rounded (pill shape).
  static const double full = 999;

  // ─── Pre-built BorderRadius ─────────────────────────────────

  static final BorderRadius borderRadiusXs = BorderRadius.circular(xs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(sm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(md);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(lg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(xl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(full);
}
