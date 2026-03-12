import 'package:ca_app/features/payroll/domain/models/pay_component.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_run.dart';

/// Itemized payslip for an employee for a single month.
///
/// Wraps a [PayrollRun] with detailed earning and deduction line items and
/// year-to-date (YTD) totals for Form 16 and payslip display.
///
/// All monetary values are in paise (1/100th of a rupee).
class Payslip {
  const Payslip({
    required this.payrollRun,
    required this.earnings,
    required this.deductions,
    required this.ytdGrossPaise,
    required this.ytdTdsPaise,
    required this.ytdPfPaise,
  });

  /// The underlying payroll computation result.
  final PayrollRun payrollRun;

  /// Itemized list of earning components (Basic, HRA, etc.).
  final List<PayComponent> earnings;

  /// Itemized list of deduction components (PF, ESI, TDS, etc.).
  final List<PayComponent> deductions;

  /// Year-to-date gross pay in paise (April–current month).
  final int ytdGrossPaise;

  /// Year-to-date TDS deducted in paise.
  final int ytdTdsPaise;

  /// Year-to-date employee PF contribution in paise.
  final int ytdPfPaise;

  /// Total earnings in paise (sum of all earning components).
  int get totalEarningsPaise =>
      earnings.fold(0, (sum, c) => sum + c.amountPaise);

  /// Total deductions in paise (sum of all deduction components).
  int get totalDeductionsPaise =>
      deductions.fold(0, (sum, c) => sum + c.amountPaise);

  Payslip copyWith({
    PayrollRun? payrollRun,
    List<PayComponent>? earnings,
    List<PayComponent>? deductions,
    int? ytdGrossPaise,
    int? ytdTdsPaise,
    int? ytdPfPaise,
  }) {
    return Payslip(
      payrollRun: payrollRun ?? this.payrollRun,
      earnings: earnings ?? this.earnings,
      deductions: deductions ?? this.deductions,
      ytdGrossPaise: ytdGrossPaise ?? this.ytdGrossPaise,
      ytdTdsPaise: ytdTdsPaise ?? this.ytdTdsPaise,
      ytdPfPaise: ytdPfPaise ?? this.ytdPfPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Payslip) return false;
    if (other.payrollRun != payrollRun) return false;
    if (other.ytdGrossPaise != ytdGrossPaise) return false;
    if (other.ytdTdsPaise != ytdTdsPaise) return false;
    if (other.ytdPfPaise != ytdPfPaise) return false;
    if (other.earnings.length != earnings.length) return false;
    if (other.deductions.length != deductions.length) return false;
    for (var i = 0; i < earnings.length; i++) {
      if (other.earnings[i] != earnings[i]) return false;
    }
    for (var i = 0; i < deductions.length; i++) {
      if (other.deductions[i] != deductions[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    payrollRun,
    Object.hashAll(earnings),
    Object.hashAll(deductions),
    ytdGrossPaise,
    ytdTdsPaise,
    ytdPfPaise,
  );

  @override
  String toString() =>
      'Payslip(employee: ${payrollRun.employeeId}, '
      '${payrollRun.month}/${payrollRun.year}, '
      'net: ${payrollRun.netPayPaise})';
}
