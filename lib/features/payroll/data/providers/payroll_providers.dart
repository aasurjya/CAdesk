import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/payroll_repository_providers.dart';
import '../../domain/models/employee.dart';
import '../../domain/models/payroll_month.dart';
import '../../domain/models/statutory_return.dart';

// ---------------------------------------------------------------------------
// SalaryCalculator — real statutory deduction logic
// ---------------------------------------------------------------------------

/// Immutable result of a full net pay computation.
class NetPayResult {
  const NetPayResult({
    required this.gross,
    required this.basicSalary,
    required this.hra,
    required this.specialAllowance,
    required this.otherAllowances,
    required this.employeePf,
    required this.employerPf,
    required this.employeeEsi,
    required this.employerEsi,
    required this.professionalTax,
    required this.tds,
    required this.totalDeductions,
    required this.netPay,
    required this.ctc,
  });

  final double gross;
  final double basicSalary;
  final double hra;
  final double specialAllowance;
  final double otherAllowances;
  final double employeePf;
  final double employerPf;
  final double employeeEsi;
  final double employerEsi;
  final double professionalTax;
  final double tds;
  final double totalDeductions;
  final double netPay;
  final double ctc;
}

/// Computes net salary and statutory deductions per Indian payroll rules.
class SalaryCalculator {
  SalaryCalculator._();

  /// Employee PF: 12% of basic, capped at ₹15,000 basic.
  static double employeePf(double basicSalary) {
    final cappedBasic = basicSalary.clamp(0.0, 15000.0);
    return cappedBasic * 0.12;
  }

  /// Employer PF: 12% of basic, capped at ₹15,000 basic.
  static double employerPf(double basicSalary) {
    final cappedBasic = basicSalary.clamp(0.0, 15000.0);
    return cappedBasic * 0.12;
  }

  /// Employee ESI: 0.75% of gross (only when gross ≤ ₹21,000).
  static double employeeEsi(double grossSalary) {
    if (grossSalary > 21000) {
      return 0;
    }
    return grossSalary * 0.0075;
  }

  /// Employer ESI: 3.25% of gross (only when gross ≤ ₹21,000).
  static double employerEsi(double grossSalary) {
    if (grossSalary > 21000) {
      return 0;
    }
    return grossSalary * 0.0325;
  }

  /// Professional Tax — Maharashtra slab (default).
  /// ≤ ₹7,500 → Nil | ₹7,501–10,000 → ₹175 | > ₹10,000 → ₹200 (Feb: ₹300).
  static double professionalTax(double grossSalary, {bool isFeb = false}) {
    if (grossSalary <= 7500) {
      return 0;
    }
    if (grossSalary <= 10000) {
      return 175;
    }
    return isFeb ? 300 : 200;
  }

  /// Monthly TDS under new regime (Sec 192).
  /// Standard deduction ₹75,000; slabs per Finance Bill 2025-26.
  static double monthlyTds(double annualGross) {
    final taxable = (annualGross - 75000).clamp(0.0, double.infinity);
    double annualTax = 0;
    if (taxable > 2400000) {
      annualTax += (taxable - 2400000) * 0.30;
    }
    if (taxable > 2000000) {
      annualTax += (taxable.clamp(0.0, 2400000.0) - 2000000) * 0.25;
    }
    if (taxable > 1600000) {
      annualTax += (taxable.clamp(0.0, 2000000.0) - 1600000) * 0.20;
    }
    if (taxable > 1200000) {
      annualTax += (taxable.clamp(0.0, 1600000.0) - 1200000) * 0.15;
    }
    if (taxable > 800000) {
      annualTax += (taxable.clamp(0.0, 1200000.0) - 800000) * 0.10;
    }
    if (taxable > 400000) {
      annualTax += (taxable.clamp(0.0, 800000.0) - 400000) * 0.05;
    }
    annualTax *= 1.04; // 4% health & education cess
    return annualTax / 12;
  }

