/// Severity classification of an audit log entry.
enum LogSeverity {
  /// Routine informational event (login, view).
  info,

  /// Potentially unusual event (failed attempt, bulk action).
  warning,

  /// High-impact or security-sensitive event (unauthorized access, data deletion).
  critical,
}

/// Immutable record of a user action in the CADesk audit trail.
class AuditLogEntry {
  const AuditLogEntry({
    required this.logId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.timestamp,
    required this.severity,
    required this.metadata,
    this.resourceType,
    this.resourceId,
    this.ipAddress,
  });

  final String logId;
  final String userId;
  final String userName;

  /// Action code, e.g. "ITR_FILED", "CLIENT_CREATED", "DOCUMENT_SHARED".
  final String action;
  final String? resourceType;
  final String? resourceId;
  final DateTime timestamp;
  final String? ipAddress;

  /// Additional structured context for the event.
  final Map<String, String> metadata;
  final LogSeverity severity;

  AuditLogEntry copyWith({
    String? logId,
    String? userId,
    String? userName,
    String? action,
    String? resourceType,
    String? resourceId,
    DateTime? timestamp,
    String? ipAddress,
    Map<String, String>? metadata,
    LogSeverity? severity,
  }) {
    return AuditLogEntry(
      logId: logId ?? this.logId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      action: action ?? this.action,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      metadata: metadata ?? this.metadata,
      severity: severity ?? this.severity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditLogEntry && other.logId == logId;
  }

  @override
  int get hashCode => logId.hashCode;

  @override
  String toString() =>
      'AuditLogEntry(logId: $logId, action: $action, severity: $severity)';
}
