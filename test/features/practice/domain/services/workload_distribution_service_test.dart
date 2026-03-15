import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/staff_assignment.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';
import 'package:ca_app/features/practice/domain/models/workflow_template.dart';
import 'package:ca_app/features/practice/domain/services/workload_distribution_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = WorkloadDistributionService.instance;

  // Helpers
  Staff makeStaff({
    required String id,
    StaffRole role = StaffRole.senior,
    List<WorkflowCategory> skills = const [],
    List<String> currentEngagements = const [],
  }) {
    return Staff(
      staffId: id,
      name: 'Staff $id',
      role: role,
      skills: skills,
      currentEngagements: currentEngagements,
    );
  }

  Engagement makeEngagement({
    required String id,
    required List<StaffAssignment> assignments,
  }) {
    return Engagement(
      engagementId: id,
      clientId: 'C001',
      templateId: 'T001',
      templateTasks: const [],
      assignedStaff: assignments,
      status: EngagementStatus.inProgress,
      dueDate: DateTime(2026, 3, 31),
      completedDate: null,
      billingAmount: 500000,
    );
  }

  StaffAssignment makeAssignment({
    required String staffId,
    StaffRole role = StaffRole.senior,
    int hoursLogged = 0,
  }) {
    return StaffAssignment(
      staffId: staffId,
      role: role,
      tasks: const [],
      hoursLogged: hoursLogged,
      hoursEstimated: 10,
    );
  }

  WorkflowTask makeTask({
    required String id,
    StaffRole requiredRole = StaffRole.senior,
  }) {
    return WorkflowTask(
      taskId: id,
      name: 'Task $id',
      description: 'Description for task $id',
      requiredRole: requiredRole,
      estimatedHours: 4,
      dependsOn: const [],
      checklistItems: const [],
    );
  }

  group('WorkloadDistributionService.instance', () {
    test('singleton returns same instance', () {
      expect(
        identical(WorkloadDistributionService.instance, service),
        isTrue,
      );
    });
  });

  group('WorkloadDistributionService.computeStaffWorkload', () {
    test('all staff initialised to 0 when no engagements', () {
      final staff = [
        makeStaff(id: 'S1'),
        makeStaff(id: 'S2'),
      ];
      final workload = service.computeStaffWorkload([], staff);

      expect(workload['S1'], 0);
      expect(workload['S2'], 0);
    });

    test('accumulates hours from single engagement', () {
      final staff = [makeStaff(id: 'S1')];
      final engagements = [
        makeEngagement(
          id: 'E1',
          assignments: [makeAssignment(staffId: 'S1', hoursLogged: 8)],
        ),
      ];

      final workload = service.computeStaffWorkload(engagements, staff);
      expect(workload['S1'], 8);
    });

    test('accumulates hours across multiple engagements', () {
      final staff = [makeStaff(id: 'S1')];
      final engagements = [
        makeEngagement(
          id: 'E1',
          assignments: [makeAssignment(staffId: 'S1', hoursLogged: 5)],
        ),
        makeEngagement(
          id: 'E2',
          assignments: [makeAssignment(staffId: 'S1', hoursLogged: 3)],
        ),
      ];

      final workload = service.computeStaffWorkload(engagements, staff);
      expect(workload['S1'], 8);
    });

    test('tallies hours for multiple staff independently', () {
      final staff = [makeStaff(id: 'S1'), makeStaff(id: 'S2')];
      final engagements = [
        makeEngagement(
          id: 'E1',
          assignments: [
            makeAssignment(staffId: 'S1', hoursLogged: 10),
            makeAssignment(staffId: 'S2', hoursLogged: 6),
          ],
        ),
      ];

      final workload = service.computeStaffWorkload(engagements, staff);
      expect(workload['S1'], 10);
      expect(workload['S2'], 6);
    });

    test('staff not in any engagement defaults to 0', () {
      final staff = [makeStaff(id: 'S1'), makeStaff(id: 'S2')];
      final engagements = [
        makeEngagement(
          id: 'E1',
          assignments: [makeAssignment(staffId: 'S1', hoursLogged: 7)],
        ),
      ];

      final workload = service.computeStaffWorkload(engagements, staff);
      expect(workload['S1'], 7);
      expect(workload['S2'], 0);
    });

    test('returns unmodifiable map', () {
      final staff = [makeStaff(id: 'S1')];
      final workload = service.computeStaffWorkload([], staff);

      expect(() => workload['S1'] = 99, throwsA(anything));
    });
  });

  group('WorkloadDistributionService.suggestAssignment', () {
    test('throws ArgumentError when staff list is empty', () {
      final task = makeTask(id: 'T1', requiredRole: StaffRole.senior);
      expect(
        () => service.suggestAssignment(task, []),
        throwsArgumentError,
      );
    });

    test('returns single available staff when only one exists', () {
      final staff = [makeStaff(id: 'S1', role: StaffRole.senior)];
      final task = makeTask(id: 'T1', requiredRole: StaffRole.senior);

      final result = service.suggestAssignment(task, staff);
      expect(result.staffId, 'S1');
    });

    test('prefers exact role match over others', () {
      final task = makeTask(id: 'T1', requiredRole: StaffRole.manager);
      final staff = [
        makeStaff(id: 'S1', role: StaffRole.senior, currentEngagements: []),
        makeStaff(id: 'S2', role: StaffRole.manager, currentEngagements: []),
        makeStaff(id: 'S3', role: StaffRole.junior, currentEngagements: []),
      ];

      final result = service.suggestAssignment(task, staff);
      expect(result.staffId, 'S2'); // exact role match
    });

    test('among role-matched candidates, picks one with fewest engagements', () {
      final task = makeTask(id: 'T1', requiredRole: StaffRole.senior);
      final staff = [
        makeStaff(id: 'S1', role: StaffRole.senior, currentEngagements: ['E1', 'E2']),
        makeStaff(id: 'S2', role: StaffRole.senior, currentEngagements: ['E3']),
        makeStaff(id: 'S3', role: StaffRole.senior, currentEngagements: []),
      ];

      final result = service.suggestAssignment(task, staff);
      expect(result.staffId, 'S3'); // fewest engagements (0)
    });

    test('fallback to all staff when no role match', () {
      final task = makeTask(id: 'T1', requiredRole: StaffRole.partner);
      final staff = [
        makeStaff(id: 'S1', role: StaffRole.senior, currentEngagements: ['E1']),
        makeStaff(id: 'S2', role: StaffRole.junior, currentEngagements: []),
      ];

      // No partner available, should fallback to fewest engagements
      final result = service.suggestAssignment(task, staff);
      expect(result.staffId, 'S2'); // fewest among all available
    });
  });

  group('WorkloadDistributionService.detectBottlenecks', () {
    test('returns empty list when no engagements', () {
      final bottlenecks = service.detectBottlenecks([]);
      expect(bottlenecks, isEmpty);
    });

    test('returns empty list when all staff below threshold', () {
      final engagements = [
        makeEngagement(
          id: 'E1',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
        makeEngagement(
          id: 'E2',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
      ];

      // S1 has 2 engagements, threshold is 3
      final bottlenecks = service.detectBottlenecks(engagements);
      expect(bottlenecks, isEmpty);
    });

    test('detects bottleneck when staff has 3+ engagements (at threshold)', () {
      final engagements = [
        makeEngagement(
          id: 'E1',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
        makeEngagement(
          id: 'E2',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
        makeEngagement(
          id: 'E3',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
      ];

      final bottlenecks = service.detectBottlenecks(engagements);
      expect(bottlenecks, hasLength(1));
      expect(bottlenecks.first.staffId, 'S1');
      expect(bottlenecks.first.engagementCount, 3);
    });

    test('bottleneck description contains staff ID and count', () {
      final engagements = [
        makeEngagement(
          id: 'E1',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
        makeEngagement(
          id: 'E2',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
        makeEngagement(
          id: 'E3',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
      ];

      final bottlenecks = service.detectBottlenecks(engagements);
      expect(bottlenecks.first.description, contains('S1'));
      expect(bottlenecks.first.description, contains('3'));
    });

    test('identifies multiple bottlenecks independently', () {
      final engagements = [
        makeEngagement(
          id: 'E1',
          assignments: [
            makeAssignment(staffId: 'S1'),
            makeAssignment(staffId: 'S2'),
          ],
        ),
        makeEngagement(
          id: 'E2',
          assignments: [
            makeAssignment(staffId: 'S1'),
            makeAssignment(staffId: 'S2'),
          ],
        ),
        makeEngagement(
          id: 'E3',
          assignments: [
            makeAssignment(staffId: 'S1'),
            makeAssignment(staffId: 'S2'),
          ],
        ),
      ];

      final bottlenecks = service.detectBottlenecks(engagements);
      expect(bottlenecks, hasLength(2));
      final ids = bottlenecks.map((b) => b.staffId).toSet();
      expect(ids, containsAll(['S1', 'S2']));
    });

    test('does not flag staff with fewer than 3 engagements', () {
      final engagements = [
        makeEngagement(
          id: 'E1',
          assignments: [
            makeAssignment(staffId: 'S1'),
            makeAssignment(staffId: 'S2'),
          ],
        ),
        makeEngagement(
          id: 'E2',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
        makeEngagement(
          id: 'E3',
          assignments: [makeAssignment(staffId: 'S1')],
        ),
      ];

      // S1 = 3 (bottleneck), S2 = 1 (not bottleneck)
      final bottlenecks = service.detectBottlenecks(engagements);
      expect(bottlenecks, hasLength(1));
      expect(bottlenecks.first.staffId, 'S1');
    });
  });

  group('WorkflowBottleneck', () {
    test('equality — same staffId and count are equal', () {
      const a = WorkflowBottleneck(
        staffId: 'S1',
        engagementCount: 5,
        description: 'S1 is overloaded',
      );
      const b = WorkflowBottleneck(
        staffId: 'S1',
        engagementCount: 5,
        description: 'Different description',
      );

      expect(a, equals(b));
    });

    test('inequality when staffId differs', () {
      const a = WorkflowBottleneck(
        staffId: 'S1',
        engagementCount: 5,
        description: 'desc',
      );
      const b = WorkflowBottleneck(
        staffId: 'S2',
        engagementCount: 5,
        description: 'desc',
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('Staff', () {
    test('equality by staffId and name and role', () {
      final a = makeStaff(id: 'S1', role: StaffRole.manager);
      final b = Staff(
        staffId: 'S1',
        name: 'Staff S1',
        role: StaffRole.manager,
        skills: const [],
        currentEngagements: ['E1', 'E2'],
      );

      expect(a, equals(b));
    });

    test('copyWith creates new immutable instance', () {
      final original = makeStaff(id: 'S1', role: StaffRole.senior);
      final updated = original.copyWith(role: StaffRole.manager);

      expect(updated.role, StaffRole.manager);
      expect(original.role, StaffRole.senior); // original unchanged
    });
  });
}
