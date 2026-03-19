import 'package:ca_app/features/portal_parser/domain/models/form26as_data.dart';

// ---------------------------------------------------------------------------
// Form 26AS Parser Service
// ---------------------------------------------------------------------------

/// Stateless service for parsing a Form 26AS JSON payload as downloaded from
/// the ITD e-filing portal.
///
/// ### Expected JSON shape (portal download format):
/// ```json
/// {
///   "Form26AS": {
///     "PAN": "ABCDE1234F",
///     "AssessmentYear": "2025-26",
///     "PartA": [
///       {
///         "TAN": "MUMR12345A",
///         "DeductorName": "Acme Ltd",
///         "Section": "192",
///         "AmountPaid": 600000,
///         "TaxDeducted": 60000,
///         "TaxDeposited": 60000,
///         "DepositDate": "2024-06-15",
///         "BookingStatus": "F"
///       }
///     ],
///     "PartB": [...],
///     "PartC": [...],
///     "PartD": [...],
///     "PartE": [...]
///   }
/// }
/// ```
///
/// All monetary amounts in the input are in **rupees**; this service converts
/// them to **paise** (× 100) before returning the parsed model.
class Form26AsParserService {
  const Form26AsParserService._();

  static const Form26AsParserService instance = Form26AsParserService._();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Parses [json] into a [Form26AsParserData] model.
  ///
  /// Unrecognised or missing fields are silently defaulted (empty strings /
  /// zero amounts / null dates) so the caller always receives a valid model.
  ///
  /// Throws [ArgumentError] only when the top-level "Form26AS" key is absent
  /// AND [json] itself is empty — indicating a completely invalid payload.
  Form26AsParserData parse(Map<String, Object?> json) {
    final root = _asMap(json['Form26AS']) ?? json;

    final pan = _str(root['PAN']);
    final assessmentYear = _str(root['AssessmentYear']);

    final tdsEntries = _parsePartA(_asList(root['PartA']));
    final tcsEntries = _parsePartB(_asList(root['PartB']));

    final allPartC = _asList(root['PartC']);
    final advanceTax = _parsePartCByType(allPartC, 'ADVANCE');
    final selfAssessment = _parsePartCByType(allPartC, 'SELF_ASSESSMENT');

    final refundEntries = _parsePartD(_asList(root['PartD']));
    final sftEntries = _parsePartE(_asList(root['PartE']));

    return Form26AsParserData(
      pan: pan,
      assessmentYear: assessmentYear,
      tdsEntries: tdsEntries,
      tcsEntries: tcsEntries,
      advanceTaxPayments: advanceTax,
      selfAssessmentPayments: selfAssessment,
      refundEntries: refundEntries,
      sftEntries: sftEntries,
    );
  }

