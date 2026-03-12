import 'package:ca_app/features/payroll/domain/models/full_and_final_settlement.dart';
import 'package:ca_app/features/payroll/domain/models/salary_package.dart';
import 'package:ca_app/features/payroll/domain/services/gratuity_calculator.dart';
import 'package:ca_app/features/payroll/domain/services/leave_encashment_service.dart';

/// Stateless service that computes the Full & Final Settlement for a
/// departing employee.
///
/// Combines:
/// - Gratuity (via [GratuityCalculator])
/// - Leave encashment (via [LeaveEncashmentService])
/// - Notice pay recovery or payment
///
/// All monetary values are in paise (1/100th of a rupee).
class FullAndFinalService {
  FullAndFinalService._();

  /// Computes the full and final settlement for an employee.
  ///
  /// Parameters:
  /// - [employeeId] — unique identifier.
  /// - [relievingDate] — last working day.
  /// - [joiningDate] — date of joining (used to compute years of service).
  /// - [pendingLeaves] — approved leaves pending encashment.
  /// - [package] — the employee's salary package.
  /// - [noticePeriodDays] — contractual notice period in days. Defaults to 0.
  /// - [noticeDaysServed] — days of notice actually served. Defaults to 0.
  /// - [employerInitiatedTermination] — true when the employer is terminating
  ///   the employee (notice pay owed by employer). Defaults to false.
  static FullAndFinalSettlement compute({
    required String employeeId,
    required DateTime relievingDate,
    required DateTime joiningDate,
    required int pendingLeaves,
    required SalaryPackage package,
    int noticePeriodDays = 0,
    int noticeDaysServed = 0,
    bool employerInitiatedTermination = false,
  }) {
    final years = _computedYearsOfService(joiningDate, relievingDate);
    final gratuity = GratuityCalculator.compute(
      yearsOfService: years,
      lastBasicPaise: package.basicPaise,
    );

    final dailyBasic = LeaveEncashmentService.dailyRateFromMonthly(
      package.basicPaise,
    );
    final leaveEncashment = LeaveEncashmentService.compute(
      basicPerDayPaise: dailyBasic,
      pendingLeaves: pendingLeaves,
    );

    final noticePay = _computeNoticePay(
      dailyBasicPaise: dailyBasic,
      noticePeriodDays: noticePeriodDays,
      noticeDaysServed: noticeDaysServed,
      employerInitiated: employerInitiatedTermination,
    );

    final total = gratuity + leaveEncashment + noticePay;

    return FullAndFinalSettlement(
      employeeId: employeeId,
      relievingDate: relievingDate,
      joiningDate: joiningDate,
      yearsOfService: years,
      pendingLeaves: pendingLeaves,
      gratuityAmountPaise: gratuity,
      leaveEncashmentAmountPaise: leaveEncashment,
      noticePayPaise: noticePay,
      totalPayablePaise: total,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Computes completed years of service (integer, fractions ignored).
  static int _computedYearsOfService(DateTime joining, DateTime relieving) {
    var years = relieving.year - joining.year;
    // Adjust if the relieving anniversary hasn't passed yet this year
    final anniversaryThisYear = DateTime(
      relieving.year,
      joining.month,
      joining.day,
    );
    if (relieving.isBefore(anniversaryThisYear)) {
      years -= 1;
    }
    return years < 0 ? 0 : years;
  }

  /// Computes notice pay in paise.
  ///
  /// - If employer initiated and notice period not served: positive
  ///   (employer owes employee).
  /// - If employee resigned and notice not fully served: negative
  ///   (employee owes employer).
  /// - If notice fully served or no notice period: 0.
  static int _computeNoticePay({
    required int dailyBasicPaise,
    required int noticePeriodDays,
    required int noticeDaysServed,
    required bool employerInitiated,
  }) {
    if (noticePeriodDays <= 0) return 0;
    final shortfall = noticePeriodDays - noticeDaysServed;
    if (shortfall <= 0) return 0;

    final noticePayAmount = dailyBasicPaise * shortfall;
    // Employer-initiated termination → employer pays
    // Employee resignation → employee pays (negative)
    return employerInitiated ? noticePayAmount : -noticePayAmount;
  }
}
