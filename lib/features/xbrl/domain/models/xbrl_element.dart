import 'package:flutter/material.dart';

/// XBRL element data type — determines color coding in the UI.
enum XbrlElementType {
  numeric(
    label: 'Numeric',
    color: Color(0xFF1565C0), // blue
    icon: Icons.tag_rounded,
  ),
  text(
    label: 'Text',
    color: Color(0xFF2E7D32), // green
    icon: Icons.text_fields_rounded,
  ),
  date(
    label: 'Date',
    color: Color(0xFFE65100), // orange
    icon: Icons.calendar_today_rounded,
  ),
  textBlock(
    label: 'Text Block',
    color: Color(0xFF6A1B9A), // purple
    icon: Icons.article_rounded,
  );

  const XbrlElementType({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a single XBRL tag / element within a filing.
class XbrlElement {
  const XbrlElement({
    required this.id,
    required this.filingId,
    required this.elementName,
    required this.elementType,
    required this.label,
    required this.isRequired,
    this.value,
    this.unit,
    this.isCompleted = false,
    this.validationMessage,
    this.lastUpdated,
  });

  final String id;
  final String filingId;

  /// Qualified XBRL element name, e.g. "in-bfin:ProfitLossAfterTax"
  final String elementName;
  final XbrlElementType elementType;

  /// Human-readable label from taxonomy
  final String label;

  /// Entered value (always stored as string; UI parses based on type)
  final String? value;

  /// Unit for numeric elements, e.g. "INR", "shares"
  final String? unit;
  final bool isRequired;
  final bool isCompleted;

  /// Validation message if element fails validation
  final String? validationMessage;
  final DateTime? lastUpdated;

  bool get hasError =>
      validationMessage != null && validationMessage!.isNotEmpty;

  XbrlElement copyWith({
    String? id,
    String? filingId,
    String? elementName,
    XbrlElementType? elementType,
    String? label,
    String? value,
    String? unit,
    bool? isRequired,
    bool? isCompleted,
    String? validationMessage,
    DateTime? lastUpdated,
  }) {
    return XbrlElement(
      id: id ?? this.id,
      filingId: filingId ?? this.filingId,
      elementName: elementName ?? this.elementName,
      elementType: elementType ?? this.elementType,
      label: label ?? this.label,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      validationMessage: validationMessage ?? this.validationMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XbrlElement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
