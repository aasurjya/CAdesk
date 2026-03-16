import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/rpa/data/mappers/rpa_mapper.dart';
import 'package:ca_app/features/rpa/domain/models/rpa_task.dart';

void main() {
  group('RpaMapper', () {
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'rpa-001',
          'task_type': 'gstLogin',
          'client_id': 'client-001',
          'status': 'completed',
          'scheduled_at': '2025-09-01T06:00:00.000Z',
          'started_at': '2025-09-01T06:00:05.000Z',
          'completed_at': '2025-09-01T06:02:30.000Z',
          'result': 'Login successful, session token retrieved',
          'error_message': null,
          'retry_count': 0,
        };

        final task = RpaMapper.fromJson(json);

        expect(task.id, 'rpa-001');
        expect(task.taskType, RpaTaskType.gstLogin);
        expect(task.clientId, 'client-001');
        expect(task.status, RpaStatus.completed);
        expect(task.scheduledAt.year, 2025);
        expect(task.startedAt, isNotNull);
        expect(task.completedAt, isNotNull);
        expect(task.result, 'Login successful, session token retrieved');
        expect(task.errorMessage, isNull);
        expect(task.retryCount, 0);
      });

      test(
        'handles null clientId, result, error_message, startedAt, completedAt',
        () {
          final json = {
            'id': 'rpa-002',
            'task_type': 'portalStatusCheck',
            'status': 'scheduled',
            'scheduled_at': '2025-09-02T08:00:00.000Z',
            'retry_count': 0,
          };

          final task = RpaMapper.fromJson(json);
          expect(task.clientId, isNull);
          expect(task.result, isNull);
          expect(task.errorMessage, isNull);
          expect(task.startedAt, isNull);
          expect(task.completedAt, isNull);
          expect(task.status, RpaStatus.scheduled);
        },
      );

      test('handles failed task with error message and retries', () {
        final json = {
          'id': 'rpa-003',
          'task_type': 'tdsDownload',
          'client_id': 'client-003',
          'status': 'failed',
          'scheduled_at': '2025-09-01T07:00:00.000Z',
          'started_at': '2025-09-01T07:00:01.000Z',
          'error_message': 'TRACES portal timeout after 30s',
          'retry_count': 3,
        };

        final task = RpaMapper.fromJson(json);
        expect(task.status, RpaStatus.failed);
        expect(task.errorMessage, 'TRACES portal timeout after 30s');
        expect(task.retryCount, 3);
        expect(task.result, isNull);
      });

      test('defaults task_type to portalStatusCheck for unknown value', () {
        final json = {
          'id': 'rpa-004',
          'task_type': 'unknownTask',
          'status': 'scheduled',
          'scheduled_at': '2025-09-01T06:00:00.000Z',
          'retry_count': 0,
        };

        final task = RpaMapper.fromJson(json);
        expect(task.taskType, RpaTaskType.portalStatusCheck);
      });

      test('handles all RpaTaskType values', () {
        for (final taskType in RpaTaskType.values) {
          final json = {
            'id': 'rpa-type-${taskType.name}',
            'task_type': taskType.name,
            'status': 'scheduled',
            'scheduled_at': '2025-09-01T00:00:00.000Z',
            'retry_count': 0,
          };
          final task = RpaMapper.fromJson(json);
          expect(task.taskType, taskType);
        }
      });

      test('handles all RpaStatus values', () {
        for (final status in RpaStatus.values) {
          final json = {
            'id': 'rpa-status-${status.name}',
            'task_type': 'gstLogin',
            'status': status.name,
            'scheduled_at': '2025-09-01T00:00:00.000Z',
            'retry_count': 0,
          };
          final task = RpaMapper.fromJson(json);
          expect(task.status, status);
        }
      });
    });

    group('toJson', () {
      test('includes all fields and round-trips correctly', () {
        final task = RpaTask(
          id: 'rpa-json-001',
          taskType: RpaTaskType.itrSubmit,
          clientId: 'client-json-001',
          status: RpaStatus.running,
          scheduledAt: DateTime.utc(2025, 9, 10, 6, 0),
          startedAt: DateTime.utc(2025, 9, 10, 6, 0, 5),
          completedAt: null,
          result: null,
          errorMessage: null,
          retryCount: 1,
        );

        final json = RpaMapper.toJson(task);

        expect(json['id'], 'rpa-json-001');
        expect(json['task_type'], 'itrSubmit');
        expect(json['client_id'], 'client-json-001');
        expect(json['status'], 'running');
        expect(json['started_at'], isNotNull);
        expect(json['completed_at'], isNull);
        expect(json['retry_count'], 1);

        final restored = RpaMapper.fromJson(json);
        expect(restored.id, task.id);
        expect(restored.taskType, task.taskType);
        expect(restored.status, task.status);
        expect(restored.retryCount, task.retryCount);
      });

      test('serializes null optional fields as null', () {
        final task = RpaTask(
          id: 'rpa-null',
          taskType: RpaTaskType.mcaFiling,
          status: RpaStatus.cancelled,
          scheduledAt: DateTime.utc(2025, 9, 1),
          retryCount: 0,
        );

        final json = RpaMapper.toJson(task);
        expect(json['client_id'], isNull);
        expect(json['started_at'], isNull);
        expect(json['result'], isNull);
        expect(json['error_message'], isNull);
      });
    });
  });
}
