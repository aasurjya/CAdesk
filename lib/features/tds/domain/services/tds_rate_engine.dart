import 'package:ca_app/features/tds/domain/models/tds_section_rate.dart';
import 'package:ca_app/features/tds/domain/services/tds_rate_data.dart';

/// Static service for TDS rate lookups and computation.
///
/// All methods are static. No instance creation is allowed.
class TdsRateEngine {
  TdsRateEngine._();

  /// Returns all TDS sections for the given financial year.
  static List<TdsSectionRate> getAllSections({
    String financialYear = '2025-26',
  }) {
    return _ratesForYear(financialYear);
  }

  /// Returns the applicable TDS rate (%) for a section + deductee combination.
  ///
  /// Returns 0 if the section is not found.
  static double getRate({
    required String section,
    required DeducteeType deducteeType,
    required bool hasPan,
    String financialYear = '2025-26',
  }) {
    final sectionRate = getSection(section, financialYear: financialYear);
    if (sectionRate == null) return 0.0;

    if (!hasPan) return sectionRate.rateNoPan;

    return _isIndividualOrHuf(deducteeType)
        ? sectionRate.rateIndividualHuf
        : sectionRate.rateOthers;
  }

  /// Returns a single section by code, or `null` if not found.
  static TdsSectionRate? getSection(
    String sectionCode, {
    String financialYear = '2025-26',
  }) {
    final rates = _ratesForYear(financialYear);
    for (final rate in rates) {
      if (rate.section == sectionCode) return rate;
    }
    return null;
  }

  /// Searches sections by description or section code (case-insensitive).
  static List<TdsSectionRate> searchSections(
    String query, {
    String financialYear = '2025-26',
  }) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final rates = _ratesForYear(financialYear);

    return rates
        .where(
          (r) =>
              r.section.toLowerCase().contains(lowerQuery) ||
              r.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Returns `true` if the given amount exceeds the applicable threshold.
  ///
  /// When [isAggregate] is true, checks against the aggregate threshold;
  /// otherwise checks the single-transaction threshold.
  ///
  /// Returns `false` for unknown sections.
  static bool isThresholdExceeded({
    required String section,
    required double amount,
    bool isAggregate = false,
    String financialYear = '2025-26',
  }) {
    final sectionRate = getSection(section, financialYear: financialYear);
    if (sectionRate == null) return false;

    final threshold = isAggregate
        ? sectionRate.thresholdAggregate
        : sectionRate.thresholdSingle;

    // Zero threshold means TDS applies from the first rupee.
    if (threshold == 0) return true;

    return amount > threshold;
  }

  /// Computes TDS for a payment.
  ///
  /// - For section 195 (NRI payments), adds 4% Health & Education Cess.
  /// - For all other domestic sections, surcharge and cess are 0.
  /// - If the amount is below the single-transaction threshold, returns
  ///   zero TDS with [TdsComputationResult.thresholdApplied] set to `true`.
  static TdsComputationResult computeTds({
    required String section,
    required double amount,
    required DeducteeType deducteeType,
    required bool hasPan,
    String financialYear = '2025-26',
  }) {
    final sectionRate = getSection(section, financialYear: financialYear);

    if (sectionRate == null) {
      return TdsComputationResult(
        section: section,
        grossAmount: amount,
        tdsRate: 0,
        tdsAmount: 0,
        surcharge: 0,
        educationCess: 0,
        totalTds: 0,
        thresholdApplied: false,
      );
    }

    // Check single-transaction threshold.
    final singleThreshold = sectionRate.thresholdSingle;
    if (singleThreshold > 0 && amount <= singleThreshold) {
      final rate = _applicableRate(sectionRate, deducteeType, hasPan);
      return TdsComputationResult(
        section: section,
        grossAmount: amount,
        tdsRate: rate,
        tdsAmount: 0,
        surcharge: 0,
        educationCess: 0,
        totalTds: 0,
        thresholdApplied: true,
      );
    }

    final rate = _applicableRate(sectionRate, deducteeType, hasPan);
    final tdsAmount = amount * rate / 100;

    // NRI payments (section 195) attract Health & Education Cess at 4%.
    final isNri = section == '195';
    final surcharge = 0.0;
    final cess = isNri ? tdsAmount * 0.04 : 0.0;
    final totalTds = tdsAmount + surcharge + cess;

    return TdsComputationResult(
      section: section,
      grossAmount: amount,
      tdsRate: rate,
      tdsAmount: tdsAmount,
      surcharge: surcharge,
      educationCess: cess,
      totalTds: totalTds,
      thresholdApplied: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static List<TdsSectionRate> _ratesForYear(String financialYear) {
    // Currently only FY 2025-26 is available.
    if (financialYear == '2025-26') return TdsRateData.fy202526;
    return [];
  }

  static bool _isIndividualOrHuf(DeducteeType type) {
    return type == DeducteeType.individual || type == DeducteeType.huf;
  }

  static double _applicableRate(
    TdsSectionRate sectionRate,
    DeducteeType deducteeType,
    bool hasPan,
  ) {
    if (!hasPan) return sectionRate.rateNoPan;
    return _isIndividualOrHuf(deducteeType)
        ? sectionRate.rateIndividualHuf
        : sectionRate.rateOthers;
  }
}
