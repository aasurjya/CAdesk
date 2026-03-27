import 'package:ca_app/features/portal_parser/domain/models/ais_data.dart';
import 'package:ca_app/features/portal_parser/domain/services/ais_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Sample JSON payloads
// ---------------------------------------------------------------------------

const _validPayload = <String, Object?>{
  'AIS': {
    'PAN': 'ABCDE1234F',
    'FinancialYear': '2024-25',
    'Salary': [
      {
        'SourceName': 'Acme Ltd',
        'SourcePAN': 'AABCE1234D',
        'AmountReported': 600000,
        'AmountDerived': 600000,
        'Feedback': 'A',
        'TransactionId': 'TXN001',
      },
    ],
    'Interest': [
      {
        'SourceName': 'HDFC Bank',
        'SourcePAN': 'HDFC01234X',
        'AmountReported': 25000,
        'AmountDerived': 25000,
        'Feedback': 'A',
        'TransactionId': 'TXN002',
      },
    ],
    'Dividend': [
      {
        'SourceName': 'Infosys Ltd',
        'SourcePAN': 'INFY01234X',
        'AmountReported': 15000,
        'AmountDerived': 14500,
        'Feedback': 'PA',
        'TransactionId': 'TXN003',
      },
    ],
    'Securities': [],
    'Property': [],
    'ForeignRemittance': [],
    'Other': [],
  },
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AisParserService', () {
    const service = AisParserService.instance;

    // ── instance ─────────────────────────────────────────────────────────────

    test('instance is a singleton', () {
      expect(
        identical(AisParserService.instance, AisParserService.instance),
        isTrue,
      );
    });

    // ── validate ─────────────────────────────────────────────────────────────

    group('validate', () {
      test('returns empty errors for valid payload', () {
        final errors = service.validate(_validPayload);
        expect(errors, isEmpty);
      });

      test('returns error for empty payload', () {
        final errors = service.validate({});
        expect(errors, isNotEmpty);
      });

      test('returns error for missing PAN', () {
        final payload = <String, Object?>{
          'AIS': {'FinancialYear': '2024-25'},
        };
        final errors = service.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('PAN')), isTrue);
      });

      test('returns error for PAN with wrong length (9 chars)', () {
        final payload = <String, Object?>{
          'AIS': {'PAN': 'ABCDE1234', 'FinancialYear': '2024-25'},
        };
        final errors = service.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('PAN')), isTrue);
      });

      test('returns error for missing FinancialYear', () {
        final payload = <String, Object?>{
          'AIS': {'PAN': 'ABCDE1234F'},
        };
        final errors = service.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('FinancialYear')), isTrue);
      });

      test('returns error for FinancialYear with wrong format', () {
        final payload = <String, Object?>{
          'AIS': {'PAN': 'ABCDE1234F', 'FinancialYear': '2024'},
        };
        final errors = service.validate(payload);
        expect(errors, isNotEmpty);
      });

      test('returns error when Salary field is not a list', () {
        final payload = <String, Object?>{
          'AIS': {
            'PAN': 'ABCDE1234F',
            'FinancialYear': '2024-25',
            'Salary': 'not-a-list',
          },
        };
        final errors = service.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('"Salary"')), isTrue);
      });

      test('accepts payload without AIS wrapper (flat structure)', () {
        final flat = <String, Object?>{
          'PAN': 'ABCDE1234F',
          'FinancialYear': '2024-25',
        };
        final errors = service.validate(flat);
        expect(errors, isEmpty);
      });
    });

    // ── parse — top-level fields ──────────────────────────────────────────────

    group('parse — top-level fields', () {
      test('parses PAN correctly', () {
        final result = service.parse(_validPayload);
        expect(result.pan, 'ABCDE1234F');
      });

      test('parses FinancialYear correctly', () {
        final result = service.parse(_validPayload);
        expect(result.financialYear, '2024-25');
      });
    });

    // ── parse — salary entries ────────────────────────────────────────────────

    group('parse — salary entries', () {
      late AisParserData result;

      setUp(() {
        result = service.parse(_validPayload);
      });

      test('parses one salary entry', () {
        expect(result.salaryEntries, hasLength(1));
      });

      test('salary entry has correct sourceName', () {
        expect(result.salaryEntries.first.sourceName, 'Acme Ltd');
      });

      test('salary entry converts amountReported to paise', () {
        // 600000 × 100 = 60000000 paise
        expect(result.salaryEntries.first.amountReportedPaise, 60000000);
      });

      test('salary entry converts amountDerived to paise', () {
        expect(result.salaryEntries.first.amountDerivedPaise, 60000000);
      });

      test('salary entry feedback is accepted', () {
        expect(result.salaryEntries.first.feedback, AisEntryFeedback.accepted);
      });

      test('salary entry category is salary', () {
        expect(result.salaryEntries.first.category, AisIncomeCategory.salary);
      });

      test('salary entry has transactionId', () {
        expect(result.salaryEntries.first.transactionId, 'TXN001');
      });
    });

    // ── parse — interest entries ──────────────────────────────────────────────

    group('parse — interest entries', () {
      test('parses one interest entry', () {
        final result = service.parse(_validPayload);
        expect(result.interestEntries, hasLength(1));
      });

      test('interest entry has correct sourceName', () {
        final result = service.parse(_validPayload);
        expect(result.interestEntries.first.sourceName, 'HDFC Bank');
      });

      test('interest entry converts amount to paise', () {
        final result = service.parse(_validPayload);
        // 25000 × 100 = 2500000
        expect(result.interestEntries.first.amountReportedPaise, 2500000);
      });
    });

    // ── parse — dividend entries ──────────────────────────────────────────────

    group('parse — dividend entries', () {
      test('parses one dividend entry with partial acceptance', () {
        final result = service.parse(_validPayload);
        expect(result.dividendEntries, hasLength(1));
        expect(
          result.dividendEntries.first.feedback,
          AisEntryFeedback.partiallyAccepted,
        );
      });
    });

    // ── parse — aggregate totals ──────────────────────────────────────────────

    group('parse — aggregate totals', () {
      late AisParserData result;

      setUp(() {
        result = service.parse(_validPayload);
      });

      test('allEntries contains salary + interest + dividend', () {
        // 1 salary + 1 interest + 1 dividend = 3
        expect(result.allEntries.length, 3);
      });

      test('totalReportedPaise sums all categories', () {
        // salary: 60000000, interest: 2500000, dividend: 1500000
        expect(result.totalReportedPaise, 60000000 + 2500000 + 1500000);
      });
    });

    // ── parse — empty arrays ──────────────────────────────────────────────────

    group('parse — empty category arrays', () {
      test('empty Securities array produces no securitiesEntries', () {
        final result = service.parse(_validPayload);
        expect(result.securitiesEntries, isEmpty);
      });

      test('empty Property array produces no propertyEntries', () {
        final result = service.parse(_validPayload);
        expect(result.propertyEntries, isEmpty);
      });
    });

    // ── parse — empty payload ─────────────────────────────────────────────────

    group('parse — empty payload', () {
      test('returns empty entry lists', () {
        final result = service.parse({});
        expect(result.allEntries, isEmpty);
        expect(result.salaryEntries, isEmpty);
        expect(result.interestEntries, isEmpty);
        expect(result.dividendEntries, isEmpty);
      });

      test('returns zero totals', () {
        final result = service.parse({});
        expect(result.totalReportedPaise, 0);
        expect(result.totalDerivedPaise, 0);
      });
    });

    // ── findMismatches ────────────────────────────────────────────────────────

    group('findMismatches', () {
      test('returns entries where reported != derived', () {
        final result = service.parse(_validPayload);
        final mismatches = service.findMismatches(result);
        // dividend entry: 15000 reported vs 14500 derived — mismatch
        expect(mismatches.length, greaterThanOrEqualTo(1));
        expect(mismatches.any((e) => e.transactionId == 'TXN003'), isTrue);
      });

      test('returns no mismatches when all amounts match', () {
        final payload = <String, Object?>{
          'AIS': {
            'PAN': 'ABCDE1234F',
            'FinancialYear': '2024-25',
            'Salary': [
              {
                'SourceName': 'Corp',
                'SourcePAN': 'CORP01234X',
                'AmountReported': 100000,
                'AmountDerived': 100000,
                'Feedback': 'A',
                'TransactionId': 'TXNX',
              },
            ],
          },
        };
        final result = service.parse(payload);
        expect(service.findMismatches(result), isEmpty);
      });
    });

    // ── AisIncomeCategory mapping ─────────────────────────────────────────────

    group('AisIncomeCategory.fromString', () {
      test('maps "salary" to salary', () {
        expect(
          AisIncomeCategory.fromString('salary'),
          AisIncomeCategory.salary,
        );
      });

      test('maps "interest savings" to interestSavings', () {
        expect(
          AisIncomeCategory.fromString('interest savings'),
          AisIncomeCategory.interestSavings,
        );
      });

      test('maps "fixed deposit" to interestFd', () {
        expect(
          AisIncomeCategory.fromString('fixed deposit'),
          AisIncomeCategory.interestFd,
        );
      });

      test('maps "dividend" to dividend', () {
        expect(
          AisIncomeCategory.fromString('dividend'),
          AisIncomeCategory.dividend,
        );
      });

      test('maps unknown string to other', () {
        expect(
          AisIncomeCategory.fromString('xyz_unknown'),
          AisIncomeCategory.other,
        );
      });
    });

    // ── AisEntryFeedback mapping ──────────────────────────────────────────────

    group('AisEntryFeedback.fromCode', () {
      test('"A" maps to accepted', () {
        expect(AisEntryFeedback.fromCode('A'), AisEntryFeedback.accepted);
      });

      test('"PA" maps to partiallyAccepted', () {
        expect(
          AisEntryFeedback.fromCode('PA'),
          AisEntryFeedback.partiallyAccepted,
        );
      });

      test('"NA" maps to notAccepted', () {
        expect(AisEntryFeedback.fromCode('NA'), AisEntryFeedback.notAccepted);
      });

      test('unknown code maps to noFeedback', () {
        expect(AisEntryFeedback.fromCode('XY'), AisEntryFeedback.noFeedback);
      });
    });

    // ── interest sub-keys fallback ────────────────────────────────────────────

    group('parse — InterestSavings/InterestFD fallback', () {
      test('falls back to sub-keys when "Interest" key absent', () {
        final payload = <String, Object?>{
          'AIS': {
            'PAN': 'ABCDE1234F',
            'FinancialYear': '2024-25',
            'InterestSavings': [
              {
                'SourceName': 'SBI',
                'SourcePAN': 'SBI001234X',
                'AmountReported': 5000,
                'AmountDerived': 5000,
                'Feedback': 'A',
                'TransactionId': 'TXNSAV',
              },
            ],
            'InterestFD': [
              {
                'SourceName': 'PNB',
                'SourcePAN': 'PNB001234X',
                'AmountReported': 8000,
                'AmountDerived': 8000,
                'Feedback': 'A',
                'TransactionId': 'TXNFD',
              },
            ],
          },
        };
        final result = service.parse(payload);
        // Two interest entries from the sub-keys
        expect(result.interestEntries.length, 2);
      });
    });
  });
}
