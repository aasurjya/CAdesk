import 'package:flutter/material.dart';

/// TDS/TCS return form types as prescribed by the Income Tax Department.
enum TdsFormType {
  form24Q(label: '24Q', description: 'Salary TDS'),
  form26Q(label: '26Q', description: 'Non-Salary TDS'),
  form27Q(label: '27Q', description: 'NRI TDS'),
  form27EQ(label: '27EQ', description: 'TCS');

  const TdsFormType({required this.label, required this.description});

  final String label;
  final String description;
}

/// Quarter of the financial year for TDS return filing.
enum TdsQuarter {
  q1(label: 'Q1', description: 'Apr - Jun'),
  q2(label: 'Q2', description: 'Jul - Sep'),
  q3(label: 'Q3', description: 'Oct - Dec'),
  q4(label: 'Q4', description: 'Jan - Mar');

  const TdsQuarter({required this.label, required this.description});

  final String label;
  final String description;
}

/// Filing status of a TDS/TCS return.
enum TdsReturnStatus {
  pending(
    label: 'Pending',
    color: Color(0xFFD4890E),
    icon: Icons.hourglass_empty_rounded,
  ),
  prepared(
    label: 'Prepared',
    color: Color(0xFF1565C0),
    icon: Icons.description_rounded,
  ),
  filed(
    label: 'Filed',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  revised(
    label: 'Revised',
    color: Color(0xFF6A1B9A),
    icon: Icons.replay_rounded,
  );

  const TdsReturnStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a single TDS/TCS return filing.
@immutable
class TdsReturn {
  const TdsReturn({
    required this.id,
    required this.deductorId,
    required this.tan,
    required this.formType,
    required this.quarter,
    required this.financialYear,
    required this.status,
    required this.totalDeductions,
    required this.totalTaxDeducted,
    required this.totalDeposited,
    this.filedDate,
    this.tokenNumber,
  });

  final String id;
  final String deductorId;
  final String tan;
  final TdsFormType formType;
  final TdsQuarter quarter;
  final String financialYear;
  final TdsReturnStatus status;
  final double totalDeductions;
  final double totalTaxDeducted;
  final double totalDeposited;
  final DateTime? filedDate;
  final String? tokenNumber;

  /// Returns a new [TdsReturn] with the given fields replaced.
  TdsReturn copyWith({
    String? id,
    String? deductorId,
    String? tan,
    TdsFormType? formType,
    TdsQuarter? quarter,
    String? financialYear,
    TdsReturnStatus? status,
    double? totalDeductions,
    double? totalTaxDeducted,
    double? totalDeposited,
    DateTime? filedDate,
    String? tokenNumber,
  }) {
    return TdsReturn(
      id: id ?? this.id,
      deductorId: deductorId ?? this.deductorId,
      tan: tan ?? this.tan,
      formType: formType ?? this.formType,
      quarter: quarter ?? this.quarter,
      financialYear: financialYear ?? this.financialYear,
      status: status ?? this.status,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      totalTaxDeducted: totalTaxDeducted ?? this.totalTaxDeducted,
      totalDeposited: totalDeposited ?? this.totalDeposited,
      filedDate: filedDate ?? this.filedDate,
      tokenNumber: tokenNumber ?? this.tokenNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsReturn &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deductorId == other.deductorId &&
          tan == other.tan &&
          formType == other.formType &&
          quarter == other.quarter &&
          financialYear == other.financialYear &&
          status == other.status &&
          totalDeductions == other.totalDeductions &&
          totalTaxDeducted == other.totalTaxDeducted &&
          totalDeposited == other.totalDeposited &&
          filedDate == other.filedDate &&
          tokenNumber == other.tokenNumber;

  @override
  int get hashCode => Object.hash(
        id,
        deductorId,
        tan,
        formType,
        quarter,
        financialYear,
        status,
        totalDeductions,
        totalTaxDeducted,
        totalDeposited,
        filedDate,
        tokenNumber,
      );

  @override
  String toString() =>
      'TdsReturn(id: $id, form: ${formType.label}, '
      'quarter: ${quarter.label}, fy: $financialYear, '
      'status: ${status.label})';
}
