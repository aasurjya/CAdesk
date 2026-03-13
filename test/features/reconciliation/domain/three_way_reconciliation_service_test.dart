import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/reconciliation/domain/models/reconciliation_variance.dart';
import 'package:ca_app/features/reconciliation/domain/models/three_way_match_result.dart';
import 'package:ca_app/features/reconciliation/domain/services/three_way_reconciliation_service.dart';

// ---------------------------------------------------------------------------
// Minimal stubs for Form26AsData, AisData, ItrFormData used in tests.
// The service accepts these as value objects — the tests supply concrete
// instances that satisfy the interface.
// ---------------------------------------------------------------------------

void main() {
  group('ThreeWayReconciliationService', () {
    // -----------------------------------------------------------------------
    // computeVariance
    // -----------------------------------------------------------------------
    group('computeVariance', () {
      test('→ matched when variance is zero', () {
        final v = ThreeWayReconciliationService.instance.computeVariance(
          500000,
          500000,
          source1Label: '26AS',
          source2Label: 'AIS',
        );
        expect(v.status, VarianceStatus.matched);
        expect(v.variance, 0);
        expect(v.variancePercent, 0.0);
      });

      test('→ matched when variance is within default ₹1,000 threshold', () {
        // 500 paise below threshold of 100000 paise (₹1000)
        final v = ThreeWayReconciliationService.instance.computeVariance(
          1000000,
          1000500, // ₹5 difference
          source1Label: '26AS',
          source2Label: 'AIS',
        );
        expect(v.status, VarianceStatus.matched);
        expect(v.variance, -500);
      });

      test('→ minorVariance when between ₹1,001 and ₹10,000', () {
        // ₹5,000 = 500000 paise difference
        final v = ThreeWayReconciliationService.instance.computeVariance(
          10000000,
          10500000,
          source1Label: '26AS',
          source2Label: 'ITR',
        );
        expect(v.status, VarianceStatus.minorVariance);
        expect(v.variance, -500000);
      });

      test('→ majorVariance when variance exceeds ₹10,000', () {
        // ₹50,000 = 5,000,000 paise difference
        final v = ThreeWayReconciliationService.instance.computeVariance(
          20000000,
          25000000,
          source1Label: 'AIS',
          source2Label: 'ITR',
        );
        expect(v.status, VarianceStatus.majorVariance);
        expect(v.variance, -5000000);
      });

      test('→ unmatched when one source is zero and other is non-zero', () {
        final v = ThreeWayReconciliationService.instance.computeVariance(
          0,
          5000000,
          source1Label: '26AS',
          source2Label: 'AIS',
        );
        expect(v.status, VarianceStatus.unmatched);
      });

      test('→ variancePercent computed correctly', () {
        final v = ThreeWayReconciliationService.instance.computeVariance(
          10000000,
          11000000,
          source1Label: '26AS',
          source2Label: 'AIS',
        );
        // variance = -1000000, percent = -10%
        expect(v.variancePercent, closeTo(-10.0, 0.001));
      });

      test('→ labels are preserved', () {
        final v = ThreeWayReconciliationService.instance.computeVariance(
          1000,
          1000,
          source1Label: 'Form 26AS',
          source2Label: 'AIS',
        );
        expect(v.source1Label, 'Form 26AS');
        expect(v.source2Label, 'AIS');
      });

      test('→ custom threshold respected', () {
        // Variance of 50000 paise (₹500) within a 200000 (₹2000) threshold
        final v = ThreeWayReconciliationService.instance.computeVariance(
          1000000,
          1050000,
          source1Label: 'A',
          source2Label: 'B',
          thresholdPaise: 200000,
        );
        expect(v.status, VarianceStatus.matched);
      });
    });

    // -----------------------------------------------------------------------
    // reconcile — ThreeWayMatchResult structure
    // -----------------------------------------------------------------------
    group('reconcile', () {
      test('→ returns ThreeWayMatchResult with correct pan and year', () {
        final form26as = _makeForm26As(totalIncome: 50000000); // ₹5L
        final ais = _makeAis(totalIncome: 50000000);
        final itr = _makeItr(totalIncome: 50000000);

        final result = ThreeWayReconciliationService.instance.reconcile(
          form26as,
          ais,
          itr,
          'ABCDE1234F',
          '2025-26',
        );

        expect(result.pan, 'ABCDE1234F');
        expect(result.assessmentYear, '2025-26');
      });

      test('→ all matched when all three sources agree', () {
        const income = 50000000; // ₹5L
        final result = ThreeWayReconciliationService.instance.reconcile(
          _makeForm26As(totalIncome: income),
          _makeAis(totalIncome: income),
          _makeItr(totalIncome: income),
          'ABCDE1234F',
          '2025-26',
        );

        expect(result.form26AsVsAis.status, VarianceStatus.matched);
        expect(result.form26AsVsItr.status, VarianceStatus.matched);
        expect(result.aisVsItr.status, VarianceStatus.matched);
      });

      test(
        '→ majorVariance detected when ITR income is significantly lower',
        () {
          final result = ThreeWayReconciliationService.instance.reconcile(
            _makeForm26As(totalIncome: 50000000),
            _makeAis(totalIncome: 50000000),
            _makeItr(totalIncome: 45000000), // ₹5,000 short = major
            'ABCDE1234F',
            '2025-26',
          );

          expect(result.form26AsVsItr.status, VarianceStatus.majorVariance);
          expect(result.aisVsItr.status, VarianceStatus.majorVariance);
        },
      );

      test('→ recommendations populated when variances exist', () {
        final result = ThreeWayReconciliationService.instance.reconcile(
          _makeForm26As(totalIncome: 50000000),
          _makeAis(totalIncome: 55000000),
          _makeItr(totalIncome: 45000000),
          'ABCDE1234F',
          '2025-26',
        );

        expect(result.recommendations, isNotEmpty);
      });

      test('→ no recommendations when all sources match', () {
        const income = 50000000;
        final result = ThreeWayReconciliationService.instance.reconcile(
          _makeForm26As(totalIncome: income),
          _makeAis(totalIncome: income),
          _makeItr(totalIncome: income),
          'ABCDE1234F',
          '2025-26',
        );

        expect(result.recommendations, isEmpty);
      });

      test('→ totals stored correctly in result', () {
        final result = ThreeWayReconciliationService.instance.reconcile(
          _makeForm26As(totalIncome: 40000000),
          _makeAis(totalIncome: 41000000),
          _makeItr(totalIncome: 39000000),
          'XYZAB5678C',
          '2025-26',
        );

        expect(result.form26AsTotal, 40000000);
        expect(result.aisTotalIncome, 41000000);
        expect(result.itrTotalIncome, 39000000);
      });
    });

    // -----------------------------------------------------------------------
    // identifyUnreportedIncome
    // -----------------------------------------------------------------------
    group('identifyUnreportedIncome', () {
      test('→ returns empty when AIS entries all appear in ITR', () {
        final ais = _makeAisWithSources([
          _AisSource('SBI Bank', 200000), // ₹2,000
        ]);
        final itr = _makeItrWithSources([_ItrSource('SBI Bank', 200000)]);
        final items = ThreeWayReconciliationService.instance
            .identifyUnreportedIncome(ais, itr);
        expect(items, isEmpty);
      });

      test('→ flags AIS source not in ITR', () {
        final ais = _makeAisWithSources([
          _AisSource('HDFC Bank', 500000), // ₹5,000
        ]);
        final itr = _makeItrWithSources([]); // nothing declared
        final items = ThreeWayReconciliationService.instance
            .identifyUnreportedIncome(ais, itr);
        expect(items, hasLength(1));
        expect(items.first.sourceName, 'HDFC Bank');
        expect(items.first.aisAmount, 500000);
      });

      test('→ ignores amounts below ₹1,000 (100000 paise)', () {
        final ais = _makeAisWithSources([
          _AisSource('Post Office', 50000), // ₹500 — ignored
        ]);
        final itr = _makeItrWithSources([]);
        final items = ThreeWayReconciliationService.instance
            .identifyUnreportedIncome(ais, itr);
        expect(items, isEmpty);
      });

      test('→ returns multiple flagged items', () {
        final ais = _makeAisWithSources([
          _AisSource('Axis Bank', 1500000), // ₹15,000
          _AisSource('Zerodha', 3000000), // ₹30,000
        ]);
        final itr = _makeItrWithSources([]);
        final items = ThreeWayReconciliationService.instance
            .identifyUnreportedIncome(ais, itr);
        expect(items, hasLength(2));
      });
    });

    // -----------------------------------------------------------------------
    // ReconciliationVariance model — immutability & equality
    // -----------------------------------------------------------------------
    group('ReconciliationVariance model', () {
      test('→ equality based on all fields', () {
        const a = ReconciliationVariance(
          source1Label: '26AS',
          source2Label: 'AIS',
          source1Amount: 1000,
          source2Amount: 1000,
          variance: 0,
          variancePercent: 0.0,
          status: VarianceStatus.matched,
          threshold: 100000,
        );
        const b = ReconciliationVariance(
          source1Label: '26AS',
          source2Label: 'AIS',
          source1Amount: 1000,
          source2Amount: 1000,
          variance: 0,
          variancePercent: 0.0,
          status: VarianceStatus.matched,
          threshold: 100000,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('→ copyWith returns new object with changed field', () {
        const original = ReconciliationVariance(
          source1Label: '26AS',
          source2Label: 'AIS',
          source1Amount: 1000,
          source2Amount: 2000,
          variance: -1000,
          variancePercent: -50.0,
          status: VarianceStatus.majorVariance,
          threshold: 100000,
        );
        final updated = original.copyWith(status: VarianceStatus.matched);
        expect(updated.status, VarianceStatus.matched);
        expect(updated.source1Amount, 1000);
        expect(identical(original, updated), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // ThreeWayMatchResult model — immutability & equality
    // -----------------------------------------------------------------------
    group('ThreeWayMatchResult model', () {
      test('→ isFullyMatched when all three variances are matched', () {
        const variance = ReconciliationVariance(
          source1Label: 'A',
          source2Label: 'B',
          source1Amount: 1000,
          source2Amount: 1000,
          variance: 0,
          variancePercent: 0.0,
          status: VarianceStatus.matched,
          threshold: 100000,
        );
        const result = ThreeWayMatchResult(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          form26AsTotal: 1000,
          aisTotalIncome: 1000,
          itrTotalIncome: 1000,
          form26AsVsAis: variance,
          form26AsVsItr: variance,
          aisVsItr: variance,
          unreportedIncome: [],
          recommendations: [],
        );
        expect(result.isFullyMatched, isTrue);
      });

      test('→ isFullyMatched false when any variance is non-matched', () {
        const matched = ReconciliationVariance(
          source1Label: 'A',
          source2Label: 'B',
          source1Amount: 1000,
          source2Amount: 1000,
          variance: 0,
          variancePercent: 0.0,
          status: VarianceStatus.matched,
          threshold: 100000,
        );
        const major = ReconciliationVariance(
          source1Label: 'A',
          source2Label: 'B',
          source1Amount: 1000,
          source2Amount: 5000000,
          variance: -4999000,
          variancePercent: -499.9,
          status: VarianceStatus.majorVariance,
          threshold: 100000,
        );
        const result = ThreeWayMatchResult(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          form26AsTotal: 1000,
          aisTotalIncome: 5000000,
          itrTotalIncome: 1000,
          form26AsVsAis: major,
          form26AsVsItr: matched,
          aisVsItr: major,
          unreportedIncome: [],
          recommendations: ['Investigate discrepancy'],
        );
        expect(result.isFullyMatched, isFalse);
      });

      test('→ copyWith preserves unchanged fields', () {
        const matched = ReconciliationVariance(
          source1Label: 'A',
          source2Label: 'B',
          source1Amount: 1000,
          source2Amount: 1000,
          variance: 0,
          variancePercent: 0.0,
          status: VarianceStatus.matched,
          threshold: 100000,
        );
        const original = ThreeWayMatchResult(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          form26AsTotal: 1000,
          aisTotalIncome: 1000,
          itrTotalIncome: 1000,
          form26AsVsAis: matched,
          form26AsVsItr: matched,
          aisVsItr: matched,
          unreportedIncome: [],
          recommendations: [],
        );
        final updated = original.copyWith(assessmentYear: '2026-27');
        expect(updated.assessmentYear, '2026-27');
        expect(updated.pan, 'ABCDE1234F');
        expect(identical(original, updated), isFalse);
      });
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers — lightweight test stubs
// ---------------------------------------------------------------------------

class _AisSource {
  final String name;
  final int amount;
  const _AisSource(this.name, this.amount);
}

class _ItrSource {
  final String name;
  final int amount;
  const _ItrSource(this.name, this.amount);
}

Form26AsData _makeForm26As({required int totalIncome}) =>
    Form26AsData(totalIncome: totalIncome, entries: const []);

AisData _makeAis({required int totalIncome}) =>
    AisData(totalIncome: totalIncome, sources: const []);

AisData _makeAisWithSources(List<_AisSource> sources) => AisData(
  totalIncome: sources.fold(0, (s, e) => s + e.amount),
  sources: sources
      .map((e) => AisIncomeSource(name: e.name, amount: e.amount))
      .toList(),
);

ItrFormData _makeItr({required int totalIncome}) =>
    ItrFormData(totalIncome: totalIncome, sources: const []);

ItrFormData _makeItrWithSources(List<_ItrSource> sources) => ItrFormData(
  totalIncome: sources.fold(0, (s, e) => s + e.amount),
  sources: sources
      .map((e) => ItrIncomeSource(name: e.name, amount: e.amount))
      .toList(),
);
