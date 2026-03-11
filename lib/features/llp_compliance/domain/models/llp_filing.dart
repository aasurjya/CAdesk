import 'package:flutter/material.dart';

/// LLP form types required for compliance.
enum LLPFormType {
  form11(label: 'Form 11', description: 'Annual Return'),
  form8(label: 'Form 8', description: 'Statement of Account'),
  form3(label: 'Form 3', description: 'LLP Agreement Change'),
  form4(label: 'Form 4', description: 'Partner Change'),
  itr5(label: 'ITR-5', description: 'Income Tax Return'),
  formDir3Kyc(label: 'DIR-3 KYC', description: 'Partner KYC');

  const LLPFormType({required this.label, required this.description});

  final String label;
  final String description;
}

/// Filing status for LLP compliance forms.
enum LLPFilingStatus {
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
  overdue(
    label: 'Overdue',
    color: Color(0xFFC62828),
    icon: Icons.warning_rounded,
  );

  const LLPFilingStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing an LLP compliance filing
/// with penalty calculation under MCA rules.
@immutable
class LLPFiling {
  const LLPFiling({
    required this.id,
    required this.llpId,
    required this.llpName,
    required this.formType,
    required this.dueDate,
    this.filedDate,
    required this.status,
    required this.financialYear,
    required this.penaltyPerDay,
    required this.maxPenalty,
    required this.currentPenalty,
    this.certifyingProfessional,
  });

  final String id;
  final String llpId;
  final String llpName;
  final LLPFormType formType;
  final DateTime dueDate;
  final DateTime? filedDate;
  final LLPFilingStatus status;
  final String financialYear;

  /// Penalty per day of delay in INR (typically 100).
  final int penaltyPerDay;

  /// Maximum penalty cap in INR (typically 1,00,000).
  final int maxPenalty;

  /// Current accumulated penalty in INR.
  final int currentPenalty;
  final String? certifyingProfessional;

  /// Days overdue (0 if not overdue).
  int get daysOverdue {
    if (status != LLPFilingStatus.overdue) return 0;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .difference(dueDate)
        .inDays
        .clamp(0, 9999);
  }

  /// Returns a new [LLPFiling] with the given fields replaced.
  LLPFiling copyWith({
    String? id,
    String? llpId,
    String? llpName,
    LLPFormType? formType,
    DateTime? dueDate,
    DateTime? filedDate,
    LLPFilingStatus? status,
    String? financialYear,
    int? penaltyPerDay,
    int? maxPenalty,
    int? currentPenalty,
    String? certifyingProfessional,
  }) {
    return LLPFiling(
      id: id ?? this.id,
      llpId: llpId ?? this.llpId,
      llpName: llpName ?? this.llpName,
      formType: formType ?? this.formType,
      dueDate: dueDate ?? this.dueDate,
      filedDate: filedDate ?? this.filedDate,
      status: status ?? this.status,
      financialYear: financialYear ?? this.financialYear,
      penaltyPerDay: penaltyPerDay ?? this.penaltyPerDay,
      maxPenalty: maxPenalty ?? this.maxPenalty,
      currentPenalty: currentPenalty ?? this.currentPenalty,
      certifyingProfessional:
          certifyingProfessional ?? this.certifyingProfessional,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LLPFiling &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          llpId == other.llpId &&
          formType == other.formType &&
          dueDate == other.dueDate &&
          status == other.status &&
          financialYear == other.financialYear;

  @override
  int get hashCode => Object.hash(
        id,
        llpId,
        formType,
        dueDate,
        status,
        financialYear,
      );

  @override
  String toString() =>
      'LLPFiling(id: $id, form: ${formType.label}, '
      'status: ${status.label}, penalty: $currentPenalty)';
}
