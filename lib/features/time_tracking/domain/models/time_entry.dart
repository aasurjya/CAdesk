/// Status of a time-tracking entry.
enum TimeEntryStatus {
  running('Running'),
  paused('Paused'),
  completed('Completed'),
  billed('Billed');

  const TimeEntryStatus(this.label);

  final String label;
}

/// A single time entry recorded by a staff member for a client task.
class TimeEntry {
  const TimeEntry({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.clientId,
    required this.clientName,
    required this.taskDescription,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.isBillable,
    required this.hourlyRate,
    required this.billedAmount,
    required this.status,
  });

  final String id;
  final String staffId;
  final String staffName;
  final String clientId;
  final String clientName;
  final String taskDescription;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final bool isBillable;
  final double hourlyRate;
  final double billedAmount;
  final TimeEntryStatus status;

  /// Duration formatted as "Xh Ym".
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  /// Staff initials for avatar display.
  String get staffInitials {
    final parts = staffName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return staffName.substring(0, staffName.length >= 2 ? 2 : 1).toUpperCase();
  }

  TimeEntry copyWith({
    String? id,
    String? staffId,
    String? staffName,
    String? clientId,
    String? clientName,
    String? taskDescription,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    bool? isBillable,
    double? hourlyRate,
    double? billedAmount,
    TimeEntryStatus? status,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      taskDescription: taskDescription ?? this.taskDescription,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isBillable: isBillable ?? this.isBillable,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      billedAmount: billedAmount ?? this.billedAmount,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
