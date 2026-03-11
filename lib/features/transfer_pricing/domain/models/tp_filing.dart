import 'package:flutter/material.dart';

/// Status of a Form 3CEB filing.
enum TpFilingStatus {
  notStarted(
    label: 'Not Started',
    color: Color(0xFF718096),
    icon: Icons.circle_outlined,
  ),
  dataCollection(
    label: 'Data Collection',
    color: Color(0xFFD4890E),
    icon: Icons.folder_open_rounded,
  ),
  underPreparation(
    label: 'Under Preparation',
    color: Color(0xFF1565C0),
    icon: Icons.edit_document,
  ),
  caReview(
    label: 'CA Review',
    color: Color(0xFF6A1B9A),
    icon: Icons.rate_review_rounded,
  ),
  filed(
    label: 'Filed',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  );

  const TpFilingStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model for a single international transaction within Form 3CEB.
@immutable
class TpTransaction {
  const TpTransaction({
    required this.description,
    required this.method,
    required this.alpValue,
    required this.actualValue,
    required this.adjustment,
  });

  final String description;
  final String method;
  final double alpValue;
  final double actualValue;
  final double adjustment;

  TpTransaction copyWith({
    String? description,
    String? method,
    double? alpValue,
    double? actualValue,
    double? adjustment,
  }) {
    return TpTransaction(
      description: description ?? this.description,
      method: method ?? this.method,
      alpValue: alpValue ?? this.alpValue,
      actualValue: actualValue ?? this.actualValue,
      adjustment: adjustment ?? this.adjustment,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TpTransaction &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          method == other.method;

  @override
  int get hashCode => Object.hash(description, method);
}

/// Immutable model representing a Form 3CEB filing.
@immutable
class TpFiling {
  const TpFiling({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.assessmentYear,
    required this.certifyingCA,
    required this.dueDate,
    required this.status,
    required this.internationalTransactions,
    this.filingDate,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String assessmentYear;
  final String certifyingCA;
  final DateTime dueDate;
  final DateTime? filingDate;
  final TpFilingStatus status;
  final List<TpTransaction> internationalTransactions;

  /// Total ALP value across all transactions.
  double get totalAlpValue =>
      internationalTransactions.fold(0, (sum, t) => sum + t.alpValue);

  /// Total actual value across all transactions.
  double get totalActualValue =>
      internationalTransactions.fold(0, (sum, t) => sum + t.actualValue);

  /// Total adjustment across all transactions.
  double get totalAdjustment =>
      internationalTransactions.fold(0, (sum, t) => sum + t.adjustment);

  TpFiling copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? assessmentYear,
    String? certifyingCA,
    DateTime? dueDate,
    DateTime? filingDate,
    TpFilingStatus? status,
    List<TpTransaction>? internationalTransactions,
  }) {
    return TpFiling(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      certifyingCA: certifyingCA ?? this.certifyingCA,
      dueDate: dueDate ?? this.dueDate,
      filingDate: filingDate ?? this.filingDate,
      status: status ?? this.status,
      internationalTransactions:
          internationalTransactions ?? this.internationalTransactions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TpFiling && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TpFiling(id: $id, client: $clientName, '
      'ay: $assessmentYear, status: ${status.label})';
}
