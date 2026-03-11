import 'package:flutter/material.dart';

/// FEMA form types for RBI filings.
enum FemaFormType {
  fcGpr(label: 'FC-GPR', description: 'Foreign Currency - Gross Provisional Return'),
  fcTrs(label: 'FC-TRS', description: 'Foreign Currency - Transfer of Shares'),
  apr(label: 'APR', description: 'Annual Performance Report'),
  fla(label: 'FLA', description: 'Foreign Liabilities & Assets'),
  odi(label: 'ODI', description: 'Overseas Direct Investment'),
  ecb(label: 'ECB', description: 'External Commercial Borrowing');

  const FemaFormType({required this.label, required this.description});

  final String label;
  final String description;
}

/// Filing status for FEMA submissions.
enum FemaFilingStatus {
  draft(
    label: 'Draft',
    color: Color(0xFF718096),
    icon: Icons.edit_note_rounded,
  ),
  submitted(
    label: 'Submitted',
    color: Color(0xFF1565C0),
    icon: Icons.send_rounded,
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
  pendingClarification(
    label: 'Pending Clarification',
    color: Color(0xFFD4890E),
    icon: Icons.help_outline_rounded,
  );

  const FemaFilingStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a single FEMA/RBI filing.
@immutable
class FemaFiling {
  const FemaFiling({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.formType,
    required this.filingDate,
    required this.dueDate,
    required this.status,
    required this.amount,
    required this.currency,
    this.referenceNumber,
    this.adBankName,
    this.remarks,
  });

  final String id;
  final String clientId;
  final String clientName;
  final FemaFormType formType;
  final DateTime filingDate;
  final DateTime dueDate;
  final FemaFilingStatus status;
  final double amount;
  final String currency;
  final String? referenceNumber;
  final String? adBankName;
  final String? remarks;

  FemaFiling copyWith({
    String? id,
    String? clientId,
    String? clientName,
    FemaFormType? formType,
    DateTime? filingDate,
    DateTime? dueDate,
    FemaFilingStatus? status,
    double? amount,
    String? currency,
    String? referenceNumber,
    String? adBankName,
    String? remarks,
  }) {
    return FemaFiling(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      formType: formType ?? this.formType,
      filingDate: filingDate ?? this.filingDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      adBankName: adBankName ?? this.adBankName,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FemaFiling &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FemaFiling(id: $id, form: ${formType.label}, '
      'status: ${status.label}, amount: $amount $currency)';
}
