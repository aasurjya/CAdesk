import 'package:flutter/material.dart';

/// Types of compliance filings required for DPIIT startups.
enum StartupFilingType {
  annualReturn(
    label: 'Annual Return',
    icon: Icons.assignment_rounded,
  ),
  boardMeetingMinutes(
    label: 'Board Minutes',
    icon: Icons.groups_rounded,
  ),
  dpiitUpdate(
    label: 'DPIIT Update',
    icon: Icons.update_rounded,
  ),
  form56(
    label: 'Form 56',
    icon: Icons.description_rounded,
  ),
  itr(
    label: 'ITR',
    icon: Icons.receipt_long_rounded,
  ),
  gst(
    label: 'GST Return',
    icon: Icons.account_balance_rounded,
  );

  const StartupFilingType({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Filing status of a startup compliance item.
enum StartupFilingStatus {
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
    icon: Icons.warning_rounded,
  ),
  notApplicable(
    label: 'N/A',
    color: Color(0xFF718096),
    icon: Icons.block_rounded,
  );

  const StartupFilingStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a compliance filing for a startup.
@immutable
class StartupFiling {
  const StartupFiling({
    required this.id,
    required this.startupId,
    required this.entityName,
    required this.filingType,
    required this.dueDate,
    this.filedDate,
    required this.status,
    this.remarks,
  });

  final String id;
  final String startupId;
  final String entityName;
  final StartupFilingType filingType;
  final DateTime dueDate;
  final DateTime? filedDate;
  final StartupFilingStatus status;
  final String? remarks;

  /// Days remaining until the due date (negative if overdue).
  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  /// Returns a new [StartupFiling] with the given fields replaced.
  StartupFiling copyWith({
    String? id,
    String? startupId,
    String? entityName,
    StartupFilingType? filingType,
    DateTime? dueDate,
    DateTime? filedDate,
    StartupFilingStatus? status,
    String? remarks,
  }) {
    return StartupFiling(
      id: id ?? this.id,
      startupId: startupId ?? this.startupId,
      entityName: entityName ?? this.entityName,
      filingType: filingType ?? this.filingType,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartupFiling &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startupId == other.startupId &&
          filingType == other.filingType &&
          dueDate == other.dueDate &&
          filedDate == other.filedDate &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
        id,
        startupId,
        filingType,
        dueDate,
        filedDate,
        status,
      );

  @override
  String toString() =>
      'StartupFiling(id: $id, type: ${filingType.label}, '
      'status: ${status.label})';
}
