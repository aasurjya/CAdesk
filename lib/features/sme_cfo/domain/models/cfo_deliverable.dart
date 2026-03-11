import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Category of CFO deliverable committed in the retainer.
enum DeliverableType {
  misReport('MIS Report', Icons.bar_chart_rounded),
  cashFlowForecast('Cash Flow Forecast', Icons.waterfall_chart_rounded),
  taxReview('Tax Review', Icons.receipt_long_rounded),
  boardPack('Board Pack', Icons.folder_copy_rounded),
  budgetVariance('Budget Variance', Icons.compare_arrows_rounded),
  advanceTaxCalc('Advance Tax Calc', Icons.calculate_rounded),
  gstOutflow('GST Outflow Analysis', Icons.account_balance_rounded);

  const DeliverableType(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Workflow status of a single deliverable item.
enum DeliverableStatus {
  pending('Pending', Color(0xFF718096)),
  inProgress('In Progress', Color(0xFFD4890E)),
  delivered('Delivered', Color(0xFF0D7C7C)),
  approved('Approved', Color(0xFF1A7A3A));

  const DeliverableStatus(this.label, this.color);

  final String label;
  final Color color;
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Immutable model representing a single deliverable within a CFO retainer.
class CfoDeliverable {
  const CfoDeliverable({
    required this.id,
    required this.retainerId,
    required this.clientName,
    required this.title,
    required this.deliverableType,
    required this.dueDate,
    required this.status,
    this.completedAt,
  });

  final String id;
  final String retainerId;
  final String clientName;
  final String title;
  final DeliverableType deliverableType;
  final DateTime dueDate;
  final DeliverableStatus status;

  /// Set when the deliverable has been completed; null if still in progress.
  final DateTime? completedAt;

  // ---------------------------------------------------------------------------
  // Computed properties
  // ---------------------------------------------------------------------------

  /// Whether the deliverable is past its due date and not yet completed.
  bool get isOverdue {
    if (status == DeliverableStatus.delivered ||
        status == DeliverableStatus.approved) {
      return false;
    }
    return _today.isAfter(dueDate);
  }

  /// Days remaining until the due date (negative means overdue).
  int get daysLeft => dueDate.difference(_today).inDays;

  /// Human-readable relative time since completion, or empty string if not
  /// yet completed.
  String get timeAgo {
    final completed = completedAt;
    if (completed == null) return '';
    final diff = _today.difference(completed).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 30) return '$diff days ago';
    if (diff < 365) {
      final months = (diff / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }
    final years = (diff / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  CfoDeliverable copyWith({
    String? id,
    String? retainerId,
    String? clientName,
    String? title,
    DeliverableType? deliverableType,
    DateTime? dueDate,
    DeliverableStatus? status,
    DateTime? completedAt,
  }) {
    return CfoDeliverable(
      id: id ?? this.id,
      retainerId: retainerId ?? this.retainerId,
      clientName: clientName ?? this.clientName,
      title: title ?? this.title,
      deliverableType: deliverableType ?? this.deliverableType,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Pinned reference date used for computed date properties.
final _today = DateTime(2026, 3, 11);
