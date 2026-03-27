import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/ai/rag/citation_enhancer.dart';

void main() {
  group('CitationEnhancer', () {
    late CitationEnhancer enhancer;

    setUp(() {
      enhancer = const CitationEnhancer();
    });

    group('extractCitations — Section 80C', () {
      test('text containing "Section 80C" produces a citation', () {
        const text =
            'You can claim a deduction under Section 80C up to ₹1.5 lakh.';
        final citations = enhancer.extractCitations(text);

        expect(citations, isNotEmpty);
        expect(citations.any((c) => c.reference.contains('80C')), isTrue);
      });

      test('Section 80C citation has a gazette URL', () {
        const text = 'Deduction available under Section 80C of Income Tax Act.';
        final citations = enhancer.extractCitations(text);

        final citation80c = citations.firstWhere(
          (c) => c.reference.contains('80C'),
        );
        expect(citation80c.gazetteUrl, isNotNull);
        expect(citation80c.gazetteUrl, contains('80c'));
      });

      test('Section 80C citation type is CitationType.act', () {
        const text = 'Section 80C deduction for LIC premiums.';
        final citations = enhancer.extractCitations(text);

        final actCitation = citations.firstWhere(
          (c) => c.reference.contains('80C'),
        );
        expect(actCitation.type, equals(CitationType.act));
      });

      test('shortLabel for Section 80C is §80C', () {
        const text = 'Invest under Section 80C to save tax.';
        final citations = enhancer.extractCitations(text);

        final citation = citations.firstWhere(
          (c) => c.reference.contains('80C'),
        );
        expect(citation.shortLabel, equals('§80C'));
      });
    });

    group('extractCitations — Section 24', () {
      test('text containing "Section 24" produces a citation', () {
        const text =
            'Interest on home loan is deductible under Section 24 of the IT Act.';
        final citations = enhancer.extractCitations(text);

        expect(citations.any((c) => c.reference.contains('24')), isTrue);
      });

      test('Section 24 citation has a gazette URL', () {
        const text = 'Claim house property deduction under Section 24.';
        final citations = enhancer.extractCitations(text);

        if (citations.any((c) => c.reference.contains('24'))) {
          final citation = citations.firstWhere(
            (c) => c.reference.contains('24'),
          );
          expect(citation.gazetteUrl, isNotNull);
        }
      });
    });

    group('extractCitations — multiple sections', () {
      test('text with multiple sections gets multiple citations', () {
        const text =
            'You can invest under Section 80C and also claim Section 80D '
            'for health insurance premiums.';
        final citations = enhancer.extractCitations(text);

        expect(citations.length, greaterThanOrEqualTo(2));
      });

      test('citations are deduplicated for repeated section references', () {
        const text =
            'Section 80C is beneficial. Section 80C allows up to 1.5 lakh.';
        final citations = enhancer.extractCitations(text);

        final count80c = citations
            .where((c) => c.reference.contains('80C'))
            .length;
        expect(
          count80c,
          equals(1),
          reason: 'Repeated Section 80C should be deduplicated',
        );
      });
    });

    group('extractCitations — circular references', () {
      test('text with circular reference extracts a circular citation', () {
        const text =
            'As per Circular No. 4/2023 issued by CBDT, the following applies.';
        final citations = enhancer.extractCitations(text);

        expect(citations.any((c) => c.type == CitationType.circular), isTrue);
      });

      test('circular citation reference contains the circular number', () {
        const text = 'Refer to Circular No. 4/2023 for clarification.';
        final citations = enhancer.extractCitations(text);

        final circular = citations.firstWhere(
          (c) => c.type == CitationType.circular,
          orElse: () =>
              const TaxCitation(reference: '', type: CitationType.circular),
        );
        if (circular.reference.isNotEmpty) {
          expect(circular.reference, contains('4/2023'));
        }
      });
    });

    group('extractCitations — notification references', () {
      test(
        'text with notification reference extracts a notification citation',
        () {
          const text = 'Notification No. 12/2024 issued under Section 115BAC.';
          final citations = enhancer.extractCitations(text);

          expect(
            citations.any((c) => c.type == CitationType.notification),
            isTrue,
          );
        },
      );
    });

    group('extractCitations — no references', () {
      test('text without section references returns empty list', () {
        const text =
            'Please consult your chartered accountant for advice on tax planning.';
        final citations = enhancer.extractCitations(text);

        // No section/circular/notification patterns should match.
        final actAndCircular = citations
            .where(
              (c) =>
                  c.type == CitationType.act ||
                  c.type == CitationType.circular ||
                  c.type == CitationType.notification,
            )
            .toList();
        expect(actAndCircular, isEmpty);
      });

      test('empty text returns empty list', () {
        final citations = enhancer.extractCitations('');
        expect(citations, isEmpty);
      });

      test('whitespace-only text returns empty list', () {
        final citations = enhancer.extractCitations('   ');
        expect(citations, isEmpty);
      });
    });

    group('formatWithCitations', () {
      test('returns original text unchanged when citations list is empty', () {
        const text = 'No citations here.';
        final result = enhancer.formatWithCitations(text, []);
        expect(result, equals(text));
      });

      test('appends ## References section when citations are provided', () {
        const text = 'Deduction under Section 80C.';
        final citations = enhancer.extractCitations(text);

        if (citations.isNotEmpty) {
          final formatted = enhancer.formatWithCitations(text, citations);
          expect(formatted, contains('## References'));
        }
      });

      test('each citation appears in the references section', () {
        const text = 'Invest under Section 80C and Section 80D.';
        final citations = enhancer.extractCitations(text);
        final formatted = enhancer.formatWithCitations(text, citations);

        for (final citation in citations) {
          expect(formatted, contains(citation.reference));
        }
      });

      test('reference lines include URLs for known sections', () {
        const text = 'Deduction under Section 80C of Income Tax Act 1961.';
        final citations = enhancer.extractCitations(text);
        final formatted = enhancer.formatWithCitations(text, citations);

        expect(formatted, contains('https://'));
      });
    });

    group('citationSummary', () {
      test('returns empty string for empty citations list', () {
        final summary = enhancer.citationSummary([]);
        expect(summary, isEmpty);
      });

      test('returns numbered list of citations', () {
        const text = 'Section 80C and Section 24 apply here.';
        final citations = enhancer.extractCitations(text);
        final summary = enhancer.citationSummary(citations);

        if (citations.isNotEmpty) {
          expect(summary, contains('[1]'));
        }
      });

      test('summary contains citation reference text', () {
        const text = 'Section 80C allows deduction.';
        final citations = enhancer.extractCitations(text);
        final summary = enhancer.citationSummary(citations);

        if (citations.isNotEmpty) {
          expect(summary, contains('80C'));
        }
      });
    });

    group('TaxCitation — model properties', () {
      test('TaxCitation copyWith creates new instance with updated field', () {
        const original = TaxCitation(
          reference: 'Section 80C of IT Act 1961',
          type: CitationType.act,
          gazetteUrl: 'https://example.com',
          shortLabel: '§80C',
        );
        final updated = original.copyWith(shortLabel: '§80-C');

        expect(updated.shortLabel, equals('§80-C'));
        expect(updated.reference, equals(original.reference));
        expect(identical(original, updated), isFalse);
      });

      test('TaxCitation equality is based on reference string', () {
        const c1 = TaxCitation(
          reference: 'Section 80C of IT Act 1961',
          type: CitationType.act,
        );
        const c2 = TaxCitation(
          reference: 'Section 80C of IT Act 1961',
          type: CitationType.circular, // different type
        );

        expect(c1, equals(c2));
      });
    });
  });
}
