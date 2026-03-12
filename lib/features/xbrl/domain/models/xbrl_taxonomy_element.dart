import 'package:ca_app/features/xbrl/domain/models/xbrl_context.dart';

/// XBRL data type for a taxonomy element.
enum XbrlDataType {
  /// Monetary value (e.g. revenue, assets) — requires a unit reference.
  monetaryItemType,

  /// Free-form text value.
  stringItemType,

  /// Date value in ISO-8601 format.
  dateItemType,

  /// Boolean (true/false) value.
  booleanItemType,

  /// Decimal number (e.g. EPS, ratios) — no unit reference required.
  decimalItemType,
}

/// Accounting balance direction for a monetary taxonomy element.
enum XbrlBalance {
  /// Asset / expense element (normal debit balance).
  debit,

  /// Liability / income element (normal credit balance).
  credit,

  /// Not applicable — used for non-monetary elements.
  none,
}

/// Immutable descriptor for a single element in the in-gaap XBRL taxonomy.
///
/// Carries the element's namespace, data type, period type, balance direction,
/// and whether it is an abstract grouping node or a concrete reportable fact.
class XbrlTaxonomyElement {
  const XbrlTaxonomyElement({
    required this.elementName,
    required this.namespace,
    required this.dataType,
    required this.periodType,
    required this.balance,
    required this.isAbstract,
  });

  /// Local name without namespace prefix (e.g. `CashAndCashEquivalents`).
  final String elementName;

  /// Namespace prefix (e.g. `in-gaap`).
  final String namespace;

  /// XBRL data type governing how the value is formatted.
  final XbrlDataType dataType;

  /// Whether the element is point-in-time or period-based.
  final XbrlPeriodType periodType;

  /// Accounting balance direction for monetary elements.
  final XbrlBalance balance;

  /// True if the element is an abstract grouping node, not a reportable fact.
  final bool isAbstract;

  /// Returns the fully-qualified element name, e.g. `in-gaap:Revenue`.
  String get qualifiedName => '$namespace:$elementName';

  XbrlTaxonomyElement copyWith({
    String? elementName,
    String? namespace,
    XbrlDataType? dataType,
    XbrlPeriodType? periodType,
    XbrlBalance? balance,
    bool? isAbstract,
  }) {
    return XbrlTaxonomyElement(
      elementName: elementName ?? this.elementName,
      namespace: namespace ?? this.namespace,
      dataType: dataType ?? this.dataType,
      periodType: periodType ?? this.periodType,
      balance: balance ?? this.balance,
      isAbstract: isAbstract ?? this.isAbstract,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XbrlTaxonomyElement &&
        other.elementName == elementName &&
        other.namespace == namespace &&
        other.dataType == dataType &&
        other.periodType == periodType &&
        other.balance == balance &&
        other.isAbstract == isAbstract;
  }

  @override
  int get hashCode => Object.hash(
    elementName,
    namespace,
    dataType,
    periodType,
    balance,
    isAbstract,
  );

  @override
  String toString() => 'XbrlTaxonomyElement($qualifiedName, $dataType)';
}
