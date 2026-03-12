/// Immutable row representing a single line of tax in a GSTR-3B table.
///
/// Used for both Table 3.1 (outward supply tax liability) rows.
class Gstr3bTaxRow {
  const Gstr3bTaxRow({
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
  });

  /// IGST component.
  final double igst;

  /// CGST component.
  final double cgst;

  /// SGST/UTGST component.
  final double sgst;

  /// Compensation cess component.
  final double cess;

  /// Total tax = IGST + CGST + SGST + CESS.
  double get totalTax => igst + cgst + sgst + cess;

  Gstr3bTaxRow copyWith({
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
  }) {
    return Gstr3bTaxRow(
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr3bTaxRow &&
          runtimeType == other.runtimeType &&
          igst == other.igst &&
          cgst == other.cgst &&
          sgst == other.sgst &&
          cess == other.cess;

  @override
  int get hashCode => Object.hash(igst, cgst, sgst, cess);
}

/// Immutable model representing GSTR-3B Table 3.1: Tax on outward and
/// reverse charge inward supplies.
///
/// Sub-sections:
/// - 3.1(a): Outward taxable supplies (other than zero-rated, nil-rated, exempt)
/// - 3.1(b): Outward taxable supplies (zero-rated — exports + SEZ)
/// - 3.1(c): Other outward supplies (nil-rated, exempt)
/// - 3.1(d): Inward supplies liable to reverse charge (RCM liability)
/// - 3.1(e): Non-GST outward supplies
class Gstr3bTaxLiability {
  const Gstr3bTaxLiability({
    required this.outwardTaxable,
    required this.outwardZeroRated,
    required this.otherOutward,
    required this.inwardRcm,
    required this.nonGstOutward,
  });

  /// 3.1(a): Outward taxable supplies (regular domestic B2B + B2C).
  final Gstr3bTaxRow outwardTaxable;

  /// 3.1(b): Outward taxable zero-rated (exports with IGST payment, SEZ).
  final Gstr3bTaxRow outwardZeroRated;

  /// 3.1(c): Other outward supplies (nil-rated + exempt, reported separately).
  final Gstr3bTaxRow otherOutward;

  /// 3.1(d): Inward supplies on which RCM tax is payable.
  final Gstr3bTaxRow inwardRcm;

  /// 3.1(e): Non-GST outward supplies (petroleum, alcohol etc.).
  final Gstr3bTaxRow nonGstOutward;

  /// Total IGST across all rows.
  double get totalIgst =>
      outwardTaxable.igst +
      outwardZeroRated.igst +
      otherOutward.igst +
      inwardRcm.igst +
      nonGstOutward.igst;

  /// Total CGST across all rows.
  double get totalCgst =>
      outwardTaxable.cgst +
      outwardZeroRated.cgst +
      otherOutward.cgst +
      inwardRcm.cgst +
      nonGstOutward.cgst;

  /// Total SGST across all rows.
  double get totalSgst =>
      outwardTaxable.sgst +
      outwardZeroRated.sgst +
      otherOutward.sgst +
      inwardRcm.sgst +
      nonGstOutward.sgst;

  /// Total CESS across all rows.
  double get totalCess =>
      outwardTaxable.cess +
      outwardZeroRated.cess +
      otherOutward.cess +
      inwardRcm.cess +
      nonGstOutward.cess;

  /// Total tax liability across all rows and all components.
  double get totalTaxLiability => totalIgst + totalCgst + totalSgst + totalCess;

  Gstr3bTaxLiability copyWith({
    Gstr3bTaxRow? outwardTaxable,
    Gstr3bTaxRow? outwardZeroRated,
    Gstr3bTaxRow? otherOutward,
    Gstr3bTaxRow? inwardRcm,
    Gstr3bTaxRow? nonGstOutward,
  }) {
    return Gstr3bTaxLiability(
      outwardTaxable: outwardTaxable ?? this.outwardTaxable,
      outwardZeroRated: outwardZeroRated ?? this.outwardZeroRated,
      otherOutward: otherOutward ?? this.otherOutward,
      inwardRcm: inwardRcm ?? this.inwardRcm,
      nonGstOutward: nonGstOutward ?? this.nonGstOutward,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr3bTaxLiability &&
          runtimeType == other.runtimeType &&
          outwardTaxable == other.outwardTaxable &&
          outwardZeroRated == other.outwardZeroRated &&
          otherOutward == other.otherOutward &&
          inwardRcm == other.inwardRcm &&
          nonGstOutward == other.nonGstOutward;

  @override
  int get hashCode => Object.hash(
    outwardTaxable,
    outwardZeroRated,
    otherOutward,
    inwardRcm,
    nonGstOutward,
  );
}
