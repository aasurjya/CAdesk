import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Type of e-proceeding under the Income Tax Act.
enum ProceedingType {
  scrutiny143_3('Scrutiny u/s 143(3)'),
  reassessment147('Reassessment u/s 147'),
  search153A('Search u/s 153A'),
  rectification154('Rectification u/s 154'),
  appealEffect('Appeal Effect'),
  penalty('Penalty Proceeding');

  const ProceedingType(this.label);
  final String label;
}

/// Status of an e-proceeding.
enum ProceedingStatus {
  noticeReceived('Notice Received'),
  responseDrafted('Response Drafted'),
  responseSubmitted('Response Submitted'),
  hearingScheduled('Hearing Scheduled'),
  orderPassed('Order Passed'),
  appealFiled('Appeal Filed');

  const ProceedingStatus(this.label);
  final String label;

  Color get color {
    switch (this) {
      case ProceedingStatus.noticeReceived:
        return AppColors.error;
      case ProceedingStatus.responseDrafted:
        return AppColors.warning;
      case ProceedingStatus.responseSubmitted:
        return AppColors.primaryVariant;
      case ProceedingStatus.hearingScheduled:
        return AppColors.accent;
      case ProceedingStatus.orderPassed:
        return AppColors.neutral600;
      case ProceedingStatus.appealFiled:
        return AppColors.secondary;
    }
  }

  IconData get icon {
    switch (this) {
      case ProceedingStatus.noticeReceived:
        return Icons.notification_important;
      case ProceedingStatus.responseDrafted:
        return Icons.edit_document;
      case ProceedingStatus.responseSubmitted:
        return Icons.send;
      case ProceedingStatus.hearingScheduled:
        return Icons.event;
      case ProceedingStatus.orderPassed:
        return Icons.gavel;
      case ProceedingStatus.appealFiled:
        return Icons.balance;
    }
  }
}

/// Immutable model representing a faceless assessment e-proceeding.
class EProceeding {
  const EProceeding({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.pan,
    required this.assessmentYear,
    required this.proceedingType,
    required this.noticeDate,
    required this.responseDeadline,
    required this.status,
    required this.nfacReferenceNumber,
    this.assignedOfficer,
    this.demandAmount,
    this.remarks,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String pan;
  final String assessmentYear;
  final ProceedingType proceedingType;
  final DateTime noticeDate;
  final DateTime responseDeadline;
  final ProceedingStatus status;
  final String nfacReferenceNumber;
  final String? assignedOfficer;
  final double? demandAmount;
  final String? remarks;

  /// Days remaining until response deadline.
  int get daysUntilDeadline {
    return responseDeadline.difference(DateTime.now()).inDays;
  }

  /// Whether the deadline is urgent (within 7 days).
  bool get isUrgent => daysUntilDeadline <= 7 && daysUntilDeadline >= 0;

  /// Whether the deadline has passed.
  bool get isOverdue => daysUntilDeadline < 0;

  EProceeding copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? pan,
    String? assessmentYear,
    ProceedingType? proceedingType,
    DateTime? noticeDate,
    DateTime? responseDeadline,
    ProceedingStatus? status,
    String? nfacReferenceNumber,
    String? assignedOfficer,
    double? demandAmount,
    String? remarks,
  }) {
    return EProceeding(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      proceedingType: proceedingType ?? this.proceedingType,
      noticeDate: noticeDate ?? this.noticeDate,
      responseDeadline: responseDeadline ?? this.responseDeadline,
      status: status ?? this.status,
      nfacReferenceNumber: nfacReferenceNumber ?? this.nfacReferenceNumber,
      assignedOfficer: assignedOfficer ?? this.assignedOfficer,
      demandAmount: demandAmount ?? this.demandAmount,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EProceeding && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
