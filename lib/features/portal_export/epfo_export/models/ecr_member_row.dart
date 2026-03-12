/// A single employee's data row for inclusion in an EPFO ECR file.
///
/// Represents one line in the ECR pipe-delimited format.
/// All monetary values are stored in **paise** (1/100th of a rupee).
/// The ECR file generator converts to rupees when writing the file.
///
/// ## ECR row field order (EPFO v2.0)
/// 1. UAN
/// 2. Member Name
/// 3. Gross Wages
/// 4. EPF Wages (capped at ₹15,000)
/// 5. EPS Wages (capped at ₹15,000)
/// 6. EDLI Wages (same as EPF wages)
/// 7. Employee EPF contribution (12% of EPF wages)
/// 8. Employer EPS contribution (8.33% of EPS wages)
/// 9. Employer EPF contribution (12% − EPS)
/// 10. NCP Days (Non-Contributing Period — LOP days)
/// 11. Refunds (usually 0)
class EcrMemberRow {
  const EcrMemberRow({
    required this.uan,
    required this.memberName,
    required this.grossWagesPaise,
    required this.epfWagesPaise,
    required this.epsWagesPaise,
    required this.edliWagesPaise,
    required this.employeeEpfPaise,
    required this.employerEpsPaise,
    required this.employerEpfPaise,
    required this.ncp,
    required this.refundsPaise,
  });

  /// 12-digit Universal Account Number.
  final String uan;

  /// Employee's full name as registered with EPFO.
  final String memberName;

  /// Gross wages for the month in paise.
  final int grossWagesPaise;

  /// EPF wages in paise (capped at ₹15,000 = 1,500,000 paise).
  final int epfWagesPaise;

  /// EPS wages in paise (capped at ₹15,000 = 1,500,000 paise).
  final int epsWagesPaise;

  /// EDLI wages in paise (same as EPF wages per EPFO spec).
  final int edliWagesPaise;

  /// Employee's EPF contribution in paise (12% of EPF wages).
  final int employeeEpfPaise;

  /// Employer's EPS contribution in paise (8.33% of EPS wages).
  final int employerEpsPaise;

  /// Employer's EPF contribution in paise (total 12% minus EPS share).
  final int employerEpfPaise;

  /// Non-Contributing Period days (Loss of Pay days), 0–31.
  final int ncp;

  /// Refund amount in paise (usually 0).
  final int refundsPaise;

  EcrMemberRow copyWith({
    String? uan,
    String? memberName,
    int? grossWagesPaise,
    int? epfWagesPaise,
    int? epsWagesPaise,
    int? edliWagesPaise,
    int? employeeEpfPaise,
    int? employerEpsPaise,
    int? employerEpfPaise,
    int? ncp,
    int? refundsPaise,
  }) {
    return EcrMemberRow(
      uan: uan ?? this.uan,
      memberName: memberName ?? this.memberName,
      grossWagesPaise: grossWagesPaise ?? this.grossWagesPaise,
      epfWagesPaise: epfWagesPaise ?? this.epfWagesPaise,
      epsWagesPaise: epsWagesPaise ?? this.epsWagesPaise,
      edliWagesPaise: edliWagesPaise ?? this.edliWagesPaise,
      employeeEpfPaise: employeeEpfPaise ?? this.employeeEpfPaise,
      employerEpsPaise: employerEpsPaise ?? this.employerEpsPaise,
      employerEpfPaise: employerEpfPaise ?? this.employerEpfPaise,
      ncp: ncp ?? this.ncp,
      refundsPaise: refundsPaise ?? this.refundsPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EcrMemberRow &&
        other.uan == uan &&
        other.memberName == memberName &&
        other.grossWagesPaise == grossWagesPaise &&
        other.epfWagesPaise == epfWagesPaise &&
        other.epsWagesPaise == epsWagesPaise &&
        other.edliWagesPaise == edliWagesPaise &&
        other.employeeEpfPaise == employeeEpfPaise &&
        other.employerEpsPaise == employerEpsPaise &&
        other.employerEpfPaise == employerEpfPaise &&
        other.ncp == ncp &&
        other.refundsPaise == refundsPaise;
  }

  @override
  int get hashCode => Object.hash(
    uan,
    memberName,
    grossWagesPaise,
    epfWagesPaise,
    epsWagesPaise,
    edliWagesPaise,
    employeeEpfPaise,
    employerEpsPaise,
    employerEpfPaise,
    ncp,
    refundsPaise,
  );

  @override
  String toString() =>
      'EcrMemberRow(uan: $uan, name: $memberName, '
      'gross: $grossWagesPaise, epf: $epfWagesPaise, ncp: $ncp)';
}
