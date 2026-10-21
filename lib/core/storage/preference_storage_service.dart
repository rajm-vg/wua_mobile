import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Non-sensitive preference storage using [SharedPreferences].
/// Stores theme, language, feature flags, and first-launch state.
class PreferenceStorageService {
  PreferenceStorageService({required this._prefs});
  final SharedPreferences _prefs;

  // ─── Theme ──────────────────────────────────────────────────

  Future<bool> saveThemeMode(String mode) {
    return _prefs.setString(AppConstants.themeKey, mode);
  }

  String getThemeMode() {
    return _prefs.getString(AppConstants.themeKey) ?? 'system';
  }

  // ─── Language ───────────────────────────────────────────────

  Future<bool> saveLanguage(String languageCode) {
    return _prefs.setString(AppConstants.languageKey, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(AppConstants.languageKey) ?? 'en';
  }

  // ─── First Launch ──────────────────────────────────────────

  Future<bool> setFirstLaunchComplete() {
    return _prefs.setBool(AppConstants.firstLaunchKey, false);
  }

  bool isFirstLaunch() {
    return _prefs.getBool(AppConstants.firstLaunchKey) ?? true;
  }

  // ─── Feature Flags ─────────────────────────────────────────

  Future<bool> saveFeatureFlags(String flagsJson) {
    return _prefs.setString(AppConstants.featureFlagsKey, flagsJson);
  }

  String? getFeatureFlags() {
    return _prefs.getString(AppConstants.featureFlagsKey);
  }

  // ─── Generic Helpers ────────────────────────────────────────

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();
}
