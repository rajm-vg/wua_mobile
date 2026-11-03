import 'package:flutter/widgets.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/generated/app_localizations.dart';
import 'package:wua_mobile/core/storage/preference_storage_service.dart';

export 'generated/app_localizations.dart';

/// Global notifier for controlling app locale dynamically at runtime.
final ValueNotifier<Locale?> appLocaleNotifier = ValueNotifier<Locale?>(null);

/// Updates the active application locale and persists it if storage is available.
Future<void> updateAppLocale(Locale locale) async {
  appLocaleNotifier.value = locale;
  try {
    if (sl.isRegistered<PreferenceStorageService>()) {
      await sl<PreferenceStorageService>().saveLanguage(locale.languageCode);
    }
  } catch (_) {
    // Graceful fallback during unit/widget tests
  }
}

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

  /// Whether current active locale is Marathi.
  bool get isMarathi {
    final current = Localizations.localeOf(this);
    return current.languageCode == 'mr';
  }

  /// Whether current active locale is Hindi.
  bool get isHindi {
    final current = Localizations.localeOf(this);
    return current.languageCode == 'hi';
  }

  /// Current active language code (e.g. 'en', 'mr', 'hi').
  String get currentLanguageCode {
    return Localizations.localeOf(this).languageCode;
  }

  /// Set the active locale and persist the choice.
  void setLocale(Locale locale) {
    updateAppLocale(locale);
  }

  /// Toggle between English ('en') and Marathi ('mr').
  void toggleLocale() {
    if (isMarathi) {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('mr'));
    }
  }
}
