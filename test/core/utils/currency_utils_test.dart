import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils', () {
    group('formatINR', () {
      test('formats 100 correctly', () {
        expect(CurrencyUtils.formatINR(100), '₹100.00');
      });

      test('formats 1,000 with Indian grouping', () {
        expect(CurrencyUtils.formatINR(1000), '₹1,000.00');
      });

      test('formats 10,000 with Indian grouping', () {
        expect(CurrencyUtils.formatINR(10000), '₹10,000.00');
      });

      test('formats 1 lakh (1,00,000) with Indian grouping', () {
        expect(CurrencyUtils.formatINR(100000), '₹1,00,000.00');
      });

      test('formats 1,23,456 with Indian grouping (not 123,456)', () {
        expect(CurrencyUtils.formatINR(123456), '₹1,23,456.00');
      });

      test('formats 10 lakh (10,00,000) with Indian grouping', () {
        expect(CurrencyUtils.formatINR(1000000), '₹10,00,000.00');
      });

      test('formats 1 crore (1,00,00,000) with Indian grouping', () {
        expect(CurrencyUtils.formatINR(10000000), '₹1,00,00,000.00');
      });

      test('formats 10 crore with Indian grouping', () {
        expect(CurrencyUtils.formatINR(100000000), '₹10,00,00,000.00');
      });

      test('formats 1,23,45,678 with Indian grouping', () {
        expect(CurrencyUtils.formatINR(12345678), '₹1,23,45,678.00');
      });

      test('formats amounts with paise', () {
        expect(CurrencyUtils.formatINR(1234.56), '₹1,234.56');
      });

      test('formats small amount without grouping', () {
        expect(CurrencyUtils.formatINR(50), '₹50.00');
      });

      test('formats 999 without grouping', () {
        expect(CurrencyUtils.formatINR(999), '₹999.00');
      });
    });

    group('formatINR edge cases', () {
      test('formats zero', () {
        expect(CurrencyUtils.formatINR(0), '₹0.00');
      });

      test('formats negative amount', () {
        final result = CurrencyUtils.formatINR(-5000);
        expect(result, '-₹5,000.00');
      });

      test('formats negative lakh amount', () {
        final result = CurrencyUtils.formatINR(-123456);
        expect(result, '-₹1,23,456.00');
      });

      test('formats very large amount (100 crore)', () {
        final result = CurrencyUtils.formatINR(1000000000);
        expect(result, '₹1,00,00,00,000.00');
      });

      test('formats single rupee', () {
        expect(CurrencyUtils.formatINR(1), '₹1.00');
      });
    });

    group('formatINRCompact', () {
      test('formats thousands as K', () {
        expect(CurrencyUtils.formatINRCompact(5000), '₹5K');
      });

      test('formats lakhs with L suffix', () {
        expect(CurrencyUtils.formatINRCompact(100000), '₹1L');
      });

      test('formats 1.23 lakhs with decimal', () {
        expect(CurrencyUtils.formatINRCompact(123000), '₹1.23L');
      });

      test('formats 5.5 lakhs', () {
        expect(CurrencyUtils.formatINRCompact(550000), '₹5.5L');
      });

      test('formats 1 crore', () {
        expect(CurrencyUtils.formatINRCompact(10000000), '₹1Cr');
      });

      test('formats 5.5 crore', () {
        expect(CurrencyUtils.formatINRCompact(55000000), '₹5.5Cr');
      });

      test('formats 12.34 crore', () {
        expect(CurrencyUtils.formatINRCompact(123400000), '₹12.34Cr');
      });

      test('formats small amount without suffix', () {
        expect(CurrencyUtils.formatINRCompact(500), '₹500');
      });

      test('formats zero', () {
        expect(CurrencyUtils.formatINRCompact(0), '₹0');
      });

      test('formats 10 thousand', () {
        expect(CurrencyUtils.formatINRCompact(10000), '₹10K');
      });

      test('formats 99 thousand', () {
        expect(CurrencyUtils.formatINRCompact(99000), '₹99K');
      });
    });

    group('parseINR', () {
      test('parses plain number string', () {
        expect(CurrencyUtils.parseINR('1000'), 1000.0);
      });

      test('parses string with rupee symbol', () {
        expect(CurrencyUtils.parseINR('₹1,000'), 1000.0);
      });

      test('parses Indian formatted string with lakhs', () {
        expect(CurrencyUtils.parseINR('₹1,23,456'), 123456.0);
      });

      test('parses string with crore formatting', () {
        expect(CurrencyUtils.parseINR('₹1,00,00,000'), 10000000.0);
      });

      test('parses string with decimal paise', () {
        expect(CurrencyUtils.parseINR('₹1,234.56'), 1234.56);
      });

      test('parses zero', () {
        expect(CurrencyUtils.parseINR('₹0'), 0.0);
      });

      test('parses negative amount', () {
        expect(CurrencyUtils.parseINR('-₹5,000'), -5000.0);
      });

      test('parses plain amount without symbol', () {
        expect(CurrencyUtils.parseINR('50000'), 50000.0);
      });

      test('round-trips with formatINR for whole numbers', () {
        const original = 1234567.0;
        final formatted = CurrencyUtils.formatINR(original);
        final parsed = CurrencyUtils.parseINR(formatted);
        expect(parsed, original);
      });

      test('round-trips with formatINR for lakh amount', () {
        const original = 500000.0;
        final formatted = CurrencyUtils.formatINR(original);
        final parsed = CurrencyUtils.parseINR(formatted);
        expect(parsed, original);
      });
    });
  });
}
