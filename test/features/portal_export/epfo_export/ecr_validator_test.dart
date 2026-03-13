import 'package:ca_app/features/portal_export/epfo_export/models/ecr_member_row.dart';
import 'package:ca_app/features/portal_export/epfo_export/services/ecr_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EcrValidator', () {
    // ---------------------------------------------------------------------------
    // validateUan
    // ---------------------------------------------------------------------------

    group('validateUan', () {
      test('accepts valid 12-digit UAN', () {
        expect(EcrValidator.instance.validateUan('100123456789'), isTrue);
      });

      test('rejects UAN shorter than 12 digits', () {
        expect(EcrValidator.instance.validateUan('10012345678'), isFalse);
      });

      test('rejects UAN longer than 12 digits', () {
        expect(EcrValidator.instance.validateUan('1001234567890'), isFalse);
      });

      test('rejects empty string', () {
        expect(EcrValidator.instance.validateUan(''), isFalse);
      });

      test('rejects UAN with alphabetic characters', () {
        expect(EcrValidator.instance.validateUan('10012345678A'), isFalse);
      });

      test('rejects UAN with spaces', () {
        expect(EcrValidator.instance.validateUan('100 234567890'), isFalse);
      });

      test('accepts all-zero UAN (edge case)', () {
        expect(EcrValidator.instance.validateUan('000000000000'), isTrue);
      });
    });

    // ---------------------------------------------------------------------------
    // validateEstablishmentId
    // ---------------------------------------------------------------------------

    group('validateEstablishmentId', () {
      test('accepts valid 7-digit numeric establishment ID', () {
        expect(
          EcrValidator.instance.validateEstablishmentId('7001234'),
          isTrue,
        );
      });

      test('rejects ID shorter than 7 digits', () {
        expect(
          EcrValidator.instance.validateEstablishmentId('123456'),
          isFalse,
        );
      });

      test('rejects ID longer than 7 digits', () {
        expect(
          EcrValidator.instance.validateEstablishmentId('12345678'),
          isFalse,
        );
      });

      test('rejects ID with alpha characters', () {
        expect(
          EcrValidator.instance.validateEstablishmentId('MHBAN12'),
          isFalse,
        );
      });

      test('rejects empty string', () {
        expect(EcrValidator.instance.validateEstablishmentId(''), isFalse);
      });

      test('accepts all-zero ID', () {
        expect(
          EcrValidator.instance.validateEstablishmentId('0000000'),
          isTrue,
        );
      });
    });

    // ---------------------------------------------------------------------------
    // validateMemberRow
    // ---------------------------------------------------------------------------

    group('validateMemberRow', () {
      const validRow = EcrMemberRow(
        uan: '100123456789',
        memberName: 'John Doe',
        grossWagesPaise: 1500000,
        epfWagesPaise: 1500000,
        epsWagesPaise: 1500000,
        edliWagesPaise: 1500000,
        employeeEpfPaise: 180000,
        employerEpsPaise: 125000,
        employerEpfPaise: 55000,
        ncp: 0,
        refundsPaise: 0,
      );

      test('returns empty list for valid row', () {
        final errors = EcrValidator.instance.validateMemberRow(validRow);
        expect(errors, isEmpty);
      });

      test('returns error for invalid UAN', () {
        final row = validRow.copyWith(uan: 'SHORT');
        final errors = EcrValidator.instance.validateMemberRow(row);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('uan')), isTrue);
      });

      test('returns error when EPF wages exceed gross wages', () {
        final row = validRow.copyWith(
          grossWagesPaise: 1000000, // ₹10,000
          epfWagesPaise: 1500000, // ₹15,000 — exceeds gross
        );
        final errors = EcrValidator.instance.validateMemberRow(row);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('epf wage')), isTrue);
      });

      test('returns error when EPS wages exceed EPF wages', () {
        final row = validRow.copyWith(
          epfWagesPaise: 1200000, // ₹12,000
          epsWagesPaise: 1500000, // ₹15,000 — exceeds EPF
        );
        final errors = EcrValidator.instance.validateMemberRow(row);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('eps wage')), isTrue);
      });

      test('returns error when EPS wages exceed ₹15,000 ceiling', () {
        final row = validRow.copyWith(
          epfWagesPaise: 1600000, // ₹16,000
          epsWagesPaise: 1600000, // ₹16,000 — above cap
        );
        final errors = EcrValidator.instance.validateMemberRow(row);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('eps')), isTrue);
      });

      test(
        'returns error when employee EPF not approximately 12% of EPF wages',
        () {
          // EPF wages = 1500000 paise = ₹15,000. 12% = ₹1,800 = 180000 paise.
          // Set to 100000 paise = ₹1,000 (way off).
          final row = validRow.copyWith(employeeEpfPaise: 100000);
          final errors = EcrValidator.instance.validateMemberRow(row);
          expect(errors, isNotEmpty);
          expect(
            errors.any((e) => e.toLowerCase().contains('employee epf')),
            isTrue,
          );
        },
      );

      test('returns error when gross wages are negative', () {
        final row = validRow.copyWith(grossWagesPaise: -1);
        final errors = EcrValidator.instance.validateMemberRow(row);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('gross')), isTrue);
      });

      test('returns error when ncp days are negative', () {
        final row = validRow.copyWith(ncp: -1);
        final errors = EcrValidator.instance.validateMemberRow(row);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('ncp')), isTrue);
      });

      test('returns error when ncp days exceed 31', () {
        final row = validRow.copyWith(ncp: 32);
        final errors = EcrValidator.instance.validateMemberRow(row);
        expect(errors, isNotEmpty);
      });

      test('accepts row with ncp = 31', () {
        final row = validRow.copyWith(ncp: 31);
        // ncp=31 is edge valid; but employee EPF may be off given unchanged values
        // focus: no ncp error
        final errors = EcrValidator.instance.validateMemberRow(row);
        expect(errors.any((e) => e.toLowerCase().contains('ncp')), isFalse);
      });

      test('returns error when member name is empty', () {
        final row = validRow.copyWith(memberName: '');
        final errors = EcrValidator.instance.validateMemberRow(row);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('name')), isTrue);
      });
    });

    // ---------------------------------------------------------------------------
    // validateEcrContent
    // ---------------------------------------------------------------------------

    group('validateEcrContent', () {
      const validContent =
          '#~#EPFO#~#ECR#~#V2.0#~#7001234#~#03 2024#~#2#~#\n'
          '100123456789#~#John Doe#~#15000#~#15000#~#15000#~#15000#~#1800#~#1250#~#550#~#0#~#0#~#\n'
          '100987654321#~#Jane Smith#~#20000#~#15000#~#15000#~#15000#~#1800#~#1250#~#550#~#2#~#0#~#\n';

      test('returns empty errors for valid ECR content', () {
        final errors = EcrValidator.instance.validateEcrContent(validContent);
        expect(errors, isEmpty);
      });

      test('returns error when header is missing', () {
        const noHeader =
            '100123456789#~#John Doe#~#15000#~#15000#~#15000#~#15000#~#1800#~#1250#~#550#~#0#~#0#~#\n';
        final errors = EcrValidator.instance.validateEcrContent(noHeader);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('header')), isTrue);
      });

      test('returns error for empty content', () {
        final errors = EcrValidator.instance.validateEcrContent('');
        expect(errors, isNotEmpty);
      });

      test('returns error when data row has wrong number of separators', () {
        // Row with only 9 #~# instead of 11
        const badRow =
            '#~#EPFO#~#ECR#~#V2.0#~#7001234#~#03 2024#~#1#~#\n'
            '100123456789#~#John Doe#~#15000#~#15000#~#15000#~#15000#~#1800#~#1250#~#0#~#\n';
        final errors = EcrValidator.instance.validateEcrContent(badRow);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('field')), isTrue);
      });

      test('returns error when data row has invalid UAN', () {
        const badUanContent =
            '#~#EPFO#~#ECR#~#V2.0#~#7001234#~#03 2024#~#1#~#\n'
            'BADUAN#~#John Doe#~#15000#~#15000#~#15000#~#15000#~#1800#~#1250#~#550#~#0#~#0#~#\n';
        final errors = EcrValidator.instance.validateEcrContent(badUanContent);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('uan')), isTrue);
      });

      test('returns error when wages are negative in content', () {
        const negativeWageContent =
            '#~#EPFO#~#ECR#~#V2.0#~#7001234#~#03 2024#~#1#~#\n'
            '100123456789#~#John Doe#~#-100#~#15000#~#15000#~#15000#~#1800#~#1250#~#550#~#0#~#0#~#\n';
        final errors = EcrValidator.instance.validateEcrContent(
          negativeWageContent,
        );
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.toLowerCase().contains('negative')), isTrue);
      });
    });
  });
}
