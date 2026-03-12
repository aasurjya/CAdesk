import 'package:ca_app/features/filing/domain/models/analytics/filing_statistics.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';

/// Immutable model for an ITR filing deadline entry.
class DeadlineEntry {
  const DeadlineEntry({
    required this.label,
    required this.date,
    required this.itrTypes,
    required this.description,
  });

  /// Short label for the deadline (e.g. 'Original — Non-Audit').
  final String label;

  /// Due date for filing.
  final DateTime date;

  /// ITR types this deadline applies to (e.g. ['ITR-1', 'ITR-2', 'ITR-4']).
  final List<String> itrTypes;

  /// Detailed description of the deadline.
  final String description;

  DeadlineEntry copyWith({
    String? label,
    DateTime? date,
    List<String>? itrTypes,
    String? description,
  }) {
    return DeadlineEntry(
      label: label ?? this.label,
      date: date ?? this.date,
      itrTypes: itrTypes ?? this.itrTypes,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeadlineEntry) return false;
    if (other.label != label ||
        other.date != date ||
        other.description != description) {
      return false;
    }
    if (other.itrTypes.length != itrTypes.length) return false;
    for (int i = 0; i < itrTypes.length; i++) {
      if (other.itrTypes[i] != itrTypes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(label, date, Object.hashAll(itrTypes), description);
}

/// Stateless service for computing filing analytics and deadline calendars.
///
/// Every method returns new objects — no mutation of inputs.
class FilingAnalyticsService {
  const FilingAnalyticsService._();

  /// The set of statuses considered as "filed" (completed).
  static const _filedStatuses = {
    FilingJobStatus.filed,
    FilingJobStatus.verified,
  };

  /// Computes aggregate [FilingStatistics] from a list of [FilingJob]s.
  static FilingStatistics computeStatistics(List<FilingJob> jobs) {
    final now = DateTime.now();
    final total = jobs.length;

    final filed = jobs.where((j) => _filedStatuses.contains(j.status)).toList();
    final filedCount = filed.length;

    final pending = jobs
        .where((j) => !_filedStatuses.contains(j.status))
        .toList();
    final pendingCount = pending.length;

    final overdueCount = pending
        .where((j) => j.dueDate != null && j.dueDate!.isBefore(now))
        .length;

    // Average turnaround: days between creation and filing date.
    final turnaroundDays = filed
        .where((j) => j.filingDate != null)
        .map((j) => j.filingDate!.difference(j.createdAt).inDays.toDouble())
        .toList();
    final avgTurnaround = turnaroundDays.isNotEmpty
        ? turnaroundDays.reduce((a, b) => a + b) / turnaroundDays.length
        : 0.0;

    final revenueCollected = filed.fold(
      0.0,
      (sum, j) => sum + (j.feeReceived ?? 0),
    );
    final revenueOutstanding = pending.fold(
      0.0,
      (sum, j) => sum + (j.feeQuoted ?? 0),
    );

    return FilingStatistics(
      totalFilings: total,
      filedCount: filedCount,
      pendingCount: pendingCount,
      overdueCount: overdueCount,
      averageTurnaroundDays: avgTurnaround,
      revenueCollected: revenueCollected,
      revenueOutstanding: revenueOutstanding,
    );
  }

  /// Returns the standard ITR filing deadline calendar for the given
  /// assessment year.
  ///
  /// Assessment year format: '2026-27' (for FY 2025-26).
  static List<DeadlineEntry> getDeadlineCalendar(String assessmentYear) {
    // Extract the AY start year (e.g. 2026 from '2026-27').
    final ayStartYear = int.parse(assessmentYear.split('-').first);

    return [
      DeadlineEntry(
        label: 'Original — Non-Audit',
        date: DateTime(ayStartYear, 7, 31),
        itrTypes: const ['ITR-1', 'ITR-2', 'ITR-4'],
        description:
            'Due date for individuals and entities not requiring audit.',
      ),
      DeadlineEntry(
        label: 'Original — Audit',
        date: DateTime(ayStartYear, 10, 31),
        itrTypes: const ['ITR-3', 'ITR-5', 'ITR-6'],
        description:
            'Due date for assessees whose accounts are required to be audited.',
      ),
      DeadlineEntry(
        label: 'Original — Transfer Pricing',
        date: DateTime(ayStartYear, 11, 30),
        itrTypes: const ['ITR-3', 'ITR-6'],
        description:
            'Due date for assessees with international / specified domestic '
            'transactions requiring transfer pricing report.',
      ),
      DeadlineEntry(
        label: 'Belated / Revised Return',
        date: DateTime(ayStartYear, 12, 31),
        itrTypes: const ['ITR-1', 'ITR-2', 'ITR-3', 'ITR-4', 'ITR-5', 'ITR-6'],
        description:
            'Last date to file belated return u/s 139(4) or revised '
            'return u/s 139(5).',
      ),
      DeadlineEntry(
        label: 'Updated Return (ITR-U)',
        date: DateTime(ayStartYear + 2, 3, 31),
        itrTypes: const ['ITR-U'],
        description:
            'Last date to file updated return u/s 139(8A) — within '
            '24 months from end of the relevant assessment year.',
      ),
    ];
  }
}
