import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2b_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_b2c_invoice.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnr.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_cdnur.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_exp.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_at.dart';
import 'package:ca_app/features/gst/domain/models/gstr1/gstr1_form_data.dart';
import 'package:ca_app/features/gst/domain/services/gst_invoice_classifier.dart';

/// Static service that builds GSTR-1 form data from a list of [GstInvoice]s.
///
/// Routes each invoice to the appropriate GSTR-1 table based on its
/// classification (B2B, B2CL, B2CS, export with/without payment).
///
/// Usage:
/// ```dart
/// final gstr1 = Gstr1BuilderService.build(
///   gstin: '27AABCU9603R1ZM',
///   periodMonth: 1,
///   periodYear: 2026,
///   invoices: invoiceList,
/// );
/// ```
class Gstr1BuilderService {
  Gstr1BuilderService._();

  /// Builds a [Gstr1FormData] from the provided [invoices].
  ///
  /// Each invoice is classified and placed into the correct table.
  /// [creditDebitNotes], [creditDebitNotesUnregistered], and [advanceTax]
  /// are passed through directly (pre-classified by the caller).
  static Gstr1FormData build({
    required String gstin,
    required int periodMonth,
    required int periodYear,
    required List<GstInvoice> invoices,
    List<Gstr1Cdnr> creditDebitNotes = const [],
    List<Gstr1Cdnur> creditDebitNotesUnregistered = const [],
    List<Gstr1At> advanceTax = const [],
  }) {
    final b2bInvoices = <Gstr1B2bInvoice>[];
    final b2cInvoices = <Gstr1B2cInvoice>[];
    final exports = <Gstr1Exp>[];

    for (final invoice in invoices) {
      final classification = GstInvoiceClassifier.classify(invoice);

      switch (classification) {
        case InvoiceClassification.b2b:
          b2bInvoices.add(_toB2bInvoice(invoice));
        case InvoiceClassification.b2cLarge:
          b2cInvoices.add(_toB2cInvoice(invoice, B2cCategory.large));
        case InvoiceClassification.b2cSmall:
          b2cInvoices.add(_toB2cInvoice(invoice, B2cCategory.small));
        case InvoiceClassification.exportWithPayment:
          exports.add(_toExport(invoice, ExportType.withPayment));
        case InvoiceClassification.exportWithoutPayment:
          exports.add(_toExport(invoice, ExportType.withoutPayment));
      }
    }

    return Gstr1FormData(
      gstin: gstin,
      periodMonth: periodMonth,
      periodYear: periodYear,
      b2bInvoices: List.unmodifiable(b2bInvoices),
      b2cInvoices: List.unmodifiable(b2cInvoices),
      creditDebitNotes: List.unmodifiable(creditDebitNotes),
      creditDebitNotesUnregistered: List.unmodifiable(
        creditDebitNotesUnregistered,
      ),
      exports: List.unmodifiable(exports),
      advanceTax: List.unmodifiable(advanceTax),
    );
  }

  /// Converts a [GstInvoice] to a [Gstr1B2bInvoice] (Table 4A).
  static Gstr1B2bInvoice _toB2bInvoice(GstInvoice invoice) {
    return Gstr1B2bInvoice(
      invoiceNumber: invoice.invoiceNumber,
      invoiceDate: invoice.invoiceDate,
      recipientGstin: invoice.buyerGstin ?? '',
      recipientName: invoice.buyerName,
      placeOfSupply: invoice.placeOfSupply,
      isInterState: invoice.isInterState,
      taxableValue: invoice.totalTaxableValue,
      igst: invoice.totalIgst,
      cgst: invoice.totalCgst,
      sgst: invoice.totalSgst,
      cess: invoice.totalCess,
      gstRate: _primaryGstRate(invoice),
      invoiceType: invoice.invoiceType,
      reverseCharge: invoice.reverseCharge,
    );
  }

  /// Converts a [GstInvoice] to a [Gstr1B2cInvoice] (Tables 5A/5B).
  static Gstr1B2cInvoice _toB2cInvoice(
    GstInvoice invoice,
    B2cCategory category,
  ) {
    return Gstr1B2cInvoice(
      invoiceNumber: category == B2cCategory.large
          ? invoice.invoiceNumber
          : null,
      invoiceDate: invoice.invoiceDate,
      recipientName: invoice.buyerName,
      placeOfSupply: invoice.placeOfSupply,
      isInterState: invoice.isInterState,
      taxableValue: invoice.totalTaxableValue,
      igst: invoice.totalIgst,
      cgst: invoice.totalCgst,
      sgst: invoice.totalSgst,
      cess: invoice.totalCess,
      gstRate: _primaryGstRate(invoice),
      category: category,
    );
  }

  /// Converts a [GstInvoice] to a [Gstr1Exp] (Tables 6B/6C).
  static Gstr1Exp _toExport(GstInvoice invoice, ExportType exportType) {
    return Gstr1Exp(
      invoiceNumber: invoice.invoiceNumber,
      invoiceDate: invoice.invoiceDate,
      exportType: exportType,
      currencyCode: 'INR',
      foreignCurrencyValue: invoice.grandTotal,
      taxableValue: invoice.totalTaxableValue,
      igst: invoice.totalIgst,
      cess: invoice.totalCess,
      gstRate: _primaryGstRate(invoice),
    );
  }

  /// Returns the GST rate from the first line item, or 0 if no items.
  static double _primaryGstRate(GstInvoice invoice) {
    if (invoice.items.isEmpty) {
      return 0.0;
    }
    return invoice.items.first.gstRate;
  }
}
