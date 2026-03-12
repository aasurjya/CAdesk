// ignore_for_file: public_member_api_docs

/// Severity levels for audit log entries.
enum LogSeverity { info, warning, critical }

/// An immutable record of a user action in the system.
final class AuditLogEntry {
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
  });

  final String logId;
  final String userId;
  final String userName;
  final String action;
  final DateTime timestamp;
  final LogSeverity severity;
  final Map<String, dynamic> metadata;
  final String? resourceType;
  final String? resourceId;

  AuditLogEntry copyWith({
    String? logId,
    String? userId,
    String? userName,
    String? action,
    DateTime? timestamp,
    LogSeverity? severity,
    Map<String, dynamic>? metadata,
    String? resourceType,
    String? resourceId,
  }) {
    return AuditLogEntry(
      logId: logId ?? this.logId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      metadata: metadata ?? this.metadata,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
    );
  }

  /// Equality is based solely on [logId] — the stable identity key.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditLogEntry &&
          runtimeType == other.runtimeType &&
          logId == other.logId;

  @override
  int get hashCode => logId.hashCode;

  @override
  String toString() =>
      'AuditLogEntry(logId: $logId, userId: $userId, action: $action, '
      'severity: $severity, timestamp: $timestamp)';
}
