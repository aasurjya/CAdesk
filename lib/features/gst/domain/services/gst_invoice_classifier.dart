import 'package:ca_app/features/gst/domain/models/gst_invoice.dart';

/// Classification of a GST invoice for GSTR-1 table routing.
enum InvoiceClassification {
  /// Table 4A: B2B supply to registered recipient (GSTIN present).
  b2b(label: 'B2B'),

  /// Table 5A: B2C large — inter-state, unregistered, invoice value > ₹2.5L.
  b2cLarge(label: 'B2CL'),

  /// Table 5B: B2C small — all other unregistered supplies (consolidated).
  b2cSmall(label: 'B2CS'),

  /// Table 6B: Export with payment of IGST.
  exportWithPayment(label: 'EXP-WPAY'),

  /// Table 6C: Export without payment of IGST (LUT/bond).
  exportWithoutPayment(label: 'EXP-WOPAY');

  const InvoiceClassification({required this.label});

  final String label;
}

/// Threshold (in INR) above which an inter-state B2C supply is classified
/// as B2CL (large) and must be reported invoice-wise in Table 5A.
const double _b2clThreshold = 250000.0;

/// Static service that classifies a [GstInvoice] into the correct
/// GSTR-1 table category.
///
/// Classification rules (evaluated in order):
/// 1. Export → Table 6B (IGST paid) or 6C (LUT/bond)
/// 2. GSTIN present → Table 4A (B2B)
/// 3. No GSTIN + inter-state + taxableValue > ₹2.5L → Table 5A (B2CL)
/// 4. All other unregistered → Table 5B (B2CS)
class GstInvoiceClassifier {
  GstInvoiceClassifier._();

  /// Classifies a single [invoice] into its GSTR-1 table category.
  static InvoiceClassification classify(GstInvoice invoice) {
    // Step 1: Export takes highest priority.
    if (invoice.isExport) {
      return invoice.totalIgst > 0
          ? InvoiceClassification.exportWithPayment
          : InvoiceClassification.exportWithoutPayment;
    }

    // Step 2: Registered recipient → B2B.
    if (invoice.isB2b) {
      return InvoiceClassification.b2b;
    }

    // Step 3: Unregistered — determine B2CL vs B2CS.
    // B2CL: inter-state AND taxable value strictly greater than ₹2.5L.
    if (invoice.isInterState && invoice.totalTaxableValue > _b2clThreshold) {
      return InvoiceClassification.b2cLarge;
    }

    // Step 4: All other unregistered supplies → B2CS (consolidated).
    return InvoiceClassification.b2cSmall;
  }

  /// Classifies a list of invoices and returns a map of invoice → classification.
  ///
  /// Returns a new map (immutable pattern); does not mutate inputs.
  static Map<GstInvoice, InvoiceClassification> classifyAll(
    List<GstInvoice> invoices,
  ) {
    final result = <GstInvoice, InvoiceClassification>{};
    for (final invoice in invoices) {
      result[invoice] = classify(invoice);
    }
    return Map.unmodifiable(result);
  }
}
