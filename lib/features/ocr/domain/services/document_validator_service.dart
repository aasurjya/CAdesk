import 'package:ca_app/features/ocr/domain/models/extracted_bank_statement.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_form16.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_invoice.dart';

/// Stateless singleton that validates extracted OCR data for Indian CA documents.
///
/// Returns a list of human-readable error strings. An empty list indicates
/// validation passed.
class DocumentValidatorService {
  DocumentValidatorService._();

  static final DocumentValidatorService instance = DocumentValidatorService._();

  // -------------------------------------------------------------------------
  // Format validators
  // -------------------------------------------------------------------------

  static final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  /// TAN format: 4 letters (city/state code) + 1 letter + 4 digits + 1 letter
  /// = 10 characters total, e.g. "AAATA1234X".
  static final _tanRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  /// GSTIN format (15 chars): 2-digit state code + PAN (10) + entity number +
  /// 'Z' (default) + check digit.
  /// We validate length and basic alphanumeric structure.
  static final _gstinRegex = RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]\d[A-Z]\d$');

  /// Taxable income threshold above which TDS is mandatory (250000 INR in paise).
  static const int _tdsThresholdPaise = 25000000;

  /// Tolerance for balance continuity check (100 paise = ₹1).
  static const int _balanceTolerance = 100;

  // -------------------------------------------------------------------------
  // validateForm16
  // -------------------------------------------------------------------------

  /// Validates [ExtractedForm16] and returns a list of error messages.
  List<String> validateForm16(ExtractedForm16 data) {
    final errors = <String>[];

    if (data.employeePan.isEmpty || !_panRegex.hasMatch(data.employeePan)) {
      errors.add(
        'Invalid PAN format: "${data.employeePan}". '
        'Expected 5 letters, 4 digits, 1 letter (e.g. ABCDE1234F).',
      );
    }

    if (data.employerTan.isEmpty || !_tanRegex.hasMatch(data.employerTan)) {
      errors.add(
        'Invalid TAN format: "${data.employerTan}". '
        'Expected 4 letters, 5 digits, 1 letter (e.g. AAATA1234X).',
      );
    }

    if (data.taxableIncome > _tdsThresholdPaise && data.tdsDeducted == 0) {
      final taxableInr = data.taxableIncome ~/ 100;
      errors.add(
        'TDS deducted is zero but taxable income is ₹$taxableInr '
        '(above ₹2,50,000 threshold). TDS deduction is mandatory.',
      );
    }

    return List.unmodifiable(errors);
  }

  // -------------------------------------------------------------------------
  // validateBankStatement
  // -------------------------------------------------------------------------

  /// Validates [ExtractedBankStatement] for balance continuity and closing
  /// balance consistency.
  List<String> validateBankStatement(ExtractedBankStatement stmt) {
    final errors = <String>[];

    var runningBalance = stmt.openingBalance;
    for (var i = 0; i < stmt.transactions.length; i++) {
      final tx = stmt.transactions[i];
      final expectedBalance = runningBalance + tx.credit - tx.debit;
      final diff = (tx.balance - expectedBalance).abs();
      if (diff > _balanceTolerance) {
        errors.add(
          'Balance continuity failure at transaction ${i + 1} '
          '("${tx.description}"): '
          'expected ${_paise(expectedBalance)}, '
          'found ${_paise(tx.balance)} '
          '(diff: ${_paise(diff)}).',
        );
      }
      runningBalance = tx.balance;
    }

    // Check that closing balance matches the last running balance
    final lastBalance = stmt.transactions.isNotEmpty
        ? stmt.transactions.last.balance
        : stmt.openingBalance;
    final closingDiff = (stmt.closingBalance - lastBalance).abs();
    if (closingDiff > _balanceTolerance) {
      errors.add(
        'Closing balance mismatch: statement closing is '
        '${_paise(stmt.closingBalance)}, '
        'but last transaction balance is ${_paise(lastBalance)} '
        '(diff: ${_paise(closingDiff)}).',
      );
    }

    return List.unmodifiable(errors);
  }

  // -------------------------------------------------------------------------
  // validateInvoice
  // -------------------------------------------------------------------------

  /// Validates [ExtractedInvoice] for GSTIN format and amount consistency.
  List<String> validateInvoice(ExtractedInvoice invoice) {
    final errors = <String>[];

    final sellerGstin = invoice.sellerGstin;
    if (sellerGstin != null &&
        sellerGstin.isNotEmpty &&
        !_gstinRegex.hasMatch(sellerGstin)) {
      errors.add(
        'Invalid seller GSTIN format: "$sellerGstin". '
        'Expected 15-character GST registration number.',
      );
    }

    final buyerGstin = invoice.buyerGstin;
    if (buyerGstin != null &&
        buyerGstin.isNotEmpty &&
        !_gstinRegex.hasMatch(buyerGstin)) {
      errors.add(
        'Invalid buyer GSTIN format: "$buyerGstin". '
        'Expected 15-character GST registration number.',
      );
    }

    // Verify total = sum of line items + GST
    final lineItemTotal = invoice.lineItems.fold(
      0,
      (int sum, item) => sum + item.amount,
    );
    final expectedTotal = lineItemTotal + invoice.gstAmount;
    final totalDiff = (invoice.totalAmount - expectedTotal).abs();
    if (invoice.lineItems.isNotEmpty && totalDiff > _balanceTolerance) {
      errors.add(
        'Invoice total mismatch: stated total is '
        '${_paise(invoice.totalAmount)}, '
        'but line items (${_paise(lineItemTotal)}) + '
        'GST (${_paise(invoice.gstAmount)}) = ${_paise(expectedTotal)} '
        '(diff: ${_paise(totalDiff)}).',
      );
    }

    return List.unmodifiable(errors);
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Formats a paise amount as a readable INR string for error messages.
  String _paise(int paise) {
    final inr = paise / 100;
    return '₹${inr.toStringAsFixed(2)}';
  }
}
