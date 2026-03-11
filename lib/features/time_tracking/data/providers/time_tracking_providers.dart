import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/time_tracking/domain/models/billing_summary.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';

// ---------------------------------------------------------------------------
// Active timer state & notifier (real running timer)
// ---------------------------------------------------------------------------

/// Immutable state for the active timer.
class ActiveTimerState {
  const ActiveTimerState({
    required this.isRunning,
    required this.elapsedSeconds,
    required this.clientName,
    required this.taskDescription,
    required this.billingRate,
    required this.startedAt,
  });

  final bool isRunning;
  final int elapsedSeconds;
  final String clientName;
  final String taskDescription;

  /// Billing rate per hour in ₹.
  final double billingRate;

  /// Non-null when a session has been started (even if paused).
  final DateTime? startedAt;

  String get formattedTime {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  double get billableAmount => (elapsedSeconds / 3600) * billingRate;

  static const idle = ActiveTimerState(
    isRunning: false,
    elapsedSeconds: 0,
    clientName: '',
    taskDescription: '',
    billingRate: 0,
    startedAt: null,
  );
}

class ActiveTimerNotifier extends Notifier<ActiveTimerState> {
  Timer? _ticker;

  @override
  ActiveTimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return ActiveTimerState.idle;
  }

  void start({
    required String clientName,
    required String taskDescription,
    required double billingRate,
  }) {
    _ticker?.cancel();
    state = ActiveTimerState(
      isRunning: true,
      elapsedSeconds: state.elapsedSeconds,
      clientName: clientName,
      taskDescription: taskDescription,
      billingRate: billingRate,
      startedAt: DateTime.now(),
    );
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = ActiveTimerState(
        isRunning: true,
        elapsedSeconds: state.elapsedSeconds + 1,
        clientName: state.clientName,
        taskDescription: state.taskDescription,
        billingRate: state.billingRate,
        startedAt: state.startedAt,
      );
    });
  }

  void pause() {
    _ticker?.cancel();
    state = ActiveTimerState(
      isRunning: false,
      elapsedSeconds: state.elapsedSeconds,
      clientName: state.clientName,
      taskDescription: state.taskDescription,
      billingRate: state.billingRate,
      startedAt: state.startedAt,
    );
  }

  void resume() {
    if (state.isRunning) return;
    _ticker?.cancel();
    state = ActiveTimerState(
      isRunning: true,
      elapsedSeconds: state.elapsedSeconds,
      clientName: state.clientName,
      taskDescription: state.taskDescription,
      billingRate: state.billingRate,
      startedAt: state.startedAt,
    );
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = ActiveTimerState(
        isRunning: true,
        elapsedSeconds: state.elapsedSeconds + 1,
        clientName: state.clientName,
        taskDescription: state.taskDescription,
        billingRate: state.billingRate,
        startedAt: state.startedAt,
      );
    });
  }

  void stop() {
    _ticker?.cancel();
    state = ActiveTimerState.idle;
  }
}

final activeTimerProvider =
    NotifierProvider<ActiveTimerNotifier, ActiveTimerState>(
      ActiveTimerNotifier.new,
    );

// ---------------------------------------------------------------------------
// Realization calculator service
// ---------------------------------------------------------------------------

class RealizationCalculator {
  /// Realization rate = amount billed / amount recorded × 100.
  static double realizationRate(double billedAmount, double recordedAmount) {
    if (recordedAmount == 0) return 0;
    return (billedAmount / recordedAmount * 100).clamp(0.0, 200.0);
  }

  /// Effective hourly rate = billed amount / hours worked.
  static double effectiveHourlyRate(double billedAmount, double hoursWorked) {
    if (hoursWorked == 0) return 0;
    return billedAmount / hoursWorked;
  }

  /// Weekly utilization = billable hours / total available hours × 100.
  static double weeklyUtilization(
    double billableHours, {
    double availableHours = 40,
  }) {
    return (billableHours / availableHours * 100).clamp(0.0, 150.0);
  }
}

// ---------------------------------------------------------------------------
// Running timer state (legacy — kept for backward compat with timer_widget)
// ---------------------------------------------------------------------------

/// Holds the state of the currently running timer (null = no active timer).
class RunningTimerState {
  const RunningTimerState({
    this.entryId,
    this.clientName,
    this.taskDescription,
    this.startedAt,
    this.isRunning = false,
    this.elapsedSeconds = 0,
  });

