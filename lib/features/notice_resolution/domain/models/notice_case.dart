import 'package:flutter/material.dart';

enum NoticeType {
  intimation143_1('Intimation u/s 143(1)'),
  scrutiny143_3('Scrutiny u/s 143(3)'),
  reopening148('Reopening u/s 148'),
  penaltyNotice('Penalty Notice'),
  tdsDefault('TDS Default'),
  gstDemand('GST Demand'),
  mcaNotice('MCA Notice');

  const NoticeType(this.label);
  final String label;
}

enum NoticeStatus {
  pendingReview('Pending Review', Color(0xFFD4890E), Icons.hourglass_top_rounded),
  draftReady('Draft Ready', Color(0xFF1B3A5C), Icons.edit_document),
  submitted('Submitted', Color(0xFF0D7C7C), Icons.send_rounded),
  closed('Closed', Color(0xFF1A7A3A), Icons.check_circle_rounded),
  escalated('Escalated', Color(0xFFC62828), Icons.warning_rounded);

  const NoticeStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

enum NoticeSeverity {
  critical('Critical', Color(0xFFC62828)),
  high('High', Color(0xFFD4890E)),
  medium('Medium', Color(0xFF1B3A5C)),
  low('Low', Color(0xFF718096));

  const NoticeSeverity(this.label, this.color);
  final String label;
  final Color color;
}

class NoticeCase {
  const NoticeCase({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.noticeType,
    required this.section,
    required this.receivedDate,
    required this.dueDate,
    required this.status,
    required this.severity,
    required this.amountInDispute,
    required this.description,
  });

  final String id;
  final String clientId;
  final String clientName;
  final NoticeType noticeType;
  final String section;
  final DateTime receivedDate;
  final DateTime dueDate;
  final NoticeStatus status;
  final NoticeSeverity severity;
  final double amountInDispute;
  final String description;

  /// Returns a human-readable relative time since notice was received.
  String get timeAgo {
    final now = DateTime(2026, 3, 11);
    final diff = now.difference(receivedDate);
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    return 'Today';
  }

  /// Returns the dispute amount formatted in Indian numbering (lakhs/crores).
  String get formattedAmount {
    if (amountInDispute >= 10000000) {
      final cr = amountInDispute / 10000000;
      return '₹${cr.toStringAsFixed(1)} Cr';
    }
    if (amountInDispute >= 100000) {
      final lakh = amountInDispute / 100000;
      return '₹${lakh.toStringAsFixed(1)} L';
    }
    return '₹${amountInDispute.toStringAsFixed(0)}';
  }

  /// Returns days remaining until due date (negative if overdue).
  int get daysLeft {
    final now = DateTime(2026, 3, 11);
    return dueDate.difference(now).inDays;
  }

  NoticeCase copyWith({
    String? id,
    String? clientId,
    String? clientName,
    NoticeType? noticeType,
    String? section,
    DateTime? receivedDate,
    DateTime? dueDate,
    NoticeStatus? status,
    NoticeSeverity? severity,
    double? amountInDispute,
    String? description,
  }) {
    return NoticeCase(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      noticeType: noticeType ?? this.noticeType,
      section: section ?? this.section,
      receivedDate: receivedDate ?? this.receivedDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      amountInDispute: amountInDispute ?? this.amountInDispute,
      description: description ?? this.description,
    );
  }
}
