import 'package:flutter/foundation.dart';

/// Status of a Form 26QB (TDS on property purchase) filing.
enum Form26QBStatus {
  pending(label: 'Pending'),
  paid(label: 'Paid'),
  cancelled(label: 'Cancelled');

  const Form26QBStatus({required this.label});

  final String label;
}

/// Immutable model representing a Form 26QB filing for TDS on property purchase
/// under Section 194IA.
///
/// Form 26QB is filed by the buyer (deductor) when purchasing immovable property
/// valued above ₹50 lakhs. TAN is not required — PAN-based filing.
@immutable
class Tds26QB {
  const Tds26QB({
    required this.acknowledgementNumber,
    required this.buyerPan,
    required this.buyerName,
    required this.sellerPan,
    required this.sellerName,
    required this.propertyAddress,
    required this.propertyValue,
    required this.tdsAmount,
    required this.paymentDate,
    required this.financialYear,
    required this.assessmentYear,
    required this.challanNumber,
    required this.status,
  });

  /// Unique acknowledgement number for this filing.
  final String acknowledgementNumber;

  /// PAN of the buyer (deductor).
  final String buyerPan;

  /// Name of the buyer.
  final String buyerName;

  /// PAN of the seller (deductee).
  final String sellerPan;

  /// Name of the seller.
  final String sellerName;

  /// Full address of the property being purchased.
  final String propertyAddress;

  /// Total consideration (purchase price) of the property, in rupees.
  final double propertyValue;

  /// TDS amount deducted and deposited (1% of property value).
  final double tdsAmount;

  /// Date of payment / credit to the seller.
  final DateTime paymentDate;

  /// Financial year, e.g. "2025-26".
  final String financialYear;

  /// Assessment year, e.g. "2026-27".
  final String assessmentYear;

  /// Challan number for the 26QB payment (e.g. "26QB-0001").
  final String challanNumber;

  /// Payment status.
  final Form26QBStatus status;

  // ---------------------------------------------------------------------------
  // Derived
  // ---------------------------------------------------------------------------

  /// Applicable TDS rate under Section 194IA: 1%.
  double get tdsRate => 1.0;

  /// Returns true when the property value exceeds the ₹50 lakh threshold.
  bool get isAboveThreshold => propertyValue > 5000000.0;

  /// Computed TDS = 1% of property value (regardless of threshold).
  double get computedTds => propertyValue * tdsRate / 100.0;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Tds26QB copyWith({
    String? acknowledgementNumber,
    String? buyerPan,
    String? buyerName,
    String? sellerPan,
    String? sellerName,
    String? propertyAddress,
    double? propertyValue,
    double? tdsAmount,
    DateTime? paymentDate,
    String? financialYear,
    String? assessmentYear,
    String? challanNumber,
    Form26QBStatus? status,
  }) {
    return Tds26QB(
      acknowledgementNumber:
          acknowledgementNumber ?? this.acknowledgementNumber,
      buyerPan: buyerPan ?? this.buyerPan,
      buyerName: buyerName ?? this.buyerName,
      sellerPan: sellerPan ?? this.sellerPan,
      sellerName: sellerName ?? this.sellerName,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      propertyValue: propertyValue ?? this.propertyValue,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      financialYear: financialYear ?? this.financialYear,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      challanNumber: challanNumber ?? this.challanNumber,
      status: status ?? this.status,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tds26QB &&
          runtimeType == other.runtimeType &&
          acknowledgementNumber == other.acknowledgementNumber &&
          buyerPan == other.buyerPan &&
          buyerName == other.buyerName &&
          sellerPan == other.sellerPan &&
          sellerName == other.sellerName &&
          propertyAddress == other.propertyAddress &&
          propertyValue == other.propertyValue &&
          tdsAmount == other.tdsAmount &&
          paymentDate == other.paymentDate &&
          financialYear == other.financialYear &&
          assessmentYear == other.assessmentYear &&
          challanNumber == other.challanNumber &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    acknowledgementNumber,
    buyerPan,
    buyerName,
    sellerPan,
    sellerName,
    propertyAddress,
    propertyValue,
    tdsAmount,
    paymentDate,
    financialYear,
    assessmentYear,
    challanNumber,
    status,
  );

  @override
  String toString() =>
      'Tds26QB(ack: $acknowledgementNumber, buyer: $buyerPan, '
      'seller: $sellerPan, property: $propertyValue, tds: $tdsAmount)';
}
