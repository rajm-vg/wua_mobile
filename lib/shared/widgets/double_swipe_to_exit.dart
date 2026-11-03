import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/services/services.dart';

/// Wraps the root shell or view with a double-swipe / double-back-press to exit pattern.
///
/// Behavior:
/// 1. If child routes can pop (e.g. sub-pages or modals), pops the top route normally.
/// 2. If on a non-home tab (e.g. Bills, Payments, Profile), navigates back to Dashboard (`/`).
/// 3. If on Dashboard (`/`) and swiped once, displays a sleek floating toast/snackbar.
/// 4. If swiped again within [duration] (default 2 seconds), exits the application.
class DoubleSwipeToExit extends StatefulWidget {
  const DoubleSwipeToExit({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.message,
    this.bottomOffset = 36.0,
  });

  final Widget child;
  final Duration duration;
  final String? message;
  final double bottomOffset;

  @override
  State<DoubleSwipeToExit> createState() => _DoubleSwipeToExitState();
}

class _DoubleSwipeToExitState extends State<DoubleSwipeToExit> {
  DateTime? _lastSwipeTime;

  bool _isAtHomeRoute(BuildContext context) {
    try {
      final config = GoRouter.of(context).routerDelegate.currentConfiguration;
      final location = config.lastOrNull?.matchedLocation ?? config.uri.path;
      final normalized = location.startsWith('/') ? location : '/$location';
      return normalized == '/' || normalized == '/home';
    } catch (_) {
      return true;
    }
  }

  void _onPopInvoked(bool didPop, dynamic result) {
    if (didPop) return;

    // 1. If inner navigation can pop, pop back to previous view
    if (context.canPop()) {
      context.pop();
      return;
    }

    // 2. If on a non-home bottom navigation tab, navigate back to Dashboard first
    if (!_isAtHomeRoute(context)) {
      context.go('/');
      return;
    }

    // 3. User is at the root Dashboard: handle double swipe logic
    final now = DateTime.now();
    if (_lastSwipeTime == null ||
        now.difference(_lastSwipeTime!) > widget.duration) {
      _lastSwipeTime = now;
      _showExitPrompt();
    } else {
      SnackBarService.hide(context: context);
      SystemNavigator.pop();
    }
  }

  void _showExitPrompt() {
    if (!mounted) return;

    final promptText =
        widget.message ??
        AppLocalizations.of(context)?.swipeAgainToExit ??
        'Swipe back again to exit';

    SnackBarService.showInfo(
      promptText,
      context: context,
      duration: widget.duration,
      bottomOffset: widget.bottomOffset,
      icon: Icons.arrow_back_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: widget.child,
    );
  }
}
