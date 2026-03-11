import 'package:flutter/material.dart';

/// Types of material events requiring SEBI disclosure.
enum MaterialEventType {
  acquisition(
    label: 'Acquisition',
    icon: Icons.handshake_rounded,
    color: Color(0xFF1565C0),
  ),
  litigation(
    label: 'Litigation',
    icon: Icons.gavel_rounded,
    color: Color(0xFFC62828),
  ),
  penalty(
    label: 'Penalty',
    icon: Icons.report_rounded,
    color: Color(0xFFD4890E),
  ),
  boardChange(
    label: 'Board Change',
    icon: Icons.people_rounded,
    color: Color(0xFF6A1B9A),
  ),
  dividend(
    label: 'Dividend',
    icon: Icons.payments_rounded,
    color: Color(0xFF1A7A3A),
  ),
  restructuring(
    label: 'Restructuring',
    icon: Icons.account_tree_rounded,
    color: Color(0xFF0D7C7C),
  );

  const MaterialEventType({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Immutable model representing a material event for SEBI disclosure.
@immutable
class MaterialEvent {
  const MaterialEvent({
    required this.id,
    required this.clientId,
    required this.companyName,
    required this.eventType,
    required this.description,
    required this.eventDate,
    required this.disclosureDeadline,
    required this.isDisclosed,
    this.filingReference,
  });

  final String id;
  final String clientId;
  final String companyName;
  final MaterialEventType eventType;
  final String description;
  final DateTime eventDate;
  final DateTime disclosureDeadline;
  final bool isDisclosed;
  final String? filingReference;

  /// Hours remaining until disclosure deadline.
  int hoursUntilDeadline(DateTime now) {
    return disclosureDeadline.difference(now).inHours;
  }

  /// Whether the disclosure deadline has passed without filing.
  bool isOverdue(DateTime now) {
    return !isDisclosed && disclosureDeadline.isBefore(now);
  }

  MaterialEvent copyWith({
    String? id,
    String? clientId,
    String? companyName,
    MaterialEventType? eventType,
    String? description,
    DateTime? eventDate,
    DateTime? disclosureDeadline,
    bool? isDisclosed,
    String? filingReference,
  }) {
    return MaterialEvent(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      companyName: companyName ?? this.companyName,
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      disclosureDeadline: disclosureDeadline ?? this.disclosureDeadline,
      isDisclosed: isDisclosed ?? this.isDisclosed,
      filingReference: filingReference ?? this.filingReference,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MaterialEvent(id: $id, company: $companyName, '
      'type: ${eventType.label}, disclosed: $isDisclosed)';
}
