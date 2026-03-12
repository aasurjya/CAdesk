import 'package:ca_app/features/gst/domain/models/e_invoice.dart';

/// Valid Indian state codes (01–38).
const _validStateCodes = {
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '27',
  '28',
  '29',
  '30',
  '31',
  '32',
  '33',
  '34',
  '35',
  '36',
  '37',
  '38',
};

/// E-invoice turnover threshold: 5 crore INR.
const _eInvoiceThreshold = 50000000.0;

/// Static service for e-invoice validation, calculation, and payload
/// generation per NIC/IRP specifications.
class EInvoiceService {
  EInvoiceService._();

  /// Validate an e-invoice and return a list of error messages.
  /// An empty list means the invoice is valid.
  static List<String> validate(EInvoice invoice) {
    final errors = <String>[];

    // GSTIN validation.
    if (invoice.sellerGstin.length != 15) {
      errors.add('Seller GSTIN must be exactly 15 characters');
    }
    if (invoice.buyerGstin.length != 15) {
      errors.add('Buyer GSTIN must be exactly 15 characters');
    }

    // Document number.
    if (invoice.documentNumber.isEmpty) {
      errors.add('Document number must not be empty');
    }

    // Items.
    if (invoice.items.isEmpty) {
      errors.add('Invoice must have at least one item');
    }

    for (final item in invoice.items) {
      if (item.hsnCode.isEmpty || item.hsnCode.length < 4) {
        errors.add('Item ${item.slNo}: HSN code must be at least 4 digits');
      }
      if (item.taxableValue < 0 ||
          item.igst < 0 ||
          item.cgst < 0 ||
          item.sgst < 0 ||
          item.cess < 0) {
        errors.add('Item ${item.slNo}: Amounts must not be negative');
      }
    }

    // Totals must match sum of items.
    if (invoice.items.isNotEmpty) {
      final computed = calculateTotals(invoice.items);
      if (_notClose(
        invoice.totals.totalTaxableValue,
        computed.totalTaxableValue,
      )) {
        errors.add('Total taxable value does not match sum of items');
      }
      if (_notClose(invoice.totals.totalIgst, computed.totalIgst)) {
        errors.add('Total IGST does not match sum of items');
      }
      if (_notClose(invoice.totals.totalCgst, computed.totalCgst)) {
        errors.add('Total CGST does not match sum of items');
      }
      if (_notClose(invoice.totals.totalSgst, computed.totalSgst)) {
        errors.add('Total SGST does not match sum of items');
      }
      if (_notClose(invoice.totals.totalCess, computed.totalCess)) {
        errors.add('Total Cess does not match sum of items');
      }
      if (_notClose(
        invoice.totals.totalInvoiceValue,
        computed.totalInvoiceValue,
      )) {
        errors.add('Total invoice value does not match sum of items');
      }
    }

    // State code validation.
    if (!_validStateCodes.contains(invoice.sellerAddress.stateCode)) {
      errors.add(
        'Seller state code "${invoice.sellerAddress.stateCode}" is invalid',
      );
    }
    if (!_validStateCodes.contains(invoice.buyerAddress.stateCode)) {
      errors.add(
        'Buyer state code "${invoice.buyerAddress.stateCode}" is invalid',
      );
    }

    return errors;
  }

  /// Calculate totals from a list of e-invoice items.
  static EInvoiceTotals calculateTotals(List<EInvoiceItem> items) {
    var taxableValue = 0.0;
    var igst = 0.0;
    var cgst = 0.0;
    var sgst = 0.0;
    var cess = 0.0;
    var invoiceValue = 0.0;

    for (final item in items) {
      taxableValue += item.taxableValue;
      igst += item.igst;
      cgst += item.cgst;
      sgst += item.sgst;
      cess += item.cess;
      invoiceValue += item.totalItemValue;
    }

    return EInvoiceTotals(
      totalValue: invoiceValue,
      totalTaxableValue: taxableValue,
      totalIgst: igst,
      totalCgst: cgst,
      totalSgst: sgst,
      totalCess: cess,
      totalInvoiceValue: invoiceValue,
    );
  }

  /// Whether e-invoicing is applicable based on aggregate turnover.
  /// Applicable for turnover >= 5 crore (50,000,000 INR).
  static bool isEInvoiceApplicable({required double turnover}) {
    return turnover >= _eInvoiceThreshold;
  }

  /// Generate NIC/IRP-format JSON payload for IRN generation.
  static Map<String, dynamic> generateIrnPayload(EInvoice invoice) {
    return {
      'Version': '1.1',
      'TranDtls': {'TaxSch': 'GST', 'SupTyp': invoice.supplyType.code},
      'DocDtls': {
        'Typ': invoice.documentType.code,
        'No': invoice.documentNumber,
        'Dt': _formatDate(invoice.documentDate),
      },
      'SellerDtls': _addressToPayload(
        invoice.sellerAddress,
        invoice.sellerGstin,
      ),
      'BuyerDtls': _addressToPayload(invoice.buyerAddress, invoice.buyerGstin),
      'ItemList': invoice.items.map(_itemToPayload).toList(),
      'ValDtls': {
        'AssVal': invoice.totals.totalTaxableValue,
        'IgstVal': invoice.totals.totalIgst,
        'CgstVal': invoice.totals.totalCgst,
        'SgstVal': invoice.totals.totalSgst,
        'CesVal': invoice.totals.totalCess,
        'TotInvVal': invoice.totals.totalInvoiceValue,
      },
    };
  }

  // ── Private Helpers ─────────────────────────────────────────────────

  static Map<String, dynamic> _addressToPayload(
    EInvoiceAddress address,
    String gstin,
  ) {
    return {
      'Gstin': gstin,
      'LglNm': address.legalName,
      if (address.tradeName != null) 'TrdNm': address.tradeName,
      'Addr1': address.address1,
      if (address.address2 != null) 'Addr2': address.address2,
      'Loc': address.city,
      'Stcd': address.stateCode,
      'Pin': int.tryParse(address.pincode) ?? 0,
    };
  }

  static Map<String, dynamic> _itemToPayload(EInvoiceItem item) {
    return {
      'SlNo': '${item.slNo}',
      'PrdDesc': item.productDescription,
      'IsServc': 'N',
      'HsnCd': item.hsnCode,
      'Qty': item.quantity,
      'Unit': item.unit,
      'UnitPrice': item.unitPrice,
      'Discount': item.discount,
      'AssAmt': item.taxableValue,
      'GstRt': item.gstRate,
      'IgstAmt': item.igst,
      'CgstAmt': item.cgst,
      'SgstAmt': item.sgst,
      'CesAmt': item.cess,
      'TotItemVal': item.totalItemValue,
    };
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  /// Check if two doubles are not close (tolerance 0.01 for rounding).
  static bool _notClose(double a, double b) {
    return (a - b).abs() > 0.01;
  }
}
