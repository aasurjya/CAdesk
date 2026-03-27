import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/reconciliation/domain/models/pan_tds_consolidation.dart';
import 'package:ca_app/features/reconciliation/domain/services/pan_tds_consolidation_service.dart';
import 'package:ca_app/features/reconciliation/domain/services/three_way_reconciliation_service.dart'
    show Form26AsData, Form26AsEntry;

void main() {
  final service = PanTdsConsolidationService.instance;

  // ---------------------------------------------------------------------------
  // Test data helpers
  // ---------------------------------------------------------------------------

  Form26AsData makeForm26AsWithEntries(List<_DeductorEntry> entries) =>
      Form26AsData(
        totalIncome: entries.fold(0, (s, e) => s + e.grossAmount),
        entries: entries
            .map(
              (e) => Form26AsEntry(
                deductorName: e.name,
                deductorTan: e.tan,
                grossAmount: e.grossAmount,
                tdsDeducted: e.tdsDeducted,
                tdsCredited: e.tdsCredited,
              ),
            )
            .toList(),
      );

  group('PanTdsConsolidationService', () {
    // -----------------------------------------------------------------------
    // groupByDeductor
    // -----------------------------------------------------------------------
    group('groupByDeductor', () {
      test('→ groups entries by TAN', () {
        final data = makeForm26AsWithEntries([
          const _DeductorEntry('ABC Ltd', 'TAN001', 500000, 50000, 50000),
          const _DeductorEntry('ABC Ltd', 'TAN001', 300000, 30000, 30000),
          const _DeductorEntry('XYZ Ltd', 'TAN002', 1000000, 100000, 100000),
        ]);
        final grouped = service.groupByDeductor(data);
        expect(grouped.keys, containsAll(['TAN001', 'TAN002']));
        expect(grouped['TAN001']!.totalGrossAmount, 800000);
        expect(grouped['TAN002']!.totalGrossAmount, 1000000);
      });

      test('→ single entry per TAN', () {
        final data = makeForm26AsWithEntries([
          const _DeductorEntry('Only Co', 'TAN999', 200000, 20000, 20000),
        ]);
        final grouped = service.groupByDeductor(data);
        expect(grouped.length, 1);
        expect(grouped['TAN999']!.deductorName, 'Only Co');
      });

      test('→ empty data returns empty map', () {
        const data = Form26AsData(totalIncome: 0, entries: []);
        final grouped = service.groupByDeductor(data);
        expect(grouped, isEmpty);
      });
    });

    // -----------------------------------------------------------------------
    // consolidate
    // -----------------------------------------------------------------------
    group('consolidate', () {
      test('→ returns correct pan and assessmentYear', () {
        const data = Form26AsData(totalIncome: 0, entries: []);
        final result = service.consolidate(data, 'ABCDE1234F', '2025-26');
        expect(result.pan, 'ABCDE1234F');
        expect(result.assessmentYear, '2025-26');
      });

      test('→ totalTdsDeducted sums across all deductors', () {
        final data = makeForm26AsWithEntries([
          const _DeductorEntry('Co A', 'TAN001', 500000, 50000, 50000),
          const _DeductorEntry('Co B', 'TAN002', 1000000, 100000, 100000),
        ]);
        final result = service.consolidate(data, 'ABCDE1234F', '2025-26');
        expect(result.totalTdsDeducted, 150000);
      });

      test('→ totalTdsCredited sums across all deductors', () {
        final data = makeForm26AsWithEntries([
          const _DeductorEntry(
            'Co A',
            'TAN001',
            500000,
            50000,
            40000,
          ), // ₹100 short credit
          const _DeductorEntry('Co B', 'TAN002', 1000000, 100000, 100000),
        ]);
        final result = service.consolidate(data, 'ABCDE1234F', '2025-26');
        expect(result.totalTdsCredited, 140000);
      });

      test('→ shortfall = deducted - credited', () {
        final data = makeForm26AsWithEntries([
          const _DeductorEntry(
            'Co A',
            'TAN001',
            500000,
            50000,
            30000,
          ), // shortfall 20000
          const _DeductorEntry('Co B', 'TAN002', 1000000, 100000, 100000),
        ]);
        final result = service.consolidate(data, 'ABCDE1234F', '2025-26');
        expect(result.shortfall, 20000);
      });

      test('→ zero shortfall when all TDS is credited', () {
        final data = makeForm26AsWithEntries([
          const _DeductorEntry('Co A', 'TAN001', 500000, 50000, 50000),
          const _DeductorEntry('Co B', 'TAN002', 1000000, 100000, 100000),
        ]);
        final result = service.consolidate(data, 'ABCDE1234F', '2025-26');
        expect(result.shortfall, 0);
      });

      test('→ deductorWiseSummary has one entry per unique TAN', () {
        final data = makeForm26AsWithEntries([
          const _DeductorEntry('Co A', 'TAN001', 100000, 10000, 10000),
          const _DeductorEntry(
            'Co A',
            'TAN001',
            200000,
            20000,
            20000,
          ), // same TAN
          const _DeductorEntry('Co B', 'TAN002', 500000, 50000, 50000),
        ]);
        final result = service.consolidate(data, 'ABCDE1234F', '2025-26');
        expect(result.deductorWiseSummary, hasLength(2));
      });
    });

    // -----------------------------------------------------------------------
    // detectShortCredits
    // -----------------------------------------------------------------------
    group('detectShortCredits', () {
      test('→ returns empty when no shortfall exists', () {
        const recon = PanTdsConsolidation(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          deductorWiseSummary: [],
          totalIncome: 5000000,
          totalTdsDeducted: 100000,
          totalTdsCredited: 100000,
          shortfall: 0,
        );
        final shorts = service.detectShortCredits(recon);
        expect(shorts, isEmpty);
      });

      test('→ flags deductors with credit shortfall', () {
        const deductor = DeductorTdsSummary(
          deductorName: 'Shady Corp',
          deductorTan: 'TAN999',
          totalGrossAmount: 500000,
          totalTdsDeducted: 50000,
          totalTdsCredited: 30000, // 20000 short
        );
        const recon = PanTdsConsolidation(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          deductorWiseSummary: [deductor],
          totalIncome: 500000,
          totalTdsDeducted: 50000,
          totalTdsCredited: 30000,
          shortfall: 20000,
        );
        final shorts = service.detectShortCredits(recon);
        expect(shorts, hasLength(1));
        expect(shorts.first.deductorTan, 'TAN999');
        expect(shorts.first.shortfallAmount, 20000);
      });

      test('→ does not flag deductors with full credit', () {
        const deductorOk = DeductorTdsSummary(
          deductorName: 'Good Corp',
          deductorTan: 'TAN001',
          totalGrossAmount: 500000,
          totalTdsDeducted: 50000,
          totalTdsCredited: 50000, // fully credited
        );
        const deductorBad = DeductorTdsSummary(
          deductorName: 'Bad Corp',
          deductorTan: 'TAN002',
          totalGrossAmount: 200000,
          totalTdsDeducted: 20000,
          totalTdsCredited: 10000, // short by 10000
        );
        const recon = PanTdsConsolidation(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          deductorWiseSummary: [deductorOk, deductorBad],
          totalIncome: 700000,
          totalTdsDeducted: 70000,
          totalTdsCredited: 60000,
          shortfall: 10000,
        );
        final shorts = service.detectShortCredits(recon);
        expect(shorts, hasLength(1));
        expect(shorts.first.deductorTan, 'TAN002');
      });
    });

    // -----------------------------------------------------------------------
    // computeTotalTaxCredit
    // -----------------------------------------------------------------------
    group('computeTotalTaxCredit', () {
      test('→ returns totalTdsCredited', () {
        const recon = PanTdsConsolidation(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          deductorWiseSummary: [],
          totalIncome: 5000000,
          totalTdsDeducted: 100000,
          totalTdsCredited: 95000,
          shortfall: 5000,
        );
        expect(service.computeTotalTaxCredit(recon), 95000);
      });
    });

    // -----------------------------------------------------------------------
    // PanTdsConsolidation model
    // -----------------------------------------------------------------------
    group('PanTdsConsolidation model', () {
      test('→ equality and hashCode', () {
        const a = PanTdsConsolidation(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          deductorWiseSummary: [],
          totalIncome: 500000,
          totalTdsDeducted: 50000,
          totalTdsCredited: 50000,
          shortfall: 0,
        );
        const b = PanTdsConsolidation(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          deductorWiseSummary: [],
          totalIncome: 500000,
          totalTdsDeducted: 50000,
          totalTdsCredited: 50000,
          shortfall: 0,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('→ copyWith preserves unchanged fields', () {
        const original = PanTdsConsolidation(
          pan: 'ABCDE1234F',
          assessmentYear: '2025-26',
          deductorWiseSummary: [],
          totalIncome: 500000,
          totalTdsDeducted: 50000,
          totalTdsCredited: 50000,
          shortfall: 0,
        );
        final updated = original.copyWith(shortfall: 5000);
        expect(updated.shortfall, 5000);
        expect(updated.pan, 'ABCDE1234F');
        expect(identical(original, updated), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // DeductorTdsSummary model
    // -----------------------------------------------------------------------
    group('DeductorTdsSummary model', () {
      test('→ shortfall computed as deducted minus credited', () {
        const summary = DeductorTdsSummary(
          deductorName: 'Test Co',
          deductorTan: 'TAN123',
          totalGrossAmount: 1000000,
          totalTdsDeducted: 100000,
          totalTdsCredited: 80000,
        );
        expect(summary.creditShortfall, 20000);
      });

      test('→ zero shortfall when fully credited', () {
        const summary = DeductorTdsSummary(
          deductorName: 'Test Co',
          deductorTan: 'TAN123',
          totalGrossAmount: 1000000,
          totalTdsDeducted: 100000,
          totalTdsCredited: 100000,
        );
        expect(summary.creditShortfall, 0);
      });
    });
  });
}

// ---------------------------------------------------------------------------
// Minimal test data helpers
// ---------------------------------------------------------------------------

class _DeductorEntry {
  final String name;
  final String tan;
  final int grossAmount;
  final int tdsDeducted;
  final int tdsCredited;

  const _DeductorEntry(
    this.name,
    this.tan,
    this.grossAmount,
    this.tdsDeducted,
    this.tdsCredited,
  );
}
