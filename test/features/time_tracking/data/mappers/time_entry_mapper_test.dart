import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/time_tracking/data/mappers/time_entry_mapper.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';

void main() {
  group('TimeEntryMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'te-001',
          'staff_id': 'staff-001',
          'staff_name': 'Amit Shah',
          'client_id': 'client-001',
          'client_name': 'Rajesh Kumar',
          'task_description': 'ITR preparation and filing',
          'start_time': '2026-03-10T10:00:00.000Z',
          'end_time': '2026-03-10T12:30:00.000Z',
          'duration_minutes': 150,
          'is_billable': true,
          'hourly_rate': 1500.0,
          'billed_amount': 3750.0,
          'status': 'completed',
        };

        final entry = TimeEntryMapper.fromJson(json);

        expect(entry.id, 'te-001');
        expect(entry.staffId, 'staff-001');
        expect(entry.staffName, 'Amit Shah');
        expect(entry.clientId, 'client-001');
        expect(entry.clientName, 'Rajesh Kumar');
        expect(entry.taskDescription, 'ITR preparation and filing');
        expect(entry.durationMinutes, 150);
        expect(entry.isBillable, isTrue);
        expect(entry.hourlyRate, 1500.0);
        expect(entry.billedAmount, 3750.0);
        expect(entry.status, TimeEntryStatus.completed);
        expect(entry.endTime, isNotNull);
      });

      test('handles null end_time for running entry', () {
        final json = {
          'id': 'te-002',
          'staff_id': 'staff-001',
          'staff_name': 'Amit Shah',
          'client_id': 'client-002',
          'client_name': 'Mehta & Sons',
          'task_description': 'GST reconciliation',
          'start_time': '2026-03-15T09:00:00.000Z',
          'end_time': null,
          'duration_minutes': 0,
          'is_billable': true,
          'hourly_rate': 1500.0,
          'billed_amount': 0.0,
          'status': 'running',
        };

        final entry = TimeEntryMapper.fromJson(json);
        expect(entry.endTime, isNull);
        expect(entry.status, TimeEntryStatus.running);
        expect(entry.billedAmount, 0.0);
      });

      test('handles null staff_id and staff_name with defaults', () {
        final json = {
          'id': 'te-003',
          'client_id': 'client-003',
          'task_description': 'Audit work',
          'start_time': '2026-03-15T14:00:00.000Z',
          'status': 'completed',
        };

        final entry = TimeEntryMapper.fromJson(json);
        expect(entry.staffId, '');
        expect(entry.staffName, '');
        expect(entry.clientName, '');
        expect(entry.durationMinutes, 0);
        expect(entry.isBillable, isTrue); // defaults to true
        expect(entry.hourlyRate, 0.0);
        expect(entry.billedAmount, 0.0);
      });

      test('defaults status to completed for unknown value', () {
        final json = {
          'id': 'te-004',
          'staff_id': 'staff-001',
          'staff_name': 'Test',
          'client_id': 'c1',
          'client_name': 'Test',
          'task_description': 'Test task',
          'start_time': '2026-03-15T09:00:00.000Z',
          'duration_minutes': 60,
          'is_billable': false,
          'hourly_rate': 0.0,
          'billed_amount': 0.0,
          'status': 'unknownStatus',
        };

        final entry = TimeEntryMapper.fromJson(json);
        expect(entry.status, TimeEntryStatus.completed);
      });

      test('handles all TimeEntryStatus values', () {
        for (final status in TimeEntryStatus.values) {
          final json = {
            'id': 'te-status-${status.name}',
            'staff_id': 's1',
            'staff_name': 'Test',
            'client_id': 'c1',
            'client_name': 'Test',
            'task_description': 'Test',
            'start_time': '2026-03-15T09:00:00.000Z',
            'duration_minutes': 60,
            'is_billable': true,
            'hourly_rate': 1000.0,
            'billed_amount': 0.0,
            'status': status.name,
          };
          final entry = TimeEntryMapper.fromJson(json);
          expect(entry.status, status);
        }
      });

      test('defaults is_billable to true when absent', () {
        final json = {
          'id': 'te-005',
          'client_id': 'c1',
          'task_description': 'Pro-bono work',
          'start_time': '2026-03-15T09:00:00.000Z',
          'duration_minutes': 30,
          'status': 'completed',
        };

        final entry = TimeEntryMapper.fromJson(json);
        expect(entry.isBillable, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late TimeEntry sampleEntry;

      setUp(() {
        sampleEntry = TimeEntry(
          id: 'te-json-001',
          staffId: 'staff-json-001',
          staffName: 'Priya Nair',
          clientId: 'client-json-001',
          clientName: 'Sharma Industries',
          taskDescription: 'TDS return preparation',
          startTime: DateTime(2026, 3, 10, 9, 0),
          endTime: DateTime(2026, 3, 10, 11, 0),
          durationMinutes: 120,
          isBillable: true,
          hourlyRate: 2000.0,
          billedAmount: 4000.0,
          status: TimeEntryStatus.billed,
        );
      });

      test('includes all fields', () {
        final json = TimeEntryMapper.toJson(sampleEntry);

        expect(json['id'], 'te-json-001');
        expect(json['staff_id'], 'staff-json-001');
        expect(json['staff_name'], 'Priya Nair');
        expect(json['client_id'], 'client-json-001');
        expect(json['client_name'], 'Sharma Industries');
        expect(json['task_description'], 'TDS return preparation');
        expect(json['duration_minutes'], 120);
        expect(json['is_billable'], isTrue);
        expect(json['hourly_rate'], 2000.0);
        expect(json['billed_amount'], 4000.0);
        expect(json['status'], 'billed');
      });

      test('serializes start_time and end_time as ISO strings', () {
        final json = TimeEntryMapper.toJson(sampleEntry);
        expect(json['start_time'], startsWith('2026-03-10'));
        expect(json['end_time'], startsWith('2026-03-10'));
      });

      test('serializes null end_time as null', () {
        // Create directly as copyWith can't clear endTime
        final entry = TimeEntry(
          id: 'te-running',
          staffId: 'staff-001',
          staffName: 'Test',
          clientId: 'c1',
          clientName: 'Test',
          taskDescription: 'Task',
          startTime: DateTime(2026, 3, 15, 9, 0),
          durationMinutes: 0,
          isBillable: true,
          hourlyRate: 1000.0,
          billedAmount: 0.0,
          status: TimeEntryStatus.running,
        );
        final json = TimeEntryMapper.toJson(entry);
        expect(json['end_time'], isNull);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = TimeEntryMapper.toJson(sampleEntry);
        final restored = TimeEntryMapper.fromJson(json);

        expect(restored.id, sampleEntry.id);
        expect(restored.staffId, sampleEntry.staffId);
        expect(restored.staffName, sampleEntry.staffName);
        expect(restored.clientId, sampleEntry.clientId);
        expect(restored.taskDescription, sampleEntry.taskDescription);
        expect(restored.durationMinutes, sampleEntry.durationMinutes);
        expect(restored.isBillable, sampleEntry.isBillable);
        expect(restored.hourlyRate, sampleEntry.hourlyRate);
        expect(restored.status, sampleEntry.status);
      });

      test('formattedDuration returns hours and minutes correctly', () {
        final entry = sampleEntry.copyWith(durationMinutes: 125);
        expect(entry.formattedDuration, '2h 5m');
      });

      test('formattedDuration returns only minutes when under 1 hour', () {
        final entry = sampleEntry.copyWith(durationMinutes: 45);
        expect(entry.formattedDuration, '45m');
      });

      test('staffInitials returns correct initials', () {
        expect(sampleEntry.staffInitials, 'PN');
      });
    });
  });
}
