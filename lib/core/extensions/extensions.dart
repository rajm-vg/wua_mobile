import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

export '../l10n/l10n.dart';
export '../theme/theme.dart';

/// Extension methods on [BuildContext] for cleaner widget code.
extension BuildContextExtensions on BuildContext {
  // ─── Theme Shortcuts ────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // ─── MediaQuery Shortcuts ──────────────────────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  Brightness get platformBrightness => MediaQuery.platformBrightnessOf(this);

  // ─── Navigation ────────────────────────────────────────────
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  bool get canPop => Navigator.of(this).canPop();

  // ─── SnackBar ──────────────────────────────────────────────
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  // ─── Keyboard ──────────────────────────────────────────────
  void hideKeyboard() => FocusScope.of(this).unfocus();
}

/// Extension methods on [String].
extension StringExtensions on String {
  /// Capitalizes the first letter.
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns true if the string is a valid email.
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Returns true if the string is a valid phone number (10 digits).
  bool get isValidPhone => RegExp(r'^\d{10}$').hasMatch(this);
}

/// Extension methods on [DateTime].
extension DateTimeExtensions on DateTime {
  /// Formats as dd/MM/yyyy.
  String get formatted => DateFormat('dd/MM/yyyy').format(this);

  /// Formats as dd/MM/yyyy HH:mm.
  String get formattedWithTime => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Formats to ISO 8601 string for API calls.
  String get toApiFormat => toUtc().toIso8601String();

  /// Returns human-readable relative time (e.g., "2 hours ago").
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}

/// Extension methods on [num] for currency formatting.
extension NumExtensions on num {
  /// Formats as Indian Rupee currency string.
  String get toRupee => '₹${NumberFormat('#,##,###.##', 'en_IN').format(this)}';
}
