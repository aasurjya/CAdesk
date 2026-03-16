import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tasks/data/mappers/task_mapper.dart';
import 'package:ca_app/features/tasks/domain/models/task.dart';
import 'package:ca_app/features/tasks/domain/models/task_priority.dart';
import 'package:ca_app/features/tasks/domain/models/task_status.dart';

void main() {
  group('TaskMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all required fields correctly', () {
        final json = {
          'id': 'task-001',
          'title': 'File ITR-1 for Rajesh Kumar',
          'description': 'Annual income tax return filing',
          'client_id': 'cli-001',
          'client_name': 'Rajesh Kumar',
          'task_type': 'itrFiling',
          'priority': 'high',
          'status': 'inProgress',
          'assigned_to': 'Priya Sharma',
          'assigned_by': 'CA Mehta',
          'due_date': '2026-07-31T00:00:00.000',
          'created_at': '2026-03-01T09:00:00.000',
          'tags': ['ITR', 'FY2025-26'],
        };
        final task = TaskMapper.fromJson(json);

        expect(task.id, 'task-001');
        expect(task.title, 'File ITR-1 for Rajesh Kumar');
        expect(task.description, 'Annual income tax return filing');
        expect(task.clientId, 'cli-001');
        expect(task.clientName, 'Rajesh Kumar');
        expect(task.taskType, TaskType.itrFiling);
        expect(task.priority, TaskPriority.high);
        expect(task.status, TaskStatus.inProgress);
        expect(task.assignedTo, 'Priya Sharma');
        expect(task.assignedBy, 'CA Mehta');
        expect(task.dueDate, DateTime.parse('2026-07-31T00:00:00.000'));
        expect(task.createdAt, DateTime.parse('2026-03-01T09:00:00.000'));
        expect(task.tags, ['ITR', 'FY2025-26']);
      });

      test('defaults description to empty string when missing', () {
        final json = {
          'id': 'task-002',
          'title': 'GST Filing',
          'client_id': 'cli-002',
          'client_name': 'Mehta & Sons',
          'due_date': '2026-03-20T00:00:00.000',
          'created_at': '2026-03-01T00:00:00.000',
        };
        final task = TaskMapper.fromJson(json);
        expect(task.description, '');
      });

      test('defaults task_type to other for unknown value', () {
        final json = {
          'id': 'task-003',
          'title': 'Misc Task',
          'client_id': 'cli-003',
          'client_name': 'Test Client',
          'task_type': 'unknownType',
          'due_date': '2026-03-20T00:00:00.000',
          'created_at': '2026-03-01T00:00:00.000',
        };
        final task = TaskMapper.fromJson(json);
        expect(task.taskType, TaskType.other);
      });

      test('defaults priority to medium for unknown value', () {
        final json = {
          'id': 'task-004',
          'title': 'Test',
          'client_id': 'cli-004',
          'client_name': 'Test Client',
          'priority': 'invalidPriority',
          'due_date': '2026-03-20T00:00:00.000',
          'created_at': '2026-03-01T00:00:00.000',
        };
        final task = TaskMapper.fromJson(json);
        expect(task.priority, TaskPriority.medium);
      });

      test('defaults status to todo for unknown value', () {
        final json = {
          'id': 'task-005',
          'title': 'Test',
          'client_id': 'cli-005',
          'client_name': 'Test Client',
          'status': 'invalidStatus',
          'due_date': '2026-03-20T00:00:00.000',
          'created_at': '2026-03-01T00:00:00.000',
        };
        final task = TaskMapper.fromJson(json);
        expect(task.status, TaskStatus.todo);
      });

      test('maps null completed_at to null completedDate', () {
        final json = {
          'id': 'task-006',
          'title': 'Test',
          'client_id': 'cli-006',
          'client_name': 'Test Client',
          'completed_at': null,
          'due_date': '2026-03-20T00:00:00.000',
          'created_at': '2026-03-01T00:00:00.000',
        };
        final task = TaskMapper.fromJson(json);
        expect(task.completedDate, isNull);
      });

      test('maps completed_at to completedDate', () {
        final json = {
          'id': 'task-007',
          'title': 'Test',
          'client_id': 'cli-007',
          'client_name': 'Test Client',
          'completed_at': '2026-03-15T10:00:00.000',
          'due_date': '2026-03-20T00:00:00.000',
          'created_at': '2026-03-01T00:00:00.000',
        };
        final task = TaskMapper.fromJson(json);
        expect(task.completedDate, DateTime.parse('2026-03-15T10:00:00.000'));
      });

      test('returns empty tags when tags field is null', () {
        final json = {
          'id': 'task-008',
          'title': 'Test',
          'client_id': 'cli-008',
          'client_name': 'Test Client',
          'tags': null,
          'due_date': '2026-03-20T00:00:00.000',
          'created_at': '2026-03-01T00:00:00.000',
        };
        final task = TaskMapper.fromJson(json);
        expect(task.tags, isEmpty);
      });

      test('handles tags as JSON string', () {
        final json = {
          'id': 'task-009',
          'title': 'Test',
          'client_id': 'cli-009',
          'client_name': 'Test Client',
          'tags': '["urgent","gst"]',
          'due_date': '2026-03-20T00:00:00.000',
          'created_at': '2026-03-01T00:00:00.000',
        };
        final task = TaskMapper.fromJson(json);
        expect(task.tags, ['urgent', 'gst']);
      });

      test('handles all TaskType values', () {
        for (final type in TaskType.values) {
          final json = {
            'id': 'task-type-${type.name}',
            'title': 'Test',
            'client_id': 'cli',
            'client_name': 'Client',
            'task_type': type.name,
            'due_date': '2026-03-20T00:00:00.000',
            'created_at': '2026-03-01T00:00:00.000',
          };
          final task = TaskMapper.fromJson(json);
          expect(task.taskType, type);
        }
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late Task sampleTask;

      setUp(() {
        sampleTask = Task(
          id: 'task-json-001',
          title: 'File GSTR-3B',
          description: 'Monthly GST return',
          clientId: 'cli-001',
          clientName: 'ABC Pvt Ltd',
          taskType: TaskType.gstReturn,
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
          assignedTo: 'Priya Nair',
          assignedBy: 'CA Mehta',
          dueDate: DateTime(2026, 3, 20),
          createdAt: DateTime(2026, 3, 1),
          tags: const ['GST', 'monthly'],
        );
      });

      test('includes all required fields', () {
        final json = TaskMapper.toJson(sampleTask);
        expect(json['id'], 'task-json-001');
        expect(json['title'], 'File GSTR-3B');
        expect(json['description'], 'Monthly GST return');
        expect(json['client_id'], 'cli-001');
        expect(json['client_name'], 'ABC Pvt Ltd');
        expect(json['task_type'], 'gstReturn');
        expect(json['priority'], 'high');
        expect(json['status'], 'inProgress');
        expect(json['assigned_to'], 'Priya Nair');
        expect(json['assigned_by'], 'CA Mehta');
      });

      test('serializes tags as a list', () {
        final json = TaskMapper.toJson(sampleTask);
        expect(json['tags'], ['GST', 'monthly']);
      });

      test('serializes null completedDate as null', () {
        final json = TaskMapper.toJson(sampleTask);
        expect(json['completed_at'], isNull);
      });

      test('serializes non-null completedDate', () {
        final task = sampleTask.copyWith(
          completedDate: DateTime(2026, 3, 18, 14, 30),
        );
        final json = TaskMapper.toJson(task);
        expect(json['completed_at'], isNotNull);
        expect(json['completed_at'], contains('2026-03-18'));
      });

      test('round-trip: fromJson(toJson(task)) preserves core fields', () {
        final json = TaskMapper.toJson(sampleTask);
        // Add required created_at for fromJson
        json['created_at'] = sampleTask.createdAt.toIso8601String();
        final restored = TaskMapper.fromJson(json);

        expect(restored.id, sampleTask.id);
        expect(restored.title, sampleTask.title);
        expect(restored.taskType, sampleTask.taskType);
        expect(restored.priority, sampleTask.priority);
        expect(restored.status, sampleTask.status);
        expect(restored.tags, sampleTask.tags);
      });
    });
  });
}
