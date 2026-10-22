import 'package:flutter/widgets.dart';

import 'package:wua_mobile/core/l10n/generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Global notifier for controlling app locale dynamically.
final ValueNotifier<Locale?> appLocaleNotifier = ValueNotifier<Locale?>(null);

/// Extension on [BuildContext] to access localized strings cleanly via `context.l10n`.
extension AppLocalizationsX on BuildContext {
  /// Localized strings provider.
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    assert(
      localizations != null,
      'No AppLocalizations found in context. Ensure MaterialApp includes '
      'AppLocalizations.localizationsDelegates and supportedLocales.',
    );
    return localizations!;
  }

  /// Whether current active locale is Hindi.
  bool get isHindi {
    final current = Localizations.localeOf(this);
    return current.languageCode == 'hi';
  }

  /// Toggle between English and Hindi.
  void toggleLocale() {
    if (isHindi) {
      appLocaleNotifier.value = const Locale('en');
    } else {
      appLocaleNotifier.value = const Locale('hi');
    }
  }
}

