import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/ai/rag/tax_law_context.dart';

void main() {
  group('TaxLawContext', () {
    late TaxLawContext taxLawContext;

    setUp(() {
      taxLawContext = const TaxLawContext();
    });

    const question = 'Can I claim HRA deduction this year?';

    group('buildQuery — return type and structure', () {
      test('returns a RagQuery instance', () {
        const context = FilingContext(assessmentYear: '2024-25');
        final query = taxLawContext.buildQuery(question, context);

        expect(query, isA<RagQuery>());
      });

      test('RagQuery has enrichedPrompt, filterTags, and metadata', () {
        const context = FilingContext(assessmentYear: '2024-25');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.enrichedPrompt, isNotEmpty);
        expect(query.filterTags, isA<List<String>>());
        expect(query.metadata, isA<Map<String, String>>());
      });
    });

    group('buildQuery — assessment year in prompt', () {
      test('enrichedPrompt contains the assessment year', () {
        const context = FilingContext(assessmentYear: '2024-25');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.enrichedPrompt, contains('2024-25'));
      });

      test('metadata contains ay key matching assessment year', () {
        const context = FilingContext(assessmentYear: '2024-25');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.metadata['ay'], equals('2024-25'));
      });
    });

    group('buildQuery — income sources', () {
      test('enrichedPrompt includes income source labels', () {
        const context = FilingContext(
          assessmentYear: '2024-25',
          incomeSources: ['salary', 'house_property'],
        );
        final query = taxLawContext.buildQuery(question, context);

        expect(query.enrichedPrompt, contains('Salary'));
        expect(query.enrichedPrompt, contains('House Property'));
      });

      test('filterTags includes income sources', () {
        const context = FilingContext(
          incomeSources: ['salary', 'capital_gains'],
        );
        final query = taxLawContext.buildQuery(question, context);

        expect(query.filterTags, contains('salary'));
        expect(query.filterTags, contains('capital_gains'));
      });

      test('metadata income_sources key contains comma-separated sources', () {
        const context = FilingContext(
          incomeSources: ['salary', 'house_property'],
        );
        final query = taxLawContext.buildQuery(question, context);

        expect(query.metadata['income_sources'], contains('salary'));
        expect(query.metadata['income_sources'], contains('house_property'));
      });
    });

    group('buildQuery — active module', () {
      test('filterTags includes active module', () {
        const context = FilingContext(activeModule: 'itr1');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.filterTags, contains('itr1'));
      });

      test('ITR module adds income_tax_act and income_tax_rules tags', () {
        const context = FilingContext(activeModule: 'itr1');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.filterTags, contains('income_tax_act'));
        expect(query.filterTags, contains('income_tax_rules'));
      });

      test('GSTR module adds cgst_act and igst_act tags', () {
        const context = FilingContext(activeModule: 'gstr1');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.filterTags, contains('cgst_act'));
        expect(query.filterTags, contains('igst_act'));
      });

      test('enrichedPrompt includes form label for itr1', () {
        const context = FilingContext(activeModule: 'itr1');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.enrichedPrompt, contains('ITR-1'));
      });

      test('metadata module key matches active module', () {
        const context = FilingContext(activeModule: 'itr2');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.metadata['module'], equals('itr2'));
      });
    });

    group('buildQuery — tax regime', () {
      test('filterTags includes regime_new for new regime', () {
        const context = FilingContext(taxRegime: 'new');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.filterTags, contains('regime_new'));
      });

      test('filterTags includes regime_old for old regime', () {
        const context = FilingContext(taxRegime: 'old');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.filterTags, contains('regime_old'));
      });

      test('enrichedPrompt contains New Regime label for new regime', () {
        const context = FilingContext(taxRegime: 'new');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.enrichedPrompt, contains('New Regime'));
      });

      test('metadata regime key is set correctly', () {
        const context = FilingContext(taxRegime: 'old');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.metadata['regime'], equals('old'));
      });
    });

    group('buildQuery — empty context', () {
      test(
        'empty FilingContext returns enrichedPrompt equal to user question',
        () {
          const emptyContext = FilingContext();
          final query = taxLawContext.buildQuery(question, emptyContext);

          expect(query.enrichedPrompt, equals(question));
        },
      );

      test('empty FilingContext returns empty filterTags', () {
        const emptyContext = FilingContext();
        final query = taxLawContext.buildQuery(question, emptyContext);

        expect(query.filterTags, isEmpty);
      });

      test('empty FilingContext metadata has income_sources key', () {
        const emptyContext = FilingContext();
        final query = taxLawContext.buildQuery(question, emptyContext);

        // income_sources is always present (empty string for no sources).
        expect(query.metadata.containsKey('income_sources'), isTrue);
      });
    });

    group('buildQuery — PAN masking', () {
      test('enrichedPrompt masks PAN (does not expose full PAN)', () {
        const context = FilingContext(clientPan: 'ABCDE1234F');
        final query = taxLawContext.buildQuery(question, context);

        // Full PAN should not appear; masked version should.
        expect(query.enrichedPrompt, isNot(contains('ABCDE1234F')));
        expect(query.enrichedPrompt, contains('1234F'));
      });
    });

    group('buildQuery — [Context] and [Question] blocks', () {
      test(
        'enrichedPrompt includes [Context] header when context is present',
        () {
          const context = FilingContext(assessmentYear: '2024-25');
          final query = taxLawContext.buildQuery(question, context);

          expect(query.enrichedPrompt, contains('[Context]'));
        },
      );

      test(
        'enrichedPrompt includes [Question] header when context is present',
        () {
          const context = FilingContext(assessmentYear: '2024-25');
          final query = taxLawContext.buildQuery(question, context);

          expect(query.enrichedPrompt, contains('[Question]'));
        },
      );

      test('original question text is included in enrichedPrompt', () {
        const context = FilingContext(assessmentYear: '2024-25');
        final query = taxLawContext.buildQuery(question, context);

        expect(query.enrichedPrompt, contains(question));
      });
    });

    group('FilingContext — copyWith immutability', () {
      test('copyWith returns new instance with updated field', () {
        const original = FilingContext(assessmentYear: '2023-24');
        final updated = original.copyWith(assessmentYear: '2024-25');

        expect(updated.assessmentYear, equals('2024-25'));
        expect(identical(original, updated), isFalse);
      });
    });

    group('RagQuery — copyWith immutability', () {
      test('copyWith returns new instance with updated enrichedPrompt', () {
        const original = RagQuery(
          enrichedPrompt: 'original',
          filterTags: [],
          metadata: {},
        );
        final updated = original.copyWith(enrichedPrompt: 'updated');

        expect(updated.enrichedPrompt, equals('updated'));
        expect(identical(original, updated), isFalse);
      });
    });
  });
}
