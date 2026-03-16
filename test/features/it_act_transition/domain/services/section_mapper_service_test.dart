import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/it_act_transition/domain/models/act_mode.dart';
import 'package:ca_app/features/it_act_transition/domain/models/section_mapping.dart';
import 'package:ca_app/features/it_act_transition/domain/services/section_mapper_service.dart';

void main() {
  group('SectionMapperService — Lookup', () {
    test('has at least 200 mappings', () {
      expect(
        SectionMapperService.allMappings.length,
        greaterThanOrEqualTo(200),
      );
    });

    test('all mappings have non-empty section1961', () {
      for (final m in SectionMapperService.allMappings) {
        expect(
          m.section1961.isNotEmpty,
          isTrue,
          reason: 'Empty section1961 found: $m',
        );
      }
    });

    test('all mappings have non-empty section2025', () {
      for (final m in SectionMapperService.allMappings) {
        expect(
          m.section2025.isNotEmpty,
          isTrue,
          reason: 'Empty section2025 found: $m',
        );
      }
    });

    test('no duplicate section1961 values', () {
      final seen = <String>{};
      for (final m in SectionMapperService.allMappings) {
        expect(
          seen.add(m.section1961),
          isTrue,
          reason: 'Duplicate section1961: ${m.section1961}',
        );
      }
    });
  });

  group('SectionMapperService — from1961', () {
    test('maps 80C → 123', () {
      final result = SectionMapperService.from1961('80C');
      expect(result, isNotNull);
      expect(result!.section2025, '123');
    });

    test('maps 80D → 126', () {
      final result = SectionMapperService.from1961('80D');
      expect(result, isNotNull);
      expect(result!.section2025, '126');
    });

    test('maps 80G → 133', () {
      final result = SectionMapperService.from1961('80G');
      expect(result, isNotNull);
      expect(result!.section2025, '133');
    });

    test('maps 80TTA → 136', () {
      final result = SectionMapperService.from1961('80TTA');
      expect(result, isNotNull);
      expect(result!.section2025, '136');
    });

    test('maps 80TTB → 137', () {
      final result = SectionMapperService.from1961('80TTB');
      expect(result, isNotNull);
      expect(result!.section2025, '137');
    });

    test('maps 115BAC → 202', () {
      final result = SectionMapperService.from1961('115BAC');
      expect(result, isNotNull);
      expect(result!.section2025, '202');
    });

    test('maps 87A → 156', () {
      final result = SectionMapperService.from1961('87A');
      expect(result, isNotNull);
      expect(result!.section2025, '156');
    });

    test('maps 143(1) → 270(1)', () {
      final result = SectionMapperService.from1961('143(1)');
      expect(result, isNotNull);
      expect(result!.section2025, '270(1)');
    });

    test('maps 143(3) → 270(3)', () {
      final result = SectionMapperService.from1961('143(3)');
      expect(result, isNotNull);
      expect(result!.section2025, '270(3)');
    });

    test('maps 147 → 279', () {
      final result = SectionMapperService.from1961('147');
      expect(result, isNotNull);
      expect(result!.section2025, '279');
    });

    test('maps 148 → 280', () {
      final result = SectionMapperService.from1961('148');
      expect(result, isNotNull);
      expect(result!.section2025, '280');
    });

    test('maps 154 → 287', () {
      final result = SectionMapperService.from1961('154');
      expect(result, isNotNull);
      expect(result!.section2025, '287');
    });

    test('maps 234A → 461', () {
      final result = SectionMapperService.from1961('234A');
      expect(result, isNotNull);
      expect(result!.section2025, '461');
    });

    test('maps 234B → 462', () {
      final result = SectionMapperService.from1961('234B');
      expect(result, isNotNull);
      expect(result!.section2025, '462');
    });

    test('maps 234C → 463', () {
      final result = SectionMapperService.from1961('234C');
      expect(result, isNotNull);
      expect(result!.section2025, '463');
    });

    test('maps 192 → 392(Table-1)', () {
      final result = SectionMapperService.from1961('192');
      expect(result, isNotNull);
      expect(result!.section2025, '392');
      expect(result.category, SectionCategory.tds);
    });

    test('maps 194C → 393(Table-I)', () {
      final result = SectionMapperService.from1961('194C');
      expect(result, isNotNull);
      expect(result!.category, SectionCategory.tds);
    });

    test('maps 194S → 393(1-25) (VDA category)', () {
      final result = SectionMapperService.from1961('194S');
      expect(result, isNotNull);
      expect(result!.category, SectionCategory.vda);
    });

    test('maps 115BBH → 199', () {
      final result = SectionMapperService.from1961('115BBH');
      expect(result, isNotNull);
      expect(result!.section2025, '199');
    });

    test('maps 45 → 67', () {
      final result = SectionMapperService.from1961('45');
      expect(result, isNotNull);
      expect(result!.section2025, '67');
      expect(result.category, SectionCategory.capitalGains);
    });

    test('maps 112A → 198', () {
      final result = SectionMapperService.from1961('112A');
      expect(result, isNotNull);
      expect(result!.section2025, '198');
    });

    test('returns null for unknown section', () {
      final result = SectionMapperService.from1961('999XYZ');
      expect(result, isNull);
    });
  });

  group('SectionMapperService — from2025', () {
    test('maps 123 → 80C', () {
      final result = SectionMapperService.from2025('123');
      expect(result, isNotNull);
      expect(result!.section1961, '80C');
    });

    test('maps 270(1) → 143(1)', () {
      final result = SectionMapperService.from2025('270(1)');
      expect(result, isNotNull);
      expect(result!.section1961, '143(1)');
    });

    test('maps 202 → 115BAC', () {
      final result = SectionMapperService.from2025('202');
      expect(result, isNotNull);
      expect(result!.section1961, '115BAC');
    });

    test('returns null for unknown section', () {
      final result = SectionMapperService.from2025('999XYZ');
      expect(result, isNull);
    });
  });

  group('SectionMapperService — displaySection', () {
    test('displays 1961 section for act1961 mode', () {
      final display = SectionMapperService.displaySection(
        section1961: '80C',
        mode: ActMode.act1961,
      );
      expect(display, 'Section 80C');
    });

    test('displays 2025 section for act2025 mode', () {
      final display = SectionMapperService.displaySection(
        section1961: '80C',
        mode: ActMode.act2025,
      );
      expect(display, 'Section 123');
    });

    test('falls back to 1961 section if mapping not found', () {
      final display = SectionMapperService.displaySection(
        section1961: 'UNKNOWN',
        mode: ActMode.act2025,
      );
      expect(display, 'Section UNKNOWN');
    });
  });

  group('SectionMapperService — dualDisplay', () {
    test('shows both sections', () {
      final display = SectionMapperService.dualDisplay('143(1)');
      expect(display, 'Section 270(1) [erstwhile Section 143(1)]');
    });

    test('falls back for unknown section', () {
      final display = SectionMapperService.dualDisplay('UNKNOWN');
      expect(display, 'Section UNKNOWN');
    });
  });

  group('SectionMapperService — searchByDescription', () {
    test('finds deduction sections by keyword', () {
      final results = SectionMapperService.searchByDescription(
        'life insurance',
      );
      expect(results, isNotEmpty);
      expect(
        results.any((m) => m.section1961 == '80C'),
        isTrue,
        reason: 'Should find 80C for "life insurance"',
      );
    });

    test('search is case-insensitive', () {
      final results = SectionMapperService.searchByDescription('ADVANCE TAX');
      expect(results, isNotEmpty);
    });

    test('returns empty for no match', () {
      final results = SectionMapperService.searchByDescription(
        'xyznonexistent',
      );
      expect(results, isEmpty);
    });
  });

  group('SectionMapperService — byCategory', () {
    test('returns deduction sections', () {
      final results = SectionMapperService.byCategory(
        SectionCategory.deductions,
      );
      expect(results, isNotEmpty);
      expect(
        results.every((m) => m.category == SectionCategory.deductions),
        isTrue,
      );
    });

    test('returns TDS sections', () {
      final results = SectionMapperService.byCategory(SectionCategory.tds);
      expect(results, isNotEmpty);
      expect(results.every((m) => m.category == SectionCategory.tds), isTrue);
    });

    test('returns capital gains sections', () {
      final results = SectionMapperService.byCategory(
        SectionCategory.capitalGains,
      );
      expect(results, isNotEmpty);
    });

    test('returns assessment sections', () {
      final results = SectionMapperService.byCategory(
        SectionCategory.assessment,
      );
      expect(results, isNotEmpty);
    });

    test('returns interest sections', () {
      final results = SectionMapperService.byCategory(SectionCategory.interest);
      expect(results, isNotEmpty);
    });
  });

  group('SectionMapperService — critical codebase sections covered', () {
    // These are the 40+ unique sections found in the codebase scan.
    // Every one must have a mapping.
    final criticalSections = [
      '80C',
      '80CCC',
      '80CCD(1)',
      '80CCD(1B)',
      '80CCD(2)',
      '80D',
      '80DD',
      '80DDB',
      '80E',
      '80EE',
      '80EEA',
      '80G',
      '80GG',
      '80GGA',
      '80GGC',
      '80TTA',
      '80TTB',
      '80U',
      '115BAC',
      '115BBH',
      '115BAA',
      '115JB',
      '87A',
      '192',
      '193',
      '194',
      '194A',
      '194B',
      '194BB',
      '194C',
      '194D',
      '194DA',
      '194E',
      '194EE',
      '194G',
      '194H',
      '194I(a)',
      '194I(b)',
      '194IA',
      '194IB',
      '194J(a)',
      '194J(b)',
      '194K',
      '194LA',
      '194LBC',
      '194M',
      '194N',
      '194O',
      '194Q',
      '194R',
      '194S',
      '194T',
      '195',
      '206C',
      '206AA',
      '143(1)',
      '143(3)',
      '142',
      '144',
      '147',
      '148',
      '153A',
      '154',
      '234A',
      '234B',
      '234C',
      '234D',
      '234E',
      '234F',
      '45',
      '48',
      '54',
      '111A',
      '112',
      '112A',
      '6',
      '90',
      '91',
      '92C',
      '139',
      '140A',
      '140B',
      '10',
      '11',
      '12',
      '12AB',
      '80IAC',
      '56(2)(viib)',
    ];

    for (final section in criticalSections) {
      test('mapping exists for section $section', () {
        final result = SectionMapperService.from1961(section);
        expect(
          result,
          isNotNull,
          reason: 'Missing mapping for critical section: $section',
        );
      });
    }
  });
}
