import 'package:ca_app/features/xbrl/domain/models/xbrl_document.dart';

/// Severity level for an XBRL validation finding.
enum XbrlValidationSeverity {
  /// Blocking error — the document cannot be submitted to MCA.
  error,

  /// Non-blocking warning — the document may be submitted but should be reviewed.
  warning,
}

/// Immutable XBRL validation finding.
class XbrlValidationError {
  const XbrlValidationError({
    required this.field,
    required this.message,
    required this.severity,
  });

  /// The field or element name that failed validation.
  final String field;

  /// Human-readable description of the issue.
  final String message;

  /// Severity of this finding.
  final XbrlValidationSeverity severity;

  XbrlValidationError copyWith({
    String? field,
    String? message,
    XbrlValidationSeverity? severity,
  }) {
    return XbrlValidationError(
      field: field ?? this.field,
      message: message ?? this.message,
      severity: severity ?? this.severity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XbrlValidationError &&
        other.field == field &&
        other.message == message &&
        other.severity == severity;
  }

  @override
  int get hashCode => Object.hash(field, message, severity);

  @override
  String toString() =>
      'XbrlValidationError(${severity.name}) $field: $message';
}

/// Stateless singleton that validates a completed [XbrlDocument] against MCA
/// XBRL filing requirements.
///
/// Checks performed:
/// 1. Non-empty company name, CIN, and schemaRef.
/// 2. At least one context and one unit defined.
/// 3. All mandatory in-gaap elements present as facts.
/// 4. Every fact references an existing context.
/// 5. Every monetary fact references an existing unit.
class XbrlValidationService {
  XbrlValidationService._();

  static final XbrlValidationService instance = XbrlValidationService._();

  /// Mandatory in-gaap element qualified names required by MCA for AOC-4 XBRL.
  static const List<String> _mandatoryElements = [
    'in-gaap:CashAndCashEquivalents',
    'in-gaap:TradeReceivables',
    'in-gaap:PropertyPlantAndEquipment',
    'in-gaap:Assets',
    'in-gaap:ShareCapital',
    'in-gaap:EquityAndLiabilities',
    'in-gaap:Revenue',
    'in-gaap:ProfitBeforeTax',
    'in-gaap:ProfitAfterTax',
    'in-gaap:BasicEarningsPerShare',
    'in-gaap:CashFlowFromOperatingActivities',
    'in-gaap:CashFlowFromInvestingActivities',
    'in-gaap:CashFlowFromFinancingActivities',
  ];

  /// Validates [doc] and returns a list of [XbrlValidationError]s.
  ///
  /// Returns an empty list when the document is valid for MCA submission.
  List<XbrlValidationError> validate(XbrlDocument doc) {
    final errors = <XbrlValidationError>[];

    _validateMetadata(doc, errors);
    _validateContextsAndUnits(doc, errors);
    _validateMandatoryElements(doc, errors);
    _validateFactReferences(doc, errors);

    return List.unmodifiable(errors);
  }

  // ---------------------------------------------------------------------------
  // Private validation steps
  // ---------------------------------------------------------------------------

  void _validateMetadata(
    XbrlDocument doc,
    List<XbrlValidationError> errors,
  ) {
    if (doc.companyName.trim().isEmpty) {
      errors.add(
        const XbrlValidationError(
          field: 'companyName',
          message: 'Company name must not be empty',
          severity: XbrlValidationSeverity.error,
        ),
      );
    }
    if (doc.cin.trim().isEmpty) {
      errors.add(
        const XbrlValidationError(
          field: 'cin',
          message: 'CIN must not be empty',
          severity: XbrlValidationSeverity.error,
        ),
      );
    }
    if (doc.schemaRef.trim().isEmpty) {
      errors.add(
        const XbrlValidationError(
          field: 'schemaRef',
          message: 'Schema reference (taxonomy URL) must not be empty',
          severity: XbrlValidationSeverity.error,
        ),
      );
    }
  }

  void _validateContextsAndUnits(
    XbrlDocument doc,
    List<XbrlValidationError> errors,
  ) {
    if (doc.contexts.isEmpty) {
      errors.add(
        const XbrlValidationError(
          field: 'contexts',
          message: 'At least one XBRL context must be defined',
          severity: XbrlValidationSeverity.error,
        ),
      );
    }
    if (doc.units.isEmpty) {
      errors.add(
        const XbrlValidationError(
          field: 'units',
          message: 'At least one XBRL unit must be defined',
          severity: XbrlValidationSeverity.error,
        ),
      );
    }
  }

  void _validateMandatoryElements(
    XbrlDocument doc,
    List<XbrlValidationError> errors,
  ) {
    final presentElements =
        doc.facts.map((f) => f.elementName).toSet();

    for (final element in _mandatoryElements) {
      if (!presentElements.contains(element)) {
        errors.add(
          XbrlValidationError(
            field: element,
            message: 'Mandatory element $element is missing from the document',
            severity: XbrlValidationSeverity.error,
          ),
        );
      }
    }
  }

  void _validateFactReferences(
    XbrlDocument doc,
    List<XbrlValidationError> errors,
  ) {
    final contextIds = doc.contexts.map((c) => c.contextId).toSet();
    final unitIds = doc.units.map((u) => u.unitId).toSet();

    for (final fact in doc.facts) {
      if (!contextIds.contains(fact.contextRef)) {
        errors.add(
          XbrlValidationError(
            field: fact.elementName,
            message:
                'Fact references context "${fact.contextRef}" which is not '
                'defined in the document',
            severity: XbrlValidationSeverity.error,
          ),
        );
      }

      if (fact.unitRef != null && !unitIds.contains(fact.unitRef)) {
        errors.add(
          XbrlValidationError(
            field: fact.elementName,
            message:
                'Fact references unit "${fact.unitRef}" which is not defined '
                'in the document',
            severity: XbrlValidationSeverity.error,
          ),
        );
      }
    }
  }
}