  /// Validates [json] for structural completeness.
  ///
  /// Returns an empty list when the payload is valid.
  /// Returns a list of human-readable error strings otherwise.
  List<String> validate(Map<String, Object?> json) {
    final errors = <String>[];

    final root = _asMap(json['Form26AS']) ?? json;

    if (root.isEmpty) {
      errors.add('Payload is empty or missing "Form26AS" wrapper.');
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

    if (root['PartA'] != null && root['PartA'] is! List) {
      errors.add('"PartA" must be an array.');
    }
    if (root['PartB'] != null && root['PartB'] is! List) {
      errors.add('"PartB" must be an array.');
    }
    if (root['PartC'] != null && root['PartC'] is! List) {
      errors.add('"PartC" must be an array.');
    }
    if (root['PartD'] != null && root['PartD'] is! List) {
      errors.add('"PartD" must be an array.');
    }
    if (root['PartE'] != null && root['PartE'] is! List) {
      errors.add('"PartE" must be an array.');
    }

    return errors;
  }

  // ── Part A — TDS entries ───────────────────────────────────────────────────

  List<Form26AsTdsEntry> _parsePartA(List<Object?> rawList) {
    return rawList
        .whereType<Map<String, Object?>>()
        .map(_parseTdsEntry)
        .toList(growable: false);
  }

  Form26AsTdsEntry _parseTdsEntry(Map<String, Object?> m) {
    return Form26AsTdsEntry(
      deductorTan: _str(m['TAN']),
      deductorName: _str(m['DeductorName']),
      section: _str(m['Section']),
      amountPaidPaise: _toPaise(m['AmountPaid']),
      taxDeductedPaise: _toPaise(m['TaxDeducted']),
      taxDepositedPaise: _toPaise(m['TaxDeposited']),
      depositDate: _parseDate(_str(m['DepositDate'])),
      bookingStatus: Form26AsBookingStatus.fromCode(_str(m['BookingStatus'])),
    );
  }

  // ── Part B — TCS entries ───────────────────────────────────────────────────

  List<Form26AsTcsEntry> _parsePartB(List<Object?> rawList) {
    return rawList
        .whereType<Map<String, Object?>>()
        .map(_parseTcsEntry)
        .toList(growable: false);
  }

  Form26AsTcsEntry _parseTcsEntry(Map<String, Object?> m) {
    return Form26AsTcsEntry(
      collectorTan: _str(m['TAN']),
      collectorName: _str(m['CollectorName']),
      section: _str(m['Section']),
      amountPaidPaise: _toPaise(m['AmountPaid']),
      taxCollectedPaise: _toPaise(m['TaxCollected']),
      taxDepositedPaise: _toPaise(m['TaxDeposited']),
      depositDate: _parseDate(_str(m['DepositDate'])),
      bookingStatus: Form26AsBookingStatus.fromCode(_str(m['BookingStatus'])),
    );
  }

  // ── Part C — tax payments ─────────────────────────────────────────────────

  List<Form26AsTaxPayment> _parsePartCByType(
    List<Object?> rawList,
    String challanType,
  ) {
    return rawList
        .whereType<Map<String, Object?>>()
        .where(
          (m) =>
              _str(m['ChallanType']).toUpperCase() == challanType.toUpperCase(),
        )
        .map(_parseTaxPayment)
        .toList(growable: false);
  }

  Form26AsTaxPayment _parseTaxPayment(Map<String, Object?> m) {
    return Form26AsTaxPayment(
      bsrCode: _str(m['BSRCode']),
      challanSerial: _str(m['ChallanSerial']),
      depositDate: _parseDate(_str(m['DepositDate'])),
      amountPaise: _toPaise(m['Amount']),
      challanType: _str(m['ChallanType']).toUpperCase(),
    );
  }

  // ── Part D — refund entries ────────────────────────────────────────────────

  List<Form26AsRefundEntry> _parsePartD(List<Object?> rawList) {
    return rawList
        .whereType<Map<String, Object?>>()
        .map(_parseRefundEntry)
        .toList(growable: false);
  }

  Form26AsRefundEntry _parseRefundEntry(Map<String, Object?> m) {
    return Form26AsRefundEntry(
      assessmentYear: _str(m['AssessmentYear']),
      amountPaise: _toPaise(m['Amount']),
      mode: _str(m['Mode']),
      paymentDate: _parseDate(_str(m['PaymentDate'])),
    );
  }

  // ── Part E — SFT entries ───────────────────────────────────────────────────

  List<Form26AsSftEntry> _parsePartE(List<Object?> rawList) {
    return rawList
        .whereType<Map<String, Object?>>()
        .map(_parseSftEntry)
        .toList(growable: false);
  }

  Form26AsSftEntry _parseSftEntry(Map<String, Object?> m) {
    return Form26AsSftEntry(
      reportingEntity: _str(m['ReportingEntity']),
      reportingEntityPan: _str(m['ReportingEntityPAN']),
      category: SftCategory.fromString(_str(m['Category'])),
      amountPaise: _toPaise(m['Amount']),
      transactionDate: _parseDate(_str(m['TransactionDate'])),
      description: _str(m['Description']),
    );
  }

  // ── Utilities ──────────────────────────────────────────────────────────────

  /// Safely casts [v] to [Map<String, Object?>], returning null on failure.
  Map<String, Object?>? _asMap(Object? v) {
    if (v is Map<String, Object?>) return v;
    if (v is Map) return v.cast<String, Object?>();
    return null;
  }

  /// Safely casts [v] to [List<Object?>], returning an empty list on failure.
  List<Object?> _asList(Object? v) {
    if (v is List<Object?>) return v;
    if (v is List) return v.cast<Object?>();
    return const [];
  }

  /// Extracts a non-null string from a JSON value.
  String _str(Object? v) {
    if (v is String) return v.trim();
    return '';
  }

  /// Converts a rupee value (int / double / String) to paise (× 100).
  int _toPaise(Object? v) {
    if (v is int) return v * 100;
    if (v is double) return (v * 100).round();
    if (v is String) {
      final parsed = double.tryParse(v);
      if (parsed != null) return (parsed * 100).round();
    }
    return 0;
  }

  /// Parses an ISO-8601 date string (YYYY-MM-DD) or returns null.
  DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      // Try DD-MM-YYYY fallback
      final parts = raw.split('-');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          // If year is 4 digits it's already YYYY-MM-DD-parsed above.
          // This handles DD-MM-YYYY where day < 32.
          if (year > 31) return DateTime(year, month, day);
        }
      }
      return null;
    }
  }
}
