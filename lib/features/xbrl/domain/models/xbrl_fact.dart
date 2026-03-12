/// Immutable XBRL fact representing a single tagged value in an instance
/// document.
///
/// Each fact binds a qualified element name to a context, an optional unit
/// (required for monetary and decimal types), a string-encoded value, and a
/// decimals attribute indicating precision.
///
/// Monetary values are stored as INR (rupees, not paise) with two decimal
/// places (e.g. `"5000000.00"`).
class XbrlFact {
  const XbrlFact({
    required this.elementName,
    required this.contextRef,
    required this.value,
    required this.decimals,
    this.unitRef,
  });

  /// Fully-qualified XBRL element name, e.g. `in-gaap:CashAndCashEquivalents`.
  final String elementName;

  /// `id` of the [XbrlContext] this fact belongs to.
  final String contextRef;

  /// `id` of the [XbrlUnit] for monetary/decimal facts; null for other types.
  final String? unitRef;

  /// String-encoded value (monetary values formatted as `"NNN.NN"`).
  final String value;

  /// Precision indicator — `0` for exact rupees, `-3` for thousands.
  final int decimals;

  XbrlFact copyWith({
    String? elementName,
    String? contextRef,
    String? unitRef,
    String? value,
    int? decimals,
  }) {
    return XbrlFact(
      elementName: elementName ?? this.elementName,
      contextRef: contextRef ?? this.contextRef,
      unitRef: unitRef ?? this.unitRef,
      value: value ?? this.value,
      decimals: decimals ?? this.decimals,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XbrlFact &&
        other.elementName == elementName &&
        other.contextRef == contextRef &&
        other.unitRef == unitRef &&
        other.value == value &&
        other.decimals == decimals;
  }

  @override
  int get hashCode =>
      Object.hash(elementName, contextRef, unitRef, value, decimals);

  @override
  String toString() =>
      'XbrlFact($elementName, ctx=$contextRef, val=$value)';
}
