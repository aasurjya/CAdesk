<<<<<<< HEAD
// ignore_for_file: public_member_api_docs

/// Severity levels for audit log entries.
enum LogSeverity { info, warning, critical }

/// An immutable record of a user action in the system.
final class AuditLogEntry {
=======
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
>>>>>>> worktree-agent-ad3dc1f5
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
<<<<<<< HEAD
=======
    this.ipAddress,
>>>>>>> worktree-agent-ad3dc1f5
  });

  final String logId;
  final String userId;
  final String userName;
<<<<<<< HEAD
  final String action;
  final DateTime timestamp;
  final LogSeverity severity;
  final Map<String, dynamic> metadata;
  final String? resourceType;
  final String? resourceId;
=======

  /// Action code, e.g. "ITR_FILED", "CLIENT_CREATED", "DOCUMENT_SHARED".
  final String action;
  final String? resourceType;
  final String? resourceId;
  final DateTime timestamp;
  final String? ipAddress;

  /// Additional structured context for the event.
  final Map<String, String> metadata;
  final LogSeverity severity;
>>>>>>> worktree-agent-ad3dc1f5

  AuditLogEntry copyWith({
    String? logId,
    String? userId,
    String? userName,
    String? action,
<<<<<<< HEAD
    DateTime? timestamp,
    LogSeverity? severity,
    Map<String, dynamic>? metadata,
    String? resourceType,
    String? resourceId,
=======
    String? resourceType,
    String? resourceId,
    DateTime? timestamp,
    String? ipAddress,
    Map<String, String>? metadata,
    LogSeverity? severity,
>>>>>>> worktree-agent-ad3dc1f5
  }) {
    return AuditLogEntry(
      logId: logId ?? this.logId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      action: action ?? this.action,
<<<<<<< HEAD
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
=======
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
>>>>>>> worktree-agent-ad3dc1f5

  @override
  int get hashCode => logId.hashCode;

  @override
  String toString() =>
<<<<<<< HEAD
      'AuditLogEntry(logId: $logId, userId: $userId, action: $action, '
      'severity: $severity, timestamp: $timestamp)';
=======
      'AuditLogEntry(logId: $logId, action: $action, severity: $severity)';
>>>>>>> worktree-agent-ad3dc1f5
}
