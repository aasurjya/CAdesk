/// Tax type applicable based on place of supply determination.
enum GstTaxType { igst, cgstSgst }

/// Type of supply — goods or services.
enum SupplyType { goods, services }

/// Category of GST supply for place of supply determination.
enum GstSupplyCategory {
  regular,
  billToShipTo,
  installedAtSite,
  importGoods,
  exportGoods,
  sez,
}

/// Immutable result of a place of supply determination.
class PlaceOfSupplyResult {
  const PlaceOfSupplyResult({
    required this.supplierStateCode,
    required this.recipientStateCode,
    required this.placeOfSupplyStateCode,
    required this.isInterState,
    required this.taxType,
    required this.applicableSection,
    required this.reason,
  });

  /// State code of the supplier (e.g. '27' for Maharashtra).
  final String supplierStateCode;

  /// State code of the recipient.
  final String recipientStateCode;

  /// Determined place of supply state code.
  final String placeOfSupplyStateCode;

  /// Whether the supply is inter-state.
  final bool isInterState;

  /// Applicable tax type: IGST or CGST+SGST.
  final GstTaxType taxType;

  /// IGST Act section that applies (e.g. 'Section 10', 'Section 12').
  final String applicableSection;

  /// Human-readable reason for the determination.
  final String reason;

  PlaceOfSupplyResult copyWith({
    String? supplierStateCode,
    String? recipientStateCode,
    String? placeOfSupplyStateCode,
    bool? isInterState,
    GstTaxType? taxType,
    String? applicableSection,
    String? reason,
  }) {
    return PlaceOfSupplyResult(
      supplierStateCode: supplierStateCode ?? this.supplierStateCode,
      recipientStateCode: recipientStateCode ?? this.recipientStateCode,
      placeOfSupplyStateCode:
          placeOfSupplyStateCode ?? this.placeOfSupplyStateCode,
      isInterState: isInterState ?? this.isInterState,
      taxType: taxType ?? this.taxType,
      applicableSection: applicableSection ?? this.applicableSection,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceOfSupplyResult &&
          runtimeType == other.runtimeType &&
          supplierStateCode == other.supplierStateCode &&
          recipientStateCode == other.recipientStateCode &&
          placeOfSupplyStateCode == other.placeOfSupplyStateCode &&
          isInterState == other.isInterState &&
          taxType == other.taxType &&
          applicableSection == other.applicableSection &&
          reason == other.reason;

  @override
  int get hashCode => Object.hash(
    supplierStateCode,
    recipientStateCode,
    placeOfSupplyStateCode,
    isInterState,
    taxType,
    applicableSection,
    reason,
  );
}
