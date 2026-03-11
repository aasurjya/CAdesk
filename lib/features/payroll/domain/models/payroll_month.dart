import 'package:flutter/material.dart';

/// Processing status of a monthly payroll record.
enum PayrollStatus {
  draft(
    label: 'Draft',
    color: Color(0xFF718096),
    icon: Icons.edit_note_rounded,
  ),
  processed(
    label: 'Processed',
    color: Color(0xFF2A5B8C),
    icon: Icons.check_rounded,
  ),
  approved(
    label: 'Approved',
    color: Color(0xFFD4890E),
    icon: Icons.thumb_up_rounded,
  ),
  disbursed(
    label: 'Disbursed',
    color: Color(0xFF1A7A3A),
    icon: Icons.payments_rounded,
  );

  const PayrollStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable monthly payroll record for one employee.
class PayrollMonth {
  const PayrollMonth({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.workingDays,
    required this.presentDays,
    required this.lopDays,
    required this.basicPaid,
    required this.allowancesPaid,
    required this.grossPaid,
    required this.pfDeducted,
    required this.esiDeducted,
    required this.tdsDeducted,
    required this.otherDeductions,
    required this.netPaid,
    required this.status,
    this.disbursedDate,
  });

  final String id;
  final String employeeId;
  final String employeeName;

  /// 1–12
  final int month;
  final int year;

  final int workingDays;
  final int presentDays;
  final int lopDays;

  // Earnings
  final double basicPaid;
  final double allowancesPaid;
  final double grossPaid;

  // Deductions
  final double pfDeducted;
  final double esiDeducted;
  final double tdsDeducted;
  final double otherDeductions;
  final double netPaid;

  final PayrollStatus status;
  final DateTime? disbursedDate;

  double get totalDeductions =>
      pfDeducted + esiDeducted + tdsDeducted + otherDeductions;

  /// Human-readable period label, e.g. "Jan 2026".
  String get periodLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} $year';
  }

  PayrollMonth copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    int? month,
    int? year,
    int? workingDays,
    int? presentDays,
    int? lopDays,
    double? basicPaid,
    double? allowancesPaid,
    double? grossPaid,
    double? pfDeducted,
    double? esiDeducted,
    double? tdsDeducted,
    double? otherDeductions,
    double? netPaid,
    PayrollStatus? status,
    DateTime? disbursedDate,
  }) {
    return PayrollMonth(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      month: month ?? this.month,
      year: year ?? this.year,
      workingDays: workingDays ?? this.workingDays,
      presentDays: presentDays ?? this.presentDays,
      lopDays: lopDays ?? this.lopDays,
      basicPaid: basicPaid ?? this.basicPaid,
      allowancesPaid: allowancesPaid ?? this.allowancesPaid,
      grossPaid: grossPaid ?? this.grossPaid,
      pfDeducted: pfDeducted ?? this.pfDeducted,
      esiDeducted: esiDeducted ?? this.esiDeducted,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      netPaid: netPaid ?? this.netPaid,
      status: status ?? this.status,
      disbursedDate: disbursedDate ?? this.disbursedDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayrollMonth &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
