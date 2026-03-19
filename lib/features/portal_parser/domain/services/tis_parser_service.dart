import 'package:ca_app/features/portal_parser/domain/models/ais_data.dart';
import 'package:ca_app/features/portal_parser/domain/models/tis_data.dart';

// ---------------------------------------------------------------------------
// TIS Parser Service
// ---------------------------------------------------------------------------

/// Stateless service for parsing a Taxpayer Information Summary (TIS) JSON
/// payload as downloaded from the ITD e-filing portal.
///
/// ### Expected JSON shape:
/// ```json
/// {
///   "TIS": {
///     "PAN": "ABCDE1234F",
///     "AssessmentYear": "2025-26",
///     "Categories": [
///       {
///         "Category": "Salary",
///         "ReportedAmount": 700000,
///         "ComputedAmount": 700000,
///         "Feedback": "A",
///         "SourceCount": 1
///       }
///     ]
///   }
/// }
/// ```
///
/// All monetary amounts in the input are in **rupees**; converted to **paise**
/// (× 100) in the returned model.
class TisParserService {
  const TisParserService._();

  static const TisParserService instance = TisParserService._();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Parses [json] into a [TisParserData] model.
  ///
  /// Missing or malformed fields are silently defaulted so the caller always
  /// receives a valid, fully initialised model.
  TisParserData parse(Map<String, Object?> json) {
    final root = _asMap(json['TIS']) ?? json;

    final pan = _str(root['PAN']);
    final financialYear = _str(root['AssessmentYear']);

    final derivedIncomes = _parseCategories(_asList(root['Categories']));

    return TisParserData(
      pan: pan,
      financialYear: financialYear,
      derivedIncomes: derivedIncomes,
    );
  }

  /// Validates [json] for structural completeness.
  ///
  /// Returns an empty list when valid; a list of error strings otherwise.
  List<String> validate(Map<String, Object?> json) {
    final errors = <String>[];

    final root = _asMap(json['TIS']) ?? json;

    if (root.isEmpty) {
      errors.add('Payload is empty or missing "TIS" wrapper.');
      return errors;
    }

    final pan = _str(root['PAN']);
    if (pan.isEmpty) {
      errors.add('Missing or empty PAN field.');
    } else if (pan.length != 10) {
      errors.add('PAN must be exactly 10 characters; got "${pan.length}".');
    }

    final ay = _str(root['AssessmentYear']);
    if (ay.isEmpty) {
      errors.add('Missing or empty AssessmentYear field.');
    } else if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(ay)) {
      errors.add(
        'AssessmentYear must match YYYY-YY format (e.g. "2025-26"); '
        'got "$ay".',
      );
    }

    if (root['Categories'] != null && root['Categories'] is! List) {
      errors.add('"Categories" must be an array.');
    }

