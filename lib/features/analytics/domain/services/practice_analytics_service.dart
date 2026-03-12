import 'package:ca_app/features/analytics/domain/models/practice_metrics.dart';
import 'package:ca_app/features/practice/domain/models/billing_invoice.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/staff_assignment.dart';

/// Computes practice-level analytics from raw engagement and billing data.
///
/// Stateless singleton — all methods are pure functions of their inputs.
class PracticeAnalyticsService {
  PracticeAnalyticsService._();

  static final PracticeAnalyticsService instance =
      PracticeAnalyticsService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Computes a full [PracticeMetrics] snapshot for [period].
  ///
  /// Parameters:
  /// - [invoices]: all billing invoices for this period (any status).
  /// - [engagements]: all engagements for this period.
  /// - [period]: fiscal period label, e.g. "FY2024-25".
  /// - [priorRevenue]: total revenue in the previous period (for YoY growth).
  /// - [firmId]: identifier of the CA firm.
  /// - [newClientsCount]: clients acquired this period.
  /// - [churnedClientsCount]: clients lost this period.
  /// - [pendingFilings]: count of filings awaiting submission.
  /// - [overdueFilings]: count of filings past deadline.
  /// - [totalAvailableHours]: total staff hours available (staff × 8h × days).
  PracticeMetrics computeMetrics(
    List<BillingInvoice> invoices,
    List<Engagement> engagements,
    String period, {
    required int priorRevenue,
    required String firmId,
    required int newClientsCount,
    required int churnedClientsCount,
    required int pendingFilings,
    required int overdueFilings,
    required int totalAvailableHours,
  }) {
    final totalRevenue = invoices.fold(0, (sum, inv) => sum + inv.totalAmount);
    final clientIds = invoices.map((inv) => inv.clientId).toSet();
    final totalClients = clientIds.length;

    final allAssignments = engagements
        .expand((e) => e.assignedStaff)
        .toList();

    final revenueGrowth = computeRevenueGrowth(totalRevenue, priorRevenue);
    final complianceRate = computeFilingComplianceRate(engagements);
    final utilizationRate =
        computeUtilizationRate(allAssignments, totalAvailableHours);

    return PracticeMetrics(
      period: period,
      firmId: firmId,
      totalRevenue: totalRevenue,
      revenueGrowth: revenueGrowth,
      totalClients: totalClients,
      newClients: newClientsCount,
      churnedClients: churnedClientsCount,
      filingComplianceRate: complianceRate,
      pendingFilings: pendingFilings,
      overdueFilings: overdueFilings,
      utilizationRate: utilizationRate,
    );
  }

  /// Returns YoY revenue growth as a percentage.
  ///
  /// Returns 0.0 when [priorRevenue] is zero to avoid division by zero.
  double computeRevenueGrowth(int currentRevenue, int priorRevenue) {
    if (priorRevenue == 0) return 0.0;
    return ((currentRevenue - priorRevenue) / priorRevenue) * 100.0;
  }

  /// Returns the fraction of [engagements] completed on or before deadline.
  ///
  /// An engagement is compliant when:
  /// - Its [EngagementStatus] is [EngagementStatus.done] or [EngagementStatus.billed].
  /// - Its [Engagement.completedDate] is not null and is on or before [Engagement.dueDate].
  ///
  /// Returns 0.0 for an empty list.
  double computeFilingComplianceRate(List<Engagement> engagements) {
    if (engagements.isEmpty) return 0.0;

    var compliantCount = 0;
    for (final e in engagements) {
      final completed = e.completedDate;
      final isDone =
          e.status == EngagementStatus.done ||
          e.status == EngagementStatus.billed;
      if (isDone && completed != null && !completed.isAfter(e.dueDate)) {
        compliantCount++;
      }
    }
    return compliantCount / engagements.length;
  }

  /// Returns the ratio of billable hours to [totalAvailableHours].
  ///
  /// Sums [StaffAssignment.hoursLogged] across [assignments].
  /// Result is clamped to [0.0, 1.0] — over-capacity situations cap at 1.0.
  /// Returns 0.0 when [totalAvailableHours] is zero.
  double computeUtilizationRate(
    List<StaffAssignment> assignments,
    int totalAvailableHours,
  ) {
    if (totalAvailableHours == 0) return 0.0;
    if (assignments.isEmpty) return 0.0;

    final totalLogged =
        assignments.fold(0, (sum, a) => sum + a.hoursLogged);
    final raw = totalLogged / totalAvailableHours;
    return raw.clamp(0.0, 1.0);
  }
}
