import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/spacing.dart';

/// Semantic types of SnackBars with tailored colors, icons, and themes.
enum SnackBarType {
  success,
  error,
  warning,
  info,
  neutral;

  Color get iconColor {
    switch (this) {
      case SnackBarType.success:
        return const Color(0xFF00E676);
      case SnackBarType.error:
        return const Color(0xFFFF5252);
      case SnackBarType.warning:
        return const Color(0xFFFFB300);
      case SnackBarType.info:
        return const Color(0xFF40C4FF);
      case SnackBarType.neutral:
        return Colors.white;
    }
  }

  Color get iconBgColor {
    return iconColor.withValues(alpha: 0.16);
  }

  Color get borderColor {
    return iconColor.withValues(alpha: 0.35);
  }

  IconData get defaultIcon {
    switch (this) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_outline_rounded;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
      case SnackBarType.info:
        return Icons.info_outline_rounded;
      case SnackBarType.neutral:
        return Icons.notifications_none_rounded;
    }
  }

  Duration get defaultDuration {
    switch (this) {
      case SnackBarType.error:
      case SnackBarType.warning:
        return const Duration(seconds: 4);
      case SnackBarType.success:
      case SnackBarType.info:
      case SnackBarType.neutral:
        return const Duration(seconds: 3);
    }
  }
}

/// A centralized, dynamic, modular SnackBar service that can be called from anywhere
/// in the application with or without a [BuildContext].
class SnackBarService {
  /// Global key attached to [MaterialApp.scaffoldMessengerKey] allowing
  /// context-less SnackBar dispatches from anywhere (blocs, services, repositories).
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Dispatches a styled, floating SnackBar.
  static void show({
    required String message,
    String? title,
    SnackBarType type = SnackBarType.info,
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
    bool showCloseButton = false,
    BuildContext? context,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final messengerState = context != null
        ? ScaffoldMessenger.maybeOf(context) ?? scaffoldMessengerKey.currentState
        : scaffoldMessengerKey.currentState;

    if (messengerState == null) return;

    final effectiveDuration = duration ?? type.defaultDuration;
    final effectiveIcon = icon ?? type.defaultIcon;
    final effectiveBg = backgroundColor ??
        const Color(0xFF14242A); // Deep slate teal matching WUA dark palette
    final effectiveBorder = type.borderColor;

    messengerState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: effectiveDuration,
          elevation: 6,
          backgroundColor: effectiveBg,
          margin: EdgeInsets.fromLTRB(16, 0, 16, bottomOffset ?? 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: effectiveBorder,
              width: 1.2,
            ),
          ),
          content: Row(
            children: [
              // Type Icon Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: type.iconBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: type.borderColor,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    effectiveIcon,
                    color: type.iconColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Title and Message Column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.isNotEmpty) ...[
                      Text(
                        title,
                        style: TextStyle(
                          color: foregroundColor ?? Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: TextStyle(
                        color: (foregroundColor ?? Colors.white)
                            .withValues(alpha: 0.92),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Optional Action Button
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: AppSpacing.xs),
                TextButton(
                  onPressed: () {
                    messengerState.hideCurrentSnackBar();
                    onAction();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: type.iconColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                      color: type.iconColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (showCloseButton) ...[
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  onPressed: messengerState.hideCurrentSnackBar,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      );
  }

  /// Convenience method for Success messages.
  static void showSuccess(
    String message, {
    String? title,
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
    bool showCloseButton = false,
    BuildContext? context,
  }) {
    show(
      message: message,
      title: title,
      type: SnackBarType.success,
      duration: duration,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      bottomOffset: bottomOffset,
      showCloseButton: showCloseButton,
      context: context,
    );
  }

  /// Convenience method for Error messages.
  static void showError(
    String message, {
    String? title,
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
    bool showCloseButton = false,
    BuildContext? context,
  }) {
    show(
      message: message,
      title: title,
      type: SnackBarType.error,
      duration: duration,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      bottomOffset: bottomOffset,
      showCloseButton: showCloseButton,
      context: context,
    );
  }

  /// Convenience method for Warning messages.
  static void showWarning(
    String message, {
    String? title,
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
    bool showCloseButton = false,
    BuildContext? context,
  }) {
    show(
      message: message,
      title: title,
      type: SnackBarType.warning,
      duration: duration,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      bottomOffset: bottomOffset,
      showCloseButton: showCloseButton,
      context: context,
    );
  }

  /// Convenience method for Informational messages.
  static void showInfo(
    String message, {
    String? title,
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    double? bottomOffset,
    bool showCloseButton = false,
    BuildContext? context,
  }) {
    show(
      message: message,
      title: title,
      type: SnackBarType.info,
      duration: duration,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      bottomOffset: bottomOffset,
      showCloseButton: showCloseButton,
      context: context,
    );
  }

  /// Hides the active SnackBar if visible.
  static void hide({BuildContext? context}) {
    final messengerState = context != null
        ? ScaffoldMessenger.maybeOf(context) ?? scaffoldMessengerKey.currentState
        : scaffoldMessengerKey.currentState;
    messengerState?.hideCurrentSnackBar();
  }
}

/// Shorthand ergonomic alias for [SnackBarService].
typedef AppSnackBar = SnackBarService;

