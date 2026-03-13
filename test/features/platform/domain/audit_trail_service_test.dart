import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';
import 'package:ca_app/features/platform/domain/services/audit_trail_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuditTrailService service;

  setUp(() {
    service = AuditTrailService();
  });

  group('AuditTrailService.log', () {
    test('creates and stores an audit log entry', () {
      final entry = service.log(
        'user-1',
        'Alice',
        'ITR_FILED',
        resourceType: 'ITR',
        resourceId: 'itr-123',
      );

      expect(entry.userId, 'user-1');
      expect(entry.userName, 'Alice');
      expect(entry.action, 'ITR_FILED');
      expect(entry.resourceType, 'ITR');
      expect(entry.resourceId, 'itr-123');
      expect(entry.logId, isNotEmpty);
    });

    test('entry has a timestamp close to now', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final entry = service.log('user-1', 'Alice', 'CLIENT_CREATED');
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(
        entry.timestamp.isAfter(before) && entry.timestamp.isBefore(after),
        isTrue,
      );
    });

    test('stores metadata when provided', () {
      final entry = service.log(
        'user-2',
        'Bob',
        'DOCUMENT_SHARED',
        metadata: {'recipientId': 'client-55', 'docType': 'PDF'},
      );

      expect(entry.metadata['recipientId'], 'client-55');
      expect(entry.metadata['docType'], 'PDF');
    });

    test('defaults to info severity when no severity specified', () {
      final entry = service.log('user-1', 'Alice', 'LOGIN');
      expect(entry.severity, LogSeverity.info);
    });

    test('accepts explicit severity', () {
      final entry = service.log(
        'user-1',
        'Alice',
        'UNAUTHORIZED_ACCESS',
        severity: LogSeverity.critical,
      );
      expect(entry.severity, LogSeverity.critical);
    });

    test('returned entry is stored and retrievable', () {
      service.log('user-1', 'Alice', 'LOGIN');
      final logs = service.getRecentLogs('firm-1');
      expect(logs, hasLength(1));
    });
  });

  group('AuditTrailService.getRecentLogs', () {
    test('returns at most limit entries', () {
      for (var i = 0; i < 10; i++) {
        service.log('user-1', 'Alice', 'ACTION_$i');
      }

      final logs = service.getRecentLogs('firm-1', limit: 5);
      expect(logs.length, 5);
    });

    test('returns entries in reverse chronological order', () {
      service.log('user-1', 'Alice', 'FIRST');
      service.log('user-2', 'Bob', 'SECOND');

      final logs = service.getRecentLogs('firm-1');
      expect(logs.first.action, 'SECOND');
      expect(logs.last.action, 'FIRST');
    });

    test('returns empty list when no logs exist', () {
      final logs = service.getRecentLogs('firm-1');
      expect(logs, isEmpty);
    });
  });

  group('AuditTrailService.getLogsForResource', () {
    test('returns only logs matching resourceType and resourceId', () {
      service.log(
        'user-1',
        'Alice',
        'ITR_FILED',
        resourceType: 'ITR',
        resourceId: 'itr-1',
      );
      service.log(
        'user-2',
        'Bob',
        'GST_SUBMITTED',
        resourceType: 'GST',
        resourceId: 'gst-1',
      );
      service.log(
        'user-1',
        'Alice',
        'ITR_REVISED',
        resourceType: 'ITR',
        resourceId: 'itr-1',
      );

      final logs = service.getLogsForResource('ITR', 'itr-1');
      expect(logs, hasLength(2));
      expect(logs.every((l) => l.resourceType == 'ITR'), isTrue);
    });

    test('returns empty list when no logs match', () {
      final logs = service.getLogsForResource('ITR', 'nonexistent');
      expect(logs, isEmpty);
    });
  });

  group('AuditTrailService.getLogsForUser', () {
    test('returns only logs for the specified user', () {
      service.log('user-1', 'Alice', 'ACTION_A');
      service.log('user-2', 'Bob', 'ACTION_B');
      service.log('user-1', 'Alice', 'ACTION_C');

      final logs = service.getLogsForUser('user-1');
      expect(logs, hasLength(2));
      expect(logs.every((l) => l.userId == 'user-1'), isTrue);
    });

    test('filters by date range when from and to are provided', () {
      final base = DateTime(2025, 6, 1);
      service.log(
        'user-1',
        'Alice',
        'BEFORE',
        overrideTimestamp: base.subtract(const Duration(days: 2)),
      );
      service.log(
        'user-1',
        'Alice',
        'WITHIN',
        overrideTimestamp: base.add(const Duration(days: 1)),
      );
      service.log(
        'user-1',
        'Alice',
        'AFTER',
        overrideTimestamp: base.add(const Duration(days: 10)),
      );

      final logs = service.getLogsForUser(
        'user-1',
        from: base,
        to: base.add(const Duration(days: 5)),
      );
      expect(logs, hasLength(1));
      expect(logs.first.action, 'WITHIN');
    });
  });

  group('AuditTrailService.filterBySeverity', () {
    test('returns logs at or above the minimum severity', () {
      final logs = [
        AuditLogEntry(
          logId: '1',
          userId: 'u1',
          userName: 'U',
          action: 'A',
          timestamp: DateTime.now(),
          severity: LogSeverity.info,
          metadata: const {},
        ),
        AuditLogEntry(
          logId: '2',
          userId: 'u1',
          userName: 'U',
          action: 'B',
          timestamp: DateTime.now(),
          severity: LogSeverity.warning,
          metadata: const {},
        ),
        AuditLogEntry(
          logId: '3',
          userId: 'u1',
          userName: 'U',
          action: 'C',
          timestamp: DateTime.now(),
          severity: LogSeverity.critical,
          metadata: const {},
        ),
      ];

      final result = service.filterBySeverity(logs, LogSeverity.warning);
      expect(result, hasLength(2));
      expect(result.every((l) => l.severity != LogSeverity.info), isTrue);
    });

    test('returns all logs when minSeverity is info', () {
      final logs = [
        AuditLogEntry(
          logId: '1',
          userId: 'u1',
          userName: 'U',
          action: 'A',
          timestamp: DateTime.now(),
          severity: LogSeverity.info,
          metadata: const {},
        ),
        AuditLogEntry(
          logId: '2',
          userId: 'u1',
          userName: 'U',
          action: 'B',
          timestamp: DateTime.now(),
          severity: LogSeverity.critical,
          metadata: const {},
        ),
      ];

      final result = service.filterBySeverity(logs, LogSeverity.info);
      expect(result, hasLength(2));
    });
  });

  group('AuditLogEntry immutability', () {
    test('copyWith creates new instance with updated fields', () {
      final entry = AuditLogEntry(
        logId: 'log-1',
        userId: 'user-1',
        userName: 'Alice',
        action: 'LOGIN',
        timestamp: DateTime(2025, 1, 1),
        severity: LogSeverity.info,
        metadata: const {},
      );

      final updated = entry.copyWith(action: 'LOGOUT');
      expect(updated.action, 'LOGOUT');
      expect(updated.userId, 'user-1');
      expect(identical(entry, updated), isFalse);
    });

    test('operator == based on logId', () {
      final t = DateTime(2025, 1, 1);
      final a = AuditLogEntry(
        logId: 'log-1',
        userId: 'u1',
        userName: 'U',
        action: 'A',
        timestamp: t,
        severity: LogSeverity.info,
        metadata: const {},
      );
      final b = AuditLogEntry(
        logId: 'log-1',
        userId: 'u2',
        userName: 'V',
        action: 'B',
        timestamp: t,
        severity: LogSeverity.warning,
        metadata: const {},
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
