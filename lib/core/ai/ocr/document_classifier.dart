// ---------------------------------------------------------------------------
// DocumentType enum
// ---------------------------------------------------------------------------

/// The recognised types of Indian tax and financial documents.
enum DocumentType {
  /// Form 16 / Form 16A – TDS certificate from employer.
  form16,

  /// Form 26AS – Annual Information Statement / Tax Credit Statement.
  form26as,

  /// GST invoice (B2B or B2C).
  gstInvoice,

  /// Bank statement (any format).
  bankStatement,

  /// PAN card image.
  panCard,

  /// Aadhaar card image.
  aadhaarCard,

  /// Balance sheet / profit & loss statement.
  balanceSheet,

  /// Salary slip / payslip.
  salarySlip,

  /// Could not be classified with reasonable confidence.
  unknown,
}

// ---------------------------------------------------------------------------
// Keyword catalogue
// ---------------------------------------------------------------------------

/// Maps each [DocumentType] to a list of distinguishing keyword patterns.
///
/// Order matters — the classifier tallies matches and picks the highest-score
/// type. Add more patterns to increase recall.
const Map<DocumentType, List<String>> _keywords = {
  DocumentType.form16: [
    'form 16',
    'form no. 16',
    'tds certificate',
    'certificate of tax deducted',
    'part a',
    'part b',
    'salary income',
    'employer tan',
    'challan identification number',
    'income from salaries',
  ],
  DocumentType.form26as: [
    'form 26as',
    'annual tax statement',
    'annual information statement',
    'tax credit statement',
    'traces',
    'tds/tcs credit',
    'part a – details of tax deducted',
    'part c – details of tax paid',
    'assessment year',
    'status of filing',
  ],
  DocumentType.gstInvoice: [
    'gstin',
    'goods and services tax',
    'tax invoice',
    'gst invoice',
    'igst',
    'cgst',
    'sgst',
    'place of supply',
    'hsn',
    'sac',
    'e-way bill',
  ],
  DocumentType.bankStatement: [
    'account statement',
    'statement of account',
    'account number',
    'ifsc',
    'balance',
    'credit',
    'debit',
    'transaction date',
    'closing balance',
    'opening balance',
  ],
  DocumentType.panCard: [
    'permanent account number',
    'income tax department',
    'govt. of india',
    'date of birth',
    'father',
    'name',
    // PAN regex will supplement keyword matching
  ],
  DocumentType.aadhaarCard: [
    'aadhaar',
    'aadhar',
    'unique identification',
    'uidai',
    'enrolment no',
    'your aadhaar',
    'government of india',
  ],
  DocumentType.balanceSheet: [
    'balance sheet',
    'profit & loss',
    'profit and loss',
    'income statement',
    'equity',
    'liabilities',
    'assets',
    'retained earnings',
    'shareholders',
    'audited',
  ],
  DocumentType.salarySlip: [
    'salary slip',
    'pay slip',
    'payslip',
    'pay stub',
    'basic salary',
    'hra',
    'house rent allowance',
    'gross salary',
    'net salary',
    'pf',
    'professional tax',
    'employee id',
  ],
};

// ---------------------------------------------------------------------------
// Primary ID extraction patterns
// ---------------------------------------------------------------------------

/// RegExp to extract PAN (format: AAAAA9999A).
final RegExp _panRegex = RegExp(r'\b[A-Z]{5}[0-9]{4}[A-Z]\b');

/// RegExp to extract GSTIN (format: 99AAAAA9999A9Z9).
final RegExp _gstinRegex = RegExp(
  r'\b[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9A-Z]Z[0-9A-Z]\b',
);

/// RegExp to extract TAN (format: AAAA99999A).
final RegExp _tanRegex = RegExp(r'\b[A-Z]{4}[0-9]{5}[A-Z]\b');

// ---------------------------------------------------------------------------
// DocumentClassifier
// ---------------------------------------------------------------------------

