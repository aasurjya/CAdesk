import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_export/tds_export/services/fvu_field_encoder.dart';

void main() {
  group('FvuFieldEncoder', () {
    group('padLeft', () {
      test('pads value to width with spaces', () {
        expect(FvuFieldEncoder.padLeft('123', 6), equals('   123'));
      });

      test('pads value with custom character', () {
        expect(FvuFieldEncoder.padLeft('42', 5, pad: '0'), equals('00042'));
      });

      test('returns value unchanged when equal to width', () {
        expect(FvuFieldEncoder.padLeft('ABCDE', 5), equals('ABCDE'));
      });

      test('truncates value when longer than width', () {
        expect(FvuFieldEncoder.padLeft('ABCDEFGH', 5), equals('ABCDE'));
      });

      test('handles empty string', () {
        expect(FvuFieldEncoder.padLeft('', 3), equals('   '));
      });
    });

    group('padRight', () {
      test('pads value to width with spaces', () {
        expect(FvuFieldEncoder.padRight('ABC', 6), equals('ABC   '));
      });

      test('pads value with custom character', () {
        expect(FvuFieldEncoder.padRight('X', 4, pad: '-'), equals('X---'));
      });

      test('returns value unchanged when equal to width', () {
        expect(FvuFieldEncoder.padRight('HELLO', 5), equals('HELLO'));
      });

      test('truncates value when longer than width', () {
        expect(FvuFieldEncoder.padRight('TOOLONGSTRING', 5), equals('TOOLO'));
      });

      test('handles empty string', () {
        expect(FvuFieldEncoder.padRight('', 4), equals('    '));
      });
    });

    group('encodeAmount', () {
      test('encodes zero paise as 15 zeros', () {
        expect(FvuFieldEncoder.encodeAmount(0), equals('000000000000000'));
      });

      test('encodes 100 paise (1 rupee) correctly', () {
        expect(FvuFieldEncoder.encodeAmount(100), equals('000000000000100'));
      });

      test('encodes large amount correctly', () {
        // 10,00,000 rupees = 1,00,00,00,000 paise (but spec says paise as integer)
        // 1000000 paise = 10000 rupees
        expect(
          FvuFieldEncoder.encodeAmount(1000000),
          equals('000000001000000'),
        );
      });

      test('produces exactly 15 digits', () {
        expect(FvuFieldEncoder.encodeAmount(50000), hasLength(15));
      });

      test('encodes typical TDS amount', () {
        // 1500000 paise = 15000.00 rupees
        expect(
          FvuFieldEncoder.encodeAmount(1500000),
          equals('000000001500000'),
        );
      });
    });

    group('encodePan', () {
      test('converts pan to uppercase', () {
        expect(FvuFieldEncoder.encodePan('abcde1234f'), equals('ABCDE1234F'));
      });

      test('trims whitespace', () {
        expect(
          FvuFieldEncoder.encodePan('  ABCDE1234F  '),
          equals('ABCDE1234F'),
        );
      });

      test('returns PANNOTAVBL for empty string', () {
        expect(FvuFieldEncoder.encodePan(''), equals('PANNOTAVBL'));
      });

      test('returns PANNOTAVBL for null/blank pan', () {
        expect(FvuFieldEncoder.encodePan('   '), equals('PANNOTAVBL'));
      });

      test('preserves valid 10-char pan', () {
        expect(FvuFieldEncoder.encodePan('ABCDE1234F'), equals('ABCDE1234F'));
      });
    });

    group('encodeTan', () {
      test('converts tan to uppercase', () {
        expect(FvuFieldEncoder.encodeTan('aaata1234x'), equals('AAATA1234X'));
      });

      test('trims whitespace', () {
        expect(
          FvuFieldEncoder.encodeTan('  AAATA1234X  '),
          equals('AAATA1234X'),
        );
      });

      test('pads to 10 chars if shorter', () {
        expect(FvuFieldEncoder.encodeTan('AAATA'), hasLength(10));
      });

      test('produces exactly 10 chars for valid TAN', () {
        expect(FvuFieldEncoder.encodeTan('AAATA1234X'), hasLength(10));
      });

      test('truncates if longer than 10', () {
        expect(FvuFieldEncoder.encodeTan('AAATA1234XEXTRA'), hasLength(10));
      });
    });

    group('encodeDate', () {
      test('formats date as DDMMYYYY', () {
        final date = DateTime(2024, 4, 1);
        expect(FvuFieldEncoder.encodeDate(date), equals('01042024'));
      });

      test('pads day and month with leading zero', () {
        final date = DateTime(2024, 1, 5);
        expect(FvuFieldEncoder.encodeDate(date), equals('05012024'));
      });

      test('formats double-digit day and month', () {
        final date = DateTime(2024, 12, 31);
        expect(FvuFieldEncoder.encodeDate(date), equals('31122024'));
      });

      test('produces exactly 8 characters', () {
        final date = DateTime(2024, 6, 15);
        expect(FvuFieldEncoder.encodeDate(date), hasLength(8));
      });
    });

    group('encodeQuarter', () {
      test('encodes quarter 1 as Q1', () {
        expect(FvuFieldEncoder.encodeQuarter(1), equals('Q1'));
      });

      test('encodes quarter 2 as Q2', () {
        expect(FvuFieldEncoder.encodeQuarter(2), equals('Q2'));
      });

      test('encodes quarter 3 as Q3', () {
        expect(FvuFieldEncoder.encodeQuarter(3), equals('Q3'));
      });

      test('encodes quarter 4 as Q4', () {
        expect(FvuFieldEncoder.encodeQuarter(4), equals('Q4'));
      });

      test('throws for invalid quarter 0', () {
        expect(() => FvuFieldEncoder.encodeQuarter(0), throwsArgumentError);
      });

      test('throws for invalid quarter 5', () {
        expect(() => FvuFieldEncoder.encodeQuarter(5), throwsArgumentError);
      });
    });

    group('encodeRate', () {
      test('formats rate with 2 decimal places', () {
        expect(FvuFieldEncoder.encodeRate(10.0), equals('10.00'));
      });

      test('formats fractional rate correctly', () {
        expect(FvuFieldEncoder.encodeRate(7.5), equals('7.50'));
      });

      test('formats whole number rate', () {
        expect(FvuFieldEncoder.encodeRate(20.0), equals('20.00'));
      });

      test('formats rate with more decimal places truncated to 2', () {
        expect(FvuFieldEncoder.encodeRate(10.123), equals('10.12'));
      });

      test('formats zero rate', () {
        expect(FvuFieldEncoder.encodeRate(0.0), equals('0.00'));
      });
    });
  });
}
