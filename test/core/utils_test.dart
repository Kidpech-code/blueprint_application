import 'package:blueprint_application/core/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUtils date helpers', () {
    test('formatDate should use yyyy-MM-dd pattern', () {
      final date = DateTime(2024, 5, 4);
      expect(AppUtils.formatDate(date), '2024-05-04');
    });

    test('parseDate should return null for invalid input', () {
      expect(AppUtils.parseDate('not-a-date'), isNull);
    });

    test('parseDateTime should roundtrip formatted value', () {
      final original = DateTime(2024, 5, 4, 13, 45, 30);
      final formatted = AppUtils.formatDateTime(original);
      final parsed = AppUtils.parseDateTime(formatted);

      expect(parsed, isNotNull);
      expect(parsed, equals(DateTime(2024, 5, 4, 13, 45, 30)));
    });
  });

  group('AppUtils string helpers', () {
    test('truncateText should append ellipsis when exceeding max length', () {
      const source = 'A very long sentence that needs truncation';
      expect(AppUtils.truncateText(source, 10), 'A very long...');
    });

    test('capitalizeFirst should return original text for empty input', () {
      expect(AppUtils.capitalizeFirst(''), isEmpty);
    });

    test('capitalizeFirst should only affect the first character', () {
      expect(AppUtils.capitalizeFirst('hELLO'), 'Hello');
    });
  });

  group('AppUtils url helpers', () {
    test('isValidUrl should validate http and https schemes', () {
      expect(AppUtils.isValidUrl('https://example.com'), isTrue);
      expect(AppUtils.isValidUrl('http://example.com'), isTrue);
      expect(AppUtils.isValidUrl('ftp://example.com'), isFalse);
    });

    test('extractDomain should return host from url', () {
      expect(AppUtils.extractDomain('https://sub.example.com/path'), 'sub.example.com');
      expect(AppUtils.extractDomain(null), isNull);
    });
  });
}
