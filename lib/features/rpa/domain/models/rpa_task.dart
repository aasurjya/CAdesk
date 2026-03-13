enum RpaTaskType {
  gstLogin,
  tdsDownload,
  itrSubmit,
  traces26asFetch,
  mcaFiling,
  portalStatusCheck,
}

enum RpaStatus { scheduled, running, completed, failed, cancelled }

class RpaTask {
  const RpaTask({
    required this.id,
    required this.taskType,
    this.clientId,
    required this.status,
    required this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.result,
    this.errorMessage,
    required this.retryCount,
  });

  final String id;
  final RpaTaskType taskType;
  final String? clientId;
  final RpaStatus status;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? result;
  final String? errorMessage;
  final int retryCount;

  RpaTask copyWith({
    String? id,
    RpaTaskType? taskType,
    String? clientId,
    RpaStatus? status,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? errorMessage,
    int? retryCount,
  }) {
    return RpaTask(
      id: id ?? this.id,
      taskType: taskType ?? this.taskType,
      clientId: clientId ?? this.clientId,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
