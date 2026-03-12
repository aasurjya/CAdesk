/// Immutable XBRL unit declaration used in an instance document.
///
/// For Indian filings, the standard unit is INR measured via ISO 4217:
/// `measure = "iso4217:INR"`.
class XbrlUnit {
  const XbrlUnit({required this.unitId, required this.measure});

  /// Unique identifier used as the `id` attribute in the XML unit element.
  final String unitId;

  /// The measure declaration — e.g. `iso4217:INR`.
  final String measure;

  XbrlUnit copyWith({String? unitId, String? measure}) {
    return XbrlUnit(
      unitId: unitId ?? this.unitId,
      measure: measure ?? this.measure,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XbrlUnit &&
        other.unitId == unitId &&
        other.measure == measure;
  }

  @override
  int get hashCode => Object.hash(unitId, measure);

  @override
  String toString() => 'XbrlUnit($unitId, $measure)';
}
