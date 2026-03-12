import 'package:ca_app/features/tds/domain/models/tds_section_rate.dart';
import 'package:ca_app/features/tds/domain/services/tds_rate_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TdsRateEngine', () {
    group('getAllSections', () {
      test('returns 31 entries for FY 2025-26', () {
        final sections = TdsRateEngine.getAllSections();
        expect(sections.length, 31);
      });

      test('all entries have financialYear 2025-26', () {
        final sections = TdsRateEngine.getAllSections();
        for (final s in sections) {
          expect(s.financialYear, '2025-26');
        }
      });
    });

    group('getRate', () {
      test('194C individual → 1%', () {
        final rate = TdsRateEngine.getRate(
          section: '194C',
          deducteeType: DeducteeType.individual,
          hasPan: true,
        );
        expect(rate, 1.0);
      });

      test('194C HUF → 1% (same as individual)', () {
        final rate = TdsRateEngine.getRate(
          section: '194C',
          deducteeType: DeducteeType.huf,
          hasPan: true,
        );
        expect(rate, 1.0);
      });

      test('194C company → 2%', () {
        final rate = TdsRateEngine.getRate(
          section: '194C',
          deducteeType: DeducteeType.company,
          hasPan: true,
        );
        expect(rate, 2.0);
      });

      test('194C firm → 2% (others rate)', () {
        final rate = TdsRateEngine.getRate(
          section: '194C',
          deducteeType: DeducteeType.firm,
          hasPan: true,
        );
        expect(rate, 2.0);
      });

      test('with no PAN → 20%', () {
        final rate = TdsRateEngine.getRate(
          section: '194C',
          deducteeType: DeducteeType.individual,
          hasPan: false,
        );
        expect(rate, 20.0);
      });

      test('194J(b) individual → 10%', () {
        final rate = TdsRateEngine.getRate(
          section: '194J(b)',
          deducteeType: DeducteeType.individual,
          hasPan: true,
        );
        expect(rate, 10.0);
      });

      test('unknown section returns 0', () {
        final rate = TdsRateEngine.getRate(
          section: '999Z',
          deducteeType: DeducteeType.individual,
          hasPan: true,
        );
        expect(rate, 0.0);
      });
    });

    group('getSection', () {
      test('exact match → returns section', () {
        final section = TdsRateEngine.getSection('194C');
        expect(section, isNotNull);
        expect(section!.section, '194C');
        expect(section.description, 'Contractor payments');
      });

      test('unknown section → returns null', () {
        final section = TdsRateEngine.getSection('999Z');
        expect(section, isNull);
      });
    });

    group('searchSections', () {
      test('by description → finds matching sections', () {
        final results = TdsRateEngine.searchSections('rent');
        expect(results.length, greaterThanOrEqualTo(2));
        for (final r in results) {
          expect(
            r.section.toLowerCase().contains('194i') ||
                r.description.toLowerCase().contains('rent'),
            isTrue,
          );
        }
      });

      test('by section code → finds matching sections', () {
        final results = TdsRateEngine.searchSections('194J');
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('no match → empty list', () {
        final results = TdsRateEngine.searchSections('xyznonexistent');
        expect(results, isEmpty);
      });

      test('case insensitive search', () {
        final upper = TdsRateEngine.searchSections('SALARY');
        final lower = TdsRateEngine.searchSections('salary');
        expect(upper.length, lower.length);
      });
    });

    group('isThresholdExceeded', () {
      test('below single threshold → false', () {
        final result = TdsRateEngine.isThresholdExceeded(
          section: '194C',
          amount: 25000,
        );
        expect(result, false);
      });

      test('above single threshold → true', () {
        final result = TdsRateEngine.isThresholdExceeded(
          section: '194C',
          amount: 35000,
        );
        expect(result, true);
      });

      test('below aggregate threshold → false', () {
        final result = TdsRateEngine.isThresholdExceeded(
          section: '194C',
          amount: 90000,
          isAggregate: true,
        );
        expect(result, false);
      });

      test('above aggregate threshold → true', () {
        final result = TdsRateEngine.isThresholdExceeded(
          section: '194C',
          amount: 150000,
          isAggregate: true,
        );
        expect(result, true);
      });

      test('section with zero threshold → always exceeded', () {
        final result = TdsRateEngine.isThresholdExceeded(
          section: '195',
          amount: 1,
        );
        expect(result, true);
      });

      test('unknown section → false', () {
        final result = TdsRateEngine.isThresholdExceeded(
          section: '999Z',
          amount: 1000000,
        );
        expect(result, false);
      });
    });

    group('computeTds', () {
      test('basic computation → amount * rate / 100', () {
        final result = TdsRateEngine.computeTds(
          section: '194C',
          amount: 100000,
          deducteeType: DeducteeType.individual,
          hasPan: true,
        );
        expect(result.section, '194C');
        expect(result.grossAmount, 100000);
        expect(result.tdsRate, 1.0);
        expect(result.tdsAmount, 1000);
        expect(result.surcharge, 0);
        expect(result.educationCess, 0);
        expect(result.totalTds, 1000);
        expect(result.thresholdApplied, false);
      });

      test('below threshold → zero TDS with thresholdApplied true', () {
        final result = TdsRateEngine.computeTds(
          section: '194C',
          amount: 25000,
          deducteeType: DeducteeType.individual,
          hasPan: true,
        );
        expect(result.tdsAmount, 0);
        expect(result.totalTds, 0);
        expect(result.thresholdApplied, true);
      });

      test('NRI payment (195) → includes 4% cess', () {
        final result = TdsRateEngine.computeTds(
          section: '195',
          amount: 100000,
          deducteeType: DeducteeType.individual,
          hasPan: true,
        );
        expect(result.tdsRate, 20.0);
        expect(result.tdsAmount, 20000);
        expect(result.educationCess, 800); // 4% of 20000
        expect(result.totalTds, 20800); // 20000 + 800
      });

      test('no PAN → uses noPan rate', () {
        final result = TdsRateEngine.computeTds(
          section: '194H',
          amount: 50000,
          deducteeType: DeducteeType.individual,
          hasPan: false,
        );
        expect(result.tdsRate, 20.0);
        expect(result.tdsAmount, 10000);
      });

      test('unknown section → zero TDS', () {
        final result = TdsRateEngine.computeTds(
          section: '999Z',
          amount: 100000,
          deducteeType: DeducteeType.individual,
          hasPan: true,
        );
        expect(result.tdsAmount, 0);
        expect(result.totalTds, 0);
      });
    });
  });
}
