import 'package:flutter/foundation.dart';

/// Immutable model representing a staff KPI record for a given period.
@immutable
class StaffKpi {
  const StaffKpi({
    required this.staffId,
    required this.staffName,
    required this.period,
    required this.billableHours,
    required this.totalHours,
    required this.tasksCompleted,
    required this.tasksAssigned,
    required this.qualityScore,
    required this.utilizationRate,
    required this.realizationRate,
  });

  final String staffId;
  final String staffName;
  final String period;
  final double billableHours;
  final double totalHours;
  final int tasksCompleted;
  final int tasksAssigned;

  /// Quality score out of 100.
  final double qualityScore;

  /// Percentage of total hours that are billable (0.0 to 1.0).
  final double utilizationRate;

  /// Percentage of billed amount actually collected (0.0 to 1.0).
  final double realizationRate;

  /// Task completion ratio (0.0 to 1.0).
  double get taskCompletionRate =>
      tasksAssigned > 0 ? (tasksCompleted / tasksAssigned).clamp(0.0, 1.0) : 0.0;

  /// Returns a new [StaffKpi] with the given fields replaced.
  StaffKpi copyWith({
    String? staffId,
    String? staffName,
    String? period,
    double? billableHours,
    double? totalHours,
    int? tasksCompleted,
    int? tasksAssigned,
    double? qualityScore,
    double? utilizationRate,
    double? realizationRate,
  }) {
    return StaffKpi(
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      period: period ?? this.period,
      billableHours: billableHours ?? this.billableHours,
      totalHours: totalHours ?? this.totalHours,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      tasksAssigned: tasksAssigned ?? this.tasksAssigned,
      qualityScore: qualityScore ?? this.qualityScore,
      utilizationRate: utilizationRate ?? this.utilizationRate,
      realizationRate: realizationRate ?? this.realizationRate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffKpi &&
          runtimeType == other.runtimeType &&
          staffId == other.staffId &&
          period == other.period &&
          billableHours == other.billableHours &&
          totalHours == other.totalHours &&
          tasksCompleted == other.tasksCompleted &&
          tasksAssigned == other.tasksAssigned &&
          qualityScore == other.qualityScore &&
          utilizationRate == other.utilizationRate &&
          realizationRate == other.realizationRate;

  @override
  int get hashCode => Object.hash(
        staffId,
        period,
        billableHours,
        totalHours,
        tasksCompleted,
        tasksAssigned,
        qualityScore,
        utilizationRate,
        realizationRate,
      );

  @override
  String toString() =>
      'StaffKpi(staffId: $staffId, period: $period, utilization: $utilizationRate)';
}
