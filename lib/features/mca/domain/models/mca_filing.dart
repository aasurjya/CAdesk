import 'package:flutter/material.dart';

/// E-Form types under Companies Act 2013 filed with MCA.
enum McaFormType {
  mgt7(
    label: 'MGT-7',
    description: 'Annual Return',
    color: Color(0xFF1B3A5C),
  ),
  mgt9(
    label: 'MGT-9',
    description: 'Extract of Annual Return',
    color: Color(0xFF2A5B8C),
  ),
  aoc4(
    label: 'AOC-4',
    description: 'Financial Statements',
    color: Color(0xFF0D7C7C),
  ),
  dir3kyc(
    label: 'DIR-3 KYC',
    description: 'Director KYC',
    color: Color(0xFFE8890C),
  ),
  adt1(
    label: 'ADT-1',
    description: 'Appointment of Auditor',
    color: Color(0xFF1A7A3A),
  ),
  inc22a(
    label: 'INC-22A',
    description: 'Active Company Tagging',
    color: Color(0xFF7B1FA2),
  ),
  form8(
    label: 'Form 8',
    description: 'Statement of Account & Solvency',
    color: Color(0xFF00838F),
  ),
  form11(
    label: 'Form 11',
    description: 'Annual Return (LLP)',
    color: Color(0xFF558B2F),
  ),
  mgmt14(
    label: 'MGT-14',
    description: 'Board Resolutions',
    color: Color(0xFFD84315),
  );

  const McaFormType({
    required this.label,
    required this.description,
    required this.color,
  });

  final String label;
  final String description;
  final Color color;
}

/// Filing status in the MCA workflow.
enum McaFilingStatus {
  draft(
    label: 'Draft',
    color: Color(0xFF718096),
    icon: Icons.edit_note_rounded,
  ),
  pending(
    label: 'Pending',
    color: Color(0xFFD4890E),
    icon: Icons.hourglass_empty_rounded,
  ),
  filed(
    label: 'Filed',
    color: Color(0xFF2A5B8C),
    icon: Icons.upload_file_rounded,
  ),
  approved(
    label: 'Approved',
    color: Color(0xFF1A7A3A),
    icon: Icons.check_circle_rounded,
  ),
  rejected(
    label: 'Rejected',
    color: Color(0xFFC62828),
    icon: Icons.cancel_rounded,
  );

  const McaFilingStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing a single MCA/ROC filing.
class McaFiling {
  const McaFiling({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.cin,
    required this.formType,
    required this.dueDate,
    required this.status,
    required this.financialYear,
    this.filedDate,
    this.srn,
    this.fees = 0,
    this.penaltyAmount = 0,
    this.certifyingProfessional,
  });

  final String id;
  final String companyId;
  final String companyName;

  /// Corporate Identification Number
  final String cin;
  final McaFormType formType;
  final DateTime dueDate;
  final DateTime? filedDate;

  /// Service Request Number assigned by MCA portal after filing
  final String? srn;
  final McaFilingStatus status;

  /// e.g. "2024-25"
  final String financialYear;

  /// Government fees in INR
  final double fees;

  /// Penalty for late filing in INR
  final double penaltyAmount;

  /// CA / CS certifying the form
  final String? certifyingProfessional;

  bool get isOverdue {
    if (status == McaFilingStatus.filed ||
        status == McaFilingStatus.approved) { return false; }
    return dueDate.isBefore(DateTime(2026, 3, 10));
  }

  bool get hasPenalty => penaltyAmount > 0;

  McaFiling copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? cin,
    McaFormType? formType,
    DateTime? dueDate,
    DateTime? filedDate,
    String? srn,
    McaFilingStatus? status,
    String? financialYear,
    double? fees,
    double? penaltyAmount,
    String? certifyingProfessional,
  }) {
    return McaFiling(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      cin: cin ?? this.cin,
      formType: formType ?? this.formType,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      srn: srn ?? this.srn,
      status: status ?? this.status,
      financialYear: financialYear ?? this.financialYear,
      fees: fees ?? this.fees,
      penaltyAmount: penaltyAmount ?? this.penaltyAmount,
      certifyingProfessional:
          certifyingProfessional ?? this.certifyingProfessional,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McaFiling &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
