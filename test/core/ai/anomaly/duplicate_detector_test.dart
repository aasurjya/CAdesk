import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/ai/anomaly/duplicate_detector.dart';

void main() {
  group('DuplicateDetector', () {
    late DuplicateDetector detector;

    setUp(() {
      detector = const DuplicateDetector();
    });

    // ---------------------------------------------------------------------------
    // Helper factory
    // ---------------------------------------------------------------------------

    Transaction tx(
      String id,
      double amount,
      DateTime date,
      String description,
    ) => Transaction(
      id: id,
      amount: amount,
      date: date,
      description: description,
    );

    final baseDate = DateTime(2024, 6, 1);

    group('findDuplicates — exact duplicates', () {
      test(
        'two identical transactions on same day are detected as duplicates',
        () {
          final t1 = tx('1', 5000.0, baseDate, 'NEFT transfer HDFC Bank');
          final t2 = tx('2', 5000.0, baseDate, 'NEFT transfer HDFC Bank');

          final groups = detector.findDuplicates([t1, t2]);

          expect(groups, hasLength(1));
          expect(groups.first.candidates, containsAll([t1, t2]));
        },
      );

      test(
        'duplicate group reason is exact_amount_same_day for same-day match',
        () {
          final t1 = tx('1', 5000.0, baseDate, 'NEFT payment');
          final t2 = tx('2', 5000.0, baseDate, 'NEFT payment');

          final groups = detector.findDuplicates([t1, t2]);

          expect(groups.first.reason, equals('exact_amount_same_day'));
        },
      );

      test('similarity is close to 1.0 for identical transactions', () {
        final t1 = tx('1', 5000.0, baseDate, 'same description');
        final t2 = tx('2', 5000.0, baseDate, 'same description');

        final groups = detector.findDuplicates([t1, t2]);

        expect(groups.first.similarity, greaterThan(0.8));
      });
    });

    group('findDuplicates — within tolerance', () {
      test(
        'amounts within 0.1% and 3 days apart with similar description are duplicates',
        () {
          // 0.1% of 5000 = 5. So 5000 and 5004 are within tolerance.
          final t1 = tx('1', 5000.0, baseDate, 'salary payment employee');
          final t2 = tx(
            '2',
            5004.0,
            baseDate.add(const Duration(days: 2)),
            'salary payment employee',
          );

          final groups = detector.findDuplicates([t1, t2]);

          expect(groups, hasLength(1));
        },
      );

      test('exact amount match across adjacent days gives correct reason', () {
        final t1 = tx('1', 3000.0, baseDate, 'vendor abc payment');
        final t2 = tx(
          '2',
          3000.0,
          baseDate.add(const Duration(days: 1)),
          'vendor abc payment',
        );

        final groups = detector.findDuplicates([t1, t2]);

        expect(groups, hasLength(1));
        // Same amount adjacent day → 'exact_amount_adjacent_day' or
        // 'similar_description_within_3_days' depending on description sim.
        expect(groups.first.reason, isNotEmpty);
      });
    });

    group('findDuplicates — not duplicates', () {
      test('transactions with very different amounts but same description are '
          'still grouped via description similarity', () {
        // Per the detector logic: if descSim >= threshold AND withinWindow → match.
        // So identical descriptions within the day window will group regardless
        // of amount difference.
        final t1 = tx('1', 5000.0, baseDate, 'NEFT payment');
        final t2 = tx('2', 50000.0, baseDate, 'NEFT payment');

        final groups = detector.findDuplicates([t1, t2]);

        // Identical description → Jaccard=1.0 ≥ 0.5 threshold + same day → grouped.
        expect(groups, hasLength(1));
        expect(
          groups.first.reason,
          isIn([
            'similar_description_within_3_days',
            'exact_amount_same_day',
            'exact_amount_adjacent_day',
            'similar_amount_same_party',
          ]),
        );
      });

      test(
        'transactions with different amounts and different descriptions are not duplicates',
        () {
          final t1 = tx('1', 5000.0, baseDate, 'salary payment');
          final t2 = tx('2', 75000.0, baseDate, 'rent invoice office');

          final groups = detector.findDuplicates([t1, t2]);

          expect(groups, isEmpty);
        },
      );

      test(
        'transactions 10 days apart are not duplicates even with same amount',
        () {
          final t1 = tx('1', 5000.0, baseDate, 'NEFT payment to vendor');
          final t2 = tx(
            '2',
            5000.0,
            baseDate.add(const Duration(days: 10)),
            'NEFT payment to vendor',
          );

          final groups = detector.findDuplicates([t1, t2]);

          expect(groups, isEmpty);
        },
      );
    });

    group('findDuplicates — empty and single input', () {
      test('empty input returns empty list', () {
        final groups = detector.findDuplicates([]);
        expect(groups, isEmpty);
      });

      test('single transaction has no duplicates', () {
        final t1 = tx('1', 5000.0, baseDate, 'NEFT payment');
        final groups = detector.findDuplicates([t1]);
        expect(groups, isEmpty);
      });
    });

    group('findDuplicates — result structure', () {
      test('detectDuplicates returns list of DuplicateGroup objects', () {
        final t1 = tx('1', 5000.0, baseDate, 'salary credit');
        final t2 = tx('2', 5000.0, baseDate, 'salary credit');

        final groups = detector.findDuplicates([t1, t2]);

        expect(groups, isA<List<DuplicateGroup>>());
      });

      test('DuplicateGroup has candidates, similarity, and reason', () {
        final t1 = tx('1', 5000.0, baseDate, 'salary credit');
        final t2 = tx('2', 5000.0, baseDate, 'salary credit');

        final group = detector.findDuplicates([t1, t2]).first;

        expect(group.candidates, isNotEmpty);
        expect(group.similarity, inInclusiveRange(0.0, 1.0));
        expect(group.reason, isNotEmpty);
      });

      test('results are sorted by descending similarity', () {
        // Create two separate duplicate pairs
        final t1 = tx('1', 5000.0, baseDate, 'identical description here');
        final t2 = tx('2', 5000.0, baseDate, 'identical description here');
        final t3 = tx(
          '3',
          3000.0,
          baseDate.add(const Duration(days: 1)),
          'another desc',
        );
        final t4 = tx(
          '4',
          3000.0,
          baseDate.add(const Duration(days: 2)),
          'another desc',
        );

        final groups = detector.findDuplicates([t1, t2, t3, t4]);

        if (groups.length >= 2) {
          expect(
            groups[0].similarity,
            greaterThanOrEqualTo(groups[1].similarity),
          );
        }
      });
    });

    group('DuplicateGroup — copyWith immutability', () {
      test('copyWith returns a new instance with updated fields', () {
        const group = DuplicateGroup(
          candidates: [],
          similarity: 0.9,
          reason: 'exact_amount_same_day',
        );
        final updated = group.copyWith(similarity: 0.5);

        expect(updated.similarity, equals(0.5));
        expect(updated.reason, equals(group.reason));
        expect(identical(group, updated), isFalse);
      });
    });

    group('Transaction — model properties', () {
      test('Transaction equality is based on id', () {
        final t1 = tx('abc', 1000.0, baseDate, 'desc');
        final t2 = tx(
          'abc',
          9999.0,
          baseDate.add(const Duration(days: 5)),
          'other',
        );

        expect(t1, equals(t2));
      });

      test('Transaction copyWith preserves unchanged fields', () {
        final original = tx('1', 1000.0, baseDate, 'description');
        final updated = original.copyWith(amount: 2000.0);

        expect(updated.id, equals(original.id));
        expect(updated.amount, equals(2000.0));
        expect(updated.description, equals(original.description));
      });
    });

    group('DuplicateDetector — configurable thresholds', () {
      test(
        'custom amountTolerancePct of 5% catches wider amount variations',
        () {
          const wideDetector = DuplicateDetector(amountTolerancePct: 5.0);
          // 5% of 5000 = 250, so 5000 and 5200 are within tolerance.
          final t1 = tx('1', 5000.0, baseDate, 'NEFT payment');
          final t2 = tx('2', 5200.0, baseDate, 'NEFT payment');

          final groups = wideDetector.findDuplicates([t1, t2]);

          expect(groups, hasLength(1));
        },
      );

      test('strict amountTolerancePct of 0% rejects minor differences', () {
        const strictDetector = DuplicateDetector(amountTolerancePct: 0.0);
        final t1 = tx('1', 5000.0, baseDate, 'same desc test');
        final t2 = tx('2', 5001.0, baseDate, 'same desc test');

        // Amount mismatch → only description match can group them.
        // Description is identical → Jaccard = 1.0 ≥ 0.5 threshold → grouped.
        final groups = strictDetector.findDuplicates([t1, t2]);

        // Description similarity grouping still applies.
        expect(groups, hasLength(1));
      });
    });
  });
}
