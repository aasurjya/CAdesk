import 'package:flutter/material.dart';

/// Types of statutory payroll returns.
enum StatutoryReturnType {
  pfEcr(
    label: 'PF ECR',
    description: 'PF Electronic Challan Return',
    color: Color(0xFF1B3A5C),
  ),
  esiReturn(
    label: 'ESI Return',
    description: 'ESI Half-Yearly Return',
    color: Color(0xFF0D7C7C),
  ),
  ptReturn(
    label: 'PT Return',
    description: 'Professional Tax Return',
    color: Color(0xFF2A5B8C),
  ),
  tds24q(
    label: 'TDS 24Q',
    description: 'Quarterly TDS on Salary',
    color: Color(0xFFD4890E),
  );

  const StatutoryReturnType({
    required this.label,
    required this.description,
    required this.color,
  });

  final String label;
  final String description;
  final Color color;
}

/// Filing status of a statutory return.
enum StatutoryReturnStatus {
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
  );

  const StatutoryReturnStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable statutory return / challan model.
class StatutoryReturn {
  const StatutoryReturn({
    required this.id,
    required this.period,
    required this.returnType,
    required this.dueDate,
    required this.status,
    required this.totalEmployees,
    required this.totalContribution,
    this.filedDate,
    this.challanNumber,
  });

  final String id;

  /// Human-readable period, e.g. "Feb 2026" or "Q3 FY 2025-26".
  final String period;
  final StatutoryReturnType returnType;
  final DateTime dueDate;
  final DateTime? filedDate;
  final StatutoryReturnStatus status;
  final int totalEmployees;
  final double totalContribution;

  /// Challan/acknowledgement number after filing.
  final String? challanNumber;

  bool get isOverdue {
    final today = DateTime.utc(2026, 3, 10);
    return status == StatutoryReturnStatus.pending &&
        dueDate.isBefore(today);
  }

  StatutoryReturn copyWith({
    String? id,
    String? period,
    StatutoryReturnType? returnType,
    DateTime? dueDate,
    DateTime? filedDate,
    StatutoryReturnStatus? status,
    int? totalEmployees,
    double? totalContribution,
    String? challanNumber,
  }) {
    return StatutoryReturn(
      id: id ?? this.id,
      period: period ?? this.period,
      returnType: returnType ?? this.returnType,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      totalEmployees: totalEmployees ?? this.totalEmployees,
      totalContribution: totalContribution ?? this.totalContribution,
      challanNumber: challanNumber ?? this.challanNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatutoryReturn &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
