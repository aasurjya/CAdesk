import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_item.dart';
import 'package:ca_app/features/portal_export/einvoice_export/models/einvoice_request.dart';

/// Tolerance (₹) used when comparing item totals to valDtls totals.
const _roundingTolerance = 1.0;

/// Regex for valid invoice numbers per NIC API spec.
/// Allowed chars: A-Z, a-z, 0-9, /, -, max 16 characters.
final _invoiceNumberRegex = RegExp(r'^[A-Za-z0-9/\-]{1,16}$');

/// Regex for HSN/SAC codes: must be exactly 4, 6, or 8 digits.
final _hsnRegex = RegExp(r'^\d{4}$|^\d{6}$|^\d{8}$');

/// Stateless service that validates an [EInvoiceRequest] against NIC IRP rules.
///
/// All methods are static; this class cannot be instantiated.
class EInvoiceValidator {
  EInvoiceValidator._();

  /// Validates the complete e-invoice request and returns a list of errors.
  ///
  /// Returns an empty list when the request is valid. Each error is a
  /// human-readable string describing the problem.
  static List<String> validate(EInvoiceRequest request) {
    final errors = <String>[];

    // GSTIN format.
    if (!validateGstin(request.sellerDtls.gstin)) {
      errors.add('Seller GSTIN must be exactly 15 characters');
    }
    if (!validateGstin(request.buyerDtls.gstin)) {
      errors.add('Buyer GSTIN must be exactly 15 characters');
    }

    // Invoice number.
    if (!validateInvoiceNumber(request.docDtls.no)) {
      errors.add(
        'Invalid invoice number "${request.docDtls.no}": '
        'max 16 alphanumeric chars plus / and -',
      );
    }

    // Invoice date must not be in the future.
    final today = DateTime.now();
    if (request.docDtls.dt.isAfter(today)) {
      errors.add('Invoice date ${request.docDtls.dt} is in the future');
    }

    // Item-level validation.
    for (final item in request.itemList) {
      if (!validateHsn(item.hsnCd)) {
        errors.add(
          'Item ${item.slNo}: HSN code "${item.hsnCd}" must be 4, 6, or 8 digits',
        );
      }
    }

    // Math check — sum of item assAmts must equal valDtls.assVal within ₹1.
    final itemAssTotal = request.itemList.fold(
      0.0,
      (double sum, EInvoiceItem i) => sum + i.assAmt,
    );
    if ((itemAssTotal - request.valDtls.assVal).abs() > _roundingTolerance) {
      errors.add(
        'ValDtls.assVal (${request.valDtls.assVal}) does not match '
        'sum of item assessable amounts ($itemAssTotal)',
      );
    }

    // Math check — sum of item igstAmts must equal valDtls.igstVal.
    final itemIgstTotal = request.itemList.fold(
      0.0,
      (double sum, EInvoiceItem i) => sum + i.igstAmt,
    );
    if ((itemIgstTotal - request.valDtls.igstVal).abs() > _roundingTolerance) {
      errors.add(
        'ValDtls.igstVal (${request.valDtls.igstVal}) does not match '
        'sum of item IGST amounts ($itemIgstTotal)',
      );
    }

    // Math check — sum of item cgstAmts must equal valDtls.cgstVal.
    final itemCgstTotal = request.itemList.fold(
      0.0,
      (double sum, EInvoiceItem i) => sum + i.cgstAmt,
    );
    if ((itemCgstTotal - request.valDtls.cgstVal).abs() > _roundingTolerance) {
      errors.add(
        'ValDtls.cgstVal (${request.valDtls.cgstVal}) does not match '
        'sum of item CGST amounts ($itemCgstTotal)',
      );
    }

    // Math check — sum of item sgstAmts must equal valDtls.sgstVal.
    final itemSgstTotal = request.itemList.fold(
      0.0,
      (double sum, EInvoiceItem i) => sum + i.sgstAmt,
    );
    if ((itemSgstTotal - request.valDtls.sgstVal).abs() > _roundingTolerance) {
      errors.add(
        'ValDtls.sgstVal (${request.valDtls.sgstVal}) does not match '
        'sum of item SGST amounts ($itemSgstTotal)',
      );
    }

    // Math check — sum of totItemVals must equal valDtls.totInvVal.
    final itemTotTotal = request.itemList.fold(
      0.0,
      (double sum, EInvoiceItem i) => sum + i.totItemVal,
    );
    if ((itemTotTotal - request.valDtls.totInvVal).abs() > _roundingTolerance) {
      errors.add(
        'ValDtls.totInvVal (${request.valDtls.totInvVal}) does not match '
        'sum of item total values ($itemTotTotal)',
      );
    }

    return errors;
  }

  /// Returns true when [gstin] is exactly 15 characters.
  ///
  /// The NIC IRP API requires the GSTIN to be exactly 15 characters.
  /// Full checksum validation is not performed here.
  static bool validateGstin(String gstin) => gstin.length == 15;

  /// Returns true when [hsn] is exactly 4, 6, or 8 numeric digits.
  static bool validateHsn(String hsn) => _hsnRegex.hasMatch(hsn);

  /// Returns true when [invNum] matches `[A-Za-z0-9/\\-]{1,16}`.
  static bool validateInvoiceNumber(String invNum) =>
      _invoiceNumberRegex.hasMatch(invNum);
}
