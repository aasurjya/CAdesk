import 'package:ca_app/features/ocr/domain/models/extracted_line_item.dart';
import 'package:flutter/foundation.dart';

/// Immutable structured data extracted from a GST Tax Invoice.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
@immutable
class ExtractedInvoice {
  const ExtractedInvoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.sellerName,
    required this.sellerGstin,
    required this.buyerName,
    required this.buyerGstin,
    required this.lineItems,
    required this.totalAmount,
    required this.gstAmount,
    required this.hsnCode,
  });

  /// Invoice reference / serial number.
  final String invoiceNumber;

  /// Date of the invoice (nullable when not parseable from text).
  final DateTime? invoiceDate;

  /// Registered name of the seller / supplier.
  final String sellerName;

  /// GSTIN of the seller (15-character GST registration number), if present.
  final String? sellerGstin;

  /// Name of the buyer / recipient.
  final String buyerName;

  /// GSTIN of the buyer, if present.
  final String? buyerGstin;

  /// List of individual line items in the invoice.
  final List<ExtractedLineItem> lineItems;

  /// Grand total amount (inclusive of GST) in paise.
  final int totalAmount;

  /// Total GST component in paise (CGST + SGST or IGST).
  final int gstAmount;

  /// Primary HSN/SAC code for the invoice, if applicable.
  final String? hsnCode;

  ExtractedInvoice copyWith({
    String? invoiceNumber,
    DateTime? invoiceDate,
    String? sellerName,
    String? sellerGstin,
    String? buyerName,
    String? buyerGstin,
    List<ExtractedLineItem>? lineItems,
    int? totalAmount,
    int? gstAmount,
    String? hsnCode,
  }) {
    return ExtractedInvoice(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      sellerName: sellerName ?? this.sellerName,
      sellerGstin: sellerGstin ?? this.sellerGstin,
      buyerName: buyerName ?? this.buyerName,
      buyerGstin: buyerGstin ?? this.buyerGstin,
      lineItems: lineItems ?? this.lineItems,
      totalAmount: totalAmount ?? this.totalAmount,
      gstAmount: gstAmount ?? this.gstAmount,
      hsnCode: hsnCode ?? this.hsnCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtractedInvoice &&
          runtimeType == other.runtimeType &&
          invoiceNumber == other.invoiceNumber &&
          invoiceDate == other.invoiceDate &&
          sellerName == other.sellerName &&
          sellerGstin == other.sellerGstin &&
          buyerName == other.buyerName &&
          buyerGstin == other.buyerGstin &&
          _listEquals(lineItems, other.lineItems) &&
          totalAmount == other.totalAmount &&
          gstAmount == other.gstAmount &&
          hsnCode == other.hsnCode;

  bool _listEquals(List<ExtractedLineItem> a, List<ExtractedLineItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    invoiceNumber,
    invoiceDate,
    sellerName,
    sellerGstin,
    buyerName,
    buyerGstin,
    Object.hashAll(lineItems),
    totalAmount,
    gstAmount,
    hsnCode,
  );

  @override
  String toString() =>
      'ExtractedInvoice(no: $invoiceNumber, seller: $sellerName, '
      'total: $totalAmount, gst: $gstAmount)';
}
