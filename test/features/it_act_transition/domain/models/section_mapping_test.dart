import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/it_act_transition/domain/models/section_mapping.dart';

void main() {
  group('SectionMapping', () {
    test('creates immutable mapping', () {
      final mapping = SectionMapping(
        section1961: '80C',
        section2025: '123',
        description: 'Deduction for life insurance, provident fund, etc.',
        category: SectionCategory.deductions,
      );
      expect(mapping.section1961, '80C');
      expect(mapping.section2025, '123');
      expect(
        mapping.description,
        'Deduction for life insurance, provident fund, etc.',
      );
      expect(mapping.category, SectionCategory.deductions);
    });

    test('equality by section1961 and section2025', () {
      final a = SectionMapping(
        section1961: '80C',
        section2025: '123',
        description: 'Deductions',
        category: SectionCategory.deductions,
      );
      final b = SectionMapping(
        section1961: '80C',
        section2025: '123',
        description: 'Deductions',
        category: SectionCategory.deductions,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality for different sections', () {
      final a = SectionMapping(
        section1961: '80C',
        section2025: '123',
        description: 'Deductions',
        category: SectionCategory.deductions,
      );
      final b = SectionMapping(
        section1961: '80D',
        section2025: '126',
        description: 'Health',
        category: SectionCategory.deductions,
      );
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates new instance', () {
      final mapping = SectionMapping(
        section1961: '80C',
        section2025: '123',
        description: 'Old desc',
        category: SectionCategory.deductions,
      );
      final copy = mapping.copyWith(description: 'New desc');
      expect(copy.description, 'New desc');
      expect(copy.section1961, '80C');
      expect(mapping.description, 'Old desc'); // original unchanged
    });

    test('copyWith with no args returns equivalent', () {
      final mapping = SectionMapping(
        section1961: '143',
        section2025: '270',
        description: 'Assessment',
        category: SectionCategory.assessment,
      );
      final copy = mapping.copyWith();
      expect(copy, equals(mapping));
    });

    test('notes field is optional', () {
      final mapping = SectionMapping(
        section1961: '194S',
        section2025: '393(Table)',
        description: 'TDS on VDA',
        category: SectionCategory.tds,
        notes: 'Consolidated into Table 1 of Section 393',
      );
      expect(mapping.notes, 'Consolidated into Table 1 of Section 393');
    });

    test('notes defaults to null', () {
      final mapping = SectionMapping(
        section1961: '80C',
        section2025: '123',
        description: 'Deductions',
        category: SectionCategory.deductions,
      );
      expect(mapping.notes, isNull);
    });
  });

  group('SectionCategory', () {
    test('has all expected values', () {
      expect(
        SectionCategory.values,
        containsAll([
          SectionCategory.taxComputation,
          SectionCategory.deductions,
          SectionCategory.tds,
          SectionCategory.tcs,
          SectionCategory.assessment,
          SectionCategory.interest,
          SectionCategory.penalty,
          SectionCategory.capitalGains,
          SectionCategory.exemptIncome,
          SectionCategory.trust,
          SectionCategory.residentialStatus,
          SectionCategory.dtaa,
          SectionCategory.transferPricing,
          SectionCategory.vda,
          SectionCategory.general,
        ]),
      );
    });

    test('each category has a label', () {
      for (final cat in SectionCategory.values) {
        expect(cat.label.isNotEmpty, isTrue);
      }
    });
  });

  group('SectionMapping.displaySection', () {
    test('returns 1961 section for act1961 mode', () {
      final mapping = SectionMapping(
        section1961: '80C',
        section2025: '123',
        description: 'Deductions',
        category: SectionCategory.deductions,
      );
      expect(mapping.displaySection1961, 'Section 80C');
      expect(mapping.displaySection2025, 'Section 123');
    });

    test('dualDisplay shows both', () {
      final mapping = SectionMapping(
        section1961: '143(1)',
        section2025: '270(1)',
        description: 'Assessment',
        category: SectionCategory.assessment,
      );
      expect(mapping.dualDisplay, 'Section 270(1) [erstwhile Section 143(1)]');
    });
  });
}
