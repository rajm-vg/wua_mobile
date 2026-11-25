import 'package:flutter/foundation.dart';

/// Global notifier incremented whenever a payment settles or state changes,
/// allowing mounted dashboard, bills, and payments screens to auto-refresh.
final ValueNotifier<int> paymentRefreshNotifier = ValueNotifier<int>(0);