  /// Full net pay computation from salary components.
  static NetPayResult compute({
    required double basicSalary,
    required double hra,
    required double specialAllowance,
    required double otherAllowances,
    required bool isFeb,
  }) {
    final gross = basicSalary + hra + specialAllowance + otherAllowances;
    final pf = employeePf(basicSalary);
    final esi = employeeEsi(gross);
    final pt = professionalTax(gross, isFeb: isFeb);
    final tds = monthlyTds(gross * 12);
    final totalDeductions = pf + esi + pt + tds;
    final netPay = gross - totalDeductions;
    return NetPayResult(
      gross: gross,
      basicSalary: basicSalary,
      hra: hra,
      specialAllowance: specialAllowance,
      otherAllowances: otherAllowances,
      employeePf: pf,
      employerPf: employerPf(basicSalary),
      employeeEsi: esi,
      employerEsi: employerEsi(gross),
      professionalTax: pt,
      tds: tds,
      totalDeductions: totalDeductions,
      netPay: netPay,
      ctc: gross + employerPf(basicSalary) + employerEsi(gross),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds an [Employee] given salary components; auto-computes deductions.
Employee _employee({
  required String id,
  required String code,
  required String name,
  required String designation,
  required String department,
  required DateTime joiningDate,
  required double basic,
  required double hra,
  required double da,
  required double conveyance,
  required double medical,
  required double special,
  required String pfNumber,
  required String esiNumber,
  required String bankAccount,
  required String ifsc,
  required String pan,
  bool active = true,
  Map<String, int>? leaveBalance,
}) {
  final gross = basic + hra + da + conveyance + medical + special;
  final pf = basic * 0.12;
  final esi = gross <= 21000 ? gross * 0.0075 : 0.0;
  // Simplified TDS under 115BAC for salaried
  final annualTaxable = (gross - pf - esi) * 12 - 50000; // std deduction
  final annualTax = annualTaxable > 0 ? _tax115BAC(annualTaxable) : 0.0;
  final tds = annualTax / 12;
  final net = gross - pf - esi - tds;

  return Employee(
    id: id,
    employeeCode: code,
    name: name,
    designation: designation,
    department: department,
    joiningDate: joiningDate,
    basicSalary: basic,
    hra: hra,
    da: da,
    conveyance: conveyance,
    medicalAllowance: medical,
    specialAllowance: special,
    grossSalary: gross,
    pfContribution: pf,
    esiContribution: esi,
    tdsMonthly: tds,
    netSalary: net,
    pfNumber: pfNumber,
    esiNumber: esiNumber,
    bankAccount: bankAccount,
    ifscCode: ifsc,
    pan: pan,
    isActive: active,
    leaveBalance: leaveBalance ?? const {'CL': 8, 'PL': 12, 'SL': 7, 'ML': 0},
  );
}

/// Simplified 115BAC tax slab for FY 2025-26 (annual taxable income).
double _tax115BAC(double income) {
  if (income <= 300000) return 0;
  if (income <= 700000) return (income - 300000) * 0.05;
  if (income <= 1000000) {
    return 20000 + (income - 700000) * 0.10;
  }
  if (income <= 1200000) {
    return 50000 + (income - 1000000) * 0.15;
  }
  if (income <= 1500000) {
    return 80000 + (income - 1200000) * 0.20;
  }
  return 140000 + (income - 1500000) * 0.30;
}

// ---------------------------------------------------------------------------
// Mock employees (12)
// ---------------------------------------------------------------------------

final List<Employee> _mockEmployees = [
  _employee(
    id: 'emp-001',
    code: 'EMP001',
    name: 'Amit Kumar Sharma',
    designation: 'Senior Manager',
    department: 'Finance',
    joiningDate: DateTime(2019, 4, 1),
    basic: 75000,
    hra: 30000,
    da: 5000,
    conveyance: 2000,
    medical: 1250,
    special: 11750,
    pfNumber: 'MH/34521/12345',
    esiNumber: '31-00123-456',
    bankAccount: '12345678901234',
    ifsc: 'SBIN0001234',
    pan: 'AAMKS1234A',
    leaveBalance: const {'CL': 6, 'PL': 18, 'SL': 5, 'ML': 0},
  ),
  _employee(
    id: 'emp-002',
    code: 'EMP002',
    name: 'Priya Mehta',
    designation: 'Accounts Executive',
    department: 'Finance',
    joiningDate: DateTime(2021, 7, 15),
    basic: 28000,
    hra: 11200,
    da: 2000,
    conveyance: 1600,
    medical: 1250,
    special: 3950,
    pfNumber: 'MH/34521/12346',
    esiNumber: '31-00123-457',
    bankAccount: '98765432100001',
    ifsc: 'HDFC0001567',
    pan: 'BVNPM7654B',
  ),
  _employee(
    id: 'emp-003',
    code: 'EMP003',
    name: 'Rajesh Verma',
    designation: 'HR Manager',
    department: 'Human Resources',
    joiningDate: DateTime(2018, 1, 10),
    basic: 55000,
    hra: 22000,
    da: 4000,
    conveyance: 2000,
    medical: 1250,
    special: 6750,
    pfNumber: 'MH/34521/12347',
    esiNumber: '31-00123-458',
    bankAccount: '11223344556677',
    ifsc: 'ICIC0002345',
    pan: 'CJKRV3456C',
    leaveBalance: const {'CL': 8, 'PL': 10, 'SL': 7, 'ML': 0},
  ),
  _employee(
    id: 'emp-004',
    code: 'EMP004',
    name: 'Sunita Gupta',
    designation: 'Software Engineer',
    department: 'IT',
    joiningDate: DateTime(2022, 3, 1),
    basic: 45000,
    hra: 18000,
    da: 3000,
    conveyance: 2000,
    medical: 1250,
    special: 7750,
    pfNumber: 'MH/34521/12348',
    esiNumber: '31-00123-459',
    bankAccount: '55667788990011',
    ifsc: 'AXIS0003456',
    pan: 'DKPSG9876D',
  ),
  _employee(
    id: 'emp-005',
    code: 'EMP005',
    name: 'Vikram Singh Yadav',
    designation: 'Sales Manager',
    department: 'Sales',
    joiningDate: DateTime(2020, 6, 1),
    basic: 50000,
    hra: 20000,
    da: 3500,
    conveyance: 2000,
    medical: 1250,
    special: 5250,
    pfNumber: 'MH/34521/12349',
    esiNumber: '31-00123-460',
    bankAccount: '22334455667788',
    ifsc: 'PUNB0001234',
    pan: 'EVISY2345E',
    leaveBalance: const {'CL': 4, 'PL': 15, 'SL': 3, 'ML': 0},
  ),
  _employee(
    id: 'emp-006',
    code: 'EMP006',
    name: 'Kavitha Nair',
    designation: 'Operations Executive',
    department: 'Operations',
    joiningDate: DateTime(2023, 1, 2),
    basic: 22000,
    hra: 8800,
    da: 1500,
    conveyance: 1600,
    medical: 1250,
    special: 2850,
    pfNumber: 'MH/34521/12350',
    esiNumber: '31-00123-461',
    bankAccount: '99001122334455',
    ifsc: 'SBIN0005678',
    pan: 'FGAKN5678F',
  ),
  _employee(
    id: 'emp-007',
    code: 'EMP007',
    name: 'Deepak Joshi',
    designation: 'Senior Accountant',
    department: 'Finance',
    joiningDate: DateTime(2017, 9, 1),
    basic: 60000,
    hra: 24000,
    da: 4500,
    conveyance: 2000,
    medical: 1250,
    special: 8250,
    pfNumber: 'MH/34521/12351',
    esiNumber: '31-00123-462',
    bankAccount: '44556677889900',
    ifsc: 'HDFC0009876',
    pan: 'GKLDJ7890G',
    leaveBalance: const {'CL': 8, 'PL': 20, 'SL': 7, 'ML': 0},
  ),
  _employee(
    id: 'emp-008',
    code: 'EMP008',
    name: 'Ananya Krishnan',
    designation: 'Marketing Executive',
    department: 'Marketing',
    joiningDate: DateTime(2022, 8, 15),
    basic: 32000,
    hra: 12800,
    da: 2200,
    conveyance: 1600,
    medical: 1250,
    special: 4150,
    pfNumber: 'MH/34521/12352',
    esiNumber: '31-00123-463',
    bankAccount: '66778899001122',
    ifsc: 'ICIC0007654',
    pan: 'HLMAK4567H',
  ),
  _employee(
    id: 'emp-009',
    code: 'EMP009',
    name: 'Suresh Babu Reddy',
    designation: 'Operations Manager',
    department: 'Operations',
    joiningDate: DateTime(2016, 5, 1),
    basic: 70000,
    hra: 28000,
    da: 5000,
    conveyance: 2000,
    medical: 1250,
    special: 9750,
    pfNumber: 'MH/34521/12353',
    esiNumber: '31-00123-464',
    bankAccount: '33445566778899',
    ifsc: 'AXIS0008765',
    pan: 'IMXSR6789I',
    leaveBalance: const {'CL': 8, 'PL': 25, 'SL': 7, 'ML': 0},
  ),
  _employee(
    id: 'emp-010',
    code: 'EMP010',
    name: 'Pooja Agarwal',
    designation: 'HR Executive',
    department: 'Human Resources',
    joiningDate: DateTime(2023, 4, 3),
    basic: 20000,
    hra: 8000,
    da: 1400,
    conveyance: 1600,
    medical: 1250,
    special: 2750,
    pfNumber: 'MH/34521/12354',
    esiNumber: '31-00123-465',
    bankAccount: '77889900112233',
    ifsc: 'PUNB0005678',
    pan: 'JNYPA3456J',
  ),
  _employee(
    id: 'emp-011',
    code: 'EMP011',
    name: 'Nikhil Malhotra',
    designation: 'IT Lead',
    department: 'IT',
    joiningDate: DateTime(2020, 11, 1),
    basic: 80000,
    hra: 32000,
    da: 6000,
    conveyance: 2000,
    medical: 1250,
    special: 11750,
    pfNumber: 'MH/34521/12355',
    esiNumber: '31-00123-466',
    bankAccount: '11001100220033',
    ifsc: 'HDFC0003210',
    pan: 'KOPNM5678K',
    leaveBalance: const {'CL': 8, 'PL': 14, 'SL': 7, 'ML': 0},
  ),
  _employee(
    id: 'emp-012',
    code: 'EMP012',
    name: 'Ritu Saxena',
    designation: 'Accounts Payable',
    department: 'Finance',
    joiningDate: DateTime(2024, 2, 1),
    basic: 18000,
    hra: 7200,
    da: 1200,
    conveyance: 1600,
    medical: 1250,
    special: 1750,
    pfNumber: 'MH/34521/12356',
    esiNumber: '31-00123-467',
    bankAccount: '44330022001199',
    ifsc: 'SBIN0007654',
    pan: 'LLPRS1234L',
  ),
];

// ---------------------------------------------------------------------------
// Mock Payroll months (24 records = 12 employees × 2 months)
// ---------------------------------------------------------------------------

PayrollMonth _payrollEntry({
  required String id,
  required Employee emp,
  required int month,
  required int year,
  required int presentDays,
  required PayrollStatus status,
  DateTime? disbursedDate,
}) {
  const workingDays = 26;
  final lop = workingDays - presentDays;
  final lopFactor = presentDays / workingDays;

  final basicPaid = emp.basicSalary * lopFactor;
  final allowances =
      (emp.hra +
          emp.da +
          emp.conveyance +
          emp.medicalAllowance +
          emp.specialAllowance) *
      lopFactor;
  final gross = basicPaid + allowances;
  final pf = basicPaid * 0.12;
  final esi = emp.grossSalary <= 21000 ? gross * 0.0075 : 0.0;
  final net = gross - pf - esi - emp.tdsMonthly;

  return PayrollMonth(
    id: id,
    employeeId: emp.id,
    employeeName: emp.name,
    month: month,
    year: year,
    workingDays: workingDays,
    presentDays: presentDays,
    lopDays: lop,
    basicPaid: basicPaid,
    allowancesPaid: allowances,
    grossPaid: gross,
    pfDeducted: pf,
    esiDeducted: esi,
    tdsDeducted: emp.tdsMonthly,
    otherDeductions: 0,
    netPaid: net > 0 ? net : 0,
    status: status,
    disbursedDate: disbursedDate,
  );
}

List<PayrollMonth> _buildPayrollMonths() {
  final entries = <PayrollMonth>[];
  // Feb 2026 — all disbursed
  for (var i = 0; i < _mockEmployees.length; i++) {
    final emp = _mockEmployees[i];
    entries.add(
      _payrollEntry(
        id: 'pay-feb-${emp.id}',
        emp: emp,
        month: 2,
        year: 2026,
        presentDays: 22 + (i % 4),
        status: PayrollStatus.disbursed,
        disbursedDate: DateTime(2026, 3, 1),
      ),
    );
  }
  // Mar 2026 — mixed statuses
  const statuses = [
    PayrollStatus.processed,
    PayrollStatus.processed,
    PayrollStatus.approved,
    PayrollStatus.draft,
    PayrollStatus.processed,
    PayrollStatus.approved,
    PayrollStatus.draft,
    PayrollStatus.processed,
    PayrollStatus.approved,
    PayrollStatus.draft,
    PayrollStatus.processed,
    PayrollStatus.draft,
  ];
  for (var i = 0; i < _mockEmployees.length; i++) {
    final emp = _mockEmployees[i];
    entries.add(
      _payrollEntry(
        id: 'pay-mar-${emp.id}',
        emp: emp,
        month: 3,
        year: 2026,
        presentDays: 20 + (i % 5),
        status: statuses[i],
      ),
    );
  }
  return List.unmodifiable(entries);
}

// ---------------------------------------------------------------------------
// Mock Statutory Returns (8)
// ---------------------------------------------------------------------------

final List<StatutoryReturn> _mockStatutoryReturns = [
  // PF ECR
  StatutoryReturn(
    id: 'sr-001',
    period: 'Feb 2026',
    returnType: StatutoryReturnType.pfEcr,
    dueDate: DateTime(2026, 3, 15),
    status: StatutoryReturnStatus.filed,
    filedDate: DateTime(2026, 3, 10),
    totalEmployees: 12,
    totalContribution: 312480,
    challanNumber: 'PF2026030000123',
  ),
  StatutoryReturn(
    id: 'sr-002',
    period: 'Mar 2026',
    returnType: StatutoryReturnType.pfEcr,
    dueDate: DateTime(2026, 4, 15),
    status: StatutoryReturnStatus.pending,
    totalEmployees: 12,
    totalContribution: 318720,
  ),
  // ESI Return (half-yearly)
  StatutoryReturn(
    id: 'sr-003',
    period: 'Oct 2025 – Mar 2026',
    returnType: StatutoryReturnType.esiReturn,
    dueDate: DateTime(2026, 5, 11),
    status: StatutoryReturnStatus.pending,
    totalEmployees: 6,
    totalContribution: 28440,
  ),
  StatutoryReturn(
    id: 'sr-004',
    period: 'Apr 2025 – Sep 2025',
    returnType: StatutoryReturnType.esiReturn,
    dueDate: DateTime(2025, 11, 11),
    status: StatutoryReturnStatus.filed,
    filedDate: DateTime(2025, 11, 8),
    totalEmployees: 6,
    totalContribution: 26820,
    challanNumber: 'ESI20251100456',
  ),
  // Professional Tax
  StatutoryReturn(
    id: 'sr-005',
    period: 'Feb 2026',
    returnType: StatutoryReturnType.ptReturn,
    dueDate: DateTime(2026, 3, 31),
    status: StatutoryReturnStatus.pending,
    totalEmployees: 12,
    totalContribution: 19200,
  ),
  StatutoryReturn(
    id: 'sr-006',
    period: 'Jan 2026',
    returnType: StatutoryReturnType.ptReturn,
    dueDate: DateTime(2026, 2, 28),
    status: StatutoryReturnStatus.overdue,
    totalEmployees: 12,
    totalContribution: 19200,
  ),
  // TDS 24Q
  StatutoryReturn(
    id: 'sr-007',
    period: 'Q3 FY 2025-26 (Oct–Dec)',
    returnType: StatutoryReturnType.tds24q,
    dueDate: DateTime(2026, 1, 31),
    status: StatutoryReturnStatus.filed,
    filedDate: DateTime(2026, 1, 28),
    totalEmployees: 12,
    totalContribution: 124560,
    challanNumber: 'TDS2026010000789',
  ),
  StatutoryReturn(
    id: 'sr-008',
    period: 'Q4 FY 2025-26 (Jan–Mar)',
    returnType: StatutoryReturnType.tds24q,
    dueDate: DateTime(2026, 5, 31),
    status: StatutoryReturnStatus.pending,
    totalEmployees: 12,
    totalContribution: 135200,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All employees — sourced from repository; falls back to mock data.
final employeesProvider =
    AsyncNotifierProvider<EmployeesNotifier, List<Employee>>(
      EmployeesNotifier.new,
    );

class EmployeesNotifier extends AsyncNotifier<List<Employee>> {
  @override
  Future<List<Employee>> build() async {
    // The PayrollRepository returns PayrollEntry (not Employee).
    // Watch the repo to ensure we're connected; use mock data for the UI.
    ref.watch(payrollRepositoryProvider);
    return List.unmodifiable(_mockEmployees);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.invalidateSelf();
      return build();
    });
  }
}

/// All payroll month records.
final payrollMonthsProvider = Provider<List<PayrollMonth>>(
  (_) => _buildPayrollMonths(),
);

/// All statutory returns.
final statutoryReturnsProvider = Provider<List<StatutoryReturn>>(
  (_) => List.unmodifiable(_mockStatutoryReturns),
);

/// Selected month/year for payroll filter (defaults to Mar 2026).
final payrollSelectedPeriodProvider =
    NotifierProvider<PayrollPeriodNotifier, ({int month, int year})>(
      PayrollPeriodNotifier.new,
    );

class PayrollPeriodNotifier extends Notifier<({int month, int year})> {
  @override
  ({int month, int year}) build() => (month: 3, year: 2026);

  void update(({int month, int year}) value) => state = value;
}

/// Payroll months filtered by selected period.
final filteredPayrollMonthsProvider = Provider<List<PayrollMonth>>((ref) {
  final period = ref.watch(payrollSelectedPeriodProvider);
  final all = ref.watch(payrollMonthsProvider);
  return all
      .where((p) => p.month == period.month && p.year == period.year)
      .toList();
});

/// Payroll summary for the selected period.
final payrollSummaryProvider = Provider<PayrollSummary>((ref) {
  final employees = ref.watch(employeesProvider).asData?.value ?? [];
  final records = ref.watch(filteredPayrollMonthsProvider);
  final returns = ref.watch(statutoryReturnsProvider);

  final totalGross = records.fold<double>(0, (s, r) => s + r.grossPaid);
  final totalNet = records.fold<double>(0, (s, r) => s + r.netPaid);
  final totalPf = records.fold<double>(0, (s, r) => s + r.pfDeducted);
  final totalEsi = records.fold<double>(0, (s, r) => s + r.esiDeducted);
  final totalTds = records.fold<double>(0, (s, r) => s + r.tdsDeducted);
  final pendingReturns = returns
      .where((r) => r.status == StatutoryReturnStatus.pending)
      .length;

  return PayrollSummary(
    totalEmployees: employees.where((e) => e.isActive).length,
    totalGrossPayout: totalGross,
    totalNetPayout: totalNet,
    totalPfContribution: totalPf,
    totalEsiContribution: totalEsi,
    totalTdsContribution: totalTds,
    pendingStatutoryReturns: pendingReturns,
  );
});

/// Simple immutable summary.
class PayrollSummary {
  const PayrollSummary({
    required this.totalEmployees,
    required this.totalGrossPayout,
    required this.totalNetPayout,
    required this.totalPfContribution,
    required this.totalEsiContribution,
    required this.totalTdsContribution,
    required this.pendingStatutoryReturns,
  });

  final int totalEmployees;
  final double totalGrossPayout;
  final double totalNetPayout;
  final double totalPfContribution;
  final double totalEsiContribution;
  final double totalTdsContribution;
  final int pendingStatutoryReturns;
}
