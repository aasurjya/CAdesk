import 'package:ca_app/features/practice/domain/models/billing_invoice.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';

/// Closed date range used to scope metric aggregations.
class DateRange {
  const DateRange({required this.start, required this.end});

  /// Inclusive start of the range (time-of-day is respected).
  final DateTime start;

  /// Inclusive end of the range.
  final DateTime end;

  /// Returns `true` when [dt] falls within [start]..[end] (inclusive).
  bool contains(DateTime dt) => !dt.isBefore(start) && !dt.isAfter(end);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start → $end)';
}

/// Aggregated billing metrics for a [DateRange].
///
/// All monetary amounts are in paise (100 paise = ₹1).
class BillingMetrics {
  const BillingMetrics({
    required this.totalBilled,
    required this.totalCollected,
    required this.outstanding,
    required this.invoiceCount,
    required this.collectionRate,
  });

  /// Sum of all invoice totals regardless of payment status, in paise.
  final double totalBilled;

  /// Sum of totals for fully [PaymentStatus.paid] invoices, in paise.
  final double totalCollected;

  /// Amount not yet collected (billed minus collected), in paise.
  final double outstanding;

  /// Number of invoices in the period.
  final int invoiceCount;

  /// Fraction collected: [totalCollected] / [totalBilled] (0–1).
  ///
  /// Returns `0.0` when [totalBilled] is zero.
  final double collectionRate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillingMetrics &&
        other.totalBilled == totalBilled &&
        other.totalCollected == totalCollected &&
        other.invoiceCount == invoiceCount;
  }

  @override
  int get hashCode => Object.hash(totalBilled, totalCollected, invoiceCount);
}

/// Aggregated filing / engagement metrics for a [DateRange].
class FilingMetrics {
  const FilingMetrics({
    required this.totalFilings,
    required this.completedOnTime,
    required this.completedLate,
    required this.pending,
    required this.complianceRate,
  });

  /// Total number of engagements in the period.
  final int totalFilings;

  /// Engagements completed on or before [Engagement.dueDate].
  final int completedOnTime;

  /// Engagements completed after [Engagement.dueDate].
  final int completedLate;

  /// Engagements not yet at [EngagementStatus.done] or [EngagementStatus.billed].
  final int pending;

  /// [completedOnTime] / [totalFilings]; `0.0` when [totalFilings] is zero.
  final double complianceRate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingMetrics &&
        other.totalFilings == totalFilings &&
        other.completedOnTime == completedOnTime &&
        other.pending == pending;
  }

  @override
  int get hashCode => Object.hash(totalFilings, completedOnTime, pending);
}

/// Aggregated task completion metrics for a [DateRange].
class TaskMetrics {
  const TaskMetrics({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionRate,
    required this.avgEstimatedHours,
  });

  /// Total [WorkflowTask] instances across all engagements in the period.
  final int totalTasks;

  /// Tasks that appear in at least one [StaffAssignment.tasks] list.
  final int completedTasks;

  /// Tasks not yet assigned to any staff member.
  final int pendingTasks;

  /// [completedTasks] / [totalTasks]; `0.0` when [totalTasks] is zero.
  final double completionRate;

  /// Mean [WorkflowTask.estimatedHours] across all tasks in the period.
  final double avgEstimatedHours;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskMetrics &&
        other.totalTasks == totalTasks &&
        other.completedTasks == completedTasks;
  }

  @override
  int get hashCode => Object.hash(totalTasks, completedTasks);
}

/// Combined snapshot of billing, filing, and task metrics for a [DateRange].
class DashboardSnapshot {
  const DashboardSnapshot({
    required this.period,
    required this.billing,
    required this.filing,
    required this.tasks,
  });

  /// The date range this snapshot covers.
  final DateRange period;

  /// Billing KPIs.
  final BillingMetrics billing;

  /// Filing / engagement KPIs.
  final FilingMetrics filing;

  /// Task completion KPIs.
  final TaskMetrics tasks;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardSnapshot && other.period == period;
  }

  @override
  int get hashCode => period.hashCode;
}

/// Aggregates KPIs from multiple modules (billing, filing, tasks) into
/// a unified [DashboardSnapshot].
///
/// Stateless singleton — all methods are pure functions of their inputs.
/// No Flutter or platform dependencies; safe for use in isolates and tests.
class CrossModuleAggregator {
  CrossModuleAggregator._();

