import 'package:flutter/material.dart';

/// Types of SEBI disclosures.
enum DisclosureType {
  quarterlyFinancial(
    label: 'Quarterly Financial',
    description: 'Quarterly financial results',
  ),
  corporateGovernance(
    label: 'Corporate Governance',
    description: 'Corporate governance report',
  ),
  relatedParty(
    label: 'Related Party',
    description: 'Related party transactions',
  ),
  materialEvent(
    label: 'Material Event',
    description: 'Material event disclosure',
  ),
  shareholding(label: 'Shareholding', description: 'Shareholding pattern');

  const DisclosureType({required this.label, required this.description});

  final String label;
  final String description;
}

/// Stock exchange for SEBI disclosure.
enum StockExchange {
  bse(label: 'BSE', description: 'Bombay Stock Exchange'),
  nse(label: 'NSE', description: 'National Stock Exchange'),
  both(label: 'BSE & NSE', description: 'Both exchanges');

  const StockExchange({required this.label, required this.description});

  final String label;
  final String description;
}

/// Filing status for SEBI disclosures.
enum DisclosureStatus {
  pending(
    label: 'Pending',
    color: Color(0xFFD4890E),
    icon: Icons.hourglass_empty_rounded,
  ),
  filed(
    label: 'Filed',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  overdue(
    label: 'Overdue',
    color: Color(0xFFC62828),
    icon: Icons.warning_amber_rounded,
  ),
  underReview(
    label: 'Under Review',
    color: Color(0xFF1565C0),
    icon: Icons.visibility_rounded,
  ),
  draft(
    label: 'Draft',
    color: Color(0xFF718096),
    icon: Icons.edit_note_rounded,
  );

  const DisclosureStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a SEBI disclosure filing.
@immutable
class SebiDisclosure {
  const SebiDisclosure({
    required this.id,
    required this.clientId,
    required this.companyName,
    required this.disclosureType,
    required this.exchange,
    required this.dueDate,
    required this.status,
    this.filedDate,
    this.period,
    this.remarks,
  });

  final String id;
  final String clientId;
  final String companyName;
  final DisclosureType disclosureType;
  final StockExchange exchange;
  final DateTime dueDate;
  final DateTime? filedDate;
  final DisclosureStatus status;
  final String? period;
  final String? remarks;

  SebiDisclosure copyWith({
    String? id,
    String? clientId,
    String? companyName,
    DisclosureType? disclosureType,
    StockExchange? exchange,
    DateTime? dueDate,
    DateTime? filedDate,
    DisclosureStatus? status,
    String? period,
    String? remarks,
  }) {
    return SebiDisclosure(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      companyName: companyName ?? this.companyName,
      disclosureType: disclosureType ?? this.disclosureType,
      exchange: exchange ?? this.exchange,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      period: period ?? this.period,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SebiDisclosure &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SebiDisclosure(id: $id, company: $companyName, '
      'type: ${disclosureType.label}, status: ${status.label})';
}