    return errors;
  }

  // ── Reconciliation helpers ─────────────────────────────────────────────────

  /// Reconciles [tis] derived income against [ais] reported income.
  ///
  /// For each TIS category, finds the matching AIS entries and computes
  /// the difference between TIS computed income and AIS reported income.
  ///
  /// Returns a list of [TisAisVariance] records for categories with a
  /// non-zero variance, sorted by absolute variance descending.
  List<TisAisVariance> reconcileWithAis(TisParserData tis, AisParserData ais) {
    final variances = <TisAisVariance>[];

    for (final tisEntry in tis.derivedIncomes) {
      final aisTotal = _sumAisForCategory(ais, tisEntry.category);
      final variance = tisEntry.computedAmountPaise - aisTotal;
      if (variance != 0) {
        variances.add(
          TisAisVariance(
            category: tisEntry.category,
            tisComputedPaise: tisEntry.computedAmountPaise,
            aisTotalPaise: aisTotal,
            variancePaise: variance,
          ),
        );
      }
    }

    variances.sort(
      (a, b) => b.variancePaise.abs().compareTo(a.variancePaise.abs()),
    );
    return variances;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  List<TisDerivedIncome> _parseCategories(List<Object?> rawList) {
    return rawList
        .whereType<Map<String, Object?>>()
        .map(_parseCategory)
        .toList(growable: false);
  }

  TisDerivedIncome _parseCategory(Map<String, Object?> m) {
    final reportedPaise = _toPaise(m['ReportedAmount']);
    final computedPaise = _toPaise(m['ComputedAmount']);

    return TisDerivedIncome(
      category: TisIncomeCategory.fromString(_str(m['Category'])),
      reportedAmountPaise: reportedPaise,
      computedAmountPaise: computedPaise,
      differentialPaise: reportedPaise - computedPaise,
      feedbackStatus: TisFeedbackStatus.fromCode(_str(m['Feedback'])),
      sourceCount: _toInt(m['SourceCount']),
    );
  }

  /// Sums all AIS entries for the AIS categories that correspond to a given
  /// TIS income category.
  int _sumAisForCategory(AisParserData ais, TisIncomeCategory category) {
    final entries = _aisEntriesForCategory(ais, category);
    return entries.fold(0, (sum, e) => sum + e.amountReportedPaise);
  }

  List<AisIncomeEntry> _aisEntriesForCategory(
    AisParserData ais,
    TisIncomeCategory category,
  ) {
    switch (category) {
      case TisIncomeCategory.salary:
        return ais.salaryEntries;
      case TisIncomeCategory.interest:
        return ais.interestEntries;
      case TisIncomeCategory.dividend:
        return ais.dividendEntries;
      case TisIncomeCategory.capitalGains:
        return ais.securitiesEntries;
      case TisIncomeCategory.rentalIncome:
        return ais.propertyEntries;
      case TisIncomeCategory.businessIncome:
      case TisIncomeCategory.otherSources:
        return [...ais.foreignRemittanceEntries, ...ais.otherEntries];
    }
  }

  // ── Type-safe utilities ────────────────────────────────────────────────────

  Map<String, Object?>? _asMap(Object? v) {
    if (v is Map<String, Object?>) return v;
    if (v is Map) return v.cast<String, Object?>();
    return null;
  }

  List<Object?> _asList(Object? v) {
    if (v is List<Object?>) return v;
    if (v is List) return v.cast<Object?>();
    return const [];
  }

  String _str(Object? v) {
    if (v is String) return v.trim();
    return '';
  }

  int _toPaise(Object? v) {
    if (v is int) return v * 100;
    if (v is double) return (v * 100).round();
    if (v is String) {
      final parsed = double.tryParse(v);
      if (parsed != null) return (parsed * 100).round();
    }
    return 0;
  }

  int _toInt(Object? v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

// ---------------------------------------------------------------------------
// Supporting value object
// ---------------------------------------------------------------------------

/// Variance between TIS computed income and AIS reported income for a
/// single income category.
class TisAisVariance {
  const TisAisVariance({
    required this.category,
    required this.tisComputedPaise,
    required this.aisTotalPaise,
    required this.variancePaise,
  });

  final TisIncomeCategory category;

  /// TIS computed income in paise.
  final int tisComputedPaise;

  /// Sum of matching AIS reported income in paise.
  final int aisTotalPaise;

  /// Difference: tisComputedPaise − aisTotalPaise (signed), in paise.
  final int variancePaise;

  TisAisVariance copyWith({
    TisIncomeCategory? category,
    int? tisComputedPaise,
    int? aisTotalPaise,
    int? variancePaise,
  }) {
    return TisAisVariance(
      category: category ?? this.category,
      tisComputedPaise: tisComputedPaise ?? this.tisComputedPaise,
      aisTotalPaise: aisTotalPaise ?? this.aisTotalPaise,
      variancePaise: variancePaise ?? this.variancePaise,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TisAisVariance &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          tisComputedPaise == other.tisComputedPaise &&
          aisTotalPaise == other.aisTotalPaise;

  @override
  int get hashCode => Object.hash(category, tisComputedPaise, aisTotalPaise);
}
