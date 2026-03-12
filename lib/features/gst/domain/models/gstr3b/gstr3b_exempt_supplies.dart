/// Immutable model representing GSTR-3B Table 3.2: Exempt, Nil-rated,
/// and Non-GST outward supplies.
///
/// These supplies carry no tax liability but must be disclosed.
/// Reported separately for inter-state and intra-state.
class Gstr3bExemptSupplies {
  const Gstr3bExemptSupplies({
    required this.interStateExempt,
    required this.intraStateExempt,
    required this.interStateNilRated,
    required this.intraStateNilRated,
    required this.interStateNonGst,
    required this.intraStateNonGst,
  });

  /// Inter-state exempt supplies (e.g. fresh fruits inter-state).
  final double interStateExempt;

  /// Intra-state exempt supplies.
  final double intraStateExempt;

  /// Inter-state nil-rated supplies (GST rate = 0%, e.g. grains in bulk).
  final double interStateNilRated;

  /// Intra-state nil-rated supplies.
  final double intraStateNilRated;

  /// Inter-state non-GST supplies (e.g. petroleum products, alcohol).
  final double interStateNonGst;

  /// Intra-state non-GST supplies.
  final double intraStateNonGst;

  /// Total exempt supplies (inter + intra).
  double get totalExempt => interStateExempt + intraStateExempt;

  /// Total nil-rated supplies (inter + intra).
  double get totalNilRated => interStateNilRated + intraStateNilRated;

  /// Total non-GST supplies (inter + intra).
  double get totalNonGst => interStateNonGst + intraStateNonGst;

  /// Grand total of all non-taxable supply categories.
  double get grandTotal => totalExempt + totalNilRated + totalNonGst;

  Gstr3bExemptSupplies copyWith({
    double? interStateExempt,
    double? intraStateExempt,
    double? interStateNilRated,
    double? intraStateNilRated,
    double? interStateNonGst,
    double? intraStateNonGst,
  }) {
    return Gstr3bExemptSupplies(
      interStateExempt: interStateExempt ?? this.interStateExempt,
      intraStateExempt: intraStateExempt ?? this.intraStateExempt,
      interStateNilRated: interStateNilRated ?? this.interStateNilRated,
      intraStateNilRated: intraStateNilRated ?? this.intraStateNilRated,
      interStateNonGst: interStateNonGst ?? this.interStateNonGst,
      intraStateNonGst: intraStateNonGst ?? this.intraStateNonGst,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gstr3bExemptSupplies &&
          runtimeType == other.runtimeType &&
          interStateExempt == other.interStateExempt &&
          intraStateExempt == other.intraStateExempt &&
          interStateNilRated == other.interStateNilRated &&
          intraStateNilRated == other.intraStateNilRated &&
          interStateNonGst == other.interStateNonGst &&
          intraStateNonGst == other.intraStateNonGst;

  @override
  int get hashCode => Object.hash(
    interStateExempt,
    intraStateExempt,
    interStateNilRated,
    intraStateNilRated,
    interStateNonGst,
    intraStateNonGst,
  );
}