  static final CrossModuleAggregator instance = CrossModuleAggregator._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Aggregates billing metrics from [invoices] for [period].
  ///
  /// Only invoices whose [BillingInvoice.dueDate] falls within [period] are
  /// included. An invoice counts as collected when its status is
  /// [PaymentStatus.paid].
  BillingMetrics aggregateBilling(
    List<BillingInvoice> invoices,
    DateRange period,
  ) {
    final inPeriod = invoices
        .where((inv) => period.contains(inv.dueDate))
        .toList();

    if (inPeriod.isEmpty) {
      return const BillingMetrics(
        totalBilled: 0,
        totalCollected: 0,
        outstanding: 0,
        invoiceCount: 0,
        collectionRate: 0,
      );
    }

    final totalBilled = inPeriod.fold<double>(
      0,
      (sum, inv) => sum + inv.totalAmount,
    );
    final totalCollected = inPeriod
        .where((inv) => inv.paymentStatus == PaymentStatus.paid)
        .fold<double>(0, (sum, inv) => sum + inv.totalAmount);

    final outstanding = totalBilled - totalCollected;
    final collectionRate = totalBilled > 0 ? totalCollected / totalBilled : 0.0;

    return BillingMetrics(
      totalBilled: totalBilled,
      totalCollected: totalCollected,
      outstanding: outstanding,
      invoiceCount: inPeriod.length,
      collectionRate: collectionRate,
    );
  }

  /// Aggregates filing metrics from [jobs] for [period].
  ///
  /// Only engagements whose [Engagement.dueDate] falls within [period] are
  /// included.
  FilingMetrics aggregateFiling(List<Engagement> jobs, DateRange period) {
    final inPeriod = jobs.where((e) => period.contains(e.dueDate)).toList();

    if (inPeriod.isEmpty) {
      return const FilingMetrics(
        totalFilings: 0,
        completedOnTime: 0,
        completedLate: 0,
        pending: 0,
        complianceRate: 0,
      );
    }

    var onTime = 0;
    var late = 0;
    var pending = 0;

    for (final e in inPeriod) {
      final isDone =
          e.status == EngagementStatus.done ||
          e.status == EngagementStatus.billed;
      if (!isDone) {
        pending++;
      } else if (e.completedDate != null &&
          !e.completedDate!.isAfter(e.dueDate)) {
        onTime++;
      } else {
        late++;
      }
    }

    final complianceRate = inPeriod.isNotEmpty ? onTime / inPeriod.length : 0.0;

    return FilingMetrics(
      totalFilings: inPeriod.length,
      completedOnTime: onTime,
      completedLate: late,
      pending: pending,
      complianceRate: complianceRate,
    );
  }

  /// Aggregates task completion metrics from [tasks] for [period].
  ///
  /// All workflow tasks across all engagements whose [Engagement.dueDate]
  /// falls in [period] are included. A task is "completed" when its
  /// [WorkflowTask.taskId] appears in any [Engagement.completedTaskIds].
  TaskMetrics aggregateTasks(List<Engagement> tasks, DateRange period) {
    final inPeriod = tasks.where((e) => period.contains(e.dueDate)).toList();

    if (inPeriod.isEmpty) {
      return const TaskMetrics(
        totalTasks: 0,
        completedTasks: 0,
        pendingTasks: 0,
        completionRate: 0,
        avgEstimatedHours: 0,
      );
    }

    final allTasks = inPeriod.expand((e) => e.templateTasks).toList();
    final completedIds = inPeriod.expand((e) => e.completedTaskIds).toSet();

    final completed = allTasks
        .where((t) => completedIds.contains(t.taskId))
        .length;
    final pending = allTasks.length - completed;
    final completionRate = allTasks.isNotEmpty
        ? completed / allTasks.length
        : 0.0;
    final avgHours = allTasks.isNotEmpty
        ? allTasks.fold<double>(0, (sum, t) => sum + t.estimatedHours) /
              allTasks.length
        : 0.0;

    return TaskMetrics(
      totalTasks: allTasks.length,
      completedTasks: completed,
      pendingTasks: pending,
      completionRate: completionRate,
      avgEstimatedHours: avgHours,
    );
  }

  /// Builds a [DashboardSnapshot] combining all three metric sets for [period].
  ///
  /// Requires both [invoices] and [engagements] because billing and filing
  /// draw from separate collections.
  DashboardSnapshot buildSnapshot(
    DateRange period, {
    required List<BillingInvoice> invoices,
    required List<Engagement> engagements,
  }) {
    return DashboardSnapshot(
      period: period,
      billing: aggregateBilling(invoices, period),
      filing: aggregateFiling(engagements, period),
      tasks: aggregateTasks(engagements, period),
    );
  }
}
