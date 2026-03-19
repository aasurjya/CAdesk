import 'package:ca_app/features/portal_parser/domain/models/ais_data.dart';

// ---------------------------------------------------------------------------
// AIS Parser Service
// ---------------------------------------------------------------------------

/// Stateless service for parsing an Annual Information Statement (AIS) JSON
/// payload as downloaded from the ITD e-filing portal.
///
/// ### Expected JSON shape:
/// ```json
/// {
///   "AIS": {
///     "PAN": "ABCDE1234F",
///     "FinancialYear": "2024-25",
///     "Salary": [
///       {
///         "SourceName": "Acme Ltd",
///         "SourcePAN": "AABCE1234D",
///         "AmountReported": 600000,
///         "AmountDerived": 600000,
///         "Feedback": "A",
///         "TransactionId": "TXN001"
///       }
///     ],
///     "Interest": [...],
///     "Dividend": [...],
///     "Securities": [...],
///     "Property": [...],
///     "ForeignRemittance": [...],
///     "Other": [...]
///   }
/// }
/// ```
///
/// All monetary amounts in the input are in **rupees**; converted to **paise**
/// (× 100) in the returned model.
class AisParserService {
  const AisParserService._();

  static const AisParserService instance = AisParserService._();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Parses [json] into an [AisParserData] model.
  ///
  /// Missing or malformed fields are silently defaulted so the caller always
  /// receives a valid, fully initialised model.
  AisParserData parse(Map<String, Object?> json) {
    final root = _asMap(json['AIS']) ?? json;

    final pan = _str(root['PAN']);
    final financialYear = _str(root['FinancialYear']);

    return AisParserData(
      pan: pan,
      financialYear: financialYear,
      salaryEntries: _parseEntries(
        _asList(root['Salary']),
        AisIncomeCategory.salary,
      ),
      interestEntries: _parseInterestEntries(root),
      dividendEntries: _parseEntries(
        _asList(root['Dividend']),
        AisIncomeCategory.dividend,
      ),
      securitiesEntries: _parseEntries(
        _asList(root['Securities']),
        AisIncomeCategory.securitiesTransaction,
      ),
      propertyEntries: _parseEntries(
        _asList(root['Property']),
        AisIncomeCategory.propertyTransaction,
      ),
      foreignRemittanceEntries: _parseEntries(
        _asList(root['ForeignRemittance']),
        AisIncomeCategory.foreignRemittance,
      ),
      otherEntries: _parseEntries(
        _asList(root['Other']),
        AisIncomeCategory.other,
      ),
    );
  }

  /// Validates [json] for structural completeness.
  ///
  /// Returns an empty list when valid; a list of error strings otherwise.
  List<String> validate(Map<String, Object?> json) {
    final errors = <String>[];

    final root = _asMap(json['AIS']) ?? json;

    if (root.isEmpty) {
      errors.add('Payload is empty or missing "AIS" wrapper.');
      return errors;
    }

    final pan = _str(root['PAN']);
    if (pan.isEmpty) {
      errors.add('Missing or empty PAN field.');
    } else if (pan.length != 10) {
      errors.add('PAN must be exactly 10 characters; got "${pan.length}".');
    }

    final fy = _str(root['FinancialYear']);
    if (fy.isEmpty) {
      errors.add('Missing or empty FinancialYear field.');
    } else if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(fy)) {
      errors.add(
        'FinancialYear must match YYYY-YY format (e.g. "2024-25"); '
        'got "$fy".',
      );
    }

    const arrayFields = [
      'Salary',
      'Interest',
      'Dividend',
      'Securities',
      'Property',
      'ForeignRemittance',
      'Other',
    ];
    for (final field in arrayFields) {
      if (root[field] != null && root[field] is! List) {
        errors.add('"$field" must be an array.');
      }
    }

    return errors;
  }

  // ── Mismatch detection ─────────────────────────────────────────────────────

  /// Detects entries where the reported and derived amounts differ.
  ///
  /// Returns only entries with a non-zero difference between
  /// [AisIncomeEntry.amountReportedPaise] and
  /// [AisIncomeEntry.amountDerivedPaise].
  List<AisIncomeEntry> findMismatches(AisParserData data) {
    return data.allEntries
        .where((e) => e.amountReportedPaise != e.amountDerivedPaise)
        .toList(growable: false);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Parses interest entries from both "Interest" and sub-keys
  /// "InterestSavings" / "InterestFD" — the portal uses different keys
  /// depending on the export version.
  List<AisIncomeEntry> _parseInterestEntries(Map<String, Object?> root) {
    // Prefer the unified "Interest" key; fall back to merged sub-keys.
    final unified = _asList(root['Interest']);
    if (unified.isNotEmpty) {
      return _parseEntries(unified, AisIncomeCategory.interestOther);
    }

    final savings = _parseEntries(
      _asList(root['InterestSavings']),
      AisIncomeCategory.interestSavings,
    );
    final fd = _parseEntries(
      _asList(root['InterestFD']),
      AisIncomeCategory.interestFd,
    );
    return [...savings, ...fd];
  }

  List<AisIncomeEntry> _parseEntries(
    List<Object?> rawList,
    AisIncomeCategory defaultCategory,
  ) {
    return rawList
        .whereType<Map<String, Object?>>()
        .map((m) => _parseEntry(m, defaultCategory))
        .toList(growable: false);
  }

  AisIncomeEntry _parseEntry(
    Map<String, Object?> m,
    AisIncomeCategory defaultCategory,
  ) {
    // Allow an explicit "Category" key to override the default.
    final categoryStr = _str(m['Category']);
    final category = categoryStr.isEmpty
        ? defaultCategory
        : AisIncomeCategory.fromString(categoryStr);

    return AisIncomeEntry(
      category: category,
      sourceName: _str(m['SourceName']),
      sourcePan: _str(m['SourcePAN']),
      amountReportedPaise: _toPaise(m['AmountReported']),
      amountDerivedPaise: _toPaise(m['AmountDerived']),
      feedback: AisEntryFeedback.fromCode(_str(m['Feedback'])),
      transactionId: _str(m['TransactionId']),
    );
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
}
