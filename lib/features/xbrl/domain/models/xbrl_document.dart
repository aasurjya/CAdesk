import 'package:ca_app/features/xbrl/domain/models/xbrl_context.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_fact.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_unit.dart';

/// Immutable XBRL instance document assembling all components required for an
/// MCA AOC-4 XBRL filing.
///
/// Contains the entity metadata, reporting period, contexts, units, and facts
/// needed to produce a valid XBRL XML document.
class XbrlDocument {
  XbrlDocument({
    required this.instanceDocumentId,
    required this.companyName,
    required this.cin,
    required this.reportingPeriodStart,
    required this.reportingPeriodEnd,
    required this.contexts,
    required this.units,
    required this.facts,
    required this.schemaRef,
  });

  /// Unique identifier for this instance document.
  final String instanceDocumentId;

  /// Legal name of the reporting company.
  final String companyName;

  /// Corporate Identification Number assigned by MCA.
  final String cin;

  /// Start date of the financial reporting period (e.g. 2023-04-01).
  final DateTime reportingPeriodStart;

  /// End date of the financial reporting period (e.g. 2024-03-31).
  final DateTime reportingPeriodEnd;

  /// XBRL contexts defining entity and period for each set of facts.
  final List<XbrlContext> contexts;

  /// Unit declarations (typically just the INR unit).
  final List<XbrlUnit> units;

  /// All tagged facts in this document.
  final List<XbrlFact> facts;

  /// URL to the taxonomy schema referenced by this document.
  final String schemaRef;

  XbrlDocument copyWith({
    String? instanceDocumentId,
    String? companyName,
    String? cin,
    DateTime? reportingPeriodStart,
    DateTime? reportingPeriodEnd,
    List<XbrlContext>? contexts,
    List<XbrlUnit>? units,
    List<XbrlFact>? facts,
    String? schemaRef,
  }) {
    return XbrlDocument(
      instanceDocumentId: instanceDocumentId ?? this.instanceDocumentId,
      companyName: companyName ?? this.companyName,
      cin: cin ?? this.cin,
      reportingPeriodStart: reportingPeriodStart ?? this.reportingPeriodStart,
      reportingPeriodEnd: reportingPeriodEnd ?? this.reportingPeriodEnd,
      contexts: contexts ?? this.contexts,
      units: units ?? this.units,
      facts: facts ?? this.facts,
      schemaRef: schemaRef ?? this.schemaRef,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! XbrlDocument) return false;
    if (other.instanceDocumentId != instanceDocumentId) return false;
    if (other.companyName != companyName) return false;
    if (other.cin != cin) return false;
    if (other.reportingPeriodStart != reportingPeriodStart) return false;
    if (other.reportingPeriodEnd != reportingPeriodEnd) return false;
    if (other.schemaRef != schemaRef) return false;
    if (other.contexts.length != contexts.length) return false;
    if (other.units.length != units.length) return false;
    if (other.facts.length != facts.length) return false;
    for (var i = 0; i < contexts.length; i++) {
      if (other.contexts[i] != contexts[i]) return false;
    }
    for (var i = 0; i < units.length; i++) {
      if (other.units[i] != units[i]) return false;
    }
    for (var i = 0; i < facts.length; i++) {
      if (other.facts[i] != facts[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    instanceDocumentId,
    companyName,
    cin,
    reportingPeriodStart,
    reportingPeriodEnd,
    schemaRef,
    Object.hashAll(contexts),
    Object.hashAll(units),
    Object.hashAll(facts),
  );

  @override
  String toString() =>
      'XbrlDocument($instanceDocumentId, $companyName, ${facts.length} facts)';
}
