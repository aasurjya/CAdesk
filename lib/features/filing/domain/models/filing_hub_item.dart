import 'package:flutter/material.dart';

/// Category of a filing in the Filing Hub.
enum FilingCategory {
  itr(
    label: 'Income Tax',
    shortLabel: 'ITR',
    color: Color(0xFF1B3A5C),
    icon: Icons.receipt_long_rounded,
  ),
  gst(
    label: 'GST',
    shortLabel: 'GST',
    color: Color(0xFF0D7C7C),
    icon: Icons.receipt_rounded,
  ),
  tds(
    label: 'TDS',
    shortLabel: 'TDS',
    color: Color(0xFFE8890C),
    icon: Icons.description_rounded,
  ),
  mca(
    label: 'MCA',
    shortLabel: 'MCA',
    color: Color(0xFF7B1FA2),
    icon: Icons.business_rounded,
  );

  const FilingCategory({
    required this.label,
    required this.shortLabel,
    required this.color,
    required this.icon,
  });

  final String label;
  final String shortLabel;
  final Color color;
  final IconData icon;
}

/// Lifecycle status of a filing item in the Filing Hub.
enum FilingHubStatus {
  overdue(
    label: 'Overdue',
    color: Color(0xFFC62828),
    icon: Icons.warning_rounded,
  ),
  dueThisWeek(
    label: 'Due This Week',
    color: Color(0xFFEF6C00),
    icon: Icons.schedule_rounded,
  ),
  inProgress(
    label: 'In Progress',
    color: Color(0xFF1565C0),
    icon: Icons.edit_rounded,
  ),
  draft(label: 'Draft', color: Color(0xFF718096), icon: Icons.drafts_rounded),
  filed(
    label: 'Filed',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  verified(
    label: 'Verified',
    color: Color(0xFF0D7C7C),
    icon: Icons.verified_rounded,
  );

  const FilingHubStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a single filing item in the Filing Hub.
class FilingHubItem {
  const FilingHubItem({
    required this.id,
    required this.clientName,
    required this.filingType,
    required this.subType,
    required this.status,
    required this.dueDate,
    this.filedDate,
  });

  final String id;
  final String clientName;
  final FilingCategory filingType;

  /// e.g. "ITR-1", "GSTR-3B", "Form 24Q"
  final String subType;
  final FilingHubStatus status;
  final DateTime dueDate;
  final DateTime? filedDate;

  /// Number of days until due date (negative if overdue).
  int get daysRemaining {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueMidnight.difference(todayMidnight).inDays;
  }

  FilingHubItem copyWith({
    String? id,
    String? clientName,
    FilingCategory? filingType,
    String? subType,
    FilingHubStatus? status,
    DateTime? dueDate,
    DateTime? filedDate,
  }) {
    return FilingHubItem(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      filingType: filingType ?? this.filingType,
      subType: subType ?? this.subType,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingHubItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
