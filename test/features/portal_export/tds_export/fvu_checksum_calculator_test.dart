import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_export/tds_export/services/fvu_checksum_calculator.dart';

void main() {
  group('FvuChecksumCalculator', () {
    group('computeChecksum', () {
      test('returns a 5-digit zero-padded decimal string', () {
        final result = FvuChecksumCalculator.computeChecksum('hello');
        expect(result, hasLength(5));
        expect(int.tryParse(result), isNotNull);
      });

      test('returns 00000 for empty string', () {
        expect(FvuChecksumCalculator.computeChecksum(''), equals('00000'));
      });

      test('computes sum of ASCII codes mod 65536', () {
        // 'A' = 65, 'B' = 66, 'C' = 67 → sum = 198
        expect(FvuChecksumCalculator.computeChecksum('ABC'), equals('00198'));
      });

      test('zero-pads result to 5 digits', () {
        // '!' = 33 → sum = 33 → '00033'
        expect(FvuChecksumCalculator.computeChecksum('!'), equals('00033'));
      });

      test('wraps around mod 65536', () {
        // Build a string whose ASCII sum exceeds 65536
        // 'A' = 65, so 65536/65 ≈ 1008 'A's → sum = 65520, 1009 'A's → 65585 mod 65536 = 49
        final str = 'A' * 1009;
        final expected = (65 * 1009) % 65536;
        expect(
          FvuChecksumCalculator.computeChecksum(str),
          equals(expected.toString().padLeft(5, '0')),
        );
      });

      test('same input always yields same checksum', () {
        const input = 'BH|AAATA1234X|26Q|2024|Q1|';
        final c1 = FvuChecksumCalculator.computeChecksum(input);
        final c2 = FvuChecksumCalculator.computeChecksum(input);
        expect(c1, equals(c2));
      });
    });

    group('appendChecksum', () {
      test('appends checksum separated by pipe to last line', () {
        const content = 'BH|AAATA1234X\nBT|1|1|100';
        final result = FvuChecksumCalculator.appendChecksum(content);
        expect(result, contains('|'));
        // Last segment should be a 5-digit number
        final lastPart = result.split('|').last.trim();
        expect(int.tryParse(lastPart), isNotNull);
        expect(lastPart, hasLength(5));
      });

      test('appended checksum matches computed checksum of original', () {
        const content = 'BH|AAATA1234X\nBT|1|1|100';
        final result = FvuChecksumCalculator.appendChecksum(content);
        final appended = result.split('|').last.trim();
        final expected = FvuChecksumCalculator.computeChecksum(content);
        expect(appended, equals(expected));
      });

      test('works with single-line content', () {
        const content = 'BH|AAATA1234X';
        final result = FvuChecksumCalculator.appendChecksum(content);
        expect(result, startsWith('BH|AAATA1234X|'));
      });
    });

    group('verifyChecksum', () {
      test('returns true for content with valid appended checksum', () {
        const original = 'BH|AAATA1234X\nBT|1|1|100';
        final withChecksum = FvuChecksumCalculator.appendChecksum(original);
        expect(FvuChecksumCalculator.verifyChecksum(withChecksum), isTrue);
      });

      test('returns false for content with wrong checksum', () {
        const content = 'BH|AAATA1234X\nBT|1|1|100|99999';
        expect(FvuChecksumCalculator.verifyChecksum(content), isFalse);
      });

      test('returns false for content without checksum separator', () {
        const content = 'BH|AAATA1234X\nBT|1|1|100';
        // No checksum appended — last segment is not 5-digit decimal
        expect(FvuChecksumCalculator.verifyChecksum(content), isFalse);
      });

      test('round-trip: append then verify succeeds', () {
        const original = 'BH|AAATA1234X|26Q|2024|Q1\nCD|0012345|01042024\nBT|1|1|10000';
        final signed = FvuChecksumCalculator.appendChecksum(original);
        expect(FvuChecksumCalculator.verifyChecksum(signed), isTrue);
      });
    });
  });
}
