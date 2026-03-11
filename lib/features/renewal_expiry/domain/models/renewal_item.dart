import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

enum RenewalItemType {
  retainer('Retainer Agreement', Icons.handshake_rounded),
  dscCertificate('DSC Certificate', Icons.security_rounded),
  gstRegistration('GST Registration', Icons.receipt_long_rounded),
  trademarkLicense('Trademark License', Icons.verified_rounded),
  shopAct('Shop Act License', Icons.store_rounded),
  isoAudit('ISO Audit', Icons.workspace_premium_rounded),
  digitalSignature('Digital Signature', Icons.draw_rounded),
  professionalTax('Professional Tax', Icons.account_balance_rounded);

  const RenewalItemType(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum RenewalStatus {
  upToDate('Up to Date', AppColors.success, Icons.check_circle_rounded),
  dueSoon('Due Soon', AppColors.warning, Icons.schedule_rounded),
  overdue('Overdue', AppColors.error, Icons.error_rounded),
  renewed('Renewed', AppColors.secondary, Icons.autorenew_rounded),
  cancelled('Cancelled', AppColors.neutral400, Icons.cancel_rounded);

  const RenewalStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class RenewalItem {
  const RenewalItem({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.itemType,
    required this.dueDate,
    required this.status,
    required this.fee,
    required this.notes,
    this.renewedDate,
    this.reminderSentAt,
  });

  final String id;
  final String clientId;
  final String clientName;
  final RenewalItemType itemType;
  final DateTime dueDate;
  final DateTime? renewedDate;
  final RenewalStatus status;
  final double fee;
  final DateTime? reminderSentAt;
  final String notes;

  /// Today's reference date (same pattern as other features in this codebase).
  static final _today = DateTime(2026, 3, 11);

  int get daysUntilDue => dueDate.difference(_today).inDays;

  bool get isOverdue => _today.isAfter(dueDate);

  bool get isDueSoon {
    if (isOverdue) return false;
    return daysUntilDue < 30;
  }

  String get formattedFee => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(fee);

  RenewalItem copyWith({
    String? id,
    String? clientId,
    String? clientName,
    RenewalItemType? itemType,
    DateTime? dueDate,
    DateTime? renewedDate,
    RenewalStatus? status,
    double? fee,
    DateTime? reminderSentAt,
    String? notes,
  }) {
    return RenewalItem(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      itemType: itemType ?? this.itemType,
      dueDate: dueDate ?? this.dueDate,
      renewedDate: renewedDate ?? this.renewedDate,
      status: status ?? this.status,
      fee: fee ?? this.fee,
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      notes: notes ?? this.notes,
    );
  }
}
