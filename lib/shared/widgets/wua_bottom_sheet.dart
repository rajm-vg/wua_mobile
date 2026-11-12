import 'package:flutter/material.dart';

/// Displays a modal bottom sheet on the root navigator so it renders above
/// shell navigation chrome such as `MainShell`'s floating bottom bar.
Future<T?> showWuaBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color backgroundColor = Colors.transparent,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    builder: builder,
  );
}

