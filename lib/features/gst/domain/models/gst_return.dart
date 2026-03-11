import 'package:flutter/material.dart';

/// GST return form types.
enum GstReturnType {
  gstr1(label: 'GSTR-1', description: 'Outward supplies'),
  gstr3b(label: 'GSTR-3B', description: 'Summary return'),
  gstr9(label: 'GSTR-9', description: 'Annual return'),
  gstr9c(label: 'GSTR-9C', description: 'Reconciliation statement'),
  gstr2a(label: 'GSTR-2A', description: 'Auto-drafted inward supplies'),
  gstr2b(label: 'GSTR-2B', description: 'Auto-drafted ITC statement');

  const GstReturnType({required this.label, required this.description});

  final String label;
  final String description;
}

/// Filing status of a GST return.
enum GstReturnStatus {
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
  lateFiled(
    label: 'Late Filed',
    color: Color(0xFFC62828),
    icon: Icons.warning_amber_rounded,
  ),
  notApplicable(
    label: 'N/A',
    color: Color(0xFF718096),
    icon: Icons.remove_circle_outline_rounded,
  );

  const GstReturnStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a single GST return filing.
class GstReturn {
  const GstReturn({
    required this.id,
    required this.clientId,
    required this.gstin,
    required this.returnType,
    required this.periodMonth,
    required this.periodYear,
    required this.dueDate,
    required this.status,
    this.filedDate,
    this.taxableValue = 0,
    this.igst = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.cess = 0,
    this.itcClaimed = 0,
  });

  final String id;
  final String clientId;
  final String gstin;
  final GstReturnType returnType;

  /// 1-12
  final int periodMonth;
  final int periodYear;
  final DateTime dueDate;
  final DateTime? filedDate;
  final GstReturnStatus status;

  final double taxableValue;
  final double igst;
  final double cgst;
  final double sgst;
  final double cess;
  final double itcClaimed;

  double get totalTax => igst + cgst + sgst + cess;

  /// Human-readable period label, e.g. "Jan 2026".
  String get periodLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[periodMonth - 1]} $periodYear';
  }

  GstReturn copyWith({
    String? id,
    String? clientId,
    String? gstin,
    GstReturnType? returnType,
    int? periodMonth,
    int? periodYear,
    DateTime? dueDate,
    DateTime? filedDate,
    GstReturnStatus? status,
    double? taxableValue,
    double? igst,
    double? cgst,
    double? sgst,
    double? cess,
    double? itcClaimed,
  }) {
    return GstReturn(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      gstin: gstin ?? this.gstin,
      returnType: returnType ?? this.returnType,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      taxableValue: taxableValue ?? this.taxableValue,
      igst: igst ?? this.igst,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      cess: cess ?? this.cess,
      itcClaimed: itcClaimed ?? this.itcClaimed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstReturn && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
