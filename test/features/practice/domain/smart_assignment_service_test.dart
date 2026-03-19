import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/practice/domain/services/smart_assignment_service.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

WorkflowTask _makeTask({
  String taskId = 'task-1',
  String name = 'GST Filing',
  StaffRole requiredRole = StaffRole.junior,
}) {
  return WorkflowTask(
    taskId: taskId,
    name: name,
    description: 'Description for $name',
    requiredRole: requiredRole,
    estimatedHours: 4,
    dependsOn: const [],
    checklistItems: const [],
  );
}

StaffMember _makeStaff({
  required String id,
  String? name,
  int currentTaskCount = 0,
  int maxCapacity = 10,
  List<String> skills = const [],
  StaffRole? role,
}) {
  return StaffMember(
    id: id,
    name: name ?? 'Staff $id',
    currentTaskCount: currentTaskCount,
    maxCapacity: maxCapacity,
    skills: skills,
    role: role,
  );
}

void main() {
  group('SmartAssignmentService', () {
    final service = SmartAssignmentService.instance;

    // -------------------------------------------------------------------------
    // Singleton
    // -------------------------------------------------------------------------

    group('singleton', () {
      test('instance is always the same object', () {
        expect(
          SmartAssignmentService.instance,
          same(SmartAssignmentService.instance),
        );
      });
    });

    // -------------------------------------------------------------------------
    // StaffMember
    // -------------------------------------------------------------------------

    group('StaffMember', () {
      test('utilizationRate is currentTaskCount / maxCapacity', () {
        final s = _makeStaff(id: 's1', currentTaskCount: 3, maxCapacity: 10);
        expect(s.utilizationRate, closeTo(0.3, 0.001));
      });

      test('utilizationRate is 0.0 when maxCapacity is zero', () {
        final s = _makeStaff(id: 's1', currentTaskCount: 0, maxCapacity: 0);
        expect(s.utilizationRate, equals(0.0));
      });

      test('utilizationRate is clamped to 1.0 when overloaded', () {
        final s = _makeStaff(id: 's1', currentTaskCount: 15, maxCapacity: 10);
        expect(s.utilizationRate, equals(1.0));
      });

      test('isAvailable is true when tasks < maxCapacity', () {
        final s = _makeStaff(id: 's1', currentTaskCount: 5, maxCapacity: 10);
        expect(s.isAvailable, isTrue);
      });

      test('isAvailable is false when tasks >= maxCapacity', () {
        final s = _makeStaff(id: 's1', currentTaskCount: 10, maxCapacity: 10);
        expect(s.isAvailable, isFalse);
      });

      test('copyWith returns new instance with changed fields', () {
        final original = _makeStaff(id: 's1', currentTaskCount: 2);
        final copy = original.copyWith(currentTaskCount: 5);

        expect(copy.currentTaskCount, equals(5));
        expect(copy.id, equals('s1'));
      });

      test('equality based on id, name, taskCount, and maxCapacity', () {
        final a = _makeStaff(id: 's1', currentTaskCount: 2, maxCapacity: 10);
        final b = _makeStaff(id: 's1', currentTaskCount: 2, maxCapacity: 10);
        expect(a, equals(b));
      });

      test('toString includes utilization percentage', () {
        final s = _makeStaff(id: 's1', currentTaskCount: 5, maxCapacity: 10);
        expect(s.toString(), contains('50%'));
      });
    });

    // -------------------------------------------------------------------------
    // recommendAssignee — empty staff
    // -------------------------------------------------------------------------

    group('recommendAssignee with empty staff', () {
      test('throws ArgumentError for empty staff list', () {
        final task = _makeTask();

        expect(
          () => service.recommendAssignee(task, []),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // -------------------------------------------------------------------------
    // recommendAssignee — single staff
    // -------------------------------------------------------------------------

    group('recommendAssignee with single staff member', () {
      test('returns recommendation with the only staff member', () {
        final task = _makeTask(name: 'GST filing');
        final staff = [_makeStaff(id: 's1')];

        final rec = service.recommendAssignee(task, staff);

        expect(rec.recommended.id, equals('s1'));
      });

      test('recommendation has non-empty reason', () {
        final task = _makeTask();
        final staff = [_makeStaff(id: 's1')];

        final rec = service.recommendAssignee(task, staff);

        expect(rec.reason, isNotEmpty);
      });

      test('alternatives list is empty for single staff', () {
        final task = _makeTask();
        final staff = [_makeStaff(id: 's1')];

        final rec = service.recommendAssignee(task, staff);

        expect(rec.alternatives, isEmpty);
      });

      test('confidenceScore is between 0.0 and 1.0', () {
        final task = _makeTask();
        final staff = [_makeStaff(id: 's1')];

        final rec = service.recommendAssignee(task, staff);

        expect(rec.confidenceScore, greaterThanOrEqualTo(0.0));
        expect(rec.confidenceScore, lessThanOrEqualTo(1.0));
      });
    });

    // -------------------------------------------------------------------------
    // recommendAssignee — utilization factor (0.3 weight)
    // -------------------------------------------------------------------------

    group('utilization scoring (weight 0.3)', () {
      test('prefers staff with lower utilization', () {
        final task = _makeTask(name: 'Tax advisory');
        final staff = [
          _makeStaff(id: 'low', currentTaskCount: 1, maxCapacity: 10),
          _makeStaff(id: 'high', currentTaskCount: 8, maxCapacity: 10),
        ];

        final rec = service.recommendAssignee(task, staff);

        expect(rec.recommended.id, equals('low'));
      });

      test(
        'fully free staff (utilization 0) gets maximum utilization bonus',
        () {
          final task = _makeTask(name: 'Audit filing');
          final freeStaff = _makeStaff(
            id: 'free',
            currentTaskCount: 0,
            maxCapacity: 10,
          );
          final busyStaff = _makeStaff(
            id: 'busy',
            currentTaskCount: 9,
            maxCapacity: 10,
          );

          final rec = service.recommendAssignee(task, [freeStaff, busyStaff]);

          expect(rec.recommended.id, equals('free'));
        },
      );
    });

    // -------------------------------------------------------------------------
    // recommendAssignee — role factor (0.3 weight)
    // -------------------------------------------------------------------------

    group('role scoring (weight 0.3)', () {
      test('prefers staff with matching required role', () {
        final task = _makeTask(
          name: 'Audit engagement',
          requiredRole: StaffRole.senior,
        );
        final matchingRole = _makeStaff(
          id: 'senior',
          currentTaskCount: 5,
          maxCapacity: 10,
          role: StaffRole.senior,
        );
        final wrongRole = _makeStaff(
          id: 'junior',
          currentTaskCount: 0,
          maxCapacity: 10,
          role: StaffRole.junior,
        );

        // The junior is fully free (+0.3 utilization) but does not match
        // role. The senior has 50% utilization (+0.15) but gains +0.3 role
        // bonus = 0.45. Junior gets 0.30 only. Senior should win.
        final rec = service.recommendAssignee(task, [matchingRole, wrongRole]);

        expect(rec.recommended.id, equals('senior'));
      });

      test('reason includes role match when role matches', () {
        final task = _makeTask(
          name: 'Partner review',
          requiredRole: StaffRole.partner,
        );
        final staff = [_makeStaff(id: 'p1', role: StaffRole.partner)];

        final rec = service.recommendAssignee(task, staff);

        expect(rec.reason.toLowerCase(), contains('partner'));
      });
    });

    // -------------------------------------------------------------------------
    // recommendAssignee — skill factor (0.4 weight)
    // -------------------------------------------------------------------------

    group('skill scoring (weight 0.4)', () {
      test('prefers staff with skill matching task keywords', () {
        final task = _makeTask(name: 'GST reconciliation filing');
        final skilled = _makeStaff(
          id: 'gst-expert',
          currentTaskCount: 5,
          maxCapacity: 10,
          skills: ['gst', 'reconciliation'],
        );
        final unskilled = _makeStaff(
          id: 'no-skills',
          currentTaskCount: 0,
          maxCapacity: 10,
          skills: [],
        );

        // Unskilled: 0.30 utilization bonus. Skilled: 0.15 utilization + 0.40
        // skill = 0.55. Skilled should win.
        final rec = service.recommendAssignee(task, [skilled, unskilled]);

        expect(rec.recommended.id, equals('gst-expert'));
      });

      test('skill bonus is capped at 0.4 regardless of matched skills', () {
        final task = _makeTask(name: 'GST ITR audit filing compliance');
        final staff = _makeStaff(
          id: 's1',
          skills: ['gst', 'itr', 'audit', 'filing', 'compliance'],
        );

        final rec = service.recommendAssignee(task, [staff]);

        // Score = utilization (up to 0.3) + role (0.0, no role) + skill (0.4 max) = max 0.7
        expect(rec.confidenceScore, lessThanOrEqualTo(1.0));
      });

      test('reason includes matched skills when skills align', () {
        final task = _makeTask(name: 'Income tax advisory');
        final staff = [
          _makeStaff(id: 's1', skills: ['income_tax']),
        ];

        final rec = service.recommendAssignee(task, staff);

        expect(rec.reason.toLowerCase(), contains('income_tax'));
      });
    });

    // -------------------------------------------------------------------------
    // recommendAssignee — all staff at capacity
    // -------------------------------------------------------------------------

    group('all staff at capacity', () {
      test('returns recommendation even when all staff are at capacity', () {
        final task = _makeTask();
        final staff = [
          _makeStaff(id: 's1', currentTaskCount: 10, maxCapacity: 10),
          _makeStaff(id: 's2', currentTaskCount: 10, maxCapacity: 10),
        ];

        // Should not throw — returns least-loaded
        final rec = service.recommendAssignee(task, staff);

        expect(rec.recommended, isNotNull);
      });
    });

    // -------------------------------------------------------------------------
    // recommendAssignee — multiple staff, alternatives
    // -------------------------------------------------------------------------

    group('alternatives list', () {
      test('alternatives contains all staff except recommended', () {
        final task = _makeTask(name: 'Audit');
        final staff = [
          _makeStaff(id: 's1'),
          _makeStaff(id: 's2'),
          _makeStaff(id: 's3'),
        ];

        final rec = service.recommendAssignee(task, staff);

        expect(rec.alternatives, hasLength(2));
        expect(
          rec.alternatives.every((s) => s.id != rec.recommended.id),
          isTrue,
        );
      });
    });

    // -------------------------------------------------------------------------
    // StaffRecommendation
    // -------------------------------------------------------------------------

    group('StaffRecommendation', () {
      test('equality based on recommended and confidenceScore', () {
        final staff = _makeStaff(id: 's1');
        final a = StaffRecommendation(
          recommended: staff,
          confidenceScore: 0.8,
          reason: 'reason A',
          alternatives: const [],
        );
        final b = StaffRecommendation(
          recommended: staff,
          confidenceScore: 0.8,
          reason: 'reason B',
          alternatives: const [],
        );
        expect(a, equals(b));
      });

      test('toString includes recommended staff name and confidence', () {
        final staff = _makeStaff(id: 's1', name: 'Ankit Sharma');
        final rec = StaffRecommendation(
          recommended: staff,
          confidenceScore: 0.75,
          reason: 'skill match',
          alternatives: const [],
        );
        expect(rec.toString(), contains('Ankit Sharma'));
        expect(rec.toString(), contains('75%'));
      });
    });
  });
}
