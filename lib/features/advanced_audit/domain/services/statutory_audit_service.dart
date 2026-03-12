import 'package:ca_app/features/advanced_audit/domain/models/audit_engagement.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_procedure.dart';
import 'package:ca_app/features/advanced_audit/domain/models/materiality_result.dart';

/// Stateless service for statutory audit planning calculations.
///
/// Implements ISA 320 (materiality), ISA 530 (sampling), and
/// standard Indian SA (Standards on Auditing) procedures.
class StatutoryAuditService {
  StatutoryAuditService._();

  // ─── Materiality constants ─────────────────────────────────────────────────

  static const double _revenueRate = 0.005; // 0.5% of total revenue
  static const double _assetRate = 0.01; // 1.0% of total assets
  static const double _profitRate = 0.05; // 5.0% of profit before tax
  static const double _performanceMaterialityRate = 0.75;

  // ─── Sample-size bands (Monetary Unit Sampling) ────────────────────────────

  static const int _sampleLow = 30;
  static const int _sampleModerate = 70;
  static const int _sampleHigh = 125;
  static const int _sampleCritical = 200;

  // ─── Standard audit areas ─────────────────────────────────────────────────

  static const List<String> _standardAreas = [
    'Revenue',
    'Expenses',
    'Assets',
    'Liabilities',
    'Equity',
    'Related Parties',
  ];

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Computes planning and performance materiality for the engagement.
  ///
  /// Planning materiality is the **lowest** of:
  ///   - 0.5% of total revenue
  ///   - 1% of total assets
  ///   - 5% of profit before tax (omitted when PBT ≤ 0)
  ///
  /// Performance materiality = 75% of planning materiality (ISA 320.11).
  ///
  /// All amounts are in paise.
  static MaterialityResult computeMateriality({
    required int totalRevenue,
    required int totalAssets,
    required int profitBeforeTax,
  }) {
    final revenueBasis = (totalRevenue * _revenueRate).round();
    final assetBasis = (totalAssets * _assetRate).round();
    final profitBasis = profitBeforeTax > 0
        ? (profitBeforeTax * _profitRate).round()
        : 0;

    // Collect valid bases (exclude profit basis when PBT ≤ 0)
    final bases = [revenueBasis, assetBasis, if (profitBasis > 0) profitBasis];

    final planning = bases.reduce((a, b) => a < b ? a : b);
    final performance = (planning * _performanceMaterialityRate).round();

    return MaterialityResult(
      planningMateriality: planning,
      performanceMateriality: performance,
      revenueBasis: revenueBasis,
      assetBasis: assetBasis,
      profitBasis: profitBasis,
    );
  }

  /// Computes the audit sample size using Monetary Unit Sampling (MUS).
  ///
  /// Sample bands:
  ///   - [AuditRiskLevel.low]      → 20–40  (mid: 30)
  ///   - [AuditRiskLevel.medium]   → 60–80  (mid: 70)
  ///   - [AuditRiskLevel.high]     → 100–150 (mid: 125)
  ///   - [AuditRiskLevel.critical] → 200+
  ///
  /// Result is capped at [populationSize].
  static int computeSampleSize({
    required AuditRiskLevel riskLevel,
    required int populationSize,
    required int materialityPaise,
  }) {
    final base = _baseSampleSize(riskLevel);
    return base.clamp(0, populationSize);
  }

  /// Generates a standard audit program for the given [engagement].
  ///
  /// Creates one [AuditProcedure] per (area, assertion) pair from a fixed
  /// set of standard assertions per area.  Sample sizes are derived from
  /// the engagement's risk level.
  static List<AuditProcedure> generateAuditProgram(AuditEngagement engagement) {
    final procedures = <AuditProcedure>[];
    var seq = 1;

    for (final area in _standardAreas) {
      final assertions = _assertionsForArea(area);
      for (final assertion in assertions) {
        final sampleSize = _baseSampleSize(engagement.riskLevel);
        procedures.add(
          AuditProcedure(
            procedureId: 'PROC-${seq.toString().padLeft(3, '0')}',
            area: area,
            assertion: assertion,
            plannedSampleSize: sampleSize,
            actualSampleSize: 0,
            exceptions: const [],
            status: ProcedureStatus.planned,
          ),
        );
        seq++;
      }
    }

    return List.unmodifiable(procedures);
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  static int _baseSampleSize(AuditRiskLevel risk) {
    switch (risk) {
      case AuditRiskLevel.low:
        return _sampleLow;
      case AuditRiskLevel.medium:
        return _sampleModerate;
      case AuditRiskLevel.high:
        return _sampleHigh;
      case AuditRiskLevel.critical:
        return _sampleCritical;
    }
  }

  /// Returns the primary assertions to test for a given audit area.
  static List<AuditAssertion> _assertionsForArea(String area) {
    switch (area) {
      case 'Revenue':
        return [
          AuditAssertion.completeness,
          AuditAssertion.accuracy,
          AuditAssertion.cutoff,
        ];
      case 'Expenses':
        return [
          AuditAssertion.existence,
          AuditAssertion.accuracy,
          AuditAssertion.completeness,
        ];
      case 'Assets':
        return [
          AuditAssertion.existence,
          AuditAssertion.accuracy,
          AuditAssertion.classification,
        ];
      case 'Liabilities':
        return [
          AuditAssertion.completeness,
          AuditAssertion.accuracy,
          AuditAssertion.cutoff,
        ];
      case 'Equity':
        return [AuditAssertion.existence, AuditAssertion.completeness];
      case 'Related Parties':
        return [
          AuditAssertion.completeness,
          AuditAssertion.accuracy,
          AuditAssertion.classification,
        ];
      default:
        return [AuditAssertion.existence, AuditAssertion.completeness];
    }
  }
}
