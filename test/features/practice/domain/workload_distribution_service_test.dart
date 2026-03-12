import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/practice/domain/models/workflow_template.dart';
import 'package:ca_app/features/practice/domain/models/workflow_task.dart';
import 'package:ca_app/features/practice/domain/models/engagement.dart';
import 'package:ca_app/features/practice/domain/models/staff_assignment.dart';
import 'package:ca_app/features/practice/domain/services/workload_distribution_service.dart';

const _staff1 = Staff(
  staffId: 'staff-001',
  name: 'Priya Sharma',
  role: StaffRole.senior,
  skills: [WorkflowCategory.itrFiling, WorkflowCategory.audit],
  currentEngagements: [],
);

const _staff2 = Staff(
  staffId: 'staff-002',
  name: 'Rahul Gupta',
  role: StaffRole.junior,
  skills: [WorkflowCategory.gstFiling],
  currentEngagements: [],
);

const _staff3 = Staff(
  staffId: 'staff-003',
  name: 'Meena Patel',
  role: StaffRole.manager,
  skills: [WorkflowCategory.itrFiling, WorkflowCategory.gstFiling],
  currentEngagements: [],
);

Engagement _makeEngagement(String id, List<StaffAssignment> assignments) {
  return Engagement(
    engagementId: id,
    clientId: 'client-001',
    templateId: 'tmpl-itr-individual',
    templateTasks: const [],
    assignedStaff: assignments,
    status: EngagementStatus.inProgress,
    dueDate: DateTime(2025, 7, 31),
    completedDate: null,
    billingAmount: 500000,
  );
}

void main() {
  group('WorkloadDistributionService.computeStaffWorkload', () {
    test('returns zero hours for staff with no engagements', () {
      final workload = WorkloadDistributionService.instance.computeStaffWorkload(
        [],
        [_staff1, _staff2],
      );
      expect(workload['staff-001'], 0);
      expect(workload['staff-002'], 0);
    });

    test('sums hoursLogged across all engagements per staff', () {
      final engagement1 = _makeEngagement('eng-001', [
        const StaffAssignment(
          staffId: 'staff-001',
          role: StaffRole.senior,
          tasks: ['t1'],
          hoursLogged: 5,
          hoursEstimated: 3,
        ),
      ]);
      final engagement2 = _makeEngagement('eng-002', [
        const StaffAssignment(
          staffId: 'staff-001',
          role: StaffRole.senior,
          tasks: ['t2'],
          hoursLogged: 3,
          hoursEstimated: 3,
        ),
      ]);
      final workload = WorkloadDistributionService.instance.computeStaffWorkload(
        [engagement1, engagement2],
        [_staff1],
      );
      expect(workload['staff-001'], 8);
    });

    test('includes all staff in result map even without engagements', () {
      final workload = WorkloadDistributionService.instance.computeStaffWorkload(
        [],
        [_staff1, _staff2, _staff3],
      );
      expect(workload.keys, containsAll(['staff-001', 'staff-002', 'staff-003']));
    });
  });

  group('WorkloadDistributionService.suggestAssignment', () {
    const itrTask = WorkflowTask(
      taskId: 't1',
      name: 'Computation',
      description: 'Compute ITR',
      requiredRole: StaffRole.senior,
      estimatedHours: 3,
      dependsOn: [],
      checklistItems: [],
    );

    test('prefers matching skill and role', () {
      final suggested = WorkloadDistributionService.instance.suggestAssignment(
        itrTask,
        [_staff1, _staff2, _staff3],
      );
      // staff-001 is senior with itrFiling skill
      expect(suggested.staffId, 'staff-001');
    });

    test('falls back to manager when no exact role match', () {
      const gstTask = WorkflowTask(
        taskId: 't2',
        name: 'GST Review',
        description: 'Review GST',
        requiredRole: StaffRole.manager,
        estimatedHours: 1,
        dependsOn: [],
        checklistItems: [],
      );
      final suggested = WorkloadDistributionService.instance.suggestAssignment(
        gstTask,
        [_staff1, _staff2, _staff3],
      );
      // staff-003 is manager with gstFiling skill
      expect(suggested.staffId, 'staff-003');
    });

    test('prefers staff with lower workload among equally qualified', () {
      const staffHighLoad = Staff(
        staffId: 'staff-004',
        name: 'Amit Kumar',
        role: StaffRole.senior,
        skills: [WorkflowCategory.itrFiling],
        currentEngagements: ['e1', 'e2', 'e3'],
      );
      const staffLowLoad = Staff(
        staffId: 'staff-005',
        name: 'Sunita Rao',
        role: StaffRole.senior,
        skills: [WorkflowCategory.itrFiling],
        currentEngagements: [],
      );
      final suggested = WorkloadDistributionService.instance.suggestAssignment(
        itrTask,
        [staffHighLoad, staffLowLoad],
      );
      expect(suggested.staffId, 'staff-005');
    });
  });

  group('WorkloadDistributionService.detectBottlenecks', () {
    test('returns empty when no engagements', () {
      final bottlenecks = WorkloadDistributionService.instance.detectBottlenecks([]);
      expect(bottlenecks, isEmpty);
    });

    test('detects bottleneck when many engagements are stuck at same task type', () {
      final engagements = List.generate(5, (i) {
        return _makeEngagement('eng-$i', [
          StaffAssignment(
            staffId: 'staff-001',
            role: StaffRole.manager,
            tasks: ['t-review'],
            hoursLogged: 0,
            hoursEstimated: 1,
          ),
        ]);
      });
      final bottlenecks = WorkloadDistributionService.instance.detectBottlenecks(
        engagements,
      );
      expect(bottlenecks, isNotEmpty);
      expect(bottlenecks.first.staffId, 'staff-001');
      expect(bottlenecks.first.engagementCount, greaterThanOrEqualTo(3));
    });
  });
}
