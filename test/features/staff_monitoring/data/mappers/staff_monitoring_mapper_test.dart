import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/staff_monitoring/data/mappers/staff_monitoring_mapper.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_activity.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_performance.dart';

void main() {
  group('StaffMonitoringMapper', () {
    // -------------------------------------------------------------------------
    // StaffActivity
    // -------------------------------------------------------------------------
    group('activityFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'act-001',
          'staff_id': 'staff-001',
          'activity_type': 'filing',
          'client_id': 'client-001',
          'task_id': 'task-001',
          'start_time': '2025-09-01T09:00:00.000Z',
          'end_time': '2025-09-01T10:30:00.000Z',
          'duration_minutes': 90,
          'notes': 'Filed ITR-1 for client',
        };

        final activity = StaffMonitoringMapper.activityFromJson(json);

        expect(activity.id, 'act-001');
        expect(activity.staffId, 'staff-001');
        expect(activity.activityType, ActivityType.filing);
        expect(activity.clientId, 'client-001');
        expect(activity.taskId, 'task-001');
        expect(activity.startTime.year, 2025);
        expect(activity.endTime, isNotNull);
        expect(activity.durationMinutes, 90);
        expect(activity.notes, 'Filed ITR-1 for client');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'act-002',
          'staff_id': 'staff-002',
          'activity_type': 'clientCall',
          'start_time': '2025-09-01T11:00:00.000Z',
        };

        final activity = StaffMonitoringMapper.activityFromJson(json);
        expect(activity.clientId, isNull);
        expect(activity.taskId, isNull);
        expect(activity.endTime, isNull);
        expect(activity.durationMinutes, 0);
        expect(activity.notes, isNull);
        expect(activity.activityType, ActivityType.clientCall);
      });

      test('defaults activity_type to other for unknown value', () {
        final json = {
          'id': 'act-003',
          'staff_id': 'staff-003',
          'activity_type': 'unknownActivity',
          'start_time': '2025-09-01T09:00:00.000Z',
        };

        final activity = StaffMonitoringMapper.activityFromJson(json);
        expect(activity.activityType, ActivityType.other);
      });

      test('handles all ActivityType values', () {
        for (final type in ActivityType.values) {
          final json = {
            'id': 'act-type-${type.name}',
            'staff_id': 'staff-001',
            'activity_type': type.name,
            'start_time': '2025-09-01T09:00:00.000Z',
          };
          final activity = StaffMonitoringMapper.activityFromJson(json);
          expect(activity.activityType, type);
        }
      });
    });

    group('activityToJson', () {
      test('includes all fields and round-trips correctly', () {
        final activity = StaffActivity(
          id: 'act-json-001',
          staffId: 'staff-json-001',
          activityType: ActivityType.documentReview,
          clientId: 'client-json-001',
          taskId: 'task-json-001',
          startTime: DateTime.utc(2025, 9, 5, 14),
          endTime: DateTime.utc(2025, 9, 5, 15, 30),
          durationMinutes: 90,
          notes: 'Reviewed audit documents',
        );

        final json = StaffMonitoringMapper.activityToJson(activity);

        expect(json['id'], 'act-json-001');
        expect(json['staff_id'], 'staff-json-001');
        expect(json['activity_type'], 'documentReview');
        expect(json['client_id'], 'client-json-001');
        expect(json['duration_minutes'], 90);
        expect(json['notes'], 'Reviewed audit documents');
        expect(json['end_time'], isNotNull);

        final restored = StaffMonitoringMapper.activityFromJson(json);
        expect(restored.id, activity.id);
        expect(restored.activityType, activity.activityType);
        expect(restored.durationMinutes, activity.durationMinutes);
      });
    });

    // -------------------------------------------------------------------------
    // StaffPerformance
    // -------------------------------------------------------------------------
    group('performanceFromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'perf-001',
          'staff_id': 'staff-001',
          'period': 'Sep 2025',
          'tasks_completed': 25,
          'hours_logged': 160.5,
          'clients_handled': 18,
          'avg_completion_time': 6.4,
          'created_at': '2025-09-30T00:00:00.000Z',
        };

        final perf = StaffMonitoringMapper.performanceFromJson(json);

        expect(perf.id, 'perf-001');
        expect(perf.staffId, 'staff-001');
        expect(perf.period, 'Sep 2025');
        expect(perf.tasksCompleted, 25);
        expect(perf.hoursLogged, 160.5);
        expect(perf.clientsHandled, 18);
        expect(perf.avgCompletionTime, 6.4);
        expect(perf.createdAt.year, 2025);
      });

      test('defaults numeric fields to 0 when missing', () {
        final json = {
          'id': 'perf-002',
          'staff_id': 'staff-002',
          'period': 'Oct 2025',
          'created_at': '2025-10-31T00:00:00.000Z',
        };

        final perf = StaffMonitoringMapper.performanceFromJson(json);
        expect(perf.tasksCompleted, 0);
        expect(perf.hoursLogged, 0.0);
        expect(perf.clientsHandled, 0);
        expect(perf.avgCompletionTime, 0.0);
      });

      test('handles integer numeric values', () {
        final json = {
          'id': 'perf-003',
          'staff_id': 'staff-003',
          'period': 'Aug 2025',
          'tasks_completed': 20,
          'hours_logged': 145,
          'clients_handled': 12,
          'avg_completion_time': 7,
          'created_at': '2025-08-31T00:00:00.000Z',
        };

        final perf = StaffMonitoringMapper.performanceFromJson(json);
        expect(perf.hoursLogged, 145.0);
        expect(perf.hoursLogged, isA<double>());
        expect(perf.avgCompletionTime, 7.0);
      });
    });

    group('performanceToJson', () {
      test('includes all fields and round-trips correctly', () {
        final perf = StaffPerformance(
          id: 'perf-json-001',
          staffId: 'staff-json-001',
          period: 'Q2 FY 2025-26',
          tasksCompleted: 75,
          hoursLogged: 480.0,
          clientsHandled: 35,
          avgCompletionTime: 6.4,
          createdAt: DateTime.utc(2025, 9, 30),
        );

        final json = StaffMonitoringMapper.performanceToJson(perf);

        expect(json['id'], 'perf-json-001');
        expect(json['staff_id'], 'staff-json-001');
        expect(json['period'], 'Q2 FY 2025-26');
        expect(json['tasks_completed'], 75);
        expect(json['hours_logged'], 480.0);
        expect(json['clients_handled'], 35);
        expect(json['avg_completion_time'], 6.4);

        final restored = StaffMonitoringMapper.performanceFromJson(json);
        expect(restored.id, perf.id);
        expect(restored.tasksCompleted, perf.tasksCompleted);
        expect(restored.hoursLogged, perf.hoursLogged);
        expect(restored.avgCompletionTime, perf.avgCompletionTime);
      });
    });
  });
}
