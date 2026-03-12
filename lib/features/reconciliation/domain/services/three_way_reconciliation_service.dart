import '../models/reconciliation_variance.dart';
import '../models/three_way_match_result.dart';

// ---------------------------------------------------------------------------
// Lightweight input data-transfer objects.
// These are kept thin — the reconciliation engine only needs aggregated totals
// and named income sources; detailed raw entries live in the filing feature.
// ---------------------------------------------------------------------------

/// A named income source from AIS.
class AisIncomeSource {
  const AisIncomeSource({required this.name, required this.amount});

  /// Reporting entity name (e.g. 'HDFC Bank', 'Infosys Ltd').
  final String name;

  /// Reported amount, in paise.
  final int amount;
}

/// A declared income source from the ITR schedules.
class ItrIncomeSource {
  const ItrIncomeSource({required this.name, required this.amount});

  /// Income source name as declared in the ITR.
  final String name;

  /// Declared amount, in paise.
  final int amount;
}

/// Aggregated Form 26AS data used as input to the reconciliation engine.
class Form26AsData {
  const Form26AsData({required this.totalIncome, required this.entries});

  /// Total gross income/payments as per Form 26AS, in paise.
  final int totalIncome;

  /// Raw entries from Form 26AS (used for PAN TDS consolidation).
  final List<Form26AsEntry> entries;
}

/// A single entry from Form 26AS (one deductor + quarter combination).
class Form26AsEntry {
  const Form26AsEntry({
    required this.deductorName,
    required this.deductorTan,
    required this.grossAmount,
    required this.tdsDeducted,
    required this.tdsCredited,
  });

  final String deductorName;
  final String deductorTan;

  /// Gross income amount, in paise.
  final int grossAmount;

  /// TDS deducted by the deductor, in paise.
  final int tdsDeducted;

  /// TDS actually credited in Form 26AS, in paise.
  final int tdsCredited;
}

/// Aggregated AIS data used as input to the reconciliation engine.
class AisData {
  const AisData({required this.totalIncome, required this.sources});

  /// Total income across all AIS categories, in paise.
  final int totalIncome;

  /// Individual income sources reported in AIS.
  final List<AisIncomeSource> sources;
}

/// Aggregated ITR form data used as input to the reconciliation engine.
///
/// Multiple ITR types (ITR-1 through ITR-7) are supported by keeping this
/// type generic — only the totals needed for reconciliation are included.
class ItrFormData {
  const ItrFormData({required this.totalIncome, required this.sources});

  /// Total income as declared in the ITR form, in paise.
  final int totalIncome;

  /// Income sources as declared in ITR schedules.
  final List<ItrIncomeSource> sources;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Stateless service for three-way reconciliation of Form 26AS, AIS, and ITR.
///
/// Computes variance between each pair of data sources, identifies unreported
/// income, and generates actionable recommendations for the assessee.
///
/// ### Variance Thresholds
/// | Threshold | Meaning |
/// |-----------|---------|
/// | ≤ ₹1,000  | Matched — rounding differences acceptable |
/// | ₹1,001–₹10,000 | Minor variance — may need explanation |
/// | > ₹10,000 | Major variance — must be investigated before filing |
///
/// ### Usage
/// ```dart
/// final result = ThreeWayReconciliationService.instance.reconcile(
///   form26as, ais, itr, 'ABCDE1234F', '2025-26',
/// );
/// ```
class ThreeWayReconciliationService {
  ThreeWayReconciliationService._();

  static final ThreeWayReconciliationService instance =
      ThreeWayReconciliationService._();

  /// Threshold for "minor variance" in paise (₹1,000 = 100,000 paise).
  static const int _minorVarianceThresholdPaise = 100000;

  /// Threshold above which variance is "major" in paise (₹10,000 = 1,000,000 paise).
  static const int _majorVarianceThresholdPaise = 1000000;

  /// Minimum AIS amount to flag as unreported income (₹1,000 = 100,000 paise).
  static const int _unreportedIncomeMinPaise = 100000;

  /// Performs a three-way reconciliation of Form 26AS, AIS, and ITR data.
  ///
  /// Returns a [ThreeWayMatchResult] with variance analysis between each pair
  /// of sources, any unreported income items, and recommendations.
  ThreeWayMatchResult reconcile(
    Form26AsData form26as,
    AisData ais,
    ItrFormData itr,
    String pan,
    String assessmentYear,
  ) {
    final vsAis = computeVariance(
      form26as.totalIncome,
      ais.totalIncome,
      source1Label: 'Form 26AS',
      source2Label: 'AIS',
    );
    final vsItr = computeVariance(
      form26as.totalIncome,
      itr.totalIncome,
      source1Label: 'Form 26AS',
      source2Label: 'ITR',
    );
    final aisVsItr = computeVariance(
      ais.totalIncome,
      itr.totalIncome,
      source1Label: 'AIS',
      source2Label: 'ITR',
    );

    final unreported = identifyUnreportedIncome(ais, itr);
    final recommendations = _buildRecommendations(vsAis, vsItr, aisVsItr, unreported);

    return ThreeWayMatchResult(
      pan: pan,
      assessmentYear: assessmentYear,
      form26AsTotal: form26as.totalIncome,
      aisTotalIncome: ais.totalIncome,
      itrTotalIncome: itr.totalIncome,
      form26AsVsAis: vsAis,
      form26AsVsItr: vsItr,
      aisVsItr: aisVsItr,
      unreportedIncome: unreported,
      recommendations: recommendations,
    );
  }

