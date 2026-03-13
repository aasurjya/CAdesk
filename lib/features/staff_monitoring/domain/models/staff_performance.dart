class StaffPerformance {
  const StaffPerformance({
    required this.id,
    required this.staffId,
    required this.period,
    required this.tasksCompleted,
    required this.hoursLogged,
    required this.clientsHandled,
    required this.avgCompletionTime,
    required this.createdAt,
  });

  final String id;
  final String staffId;
  final String period;
  final int tasksCompleted;
  final double hoursLogged;
  final int clientsHandled;
  final double avgCompletionTime;
  final DateTime createdAt;

  StaffPerformance copyWith({
    String? id,
    String? staffId,
    String? period,
    int? tasksCompleted,
    double? hoursLogged,
    int? clientsHandled,
    double? avgCompletionTime,
    DateTime? createdAt,
  }) {
    return StaffPerformance(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      period: period ?? this.period,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      hoursLogged: hoursLogged ?? this.hoursLogged,
      clientsHandled: clientsHandled ?? this.clientsHandled,
      avgCompletionTime: avgCompletionTime ?? this.avgCompletionTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
