import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/income_tax/data/providers/income_tax_providers.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/gst/data/providers/gst_providers.dart';
import 'package:ca_app/features/gst/domain/models/gst_return.dart';
import 'package:ca_app/features/tds/data/providers/tds_providers.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';

/// Aggregated KPI snapshot across all modules powering the dashboard.
class DashboardKpi {
  const DashboardKpi({
    required this.totalActiveClients,
    required this.itrPendingCount,
    required this.itrFiledThisMonth,
    required this.gstReturnsPendingCount,
    required this.gstLateFilings,
    required this.tdsChallansDue,
    required this.totalTaxCollected,
    required this.pendingTasks,
    required this.upcomingDeadlines,
  });

  /// Total ITR clients across all assessment years in the system.
  final int totalActiveClients;

  /// ITR clients with status pending or inProgress (current AY filter).
  final int itrPendingCount;

  /// ITR clients filed/verified/processed in the current calendar month.
  final int itrFiledThisMonth;

  /// GST returns with pending status across all periods.
  final int gstReturnsPendingCount;

  /// GST returns with lateFiled status.
  final int gstLateFilings;

  /// TDS returns with pending status and tax deducted > tax deposited.
  final int tdsChallansDue;

  /// Sum of taxPayable across all filed/verified/processed ITR clients.
  final double totalTaxCollected;

  /// Placeholder — tasks module not yet wired (always 0 for now).
  final int pendingTasks;

  /// Count of compliance deadlines falling within the next 7 days.
  final int upcomingDeadlines;

  DashboardKpi copyWith({
    int? totalActiveClients,
    int? itrPendingCount,
    int? itrFiledThisMonth,
    int? gstReturnsPendingCount,
    int? gstLateFilings,
    int? tdsChallansDue,
    double? totalTaxCollected,
    int? pendingTasks,
    int? upcomingDeadlines,
  }) {
    return DashboardKpi(
      totalActiveClients: totalActiveClients ?? this.totalActiveClients,
      itrPendingCount: itrPendingCount ?? this.itrPendingCount,
      itrFiledThisMonth: itrFiledThisMonth ?? this.itrFiledThisMonth,
      gstReturnsPendingCount:
          gstReturnsPendingCount ?? this.gstReturnsPendingCount,
      gstLateFilings: gstLateFilings ?? this.gstLateFilings,
      tdsChallansDue: tdsChallansDue ?? this.tdsChallansDue,
      totalTaxCollected: totalTaxCollected ?? this.totalTaxCollected,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      upcomingDeadlines: upcomingDeadlines ?? this.upcomingDeadlines,
    );
  }
}

/// Derives a [DashboardKpi] by aggregating live data from ITR, GST, and TDS
/// providers. Reacts to any upstream provider change automatically.
final dashboardKpiProvider = Provider<DashboardKpi>((ref) {
  // ── Income Tax ────────────────────────────────────────────────────────────
  final allItrClients = ref.watch(itrClientsProvider);
  final filteredItrClients = ref.watch(filteredClientsProvider);

  final itrPending = filteredItrClients
      .where(
        (c) =>
            c.filingStatus == FilingStatus.pending ||
            c.filingStatus == FilingStatus.inProgress,
      )
      .length;

  final now = DateTime.now();
  final itrFiledThisMonth = allItrClients
      .where(
        (c) =>
            (c.filingStatus == FilingStatus.filed ||
                c.filingStatus == FilingStatus.verified ||
                c.filingStatus == FilingStatus.processed) &&
            c.filedDate != null &&
            c.filedDate!.month == now.month &&
            c.filedDate!.year == now.year,
      )
      .length;

  final totalTaxCollected = allItrClients
      .where(
        (c) =>
            c.filingStatus == FilingStatus.filed ||
            c.filingStatus == FilingStatus.verified ||
            c.filingStatus == FilingStatus.processed,
      )
      .fold(0.0, (sum, c) => sum + c.taxPayable);

  // ── GST ──────────────────────────────────────────────────────────────────
  final allGstReturns = ref.watch(gstReturnsProvider);

  final gstPending = allGstReturns
      .where((r) => r.status == GstReturnStatus.pending)
      .length;

  final gstLate = allGstReturns
      .where((r) => r.status == GstReturnStatus.lateFiled)
      .length;

  // ── TDS ──────────────────────────────────────────────────────────────────
  final allTdsReturns = ref.watch(tdsReturnsProvider);

  final tdsDue = allTdsReturns
      .where(
        (r) =>
            r.status == TdsReturnStatus.pending &&
            r.totalTaxDeducted > r.totalDeposited,
      )
      .length;

  // ── Upcoming deadlines in next 7 days (hardcoded Mar 2026 schedule) ──────
  final upcomingDeadlines = _computeUpcomingDeadlines();

  return DashboardKpi(
    totalActiveClients: allItrClients.length,
    itrPendingCount: itrPending,
    itrFiledThisMonth: itrFiledThisMonth,
    gstReturnsPendingCount: gstPending,
    gstLateFilings: gstLate,
    tdsChallansDue: tdsDue,
    totalTaxCollected: totalTaxCollected,
    pendingTasks: 0,
    upcomingDeadlines: upcomingDeadlines,
  );
});

/// Returns the count of Mar 2026 deadlines that fall within 7 days of today.
///
/// Deadlines are sourced from the same hardcoded list used by
/// [ComplianceDeadlineWidget] so the KPI and the widget always agree.
int _computeUpcomingDeadlines() {
  // Reference date: 11 Mar 2026 (current date per project context).
  final today = DateTime(2026, 3, 11);
  final cutoff = today.add(const Duration(days: 7));

  // Mirrors the deadline list in ComplianceDeadlineWidget.
  final dueDates = <DateTime>[
    DateTime(2026, 3, 20), // GSTR-3B
    DateTime(2026, 3, 7), // TDS Challan (overdue)
    DateTime(2026, 3, 15), // Advance Tax
    DateTime(2026, 3, 11), // GSTR-1 (today)
    DateTime(2026, 3, 31), // TDS Return 26Q
    DateTime(2026, 3, 31), // GSTR-9
  ];

  return dueDates
      .where((d) => !d.isBefore(today) && !d.isAfter(cutoff))
      .length;
}
