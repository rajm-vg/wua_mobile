/// Safe JSON deserialization utilities to prevent runtime [TypeError]s
/// when API responses contain `null`, missing keys, or mismatched types
/// (e.g., numbers serialized as strings, booleans as `"Y"`/`1`, or dynamic maps).
class JsonParseUtils {
  JsonParseUtils._();

  /// Safely converts [value] to a trimmed [String], returning [defaultValue] if null.
  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString().trim();
  }

  /// Safely converts [value] to a trimmed [String], or `null` if null or empty.
  static String? parseStringOrNull(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  /// Safely parses [value] into an [int], returning [defaultValue] on failure.
  static int parseInt(dynamic value, {int defaultValue = 0}) =>
      parseIntOrNull(value) ?? defaultValue;

  /// Safely parses [value] into an [int], or `null` if unparseable.
  static int? parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.isFinite ? value.toInt() : null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.toInt();
    }
    return null;
  }

  /// Safely parses [value] into a [double], returning [defaultValue] on failure.
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) =>
      parseDoubleOrNull(value) ?? defaultValue;

  /// Safely parses [value] into a [double], or `null` if unparseable.
  static double? parseDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.isFinite ? value.toDouble() : null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final parsed = double.tryParse(trimmed);
      return (parsed != null && parsed.isFinite) ? parsed : null;
    }
    return null;
  }

  /// Safely parses [value] into a [bool], returning [defaultValue] on failure.
  static bool parseBool(dynamic value, {bool defaultValue = false}) =>
      parseBoolOrNull(value) ?? defaultValue;

  /// Safely parses [value] (`bool`, `num`, or `"Y"`/`"true"`/`"1"`/`"N"`/`"false"`/`"0"`)
  /// into a [bool], or `null` if unparseable.
  static bool? parseBoolOrNull(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toUpperCase();
      if (normalized == 'Y' ||
          normalized == 'YES' ||
          normalized == 'TRUE' ||
          normalized == '1') {
        return true;
      }
      if (normalized == 'N' ||
          normalized == 'NO' ||
          normalized == 'FALSE' ||
          normalized == '0') {
        return false;
      }
    }
    return null;
  }

  /// Safely parses [value] into a [DateTime], or `null` if unparseable.
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return DateTime.tryParse(trimmed);
    }
    return null;
  }

  /// Safely parses [value] into a [DateTime], returning [fallback] (or `DateTime.now()`) on failure.
  static DateTime parseDateTimeOrNow(dynamic value, {DateTime? fallback}) =>
      parseDateTime(value) ?? fallback ?? DateTime.now();

  /// Safely converts a JSON list into a `List<String>`, skipping null entries.
  static List<String> parseStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
  }

  /// Safely converts a JSON map into `Map<String, dynamic>`, or `null` if not a map.
  static Map<String, dynamic>? parseMapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  /// Safely converts a JSON list into `List<Map<String, dynamic>>`, skipping invalid entries.
  static List<Map<String, dynamic>> parseMapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(parseMapOrNull)
        .whereType<Map<String, dynamic>>()
        .toList();
  }
}
