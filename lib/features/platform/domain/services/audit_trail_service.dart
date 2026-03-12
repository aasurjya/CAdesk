// ignore_for_file: public_member_api_docs

import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';

/// Service for recording and querying immutable audit log entries.
///
/// Each [AuditTrailService] instance maintains its own in-memory store,
/// making it trivial to isolate in tests.
final class AuditTrailService {
  AuditTrailService();

  final List<AuditLogEntry> _store = [];
  int _counter = 0;

  // ---------------------------------------------------------------------------
  // Write API
  // ---------------------------------------------------------------------------

  /// Creates an [AuditLogEntry], stores it, and returns it.
  ///
  /// [overrideTimestamp] is an escape hatch used in tests to inject a fixed
  /// timestamp; production callers omit it.
  AuditLogEntry log(
    String userId,
    String userName,
    String action, {
    String? resourceType,
    String? resourceId,
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
    );
    _store.add(entry);
    return entry;
  }

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
  List<AuditLogEntry> getLogsForResource(
    String resourceType,
    String resourceId,
  ) {
    return _store
        .where(
          (e) => e.resourceType == resourceType && e.resourceId == resourceId,
        )
        .toList();
  }

  /// Returns entries for [userId], optionally filtered by date range.
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
  }
}
