import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Reason for filing an updated return (ITR-U).
enum UpdateReason {
  incomeNotReported('Income Not Reported'),
  wrongHead('Wrong Head of Income'),
  wrongRate('Wrong Rate of Tax'),
  carriedForwardLoss('Carried Forward Loss'),
  other('Other');

  const UpdateReason(this.label);
  final String label;
}

/// Status of an ITR-U filing.
enum ItrUStatus {
  draft('Draft'),
  computationDone('Computation Done'),
  paymentPending('Payment Pending'),
  filed('Filed');

  const ItrUStatus(this.label);
  final String label;

  Color get color {
    switch (this) {
      case ItrUStatus.draft:
        return AppColors.neutral400;
      case ItrUStatus.computationDone:
        return AppColors.primaryVariant;
      case ItrUStatus.paymentPending:
        return AppColors.warning;
      case ItrUStatus.filed:
        return AppColors.success;
    }
  }

  IconData get icon {
    switch (this) {
      case ItrUStatus.draft:
        return Icons.edit_outlined;
      case ItrUStatus.computationDone:
        return Icons.calculate_outlined;
      case ItrUStatus.paymentPending:
        return Icons.payment;
      case ItrUStatus.filed:
        return Icons.check_circle_outline;
    }
  }
}

/// Immutable model representing an ITR-U (Updated Return) filing.
class ItrUFiling {
  const ItrUFiling({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.pan,
    required this.originalAssessmentYear,
    required this.originalFilingDate,
    required this.updateReason,
    required this.additionalTax,
    required this.penaltyPercentage,
    required this.penaltyAmount,
    required this.totalPayable,
    required this.status,
    required this.filingDeadline,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String pan;
  final String originalAssessmentYear;
  final DateTime originalFilingDate;
  final UpdateReason updateReason;
  final double additionalTax;
  final int penaltyPercentage;
  final double penaltyAmount;
  final double totalPayable;
  final ItrUStatus status;
  final DateTime filingDeadline;

  /// Days remaining until filing deadline.
  int get daysUntilDeadline {
    return filingDeadline.difference(DateTime.now()).inDays;
  }

  ItrUFiling copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? pan,
    String? originalAssessmentYear,
    DateTime? originalFilingDate,
    UpdateReason? updateReason,
    double? additionalTax,
    int? penaltyPercentage,
    double? penaltyAmount,
    double? totalPayable,
    ItrUStatus? status,
    DateTime? filingDeadline,
  }) {
    return ItrUFiling(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      pan: pan ?? this.pan,
      originalAssessmentYear:
          originalAssessmentYear ?? this.originalAssessmentYear,
      originalFilingDate: originalFilingDate ?? this.originalFilingDate,
      updateReason: updateReason ?? this.updateReason,
      additionalTax: additionalTax ?? this.additionalTax,
      penaltyPercentage: penaltyPercentage ?? this.penaltyPercentage,
      penaltyAmount: penaltyAmount ?? this.penaltyAmount,
      totalPayable: totalPayable ?? this.totalPayable,
      status: status ?? this.status,
      filingDeadline: filingDeadline ?? this.filingDeadline,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItrUFiling && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