  /// Computes the variance between two amounts and classifies the result.
  ///
  /// [thresholdPaise] controls the "matched" boundary (default ₹1,000).
  ReconciliationVariance computeVariance(
    int amount1,
    int amount2, {
    required String source1Label,
    required String source2Label,
    int thresholdPaise = _minorVarianceThresholdPaise,
  }) {
    final variance = amount1 - amount2;
    final absVariance = variance.abs();

    final percent = amount1 == 0
        ? (amount2 == 0 ? 0.0 : -100.0)
        : (variance / amount1) * 100.0;

    final status = _classifyVariance(amount1, amount2, absVariance, thresholdPaise);

    return ReconciliationVariance(
      source1Label: source1Label,
      source2Label: source2Label,
      source1Amount: amount1,
      source2Amount: amount2,
      variance: variance,
      variancePercent: percent,
      status: status,
      threshold: thresholdPaise,
    );
  }

  /// Identifies income reported in AIS that does not appear in the ITR.
  ///
  /// Amounts below ₹1,000 (100,000 paise) are ignored as they typically
  /// represent bank interest rounding differences.
  List<UnreportedIncomeItem> identifyUnreportedIncome(
    AisData ais,
    ItrFormData itr,
  ) {
    final itrSourceNames = itr.sources.map((s) => s.name.toLowerCase()).toSet();
    final result = <UnreportedIncomeItem>[];

    for (final source in ais.sources) {
      if (source.amount < _unreportedIncomeMinPaise) continue;
      final inItr = itrSourceNames.contains(source.name.toLowerCase());
      if (!inItr) {
        result.add(
          UnreportedIncomeItem(
            sourceName: source.name,
            category: 'Income',
            aisAmount: source.amount,
          ),
        );
      }
    }

    return result;
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  VarianceStatus _classifyVariance(
    int amount1,
    int amount2,
    int absVariance,
    int threshold,
  ) {
    if (amount1 == 0 && amount2 != 0) return VarianceStatus.unmatched;
    if (amount2 == 0 && amount1 != 0) return VarianceStatus.unmatched;
    if (absVariance <= threshold) return VarianceStatus.matched;
    if (absVariance <= _majorVarianceThresholdPaise) {
      return VarianceStatus.minorVariance;
    }
    return VarianceStatus.majorVariance;
  }

  List<String> _buildRecommendations(
    ReconciliationVariance vsAis,
    ReconciliationVariance vsItr,
    ReconciliationVariance aisVsItr,
    List<UnreportedIncomeItem> unreported,
  ) {
    final recs = <String>[];

    if (vsAis.status == VarianceStatus.majorVariance) {
      recs.add(
        'Large discrepancy between Form 26AS and AIS '
        '(${_formatPaise(vsAis.variance.abs())}). '
        'Verify all income entries and request correction if needed.',
      );
    } else if (vsAis.status == VarianceStatus.minorVariance) {
      recs.add(
        'Minor variance between Form 26AS and AIS '
        '(${_formatPaise(vsAis.variance.abs())}). '
        'Check for rounding differences or recently updated entries.',
      );
    }

    if (vsItr.status == VarianceStatus.majorVariance) {
      recs.add(
        'Form 26AS income differs significantly from ITR declaration '
        '(${_formatPaise(vsItr.variance.abs())}). '
        'This must be resolved before filing to avoid notices.',
      );
    } else if (vsItr.status == VarianceStatus.minorVariance) {
      recs.add(
        'Minor variance between Form 26AS and ITR '
        '(${_formatPaise(vsItr.variance.abs())}). '
        'Provide explanation in the return or revise the declared amounts.',
      );
    }

    if (aisVsItr.status == VarianceStatus.majorVariance) {
      recs.add(
        'AIS income significantly exceeds ITR declaration '
        '(${_formatPaise(aisVsItr.variance.abs())}). '
        'Risk of income-tax notice — verify and include all AIS income.',
      );
    }

    for (final item in unreported) {
      recs.add(
        'Unreported income: ₹${_rupeesFromPaise(item.aisAmount)} from '
        '"${item.sourceName}" appears in AIS but not in ITR schedules.',
      );
    }

    return recs;
  }

  String _formatPaise(int paise) => '₹${_rupeesFromPaise(paise)}';

  String _rupeesFromPaise(int paise) {
    final rupees = paise ~/ 100;
    final remainingPaise = paise % 100;
    if (remainingPaise == 0) return rupees.toString();
    return '$rupees.${remainingPaise.toString().padLeft(2, '0')}';
  }
}
