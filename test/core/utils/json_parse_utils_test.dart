import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/utils/json_parse_utils.dart';

void main() {
  group('JsonParseUtils', () {
    test('parseString & parseStringOrNull handle null, numbers, and whitespace', () {
      expect(JsonParseUtils.parseString(null, defaultValue: 'N/A'), 'N/A');
      expect(JsonParseUtils.parseString(123), '123');
      expect(JsonParseUtils.parseString('  hello  '), 'hello');

      expect(JsonParseUtils.parseStringOrNull(null), isNull);
      expect(JsonParseUtils.parseStringOrNull('   '), isNull);
      expect(JsonParseUtils.parseStringOrNull(456), '456');
    });

    test('parseInt & parseIntOrNull handle int, double, numeric strings, and invalid values', () {
      expect(JsonParseUtils.parseInt(null, defaultValue: -1), -1);
      expect(JsonParseUtils.parseInt(42), 42);
      expect(JsonParseUtils.parseInt(42.9), 42);
      expect(JsonParseUtils.parseInt(' 42 '), 42);
      expect(JsonParseUtils.parseInt('42.7'), 42);
      expect(JsonParseUtils.parseInt('abc', defaultValue: 5), 5);
      expect(JsonParseUtils.parseIntOrNull(double.nan), isNull);
      expect(JsonParseUtils.parseIntOrNull(''), isNull);
    });

    test('parseDouble & parseDoubleOrNull handle num, strings, NaN/Infinity, and null', () {
      expect(JsonParseUtils.parseDouble(null, defaultValue: 1.5), 1.5);
      expect(JsonParseUtils.parseDouble(10), 10.0);
      expect(JsonParseUtils.parseDouble(' 123.45 '), 123.45);
      expect(JsonParseUtils.parseDouble('bad', defaultValue: 0.0), 0.0);
      expect(JsonParseUtils.parseDoubleOrNull(double.infinity), isNull);
      expect(JsonParseUtils.parseDoubleOrNull(double.nan), isNull);
    });

    test('parseBool & parseBoolOrNull handle bool, num, and Y/N/true/false strings', () {
      expect(JsonParseUtils.parseBool(true), isTrue);
      expect(JsonParseUtils.parseBool(1), isTrue);
      expect(JsonParseUtils.parseBool(0), isFalse);
      expect(JsonParseUtils.parseBool('Y'), isTrue);
      expect(JsonParseUtils.parseBool('yes'), isTrue);
      expect(JsonParseUtils.parseBool('N'), isFalse);
      expect(JsonParseUtils.parseBool(null, defaultValue: true), isTrue);
      expect(JsonParseUtils.parseBoolOrNull('maybe'), isNull);
    });

    test('parseDateTime & parseDateTimeOrNow handle ISO strings, DateTime, and invalid input', () {
      final now = DateTime(2026, 11, 25);
      expect(JsonParseUtils.parseDateTime(now), now);
      expect(
        JsonParseUtils.parseDateTime('2026-11-25T10:30:00Z'),
        DateTime.parse('2026-11-25T10:30:00Z'),
      );
      expect(JsonParseUtils.parseDateTime('invalid'), isNull);
      expect(JsonParseUtils.parseDateTime(null), isNull);
      expect(
        JsonParseUtils.parseDateTimeOrNow('invalid', fallback: now),
        now,
      );
    });

    test('parseStringList, parseMapOrNull, parseMapList filter invalid entries safely', () {
      expect(
        JsonParseUtils.parseStringList(['a', 2, null, true]),
        ['a', '2', 'true'],
      );
      expect(JsonParseUtils.parseStringList('not-a-list'), isEmpty);

      expect(JsonParseUtils.parseMapOrNull({1: 'one'}), {'1': 'one'});
      expect(JsonParseUtils.parseMapOrNull('not-a-map'), isNull);

      expect(
        JsonParseUtils.parseMapList([
          {'a': 1},
          'bad',
          null,
          {2: 'two'},
        ]),
        [
          {'a': 1},
          {'2': 'two'},
        ],
      );
    });
  });
}