  final String? entryId;
  final String? clientName;
  final String? taskDescription;
  final DateTime? startedAt;
  final bool isRunning;
  final int elapsedSeconds;

  String get formattedElapsed {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final secs = elapsedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  RunningTimerState copyWith({
    String? entryId,
    String? clientName,
    String? taskDescription,
    DateTime? startedAt,
    bool? isRunning,
    int? elapsedSeconds,
  }) {
    return RunningTimerState(
      entryId: entryId ?? this.entryId,
      clientName: clientName ?? this.clientName,
      taskDescription: taskDescription ?? this.taskDescription,
      startedAt: startedAt ?? this.startedAt,
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

final runningTimerProvider =
    NotifierProvider<RunningTimerNotifier, RunningTimerState>(
      RunningTimerNotifier.new,
    );

class RunningTimerNotifier extends Notifier<RunningTimerState> {
  @override
  RunningTimerState build() => const RunningTimerState(
    entryId: 'timer-active',
    clientName: 'ABC Infra Pvt Ltd',
    taskDescription: 'GST-3B reconciliation for Feb 2026',
    startedAt: null,
    isRunning: true,
    elapsedSeconds: 2745, // 45m 45s
  );

  void update(RunningTimerState value) => state = value;

  void start({
    required String entryId,
    required String clientName,
    required String taskDescription,
  }) {
    state = RunningTimerState(
      entryId: entryId,
      clientName: clientName,
      taskDescription: taskDescription,
      startedAt: DateTime.now(),
      isRunning: true,
    );
  }

  void pause() {
    state = state.copyWith(isRunning: false);
  }

  void resume() {
    state = state.copyWith(isRunning: true);
  }

  void stop() {
    state = const RunningTimerState();
  }

  void tick() {
    if (state.isRunning) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    }
  }
}

// ---------------------------------------------------------------------------
// Active filter
// ---------------------------------------------------------------------------

enum TimeEntryFilter {
  all('All'),
  today('Today'),
  thisWeek('This Week'),
  billable('Billable'),
  nonBillable('Non-Billable');

  const TimeEntryFilter(this.label);

  final String label;
}

final timeEntryFilterProvider =
    NotifierProvider<TimeEntryFilterNotifier, TimeEntryFilter>(
      TimeEntryFilterNotifier.new,
    );

class TimeEntryFilterNotifier extends Notifier<TimeEntryFilter> {
  @override
  TimeEntryFilter build() => TimeEntryFilter.today;

  void update(TimeEntryFilter value) => state = value;
}

// ---------------------------------------------------------------------------
// Time entries — 15 across 5 staff members
// ---------------------------------------------------------------------------

final timeEntriesProvider =
    NotifierProvider<TimeEntriesNotifier, List<TimeEntry>>(
      TimeEntriesNotifier.new,
    );

class TimeEntriesNotifier extends Notifier<List<TimeEntry>> {
  @override
  List<TimeEntry> build() => List.unmodifiable(_mockEntries);

  void update(List<TimeEntry> value) => state = value;

  /// Adds a newly stopped timer entry to the top of the list (immutable).
  void addEntry(TimeEntry entry) {
    state = List.unmodifiable([entry, ...state]);
  }
}

final _now = DateTime.now();
final _today = DateTime(_now.year, _now.month, _now.day);

final _mockEntries = <TimeEntry>[
  // Amit Sharma — 3 entries
  TimeEntry(
    id: 'te-001',
    staffId: 'staff-01',
    staffName: 'Amit Sharma',
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    taskDescription: 'ITR-2 preparation and filing',
    startTime: _today.add(const Duration(hours: 9)),
    endTime: _today.add(const Duration(hours: 11, minutes: 30)),
    durationMinutes: 150,
    isBillable: true,
    hourlyRate: 2000,
    billedAmount: 5000,
    status: TimeEntryStatus.completed,
  ),
  TimeEntry(
    id: 'te-002',
    staffId: 'staff-01',
    staffName: 'Amit Sharma',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    taskDescription: 'Statutory audit fieldwork — inventory verification',
    startTime: _today.add(const Duration(hours: 12)),
    endTime: _today.add(const Duration(hours: 15)),
    durationMinutes: 180,
    isBillable: true,
    hourlyRate: 2500,
    billedAmount: 7500,
    status: TimeEntryStatus.completed,
  ),
  TimeEntry(
    id: 'te-003',
    staffId: 'staff-01',
    staffName: 'Amit Sharma',
    clientId: '0',
    clientName: 'Internal',
    taskDescription: 'Team meeting — weekly review',
    startTime: _today.add(const Duration(hours: 15, minutes: 30)),
    endTime: _today.add(const Duration(hours: 16)),
    durationMinutes: 30,
    isBillable: false,
    hourlyRate: 0,
    billedAmount: 0,
    status: TimeEntryStatus.completed,
  ),
  // Priya Patel — 3 entries
  TimeEntry(
    id: 'te-004',
    staffId: 'staff-02',
    staffName: 'Priya Patel',
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    taskDescription: 'GST-3B reconciliation for Feb 2026',
    startTime: _today.add(const Duration(hours: 9, minutes: 30)),
    endTime: _today.add(const Duration(hours: 12)),
    durationMinutes: 150,
    isBillable: true,
    hourlyRate: 1800,
    billedAmount: 4500,
    status: TimeEntryStatus.completed,
  ),
  TimeEntry(
    id: 'te-005',
    staffId: 'staff-02',
    staffName: 'Priya Patel',
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    taskDescription: 'Input tax credit verification',
    startTime: _today.add(const Duration(hours: 13)),
    endTime: _today.add(const Duration(hours: 14, minutes: 30)),
    durationMinutes: 90,
    isBillable: true,
    hourlyRate: 1800,
    billedAmount: 2700,
    status: TimeEntryStatus.completed,
  ),
  TimeEntry(
    id: 'te-006',
    staffId: 'staff-02',
    staffName: 'Priya Patel',
    clientId: '2',
    clientName: 'Priya Mehta',
    taskDescription: 'ITR-3 computation draft — freelance income',
    startTime: _today.add(const Duration(hours: 15)),
    durationMinutes: 45,
    isBillable: true,
    hourlyRate: 1800,
    billedAmount: 1350,
    status: TimeEntryStatus.running,
  ),
  // Rohit Gupta — 3 entries
  TimeEntry(
    id: 'te-007',
    staffId: 'staff-03',
    staffName: 'Rohit Gupta',
    clientId: '4',
    clientName: 'Mehta & Sons',
    taskDescription: 'TDS Return Q4 — Form 24Q preparation',
    startTime: _today.add(const Duration(hours: 9)),
    endTime: _today.add(const Duration(hours: 11)),
    durationMinutes: 120,
    isBillable: true,
    hourlyRate: 1500,
    billedAmount: 3000,
    status: TimeEntryStatus.billed,
  ),
  TimeEntry(
    id: 'te-008',
    staffId: 'staff-03',
    staffName: 'Rohit Gupta',
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    taskDescription: 'Tax audit 3CD annexures preparation',
    startTime: _today.add(const Duration(hours: 11, minutes: 30)),
    endTime: _today.add(const Duration(hours: 14)),
    durationMinutes: 150,
    isBillable: true,
    hourlyRate: 1500,
    billedAmount: 3750,
    status: TimeEntryStatus.completed,
  ),
  TimeEntry(
    id: 'te-009',
    staffId: 'staff-03',
    staffName: 'Rohit Gupta',
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    taskDescription: 'GST filing for Feb 2026',
    startTime: _today.add(const Duration(hours: 14, minutes: 30)),
    endTime: _today.add(const Duration(hours: 15, minutes: 30)),
    durationMinutes: 60,
    isBillable: true,
    hourlyRate: 1500,
    billedAmount: 1500,
    status: TimeEntryStatus.completed,
  ),
  // Neha Singh — 3 entries
  TimeEntry(
    id: 'te-010',
    staffId: 'staff-04',
    staffName: 'Neha Singh',
    clientId: '14',
    clientName: 'Vikram Singh Rathore',
    taskDescription: 'Bookkeeping — Feb 2026 entries',
    startTime: _today.add(const Duration(hours: 9)),
    endTime: _today.add(const Duration(hours: 12, minutes: 30)),
    durationMinutes: 210,
    isBillable: true,
    hourlyRate: 1200,
    billedAmount: 4200,
    status: TimeEntryStatus.completed,
  ),
  TimeEntry(
    id: 'te-011',
    staffId: 'staff-04',
    staffName: 'Neha Singh',
    clientId: '0',
    clientName: 'Internal',
    taskDescription: 'Training session — new GST rules 2026',
    startTime: _today.add(const Duration(hours: 13)),
    endTime: _today.add(const Duration(hours: 14)),
    durationMinutes: 60,
    isBillable: false,
    hourlyRate: 0,
    billedAmount: 0,
    status: TimeEntryStatus.completed,
  ),
  TimeEntry(
    id: 'te-012',
    staffId: 'staff-04',
    staffName: 'Neha Singh',
    clientId: '10',
    clientName: 'Sharma Charitable Trust',
    taskDescription: 'Trust audit report — 12A compliance',
    startTime: _today.add(const Duration(hours: 14, minutes: 30)),
    endTime: _today.add(const Duration(hours: 16)),
    durationMinutes: 90,
    isBillable: true,
    hourlyRate: 1200,
    billedAmount: 1800,
    status: TimeEntryStatus.completed,
  ),
  // Kavita Desai — 3 entries
  TimeEntry(
    id: 'te-013',
    staffId: 'staff-05',
    staffName: 'Kavita Desai',
    clientId: '9',
    clientName: 'Deepak Patel',
    taskDescription: 'GST return Feb 2026 — freelance consultant',
    startTime: _today.add(const Duration(hours: 10)),
    endTime: _today.add(const Duration(hours: 11, minutes: 30)),
    durationMinutes: 90,
    isBillable: true,
    hourlyRate: 1500,
    billedAmount: 2250,
    status: TimeEntryStatus.completed,
  ),
  TimeEntry(
    id: 'te-014',
    staffId: 'staff-05',
    staffName: 'Kavita Desai',
    clientId: '12',
    clientName: 'Hindustan Traders AOP',
    taskDescription: 'Monthly bookkeeping — Feb 2026',
    startTime: _today.add(const Duration(hours: 12)),
    endTime: _today.add(const Duration(hours: 14)),
    durationMinutes: 120,
    isBillable: true,
    hourlyRate: 1500,
    billedAmount: 3000,
    status: TimeEntryStatus.completed,
  ),
  TimeEntry(
    id: 'te-015',
    staffId: 'staff-05',
    staffName: 'Kavita Desai',
    clientId: '7',
    clientName: 'Anil Gupta HUF',
    taskDescription: 'HUF ITR preparation — rental income',
    startTime: _today.add(const Duration(hours: 14, minutes: 30)),
    durationMinutes: 75,
    isBillable: true,
    hourlyRate: 1500,
    billedAmount: 1875,
    status: TimeEntryStatus.paused,
  ),
];

// ---------------------------------------------------------------------------
// Billing summaries — 8 clients
// ---------------------------------------------------------------------------

final billingSummariesProvider =
    NotifierProvider<BillingSummariesNotifier, List<BillingSummary>>(
      BillingSummariesNotifier.new,
    );

class BillingSummariesNotifier extends Notifier<List<BillingSummary>> {
  @override
  List<BillingSummary> build() => List.unmodifiable(_mockBillingSummaries);

  void update(List<BillingSummary> value) => state = value;
}

const _mockBillingSummaries = <BillingSummary>[
  BillingSummary(
    clientId: '1',
    clientName: 'Rajesh Kumar Sharma',
    totalHours: 12.5,
    billableHours: 10.0,
    nonBillableHours: 2.5,
    totalBilled: 20000,
    realizationRate: 80.0,
    period: 'Mar 2026',
  ),
  BillingSummary(
    clientId: '3',
    clientName: 'ABC Infra Pvt Ltd',
    totalHours: 45.0,
    billableHours: 40.0,
    nonBillableHours: 5.0,
    totalBilled: 172000,
    realizationRate: 88.9,
    period: 'Mar 2026',
  ),
  BillingSummary(
    clientId: '4',
    clientName: 'Mehta & Sons',
    totalHours: 18.0,
    billableHours: 16.0,
    nonBillableHours: 2.0,
    totalBilled: 25500,
    realizationRate: 88.9,
    period: 'Mar 2026',
  ),
  BillingSummary(
    clientId: '6',
    clientName: 'TechVista Solutions LLP',
    totalHours: 32.0,
    billableHours: 28.0,
    nonBillableHours: 4.0,
    totalBilled: 47000,
    realizationRate: 87.5,
    period: 'Mar 2026',
  ),
  BillingSummary(
    clientId: '8',
    clientName: 'Bharat Electronics Ltd',
    totalHours: 68.0,
    billableHours: 62.0,
    nonBillableHours: 6.0,
    totalBilled: 310000,
    realizationRate: 91.2,
    period: 'Mar 2026',
  ),
  BillingSummary(
    clientId: '9',
    clientName: 'Deepak Patel',
    totalHours: 8.0,
    billableHours: 7.5,
    nonBillableHours: 0.5,
    totalBilled: 13000,
    realizationRate: 93.8,
    period: 'Mar 2026',
  ),
  BillingSummary(
    clientId: '13',
    clientName: 'GreenLeaf Organics LLP',
    totalHours: 14.0,
    billableHours: 12.0,
    nonBillableHours: 2.0,
    totalBilled: 17000,
    realizationRate: 85.7,
    period: 'Mar 2026',
  ),
  BillingSummary(
    clientId: '14',
    clientName: 'Vikram Singh Rathore',
    totalHours: 22.0,
    billableHours: 20.0,
    nonBillableHours: 2.0,
    totalBilled: 32000,
    realizationRate: 90.9,
    period: 'Mar 2026',
  ),
];

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

/// Filtered time entries based on the active filter.
final filteredTimeEntriesProvider = Provider<List<TimeEntry>>((ref) {
  final entries = ref.watch(timeEntriesProvider);
  final filter = ref.watch(timeEntryFilterProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

  switch (filter) {
    case TimeEntryFilter.all:
      return entries;
    case TimeEntryFilter.today:
      return entries
          .where(
            (e) =>
                e.startTime.isAfter(todayStart) ||
                e.startTime.isAtSameMomentAs(todayStart),
          )
          .toList();
    case TimeEntryFilter.thisWeek:
      return entries
          .where(
            (e) =>
                e.startTime.isAfter(weekStart) ||
                e.startTime.isAtSameMomentAs(weekStart),
          )
          .toList();
    case TimeEntryFilter.billable:
      return entries.where((e) => e.isBillable).toList();
    case TimeEntryFilter.nonBillable:
      return entries.where((e) => !e.isBillable).toList();
  }
});

/// Today's total hours worked.
final todayTotalHoursProvider = Provider<double>((ref) {
  final entries = ref.watch(filteredTimeEntriesProvider);
  final totalMinutes = entries.fold<int>(
    0,
    (sum, e) => sum + e.durationMinutes,
  );
  return totalMinutes / 60.0;
});

/// Today's total billed amount.
final todayTotalBilledProvider = Provider<double>((ref) {
  final entries = ref.watch(filteredTimeEntriesProvider);
  return entries.fold<double>(0, (sum, e) => sum + e.billedAmount);
});

/// Weekly summary stats.
final weeklySummaryProvider = Provider<Map<String, double>>((ref) {
  final entries = ref.watch(timeEntriesProvider);
  final now = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));

  final weekEntries = entries
      .where(
        (e) =>
            e.startTime.isAfter(weekStart) ||
            e.startTime.isAtSameMomentAs(weekStart),
      )
      .toList();

  final totalMinutes = weekEntries.fold<int>(
    0,
    (sum, e) => sum + e.durationMinutes,
  );
  final billableMinutes = weekEntries
      .where((e) => e.isBillable)
      .fold<int>(0, (sum, e) => sum + e.durationMinutes);
  final totalBilled = weekEntries.fold<double>(
    0,
    (sum, e) => sum + e.billedAmount,
  );

  return {
    'totalHours': totalMinutes / 60.0,
    'billableHours': billableMinutes / 60.0,
    'totalBilled': totalBilled,
    'utilizationRate': totalMinutes > 0
        ? (billableMinutes / totalMinutes) * 100
        : 0,
  };
});

/// Realization summary derived from billing summaries.
final realizationSummaryProvider = Provider<Map<String, double>>((ref) {
  final summaries = ref.watch(billingSummariesProvider);
  if (summaries.isEmpty) {
    return {'utilizationPct': 0, 'effectiveRate': 0, 'totalBillable': 0};
  }

  final totalHours = summaries.fold<double>(0, (sum, s) => sum + s.totalHours);
  final billableHours = summaries.fold<double>(
    0,
    (sum, s) => sum + s.billableHours,
  );
  final totalBilled = summaries.fold<double>(
    0,
    (sum, s) => sum + s.totalBilled,
  );

  final utilizationPct = RealizationCalculator.weeklyUtilization(billableHours);
  final effectiveRate = RealizationCalculator.effectiveHourlyRate(
    totalBilled,
    totalHours,
  );

  return {
    'utilizationPct': utilizationPct,
    'effectiveRate': effectiveRate,
    'totalBillable': totalBilled,
  };
});
