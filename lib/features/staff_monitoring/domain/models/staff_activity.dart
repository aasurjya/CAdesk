enum ActivityType {
  filing,
  clientCall,
  documentReview,
  dataEntry,
  portalWork,
  other,
}

class StaffActivity {
  const StaffActivity({
    required this.id,
    required this.staffId,
    required this.activityType,
    this.clientId,
    this.taskId,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.notes,
  });

  final String id;
  final String staffId;
  final ActivityType activityType;
  final String? clientId;
  final String? taskId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final String? notes;

  StaffActivity copyWith({
    String? id,
    String? staffId,
    ActivityType? activityType,
    String? clientId,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? notes,
  }) {
    return StaffActivity(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      activityType: activityType ?? this.activityType,
      clientId: clientId ?? this.clientId,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
    );
  }
}
