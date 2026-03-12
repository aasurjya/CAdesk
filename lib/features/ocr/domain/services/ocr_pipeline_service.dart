import 'package:ca_app/features/ocr/domain/models/extracted_bank_statement.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_form16.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_invoice.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_line_item.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_transaction.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_document.dart';

/// Stateless singleton that orchestrates regex-based structured extraction
/// from raw OCR text for Indian CA documents.
class OcrPipelineService {
  OcrPipelineService._();

  static final OcrPipelineService instance = OcrPipelineService._();

  // -------------------------------------------------------------------------
  // Regexes — pre-compiled for efficiency
  // -------------------------------------------------------------------------

  static final _panRegex = RegExp(r'[A-Z]{5}[0-9]{4}[A-Z]');

  /// TAN: 5 letters + 4 digits + 1 letter = 10 chars (e.g. "AAATA1234X").
  static final _tanRegex = RegExp(r'[A-Z]{5}[0-9]{4}[A-Z]');
  static final _gstinRegex =
      RegExp(r'\d{2}[A-Z]{5}\d{4}[A-Z][A-Z\d]Z[A-Z\d]');

  // Form 16 extraction patterns
  static final _employerNameRegex =
      RegExp(r'(?:Name and address of the Employer|Employer):\s*(.+)', caseSensitive: false);
  static final _ayRegex =
      RegExp(r'Assessment Year:\s*(\d{4}-\d{2})', caseSensitive: false);
  static final _grossSalaryRegex =
      RegExp(r'Gross Salary:\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);
  static final _standardDeductionRegex =
      RegExp(r'Standard Deduction:\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);
  static final _taxableSalaryRegex =
      RegExp(r'Taxable (?:Salary|Income):\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);
  static final _taxDeductedRegex =
      RegExp(r'Tax Deducted:\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);

  // Bank statement patterns
  static final _accountNumberRegex =
      RegExp(r'Account Number:\s*([A-Z0-9X]+)', caseSensitive: false);
  static final _ifscRegex =
      RegExp(r'IFSC:\s*([A-Z]{4}[0-9]{7})', caseSensitive: false);
  static final _openingBalanceRegex =
      RegExp(r'Opening Balance:\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);
  static final _closingBalanceRegex =
      RegExp(r'Closing Balance:\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);

  // Bank transaction line: date  description  debit?  credit?  balance
  // Pattern matches lines starting with a date in DD-MM-YYYY format.
  // We parse the trailing numbers to determine debit/credit/balance.
  static final _txLineRegex = RegExp(
    r'^(\d{2}-\d{2}-\d{4})\s+(.+?)\s{2,}([\d,]+\.\d{2})?(?:\s{2,}([\d,]+\.\d{2}))?\s{2,}([\d,]+\.\d{2})\s*$',
  );

  // Invoice patterns
  static final _invoiceNumberRegex =
      RegExp(r'Invoice No(?:\.)?:\s*([^\n]+)', caseSensitive: false);
  static final _invoiceDateRegex =
      RegExp(r'Invoice Date:\s*(\d{2}-\d{2}-\d{4})', caseSensitive: false);
  static final _sellerNameRegex =
      RegExp(r'Seller:\s*(.+)', caseSensitive: false);
  static final _buyerNameRegex =
      RegExp(r'Buyer:\s*(.+)', caseSensitive: false);
  static final _totalAmountRegex =
      RegExp(r'Total Amount:\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);
  static final _gstAmountRegex =
      RegExp(r'GST Amount:\s*([\d,]+(?:\.\d+)?)', caseSensitive: false);
  static final _hsnCodeRegex =
      RegExp(r'HSN:\s*(\w+)', caseSensitive: false);

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Detects the [DocumentType] from raw OCR text using keyword matching.
  DocumentType detectDocumentType(String rawText) {
    final upper = rawText.toUpperCase();

    if (upper.contains('FORM NO. 16') ||
        upper.contains('FORM 16') && upper.contains('TAN')) {
      return DocumentType.form16;
    }
    if (upper.contains('FORM 26AS') || upper.contains('TAX CREDIT STATEMENT')) {
      return DocumentType.form26as;
    }
    if (upper.contains('STATEMENT OF ACCOUNT')) {
      return DocumentType.bankStatement;
    }
    if (upper.contains('TAX INVOICE') ||
        upper.contains('GST INVOICE') ||
        upper.contains('INVOICE')) {
      return DocumentType.invoice;
    }
    return DocumentType.invoice;
  }

  /// Extracts structured [ExtractedForm16] data from raw Form 16 text.
  static final _tanLabelRegex =
      RegExp(r'TAN(?:\sof\sDeductor)?:\s*([A-Z]{5}[0-9]{4}[A-Z])',
          caseSensitive: false);

  ExtractedForm16 extractForm16(String rawText) {
    final pans = _panRegex.allMatches(rawText).map((m) => m.group(0)!).toList();

    // First PAN that appears after "Employee" label, else first PAN found
    final employeePan = _findEmployeePan(rawText, pans);

    // TAN appears explicitly after "TAN:" label
    final employerTan =
        _tanLabelRegex.firstMatch(rawText)?.group(1)?.trim() ?? '';

    final employerName =
        _employerNameRegex.firstMatch(rawText)?.group(1)?.trim() ?? '';
    final assessmentYear =
        _ayRegex.firstMatch(rawText)?.group(1)?.trim() ?? '';

    final grossSalary = _parseAmount(_grossSalaryRegex, rawText);
    final standardDeduction = _parseAmount(_standardDeductionRegex, rawText);
    final taxableIncome = _parseAmount(_taxableSalaryRegex, rawText);
    final tdsDeducted = _parseAmount(_taxDeductedRegex, rawText);

    // Derive financial year from assessment year (e.g. "2024-25" → 2024)
    final financialYear = _parseFinancialYear(assessmentYear);

    final confidence = _computeForm16Confidence(
      employeePan: employeePan,
      employerTan: employerTan,
      grossSalary: grossSalary,
      tdsDeducted: tdsDeducted,
    );

    return ExtractedForm16(
      employeePan: employeePan,
      employerTan: employerTan,
      employerName: employerName,
      financialYear: financialYear,
      assessmentYear: assessmentYear,
      grossSalary: grossSalary,
      taxableIncome: taxableIncome,
      tdsDeducted: tdsDeducted,
      professionalTax: 0,
      standardDeduction: standardDeduction,
      confidence: confidence,
    );
  }

  /// Extracts structured [ExtractedBankStatement] from raw bank statement text.
  ExtractedBankStatement extractBankStatement(String rawText) {
    final accountNumber =
        _accountNumberRegex.firstMatch(rawText)?.group(1)?.trim() ?? '';
    final ifscCode = _ifscRegex.firstMatch(rawText)?.group(1)?.trim() ?? '';
    final openingBalance = _parseAmount(_openingBalanceRegex, rawText);
    final closingBalance = _parseAmount(_closingBalanceRegex, rawText);

    final transactions = _parseTransactions(rawText);

    return ExtractedBankStatement(
      accountNumber: accountNumber,
      bankName: _inferBankName(ifscCode),
      ifscCode: ifscCode,
      period: '',
      openingBalance: openingBalance,
      closingBalance: closingBalance,
      transactions: transactions,
    );
  }

  /// Extracts structured [ExtractedInvoice] from raw invoice text.
  ExtractedInvoice extractInvoice(String rawText) {
    final invoiceNumber =
        _invoiceNumberRegex.firstMatch(rawText)?.group(1)?.trim() ?? '';

    DateTime? invoiceDate;
    final dateMatch = _invoiceDateRegex.firstMatch(rawText);
    if (dateMatch != null) {
      invoiceDate = _parseDdMmYyyy(dateMatch.group(1)!);
    }

    final sellerName =
        _sellerNameRegex.firstMatch(rawText)?.group(1)?.trim() ?? '';
    final buyerName =
        _buyerNameRegex.firstMatch(rawText)?.group(1)?.trim() ?? '';

    // Extract GSTINs: all matches, then associate by context
    final gstins =
        _gstinRegex.allMatches(rawText).map((m) => m.group(0)!).toList();
    final sellerGstin = gstins.isNotEmpty ? gstins[0] : null;
    final buyerGstin = gstins.length > 1 ? gstins[1] : null;

    final totalAmount = _parseAmount(_totalAmountRegex, rawText);
    final gstAmount = _parseAmount(_gstAmountRegex, rawText);
    final hsnCode = _hsnCodeRegex.firstMatch(rawText)?.group(1)?.trim();

    return ExtractedInvoice(
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      sellerName: sellerName,
      sellerGstin: sellerGstin,
      buyerName: buyerName,
      buyerGstin: buyerGstin,
      lineItems: const [],
      totalAmount: totalAmount,
      gstAmount: gstAmount,
      hsnCode: hsnCode,
    );
  }

  /// Computes an overall confidence score for the extracted data.
  ///
  /// Penalises missing mandatory fields, invalid formats, and inconsistent
  /// amounts. Result is clamped to [0.0, 1.0].
  double computeConfidence(OcrDocument doc, Object extractedData) {
    var score = doc.confidence;

    if (extractedData is ExtractedForm16) {
      score = _penaliseForm16(score, extractedData);
    } else if (extractedData is ExtractedBankStatement) {
      score = _penaliseBankStatement(score, extractedData);
    } else if (extractedData is ExtractedInvoice) {
      score = _penaliseInvoice(score, extractedData);
    }

    return score.clamp(0.0, 1.0);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  String _findEmployeePan(String rawText, List<String> pans) {
    // Look for PAN immediately after "PAN of Employee" label
    final empPanMatch =
        RegExp(r'PAN of Employee:\s*([A-Z]{5}[0-9]{4}[A-Z])')
            .firstMatch(rawText);
    if (empPanMatch != null) return empPanMatch.group(1)!;
    // Otherwise return the last PAN found (employee typically listed last)
    return pans.isNotEmpty ? pans.last : '';
  }

  /// Parses an INR amount from regex match and converts to paise.
  int _parseAmount(RegExp regex, String text) {
    final match = regex.firstMatch(text);
    if (match == null) return 0;
    final raw = match.group(1)!.replaceAll(',', '');
    final value = double.tryParse(raw) ?? 0.0;
    return (value * 100).round();
  }

  /// Parses financial year integer from assessment year string.
  int _parseFinancialYear(String assessmentYear) {
    // "2024-25" → first 4 digits = 2024
    final match = RegExp(r'(\d{4})').firstMatch(assessmentYear);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  double _computeForm16Confidence({
    required String employeePan,
    required String employerTan,
    required int grossSalary,
    required int tdsDeducted,
  }) {
    var score = 1.0;
    if (employeePan.isEmpty) score -= 0.2;
    if (employerTan.isEmpty) score -= 0.15;
    if (grossSalary == 0) score -= 0.15;
    if (tdsDeducted == 0) score -= 0.05;
    return score.clamp(0.0, 1.0);
  }

  double _penaliseForm16(double base, ExtractedForm16 data) {
    var score = base;
    if (data.employeePan.isEmpty || !_panRegex.hasMatch(data.employeePan)) {
      score -= 0.15;
    }
    if (data.employerTan.isEmpty) {
      score -= 0.1;
    }
    if (data.grossSalary == 0) score -= 0.1;
    return score;
  }

  double _penaliseBankStatement(double base, ExtractedBankStatement data) {
    var score = base;
    if (data.accountNumber.isEmpty) score -= 0.15;
    if (data.ifscCode.isEmpty) score -= 0.1;
    if (data.transactions.isEmpty) score -= 0.1;
    return score;
  }

  double _penaliseInvoice(double base, ExtractedInvoice data) {
    var score = base;
    if (data.invoiceNumber.isEmpty) score -= 0.15;
    if (data.totalAmount == 0) score -= 0.1;
    return score;
  }

  String _inferBankName(String ifscCode) {
    if (ifscCode.length < 4) return '';
    final prefix = ifscCode.substring(0, 4).toUpperCase();
    const bankMap = {
      'SBIN': 'SBI',
      'HDFC': 'HDFC Bank',
      'ICIC': 'ICICI Bank',
      'UTIB': 'Axis Bank',
      'KKBK': 'Kotak Mahindra Bank',
      'PUNB': 'Punjab National Bank',
      'BARB': 'Bank of Baroda',
      'CNRB': 'Canara Bank',
      'UBIN': 'Union Bank of India',
    };
    return bankMap[prefix] ?? prefix;
  }

  List<ExtractedTransaction> _parseTransactions(String rawText) {
    final transactions = <ExtractedTransaction>[];

    for (final line in rawText.split('\n')) {
      final match = _txLineRegex.firstMatch(line.trim());
      if (match == null) continue;

      final date = _parseDdMmYyyy(match.group(1)!);
      if (date == null) continue;

      final description = match.group(2)?.trim() ?? '';
      final debitStr = match.group(3);
      final creditStr = match.group(4);
      final balanceStr = match.group(5) ?? '0';

      final debit = debitStr != null
          ? (double.tryParse(debitStr.replaceAll(',', '')) ?? 0.0) * 100
          : 0.0;
      final credit = creditStr != null
          ? (double.tryParse(creditStr.replaceAll(',', '')) ?? 0.0) * 100
          : 0.0;
      final balance =
          (double.tryParse(balanceStr.replaceAll(',', '')) ?? 0.0) * 100;

      transactions.add(
        ExtractedTransaction(
          date: date,
          description: description,
          debit: debit.round(),
          credit: credit.round(),
          balance: balance.round(),
          referenceNumber: null,
        ),
      );
    }

    return transactions;
  }

  DateTime? _parseDdMmYyyy(String dateStr) {
    // Expected format: "DD-MM-YYYY"
    final parts = dateStr.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }
}

/// Convenience extension used internally by mapper service.
extension ExtractedLineItemList on List<ExtractedLineItem> {
  int get totalAmount => fold(0, (sum, item) => sum + item.amount);
}
