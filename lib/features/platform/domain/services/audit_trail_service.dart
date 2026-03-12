<<<<<<< HEAD
// ignore_for_file: public_member_api_docs

import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';

/// Service for recording and querying immutable audit log entries.
///
/// Each [AuditTrailService] instance maintains its own in-memory store,
/// making it trivial to isolate in tests.
final class AuditTrailService {
=======
import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';

/// In-memory audit trail service.
///
/// Stores log entries for the lifetime of the service instance.
/// Production implementations would persist to a database or remote service.
class AuditTrailService {
>>>>>>> worktree-agent-ad3dc1f5
  AuditTrailService();

  final List<AuditLogEntry> _store = [];
  int _counter = 0;

<<<<<<< HEAD
  // ---------------------------------------------------------------------------
  // Write API
  // ---------------------------------------------------------------------------

  /// Creates an [AuditLogEntry], stores it, and returns it.
  ///
  /// [overrideTimestamp] is an escape hatch used in tests to inject a fixed
  /// timestamp; production callers omit it.
=======
  String _nextId() {
    _counter++;
    return 'log-${DateTime.now().millisecondsSinceEpoch}-$_counter';
  }

  /// Records a new [AuditLogEntry] and returns the created entry.
  ///
  /// [overrideTimestamp] is an escape hatch for testing date-range filters.
>>>>>>> worktree-agent-ad3dc1f5
  AuditLogEntry log(
    String userId,
    String userName,
    String action, {
    String? resourceType,
    String? resourceId,
<<<<<<< HEAD
    Map<String, dynamic> metadata = const {},
    LogSeverity severity = LogSeverity.info,
    DateTime? overrideTimestamp,
  }) {
    _counter++;
    final entry = AuditLogEntry(
      logId: 'log-$_counter-${DateTime.now().microsecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      action: action,
      timestamp: overrideTimestamp ?? DateTime.now(),
      severity: severity,
      metadata: metadata,
      resourceType: resourceType,
      resourceId: resourceId,
=======
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
>>>>>>> worktree-agent-ad3dc1f5
    );
    _store.add(entry);
    return entry;
  }

<<<<<<< HEAD
  // ---------------------------------------------------------------------------
  // Query API
  // ---------------------------------------------------------------------------

  /// Returns at most [limit] entries (newest first) regardless of firm.
  ///
  /// [firmId] is accepted for API consistency but ignored in this in-memory
  /// implementation — all stored entries are returned.
  List<AuditLogEntry> getRecentLogs(String firmId, {int limit = 50}) {
    final sorted = List<AuditLogEntry>.from(_store)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  /// Returns all entries whose [AuditLogEntry.resourceType] and
  /// [AuditLogEntry.resourceId] match the provided values.
=======
  /// Returns up to [limit] most-recent entries, newest first.
  ///
  /// [firmId] is reserved for multi-tenant filtering in the real implementation.
  List<AuditLogEntry> getRecentLogs(String firmId, {int limit = 50}) {
    final sorted = _store.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList(growable: false);
  }

  /// Returns all entries whose [resourceType] and [resourceId] match.
>>>>>>> worktree-agent-ad3dc1f5
  List<AuditLogEntry> getLogsForResource(
    String resourceType,
    String resourceId,
  ) {
    return _store
        .where(
          (e) => e.resourceType == resourceType && e.resourceId == resourceId,
        )
<<<<<<< HEAD
        .toList();
  }

  /// Returns entries for [userId], optionally filtered by date range.
=======
        .toList(growable: false);
  }

  /// Returns all entries for [userId], optionally bounded by [from] and [to].
>>>>>>> worktree-agent-ad3dc1f5
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
<<<<<<< HEAD
    }).toList();
  }

  /// Filters [entries] to those whose severity is at or above [minSeverity].
  List<AuditLogEntry> filterBySeverity(
    List<AuditLogEntry> entries,
    LogSeverity minSeverity,
  ) {
    final minIndex = LogSeverity.values.indexOf(minSeverity);
    return entries
        .where((e) => LogSeverity.values.indexOf(e.severity) >= minIndex)
        .toList();
=======
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
>>>>>>> worktree-agent-ad3dc1f5
  }
}
