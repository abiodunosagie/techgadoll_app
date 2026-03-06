import 'package:flutter_test/flutter_test.dart';
import 'package:techgadoll_app/core/utils/data_validators.dart';

void main() {
  group('DataValidators.safePrice', () {
    test('returns double for valid num', () {
      expect(DataValidators.safePrice(49.99), 49.99);
    });

    test('returns double for int', () {
      expect(DataValidators.safePrice(50), 50.0);
    });

    test('returns null for null', () {
      expect(DataValidators.safePrice(null), isNull);
    });

    test('returns null for negative', () {
      expect(DataValidators.safePrice(-10.0), isNull);
    });

    test('parses string number', () {
      expect(DataValidators.safePrice('29.99'), 29.99);
    });

    test('returns null for non-numeric string', () {
      expect(DataValidators.safePrice('abc'), isNull);
    });
  });

  group('DataValidators.safeImageUrl', () {
    test('returns valid https URL', () {
      expect(DataValidators.safeImageUrl('https://example.com/img.jpg'),
          'https://example.com/img.jpg');
    });

    test('returns valid http URL', () {
      expect(DataValidators.safeImageUrl('http://example.com/img.jpg'),
          'http://example.com/img.jpg');
    });

    test('returns null for null', () {
      expect(DataValidators.safeImageUrl(null), isNull);
    });

    test('returns null for empty string', () {
      expect(DataValidators.safeImageUrl(''), isNull);
    });

    test('returns null for non-http URL', () {
      expect(DataValidators.safeImageUrl('ftp://example.com'), isNull);
    });

    test('returns null for plain text', () {
      expect(DataValidators.safeImageUrl('not-a-url'), isNull);
    });
  });

  group('DataValidators.safeRating', () {
    test('returns valid rating', () {
      expect(DataValidators.safeRating(4.5), 4.5);
    });

    test('clamps to 5.0 max', () {
      expect(DataValidators.safeRating(6.0), 5.0);
    });

    test('clamps to 0.0 min', () {
      expect(DataValidators.safeRating(-1.0), 0.0);
    });

    test('returns 0.0 for null', () {
      expect(DataValidators.safeRating(null), 0.0);
    });
  });

  group('DataValidators.safeString', () {
    test('returns value when present', () {
      expect(DataValidators.safeString('Hello', 'default'), 'Hello');
    });

    test('returns default for null', () {
      expect(DataValidators.safeString(null, 'default'), 'default');
    });

    test('returns default for empty string', () {
      expect(DataValidators.safeString('', 'default'), 'default');
    });

    test('returns default for whitespace-only', () {
      expect(DataValidators.safeString('   ', 'default'), 'default');
    });
  });
}
