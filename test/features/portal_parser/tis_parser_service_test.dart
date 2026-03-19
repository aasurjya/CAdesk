import 'package:ca_app/features/portal_parser/domain/models/tis_data.dart';
import 'package:ca_app/features/portal_parser/domain/services/ais_parser_service.dart';
import 'package:ca_app/features/portal_parser/domain/services/tis_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Sample payloads
// ---------------------------------------------------------------------------

const _validTisPayload = <String, Object?>{
  'TIS': {
    'PAN': 'ABCDE1234F',
    'AssessmentYear': '2025-26',
    'Categories': [
      {
        'Category': 'Salary',
        'ReportedAmount': 700000,
        'ComputedAmount': 700000,
        'Feedback': 'A',
        'SourceCount': 1,
      },
      {
        'Category': 'Interest',
        'ReportedAmount': 30000,
        'ComputedAmount': 28000,
        'Feedback': 'NA',
        'SourceCount': 2,
      },
      {
        'Category': 'Dividend',
        'ReportedAmount': 20000,
        'ComputedAmount': 20000,
        'Feedback': 'NF',
        'SourceCount': 1,
      },
    ],
  },
};

const _validAisPayload = <String, Object?>{
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
        'SourceName': 'HDFC',
        'SourcePAN': 'HDFC01234X',
        'AmountReported': 25000,
        'AmountDerived': 25000,
        'Feedback': 'A',
        'TransactionId': 'TXN002',
      },
    ],
  },
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TisParserService', () {
    const tisService = TisParserService.instance;
    const aisService = AisParserService.instance;

    // ── instance ─────────────────────────────────────────────────────────────

    test('instance is a singleton', () {
      expect(
        identical(TisParserService.instance, TisParserService.instance),
        isTrue,
      );
    });

    // ── validate ─────────────────────────────────────────────────────────────

    group('validate', () {
      test('returns empty errors for valid payload', () {
        final errors = tisService.validate(_validTisPayload);
        expect(errors, isEmpty);
      });

      test('returns error for empty payload', () {
        final errors = tisService.validate({});
        expect(errors, isNotEmpty);
        expect(errors.first, contains('TIS'));
      });

      test('returns error for missing PAN', () {
        final payload = <String, Object?>{
          'TIS': {'AssessmentYear': '2025-26'},
        };
        final errors = tisService.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('PAN')), isTrue);
      });

      test('returns error for PAN with wrong length', () {
        final payload = <String, Object?>{
          'TIS': {'PAN': 'SHORT', 'AssessmentYear': '2025-26'},
        };
        final errors = tisService.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('PAN')), isTrue);
      });

      test('returns error for missing AssessmentYear', () {
        final payload = <String, Object?>{
          'TIS': {'PAN': 'ABCDE1234F'},
        };
        final errors = tisService.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('AssessmentYear')), isTrue);
      });

      test('returns error for AssessmentYear with wrong format', () {
        final payload = <String, Object?>{
          'TIS': {'PAN': 'ABCDE1234F', 'AssessmentYear': '2025'},
        };
        final errors = tisService.validate(payload);
        expect(errors, isNotEmpty);
      });

      test('returns error when Categories is not a list', () {
        final payload = <String, Object?>{
          'TIS': {
            'PAN': 'ABCDE1234F',
            'AssessmentYear': '2025-26',
            'Categories': 'not-a-list',
          },
        };
        final errors = tisService.validate(payload);
        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.contains('Categories')), isTrue);
      });

      test('accepts payload without TIS wrapper', () {
        final flat = <String, Object?>{
          'PAN': 'ABCDE1234F',
          'AssessmentYear': '2025-26',
        };
        final errors = tisService.validate(flat);
        expect(errors, isEmpty);
      });
    });

    // ── parse — top-level fields ──────────────────────────────────────────────

    group('parse — top-level fields', () {
      late TisParserData result;

      setUp(() {
        result = tisService.parse(_validTisPayload);
      });

      test('parses PAN correctly', () {
        expect(result.pan, 'ABCDE1234F');
      });

      test('parses AssessmentYear as financialYear', () {
        expect(result.financialYear, '2025-26');
      });
    });

    // ── parse — categories ────────────────────────────────────────────────────

    group('parse — categories', () {
      late TisParserData result;

      setUp(() {
        result = tisService.parse(_validTisPayload);
      });

      test('parses three categories', () {
        expect(result.derivedIncomes, hasLength(3));
      });

      test('first category is Salary with correct computed amount (paise)', () {
        final salary = result.derivedIncomes.firstWhere(
          (e) => e.category == TisIncomeCategory.salary,
        );
        // 700000 × 100 = 70000000
        expect(salary.computedAmountPaise, 70000000);
      });

      test('Interest category has non-zero differential', () {
        final interest = result.derivedIncomes.firstWhere(
          (e) => e.category == TisIncomeCategory.interest,
        );
        // reported 30000 - computed 28000 = 2000 rupees = 200000 paise
        expect(interest.differentialPaise, 200000);
      });

      test('Salary category sourceCount is 1', () {
        final salary = result.derivedIncomes.firstWhere(
          (e) => e.category == TisIncomeCategory.salary,
        );
        expect(salary.sourceCount, 1);
      });

      test('Interest feedback status is notAccepted', () {
        final interest = result.derivedIncomes.firstWhere(
          (e) => e.category == TisIncomeCategory.interest,
        );
        expect(interest.feedbackStatus, TisFeedbackStatus.notAccepted);
      });
    });

    // ── parse — aggregate computations ───────────────────────────────────────

    group('parse — aggregate computations', () {
      late TisParserData result;

      setUp(() {
        result = tisService.parse(_validTisPayload);
      });

      test('totalReportedPaise sums all categories', () {
        // (700000 + 30000 + 20000) × 100 = 75000000
        expect(result.totalReportedPaise, 75000000);
      });

      test('totalComputedPaise sums computed amounts', () {
        // (700000 + 28000 + 20000) × 100 = 74800000
        expect(result.totalComputedPaise, 74800000);
      });

      test('acceptedCategories returns only accepted entries', () {
        // Salary is accepted (A)
        expect(result.acceptedCategories.length, greaterThanOrEqualTo(1));
        expect(
          result.acceptedCategories.every(
            (e) => e.feedbackStatus == TisFeedbackStatus.accepted,
          ),
          isTrue,
        );
      });

      test('pendingFeedbackCategories returns no-feedback entries', () {
        // Dividend is NF
        expect(
          result.pendingFeedbackCategories.length,
          greaterThanOrEqualTo(1),
        );
        expect(
          result.pendingFeedbackCategories.every(
            (e) => e.feedbackStatus == TisFeedbackStatus.noFeedback,
          ),
          isTrue,
        );
      });

      test(
        'categoriesWithDifference returns entries with non-zero differential',
        () {
          // Only Interest has a difference
          expect(result.categoriesWithDifference.length, 1);
          expect(
            result.categoriesWithDifference.first.category,
            TisIncomeCategory.interest,
          );
        },
      );
    });

    // ── parse — empty payload ─────────────────────────────────────────────────

    group('parse — empty payload', () {
      test('returns empty derivedIncomes list', () {
        final result = tisService.parse({});
        expect(result.derivedIncomes, isEmpty);
      });

      test('returns zero totals', () {
        final result = tisService.parse({});
        expect(result.totalReportedPaise, 0);
        expect(result.totalComputedPaise, 0);
      });
    });

    // ── reconcileWithAis ──────────────────────────────────────────────────────

    group('reconcileWithAis', () {
      test('returns variances for categories with non-zero difference', () {
        final tis = tisService.parse(_validTisPayload);
        final ais = aisService.parse(_validAisPayload);

        final variances = tisService.reconcileWithAis(tis, ais);
        // TIS salary computed = 70000000, AIS salary reported = 60000000 → variance
        expect(variances, isNotEmpty);
      });

      test('variances are sorted by absolute value descending', () {
        final tis = tisService.parse(_validTisPayload);
        final ais = aisService.parse(_validAisPayload);

        final variances = tisService.reconcileWithAis(tis, ais);
        if (variances.length > 1) {
          for (var i = 0; i < variances.length - 1; i++) {
            expect(
              variances[i].variancePaise.abs(),
              greaterThanOrEqualTo(variances[i + 1].variancePaise.abs()),
            );
          }
        }
      });

      test('TisAisVariance has all required fields', () {
        final tis = tisService.parse(_validTisPayload);
        final ais = aisService.parse(_validAisPayload);

        final variances = tisService.reconcileWithAis(tis, ais);
        if (variances.isNotEmpty) {
          final v = variances.first;
          expect(v.category, isA<TisIncomeCategory>());
          expect(v.tisComputedPaise, isA<int>());
          expect(v.aisTotalPaise, isA<int>());
          expect(v.variancePaise, v.tisComputedPaise - v.aisTotalPaise);
        }
      });

      test('returns empty variances when TIS and AIS perfectly match', () {
        final tisPayload = <String, Object?>{
          'TIS': {
            'PAN': 'ABCDE1234F',
            'AssessmentYear': '2025-26',
            'Categories': [
              {
                'Category': 'Salary',
                'ReportedAmount': 600000,
                'ComputedAmount': 600000,
                'Feedback': 'A',
                'SourceCount': 1,
              },
            ],
          },
        };
        final aisPayload = <String, Object?>{
          'AIS': {
            'PAN': 'ABCDE1234F',
            'FinancialYear': '2024-25',
            'Salary': [
              {
                'SourceName': 'Acme',
                'SourcePAN': 'ACME01234X',
                'AmountReported': 600000,
                'AmountDerived': 600000,
                'Feedback': 'A',
                'TransactionId': 'TXN_MATCH',
              },
            ],
          },
        };
        final tis = tisService.parse(tisPayload);
        final ais = aisService.parse(aisPayload);
        final variances = tisService.reconcileWithAis(tis, ais);
        expect(variances, isEmpty);
      });
    });

    // ── TisIncomeCategory mapping ─────────────────────────────────────────────

    group('TisIncomeCategory.fromString', () {
      test('maps "salary" to salary', () {
        expect(
          TisIncomeCategory.fromString('salary'),
          TisIncomeCategory.salary,
        );
      });

      test('maps "interest" to interest', () {
        expect(
          TisIncomeCategory.fromString('interest'),
          TisIncomeCategory.interest,
        );
      });

      test('maps "capital gains" to capitalGains', () {
        expect(
          TisIncomeCategory.fromString('capital gains'),
          TisIncomeCategory.capitalGains,
        );
      });

      test('maps "rental income" to rentalIncome', () {
        expect(
          TisIncomeCategory.fromString('rental income'),
          TisIncomeCategory.rentalIncome,
        );
      });

      test('maps unknown string to otherSources', () {
        expect(
          TisIncomeCategory.fromString('unknown_category'),
          TisIncomeCategory.otherSources,
        );
      });
    });

    // ── TisFeedbackStatus mapping ─────────────────────────────────────────────

    group('TisFeedbackStatus.fromCode', () {
      test('"A" maps to accepted', () {
        expect(TisFeedbackStatus.fromCode('A'), TisFeedbackStatus.accepted);
      });

      test('"NA" maps to notAccepted', () {
        expect(TisFeedbackStatus.fromCode('NA'), TisFeedbackStatus.notAccepted);
      });

      test('"PA" maps to partiallyAccepted', () {
        expect(
          TisFeedbackStatus.fromCode('PA'),
          TisFeedbackStatus.partiallyAccepted,
        );
      });

      test('"NF" maps to noFeedback', () {
        expect(TisFeedbackStatus.fromCode('NF'), TisFeedbackStatus.noFeedback);
      });

      test('unknown code defaults to noFeedback', () {
        expect(TisFeedbackStatus.fromCode('XX'), TisFeedbackStatus.noFeedback);
      });
    });

    // ── TisAisVariance value object ───────────────────────────────────────────

    group('TisAisVariance', () {
      test('copyWith produces new instance with updated field', () {
        const original = TisAisVariance(
          category: TisIncomeCategory.salary,
          tisComputedPaise: 1000,
          aisTotalPaise: 900,
          variancePaise: 100,
        );
        final copy = original.copyWith(variancePaise: 200);
        expect(copy.variancePaise, 200);
        expect(copy.category, original.category);
        expect(copy.tisComputedPaise, original.tisComputedPaise);
      });

      test('equality uses category, tisComputedPaise, aisTotalPaise', () {
        const a = TisAisVariance(
          category: TisIncomeCategory.interest,
          tisComputedPaise: 500,
          aisTotalPaise: 400,
          variancePaise: 100,
        );
        const b = TisAisVariance(
          category: TisIncomeCategory.interest,
          tisComputedPaise: 500,
          aisTotalPaise: 400,
          variancePaise:
              999, // different variancePaise — but equality ignores it
        );
        expect(a, equals(b));
      });
    });
  });
}
