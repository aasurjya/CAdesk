import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_procedure.dart';
import 'package:ca_app/features/advanced_audit/domain/services/statutory_audit_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatutoryAuditService', () {
    // --------------- computeMateriality ---------------

    group('computeMateriality', () {
      test('uses 5% of PBT when PBT is positive', () {
        // Revenue 10 Cr, Assets 5 Cr, PBT 1 Cr (all in paise)
        final result = StatutoryAuditService.computeMateriality(
          totalRevenue: 1000000000, // ₹1 Cr
          totalAssets: 500000000, // ₹50 L
          profitBeforeTax: 100000000, // ₹10 L
        );
        // 5% of PBT = 5% * 100000000 = 5000000 (₹50,000)
        // 0.5% of revenue = 0.5% * 1000000000 = 5000000 (₹50,000)
        // 1% of assets = 1% * 500000000 = 5000000 (₹50,000)
        // planning materiality = min of all three
        expect(result.planningMateriality, equals(5000000));
      });

      test('uses 0.5% of revenue when PBT is negative', () {
        final result = StatutoryAuditService.computeMateriality(
          totalRevenue: 1000000000, // ₹1 Cr
          totalAssets: 500000000,
          profitBeforeTax: -50000000, // loss
        );
        // Revenue-based: 0.5% * 1000000000 = 5000000
        // Asset-based: 1% * 500000000 = 5000000
        // PBT negative → skip PBT basis
        expect(result.planningMateriality, equals(5000000));
      });

      test('performance materiality is 75% of planning materiality', () {
        final result = StatutoryAuditService.computeMateriality(
          totalRevenue: 1000000000,
          totalAssets: 500000000,
          profitBeforeTax: 100000000,
        );
        expect(
          result.performanceMateriality,
          equals((result.planningMateriality * 0.75).round()),
        );
      });

      test('returns lowest of the three bases as planning materiality', () {
        // Make asset-based the lowest
        final result = StatutoryAuditService.computeMateriality(
          totalRevenue: 10000000000, // ₹100 Cr
          totalAssets: 100000000, // ₹1 Cr — 1% = ₹1 L = 1000000
          profitBeforeTax: 5000000000, // ₹50 Cr — 5% = ₹2.5 Cr = 250000000
        );
        // revenue-based: 0.5% * 10000000000 = 50000000
        // asset-based: 1% * 100000000 = 1000000
        // pbt-based: 5% * 5000000000 = 250000000
        // lowest = 1000000
        expect(result.planningMateriality, equals(1000000));
      });

      test('materiality result is immutable — copyWith preserves values', () {
        final result = StatutoryAuditService.computeMateriality(
          totalRevenue: 1000000000,
          totalAssets: 500000000,
          profitBeforeTax: 100000000,
        );
        final copy = result.copyWith(planningMateriality: 9999999);
        expect(copy.planningMateriality, equals(9999999));
        expect(result.planningMateriality, equals(5000000));
      });
    });

    // --------------- computeSampleSize ---------------

    group('computeSampleSize', () {
      test('low risk returns sample size in 20–40 range', () {
        final size = StatutoryAuditService.computeSampleSize(
          riskLevel: AuditRiskLevel.low,
          populationSize: 1000,
          materialityPaise: 5000000,
        );
        expect(size, inInclusiveRange(20, 40));
      });

      test('moderate risk returns sample size in 60–80 range', () {
        final size = StatutoryAuditService.computeSampleSize(
          riskLevel: AuditRiskLevel.medium,
          populationSize: 1000,
          materialityPaise: 5000000,
        );
        expect(size, inInclusiveRange(60, 80));
      });

      test('high risk returns sample size in 100–150 range', () {
        final size = StatutoryAuditService.computeSampleSize(
          riskLevel: AuditRiskLevel.high,
          populationSize: 1000,
          materialityPaise: 5000000,
        );
        expect(size, inInclusiveRange(100, 150));
      });

      test('critical/very-high risk returns 200+', () {
        final size = StatutoryAuditService.computeSampleSize(
          riskLevel: AuditRiskLevel.critical,
          populationSize: 1000,
          materialityPaise: 5000000,
        );
        expect(size, greaterThanOrEqualTo(200));
      });

      test('sample size never exceeds population size', () {
        final size = StatutoryAuditService.computeSampleSize(
          riskLevel: AuditRiskLevel.critical,
          populationSize: 50,
          materialityPaise: 5000000,
        );
        expect(size, lessThanOrEqualTo(50));
      });
    });

    // --------------- generateAuditProgram ---------------

    group('generateAuditProgram', () {
      late AuditEngagement engagement;

      setUp(() {
        engagement = AuditEngagement(
          id: 'ENG001',
          clientId: 'C001',
          clientName: 'ABC Ltd',
          auditType: AuditType.statutory,
          financialYear: '2023-24',
          assignedPartner: 'CA Sharma',
          teamMembers: const [],
          status: AuditStatus.planning,
          startDate: DateTime(2024, 4, 1),
          reportDueDate: DateTime(2024, 9, 30),
          workpaperCount: 0,
          findingsCount: 0,
          riskLevel: AuditRiskLevel.medium,
        );
      });

      test('returns non-empty list of procedures', () {
        final program = StatutoryAuditService.generateAuditProgram(engagement);
        expect(program, isNotEmpty);
      });

      test('covers all standard audit areas', () {
        final program = StatutoryAuditService.generateAuditProgram(engagement);
        final areas = program.map((p) => p.area).toSet();
        expect(areas, containsAll(['Revenue', 'Expenses', 'Assets']));
        expect(
          areas,
          containsAll(['Liabilities', 'Equity', 'Related Parties']),
        );
      });

      test('all procedures start with planned status', () {
        final program = StatutoryAuditService.generateAuditProgram(engagement);
        for (final proc in program) {
          expect(proc.status, equals(ProcedureStatus.planned));
        }
      });

      test('all procedure IDs are unique', () {
        final program = StatutoryAuditService.generateAuditProgram(engagement);
        final ids = program.map((p) => p.procedureId).toList();
        expect(ids.toSet().length, equals(ids.length));
      });

      test('procedure actualSampleSize starts at 0 and exceptions empty', () {
        final program = StatutoryAuditService.generateAuditProgram(engagement);
        for (final proc in program) {
          expect(proc.actualSampleSize, equals(0));
          expect(proc.exceptions, isEmpty);
        }
      });

      test('higher risk engagement produces larger planned sample sizes', () {
        final lowRiskEngagement = engagement.copyWith(
          riskLevel: AuditRiskLevel.low,
        );
        final highRiskEngagement = engagement.copyWith(
          riskLevel: AuditRiskLevel.critical,
        );
        final lowProgram = StatutoryAuditService.generateAuditProgram(
          lowRiskEngagement,
        );
        final highProgram = StatutoryAuditService.generateAuditProgram(
          highRiskEngagement,
        );

        final lowAvg =
            lowProgram.map((p) => p.plannedSampleSize).reduce((a, b) => a + b) /
            lowProgram.length;
        final highAvg =
            highProgram
                .map((p) => p.plannedSampleSize)
                .reduce((a, b) => a + b) /
            highProgram.length;
        expect(highAvg, greaterThan(lowAvg));
      });
    });
  });
}
