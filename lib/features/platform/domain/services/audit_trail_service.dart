import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';

/// In-memory audit trail service.
///
/// Stores log entries for the lifetime of the service instance.
/// Production implementations would persist to a database or remote service.
class AuditTrailService {
  AuditTrailService();

  final List<AuditLogEntry> _store = [];
  int _counter = 0;

  String _nextId() {
    _counter++;
    return 'log-${DateTime.now().millisecondsSinceEpoch}-$_counter';
  }

  /// Records a new [AuditLogEntry] and returns the created entry.
  ///
  /// [overrideTimestamp] is an escape hatch for testing date-range filters.
  AuditLogEntry log(
    String userId,
    String userName,
    String action, {
    String? resourceType,
    String? resourceId,
    Map<String, String>? metadata,
    String? ipAddress,
    LogSeverity severity = LogSeverity.info,
    DateTime? overrideTimestamp,
  }) {
    final entry = AuditLogEntry(
      logId: _nextId(),
      userId: userId,
      userName: userName,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      timestamp: overrideTimestamp ?? DateTime.now(),
      ipAddress: ipAddress,
      metadata: metadata ?? const {},
      severity: severity,
    );
    _store.add(entry);
    return entry;
  }

  /// Returns up to [limit] most-recent entries, newest first.
  ///
  /// [firmId] is reserved for multi-tenant filtering in the real implementation.
  List<AuditLogEntry> getRecentLogs(String firmId, {int limit = 50}) {
    final sorted = _store.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList(growable: false);
  }

  /// Returns all entries whose [resourceType] and [resourceId] match.
  List<AuditLogEntry> getLogsForResource(
    String resourceType,
    String resourceId,
  ) {
    return _store
        .where(
          (e) => e.resourceType == resourceType && e.resourceId == resourceId,
        )
        .toList(growable: false);
  }

  /// Returns all entries for [userId], optionally bounded by [from] and [to].
  List<AuditLogEntry> getLogsForUser(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) {
    return _store.where((e) {
      if (e.userId != userId) return false;
      if (from != null && e.timestamp.isBefore(from)) return false;
      if (to != null && e.timestamp.isAfter(to)) return false;
      return true;
    }).toList(growable: false);
  }

  /// Returns the subset of [logs] whose severity index is >= [minSeverity].
  List<AuditLogEntry> filterBySeverity(
    List<AuditLogEntry> logs,
    LogSeverity minSeverity,
  ) {
    final minIndex = LogSeverity.values.indexOf(minSeverity);
    return logs
        .where((e) => LogSeverity.values.indexOf(e.severity) >= minIndex)
        .toList(growable: false);
  }
}
