import 'package:flutter/material.dart';

/// Category of a compliance deadline.
enum ComplianceCategory {
  incomeTax(
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
  roc(
    label: 'ROC',
    shortLabel: 'ROC',
    color: Color(0xFF7B1FA2),
    icon: Icons.business_rounded,
  ),
  other(
    label: 'Other',
    shortLabel: 'OTH',
    color: Color(0xFF718096),
    icon: Icons.folder_rounded,
  );

  const ComplianceCategory({
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

/// Recurrence frequency for a compliance deadline.
enum ComplianceFrequency {
  monthly('Monthly'),
  quarterly('Quarterly'),
  annual('Annual');

  const ComplianceFrequency(this.label);

  final String label;
}

/// Current lifecycle status of a compliance deadline.
enum ComplianceStatus {
  upcoming(
    label: 'Upcoming',
    color: Color(0xFF1565C0),
    icon: Icons.schedule_rounded,
  ),
  dueToday(
    label: 'Due Today',
    color: Color(0xFFEF6C00),
    icon: Icons.today_rounded,
  ),
  overdue(
    label: 'Overdue',
    color: Color(0xFFC62828),
    icon: Icons.warning_rounded,
  ),
  completed(
    label: 'Completed',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  );

  const ComplianceStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a statutory compliance deadline.
class ComplianceDeadline {
  const ComplianceDeadline({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.applicableTo,
    required this.isRecurring,
    required this.frequency,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final ComplianceCategory category;
  final DateTime dueDate;
  final List<String> applicableTo;
  final bool isRecurring;
  final ComplianceFrequency frequency;
  final ComplianceStatus status;

  /// Number of days until this deadline (negative if overdue).
  int get daysRemaining {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueMidnight.difference(todayMidnight).inDays;
  }

  /// Computed status based on the current date and days remaining.
  ComplianceStatus get computedStatus {
    if (status == ComplianceStatus.completed) return ComplianceStatus.completed;
    final days = daysRemaining;
    if (days < 0) return ComplianceStatus.overdue;
    if (days == 0) return ComplianceStatus.dueToday;
    return ComplianceStatus.upcoming;
  }

  ComplianceDeadline copyWith({
    String? id,
    String? title,
    String? description,
    ComplianceCategory? category,
    DateTime? dueDate,
    List<String>? applicableTo,
    bool? isRecurring,
    ComplianceFrequency? frequency,
    ComplianceStatus? status,
  }) {
    return ComplianceDeadline(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      applicableTo: applicableTo ?? this.applicableTo,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplianceDeadline && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
