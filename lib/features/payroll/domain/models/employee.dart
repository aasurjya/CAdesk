/// Immutable employee model with salary structure and statutory details.
class Employee {
  const Employee({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.designation,
    required this.department,
    required this.joiningDate,
    required this.basicSalary,
    required this.hra,
    required this.da,
    required this.conveyance,
    required this.medicalAllowance,
    required this.specialAllowance,
    required this.grossSalary,
    required this.pfContribution,
    required this.esiContribution,
    required this.tdsMonthly,
    required this.netSalary,
    required this.pfNumber,
    required this.esiNumber,
    required this.bankAccount,
    required this.ifscCode,
    required this.pan,
    required this.isActive,
    required this.leaveBalance,
  });

  final String id;
  final String employeeCode;
  final String name;
  final String designation;
  final String department;
  final DateTime joiningDate;

  // Salary components (monthly, in INR)
  final double basicSalary;
  final double hra;
  final double da;
  final double conveyance;
  final double medicalAllowance;
  final double specialAllowance;
  final double grossSalary;

  // Statutory deductions (monthly)
  final double pfContribution; // Employee PF 12% of basic
  final double esiContribution; // Employee ESI 0.75% of gross (if gross ≤ 21k)
  final double tdsMonthly; // TDS under 115BAC

  final double netSalary;

  // Statutory registration numbers
  final String pfNumber; // e.g. MH/12345/12345
  final String esiNumber; // e.g. 31-12345-678

  // Bank details
  final String bankAccount;
  final String ifscCode;
  final String pan;

  final bool isActive;

  /// Leave balances: key = leave type (e.g. 'CL', 'PL', 'SL'), value = days.
  final Map<String, int> leaveBalance;

  /// Total annual CTC = grossSalary * 12 + employer PF (12% basic) * 12.
  double get annualCtc => (grossSalary + basicSalary * 0.12) * 12;

  Employee copyWith({
    String? id,
    String? employeeCode,
    String? name,
    String? designation,
    String? department,
    DateTime? joiningDate,
    double? basicSalary,
    double? hra,
    double? da,
    double? conveyance,
    double? medicalAllowance,
    double? specialAllowance,
    double? grossSalary,
    double? pfContribution,
    double? esiContribution,
    double? tdsMonthly,
    double? netSalary,
    String? pfNumber,
    String? esiNumber,
    String? bankAccount,
    String? ifscCode,
    String? pan,
    bool? isActive,
    Map<String, int>? leaveBalance,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      joiningDate: joiningDate ?? this.joiningDate,
      basicSalary: basicSalary ?? this.basicSalary,
      hra: hra ?? this.hra,
      da: da ?? this.da,
      conveyance: conveyance ?? this.conveyance,
      medicalAllowance: medicalAllowance ?? this.medicalAllowance,
      specialAllowance: specialAllowance ?? this.specialAllowance,
      grossSalary: grossSalary ?? this.grossSalary,
      pfContribution: pfContribution ?? this.pfContribution,
      esiContribution: esiContribution ?? this.esiContribution,
      tdsMonthly: tdsMonthly ?? this.tdsMonthly,
      netSalary: netSalary ?? this.netSalary,
      pfNumber: pfNumber ?? this.pfNumber,
      esiNumber: esiNumber ?? this.esiNumber,
      bankAccount: bankAccount ?? this.bankAccount,
      ifscCode: ifscCode ?? this.ifscCode,
      pan: pan ?? this.pan,
      isActive: isActive ?? this.isActive,
      leaveBalance: leaveBalance ?? this.leaveBalance,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