/// Classifies Indian tax and financial documents from OCR-extracted text.
///
/// This is a pure-Dart domain service with no Flutter/platform dependencies.
///
/// Usage:
/// ```dart
/// final classifier = DocumentClassifier();
/// final type = classifier.classify(ocrText);
/// final pan = classifier.extractPrimaryId(ocrText, DocumentType.panCard);
/// ```
class DocumentClassifier {
  const DocumentClassifier({this.minScore = 2});

  /// Minimum total keyword matches required to classify with confidence.
  /// Below this threshold the result is [DocumentType.unknown].
  final int minScore;

  // ---------------------------------------------------------------------------
  // classify
  // ---------------------------------------------------------------------------

  /// Classifies [textSample] against the keyword catalogue.
  ///
  /// Returns [DocumentType.unknown] when confidence is below [minScore] or
  /// when the text is empty.
  DocumentType classify(String textSample) {
    if (textSample.trim().isEmpty) return DocumentType.unknown;

    final normalised = textSample.toLowerCase();
    var bestType = DocumentType.unknown;
    var bestScore = 0;

    for (final entry in _keywords.entries) {
      var score = 0;
      for (final keyword in entry.value) {
        if (normalised.contains(keyword.toLowerCase())) {
          score++;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestType = entry.key;
      }
    }

    if (bestScore < minScore) return DocumentType.unknown;
    return bestType;
  }

  // ---------------------------------------------------------------------------
  // extractPrimaryId
  // ---------------------------------------------------------------------------

  /// Extracts the primary identifier appropriate for [type] from [text].
  ///
  /// | DocumentType  | Extracted ID |
  /// |---------------|--------------|
  /// | form16        | PAN          |
  /// | form26as      | PAN          |
  /// | gstInvoice    | GSTIN        |
  /// | panCard       | PAN          |
  /// | salarySlip    | PAN          |
  /// | bankStatement | Account No. (first 8–18 digit sequence) |
  /// | balanceSheet  | PAN          |
  /// | tracesAuth    | TAN          |
  /// | aadhaarCard   | Aadhaar No.  |
  ///
  /// Returns `null` when no matching identifier is found in [text].
  String? extractPrimaryId(String text, DocumentType type) {
    if (text.trim().isEmpty) return null;

    switch (type) {
      case DocumentType.form16:
      case DocumentType.form26as:
      case DocumentType.panCard:
      case DocumentType.balanceSheet:
      case DocumentType.salarySlip:
        return _panRegex.firstMatch(text)?.group(0);

      case DocumentType.gstInvoice:
        return _gstinRegex.firstMatch(text)?.group(0);

      case DocumentType.bankStatement:
        // Extract first plausible account number: 8-18 contiguous digits.
        final acctRegex = RegExp(r'\b[0-9]{8,18}\b');
        return acctRegex.firstMatch(text)?.group(0);

      case DocumentType.aadhaarCard:
        // Aadhaar: 12 digits, often spaced as XXXX XXXX XXXX.
        final aadhaarRegex = RegExp(r'\b[0-9]{4}\s?[0-9]{4}\s?[0-9]{4}\b');
        final match = aadhaarRegex.firstMatch(text);
        return match?.group(0)?.replaceAll(' ', '');

      case DocumentType.unknown:
        // Try PAN first, then GSTIN, then TAN.
        return _panRegex.firstMatch(text)?.group(0) ??
            _gstinRegex.firstMatch(text)?.group(0) ??
            _tanRegex.firstMatch(text)?.group(0);
    }
  }

  // ---------------------------------------------------------------------------
  // extractAllIds
  // ---------------------------------------------------------------------------

  /// Extracts all recognisable identifiers from [text] as a map.
  ///
  /// Keys: `'pan'`, `'gstin'`, `'tan'`.
  Map<String, String> extractAllIds(String text) {
    final result = <String, String>{};

    final pan = _panRegex.firstMatch(text)?.group(0);
    if (pan != null) result['pan'] = pan;

    final gstin = _gstinRegex.firstMatch(text)?.group(0);
    if (gstin != null) result['gstin'] = gstin;

    final tan = _tanRegex.firstMatch(text)?.group(0);
    if (tan != null) result['tan'] = tan;

    return Map.unmodifiable(result);
  }
}
