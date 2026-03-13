import 'package:flutter/material.dart';

/// Transfer Pricing method as per Income Tax Act (Section 92C).
enum TpMethod {
  cup(label: 'CUP', description: 'Comparable Uncontrolled Price'),
  rpsm(label: 'RPSM', description: 'Resale Price Method'),
  tnmm(label: 'TNMM', description: 'Transactional Net Margin Method'),
  cpm(label: 'CPM', description: 'Cost Plus Method'),
  psm(label: 'PSM', description: 'Profit Split Method'),
  other(label: 'Other', description: 'Other Method');

  const TpMethod({required this.label, required this.description});

  final String label;
  final String description;
}

/// Filing / documentation status of a Transfer Pricing transaction.
enum TpStatus {
  draft(label: 'Draft', color: Color(0xFF757575)),
  underReview(label: 'Under Review', color: Color(0xFFD4890E)),
  documented(label: 'Documented', color: Color(0xFF1565C0)),
  filed(label: 'Filed', color: Color(0xFF1A7A3A));

  const TpStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

/// Immutable model representing a single Transfer Pricing related-party
/// transaction and its TP documentation requirements.
@immutable
class TpTransaction {
  const TpTransaction({
    required this.id,
    required this.clientId,
    required this.assessmentYear,
    required this.relatedParty,
    required this.transactionType,
    required this.transactionValue,
    required this.tpMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.documentationDue,
  });

  final String id;
  final String clientId;

  /// Assessment year in "YYYY-YY" format, e.g. "2024-25".
  final String assessmentYear;

  /// Name of the related party (associated enterprise).
  final String relatedParty;

  /// Nature of the international transaction (e.g. "Loan", "Service", "Royalty").
  final String transactionType;

  /// Value of the transaction in INR.
  final double transactionValue;

  final TpMethod tpMethod;

  /// Due date for TP documentation / Form 3CEB filing.
  final DateTime? documentationDue;

  final TpStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;

  TpTransaction copyWith({
    String? id,
    String? clientId,
    String? assessmentYear,
    String? relatedParty,
    String? transactionType,
    double? transactionValue,
    TpMethod? tpMethod,
    DateTime? documentationDue,
    TpStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TpTransaction(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      relatedParty: relatedParty ?? this.relatedParty,
      transactionType: transactionType ?? this.transactionType,
      transactionValue: transactionValue ?? this.transactionValue,
      tpMethod: tpMethod ?? this.tpMethod,
      documentationDue: documentationDue ?? this.documentationDue,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TpTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientId == other.clientId &&
          assessmentYear == other.assessmentYear &&
          relatedParty == other.relatedParty &&
          transactionType == other.transactionType &&
          transactionValue == other.transactionValue &&
          tpMethod == other.tpMethod &&
          documentationDue == other.documentationDue &&
          status == other.status &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    assessmentYear,
    relatedParty,
    transactionType,
    transactionValue,
    tpMethod,
    documentationDue,
    status,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'TpTransaction(id: $id, clientId: $clientId, '
      'ay: $assessmentYear, method: ${tpMethod.label}, '
      'status: ${status.label})';
}
