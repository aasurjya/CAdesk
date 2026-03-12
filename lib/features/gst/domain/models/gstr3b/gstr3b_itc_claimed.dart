/// Immutable row representing ITC amounts for a single ITC sub-section.
class ItcRow {
  const ItcRow({
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.cess,
  });

  /// IGST input tax credit.
  final double igst;

  /// CGST input tax credit.
  final double cgst;

  /// SGST/UTGST input tax credit.
  final double sgst;

  /// Compensation cess input tax credit.
  final double cess;

  /// Total ITC = IGST + CGST + SGST + CESS.
  double get totalItc => igst + cgst + sgst + cess;

  ItcRow copyWith({double? igst, double? cgst, double? sgst, double? cess}) {
    return ItcRow(
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItcRow &&
          runtimeType == other.runtimeType &&
          igst == other.igst &&
          cgst == other.cgst &&
          sgst == other.sgst &&
          cess == other.cess;

  @override
  int get hashCode => Object.hash(igst, cgst, sgst, cess);
}

/// Immutable model representing GSTR-3B Table 4: Eligible ITC.
///
/// Table 4 structure:
/// - 4(A): ITC Available
///   - (1): Import of goods
///   - (2): Import of services
///   - (3): Inward supplies liable to reverse charge (recipient pays)
///   - (4): Inward supplies from ISD (Input Service Distributor)
///   - (5): All other ITC (from GSTR-2B — domestic B2B purchases)
/// - 4(B): ITC Reversed
///   - (1): Per Rule 42 & 43 / Section 17(5) — blocked credits
///   - (2): Others (non-business use, etc.)
/// - Net ITC Available: 4(A) – 4(B)
/// - 4(D): Ineligible ITC (sub-rule 38, others)
class Gstr3bItcClaimed {
  const Gstr3bItcClaimed({
    required this.importGoods,
    required this.importServices,
    required this.inwardRcm,
    required this.isd,
    required this.otherItc,
    required this.reversedSection17_5,
    required this.reversedOthers,
    required this.netItcAvailable,
    required this.ineligibleRule38,
    required this.ineligibleOthers,
  });

  /// 4(A)(1): ITC on import of goods.
  final ItcRow importGoods;

  /// 4(A)(2): ITC on import of services.
  final ItcRow importServices;

  /// 4(A)(3): ITC on inward supplies under RCM.
  final ItcRow inwardRcm;

  /// 4(A)(4): ITC received from Input Service Distributor (ISD).
  final ItcRow isd;

  /// 4(A)(5): All other ITC — domestic B2B supplies from GSTR-2B.
  final ItcRow otherItc;

  /// 4(B)(1): ITC reversed — Section 17(5) blocked credits and Rule 42/43.
  final ItcRow reversedSection17_5;

  /// 4(B)(2): ITC reversed — other reversals (non-business use etc.).
  final ItcRow reversedOthers;

  /// Net ITC available = 4(A) total – 4(B) total.
  final ItcRow netItcAvailable;

  /// 4(D)(1): Ineligible ITC — per Rule 38 (banking/NBFC restriction).
  final ItcRow ineligibleRule38;

  /// 4(D)(2): Ineligible ITC — other ineligibles.
  final ItcRow ineligibleOthers;

  /// Total available ITC before reversals (sum of all 4(A) rows).
  double get totalAvailableItc =>
      importGoods.totalItc +
      importServices.totalItc +
      inwardRcm.totalItc +
      isd.totalItc +
      otherItc.totalItc;

  /// Total reversed ITC (sum of 4(B) rows).
  double get totalReversedItc =>
      reversedSection17_5.totalItc + reversedOthers.totalItc;

  Gstr3bItcClaimed copyWith({
    ItcRow? importGoods,
    ItcRow? importServices,
    ItcRow? inwardRcm,
    ItcRow? isd,
    ItcRow? otherItc,
    ItcRow? reversedSection17_5,
    ItcRow? reversedOthers,
    ItcRow? netItcAvailable,
    ItcRow? ineligibleRule38,
    ItcRow? ineligibleOthers,
  }) {
    return Gstr3bItcClaimed(
      importGoods: importGoods ?? this.importGoods,
      importServices: importServices ?? this.importServices,
      inwardRcm: inwardRcm ?? this.inwardRcm,
      isd: isd ?? this.isd,
      otherItc: otherItc ?? this.otherItc,
      reversedSection17_5: reversedSection17_5 ?? this.reversedSection17_5,
      reversedOthers: reversedOthers ?? this.reversedOthers,
      netItcAvailable: netItcAvailable ?? this.netItcAvailable,
      ineligibleRule38: ineligibleRule38 ?? this.ineligibleRule38,
      ineligibleOthers: ineligibleOthers ?? this.ineligibleOthers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr3bItcClaimed &&
          runtimeType == other.runtimeType &&
          importGoods == other.importGoods &&
          importServices == other.importServices &&
          inwardRcm == other.inwardRcm &&
          isd == other.isd &&
          otherItc == other.otherItc &&
          reversedSection17_5 == other.reversedSection17_5 &&
          reversedOthers == other.reversedOthers &&
          netItcAvailable == other.netItcAvailable &&
          ineligibleRule38 == other.ineligibleRule38 &&
          ineligibleOthers == other.ineligibleOthers;

  @override
  int get hashCode => Object.hash(
    importGoods,
    importServices,
    inwardRcm,
    isd,
    otherItc,
    reversedSection17_5,
    reversedOthers,
    netItcAvailable,
    ineligibleRule38,
    ineligibleOthers,
  );
}
