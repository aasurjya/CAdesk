import 'package:flutter/material.dart';

/// Approval route for FDI transactions.
enum FdiApprovalRoute {
  automatic(label: 'Automatic', description: 'RBI automatic route'),
  government(label: 'Government', description: 'Government approval route');

  const FdiApprovalRoute({required this.label, required this.description});

  final String label;
  final String description;
}

/// Status of an FDI transaction.
enum FdiTransactionStatus {
  initiated(
    label: 'Initiated',
    color: Color(0xFF718096),
    icon: Icons.play_circle_outline_rounded,
  ),
  underReview(
    label: 'Under Review',
    color: Color(0xFFD4890E),
    icon: Icons.hourglass_empty_rounded,
  ),
  approved(
    label: 'Approved',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  rejected(
    label: 'Rejected',
    color: Color(0xFFC62828),
    icon: Icons.cancel_rounded,
  ),
  completed(
    label: 'Completed',
    color: Color(0xFF1565C0),
    icon: Icons.verified_rounded,
  );

  const FdiTransactionStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a Foreign Direct Investment transaction.
@immutable
class FdiTransaction {
  const FdiTransaction({
    required this.id,
    required this.clientId,
    required this.entityName,
    required this.investorName,
    required this.investorCountry,
    required this.amount,
    required this.currency,
    required this.equityPercentage,
    required this.sectorCap,
    required this.approvalRoute,
    required this.transactionDate,
    required this.status,
  });

  final String id;
  final String clientId;
  final String entityName;
  final String investorName;
  final String investorCountry;
  final double amount;
  final String currency;
  final double equityPercentage;
  final double sectorCap;
  final FdiApprovalRoute approvalRoute;
  final DateTime transactionDate;
  final FdiTransactionStatus status;

  FdiTransaction copyWith({
    String? id,
    String? clientId,
    String? entityName,
    String? investorName,
    String? investorCountry,
    double? amount,
    String? currency,
    double? equityPercentage,
    double? sectorCap,
    FdiApprovalRoute? approvalRoute,
    DateTime? transactionDate,
    FdiTransactionStatus? status,
  }) {
    return FdiTransaction(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      entityName: entityName ?? this.entityName,
      investorName: investorName ?? this.investorName,
      investorCountry: investorCountry ?? this.investorCountry,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      equityPercentage: equityPercentage ?? this.equityPercentage,
      sectorCap: sectorCap ?? this.sectorCap,
      approvalRoute: approvalRoute ?? this.approvalRoute,
      transactionDate: transactionDate ?? this.transactionDate,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FdiTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FdiTransaction(id: $id, entity: $entityName, '
      'investor: $investorName, amount: $amount $currency)';
}
