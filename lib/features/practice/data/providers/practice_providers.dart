import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/practice/domain/models/workflow_task.dart';
import 'package:ca_app/features/practice/domain/models/workflow_template.dart';

// ---------------------------------------------------------------------------
// Workflow list — 6 mock workflow templates
// ---------------------------------------------------------------------------

final workflowListProvider =
    NotifierProvider<WorkflowListNotifier, List<WorkflowTemplate>>(
      WorkflowListNotifier.new,
    );

class WorkflowListNotifier extends Notifier<List<WorkflowTemplate>> {
  @override
  List<WorkflowTemplate> build() => List.unmodifiable(_mockWorkflows);
}

// ---------------------------------------------------------------------------
// Assignment list — 8 mock client assignments
// ---------------------------------------------------------------------------

/// Status of a client assignment.
enum AssignmentStatus {
  pending(label: 'Pending'),
  inProgress(label: 'In Progress'),
  completed(label: 'Completed'),
  overdue(label: 'Overdue');

  const AssignmentStatus({required this.label});

  final String label;
}

/// Immutable client-staff assignment record.
class ClientAssignment {
  const ClientAssignment({
    required this.assignmentId,
    required this.clientName,
    required this.staffName,
    required this.taskDescription,
    required this.deadline,
    required this.status,
    required this.staffRole,
  });

  final String assignmentId;
  final String clientName;
  final String staffName;
  final String taskDescription;
  final DateTime deadline;
  final AssignmentStatus status;
  final StaffRole staffRole;

  ClientAssignment copyWith({
    String? assignmentId,
    String? clientName,
    String? staffName,
    String? taskDescription,
    DateTime? deadline,
    AssignmentStatus? status,
    StaffRole? staffRole,
  }) {
    return ClientAssignment(
      assignmentId: assignmentId ?? this.assignmentId,
      clientName: clientName ?? this.clientName,
      staffName: staffName ?? this.staffName,
      taskDescription: taskDescription ?? this.taskDescription,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      staffRole: staffRole ?? this.staffRole,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientAssignment &&
        other.assignmentId == assignmentId &&
        other.clientName == clientName &&
        other.staffName == staffName;
  }

  @override
  int get hashCode => Object.hash(assignmentId, clientName, staffName);
}

final assignmentListProvider =
    NotifierProvider<AssignmentListNotifier, List<ClientAssignment>>(
      AssignmentListNotifier.new,
    );

class AssignmentListNotifier extends Notifier<List<ClientAssignment>> {
  @override
  List<ClientAssignment> build() => List.unmodifiable(_mockAssignments);

  void addAssignment(ClientAssignment assignment) {
    state = List.unmodifiable([assignment, ...state]);
  }
}

// ---------------------------------------------------------------------------
// Assignment filter
// ---------------------------------------------------------------------------

enum AssignmentFilter { all, pending, inProgress, completed, overdue }

final assignmentFilterProvider =
    NotifierProvider<AssignmentFilterNotifier, AssignmentFilter>(
      AssignmentFilterNotifier.new,
    );

class AssignmentFilterNotifier extends Notifier<AssignmentFilter> {
  @override
  AssignmentFilter build() => AssignmentFilter.all;

  void update(AssignmentFilter value) => state = value;
}

final filteredAssignmentsProvider = Provider<List<ClientAssignment>>((ref) {
  final filter = ref.watch(assignmentFilterProvider);
  final assignments = ref.watch(assignmentListProvider);

  if (filter == AssignmentFilter.all) return assignments;

  final statusMap = {
    AssignmentFilter.pending: AssignmentStatus.pending,
    AssignmentFilter.inProgress: AssignmentStatus.inProgress,
    AssignmentFilter.completed: AssignmentStatus.completed,
    AssignmentFilter.overdue: AssignmentStatus.overdue,
  };

  final targetStatus = statusMap[filter];
  return assignments.where((a) => a.status == targetStatus).toList();
});

// ---------------------------------------------------------------------------
// Team capacity — staff utilization
// ---------------------------------------------------------------------------

/// Mock team member with workload data.
class TeamMember {
  const TeamMember({
    required this.staffId,
    required this.name,
    required this.role,
    required this.assignedHours,
    required this.capacityHours,
  });

  final String staffId;
  final String name;
  final StaffRole role;
  final int assignedHours;
  final int capacityHours;

  /// Utilization as a percentage.
  double get utilization =>
      capacityHours > 0 ? assignedHours / capacityHours * 100 : 0;

  TeamMember copyWith({
    String? staffId,
    String? name,
    StaffRole? role,
    int? assignedHours,
    int? capacityHours,
  }) {
    return TeamMember(
      staffId: staffId ?? this.staffId,
      name: name ?? this.name,
      role: role ?? this.role,
      assignedHours: assignedHours ?? this.assignedHours,
      capacityHours: capacityHours ?? this.capacityHours,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamMember &&
        other.staffId == staffId &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(staffId, name);
}

final teamCapacityProvider = Provider<List<TeamMember>>((ref) {
  return List.unmodifiable(_mockTeamMembers);
});

// ---------------------------------------------------------------------------
// Practice stats — derived
// ---------------------------------------------------------------------------

class PracticeStats {
  const PracticeStats({
    required this.totalClients,
    required this.activeEngagements,
    required this.overdueTasks,
    required this.teamUtilization,
  });

  final int totalClients;
  final int activeEngagements;
  final int overdueTasks;
  final double teamUtilization;
}

final practiceStatsProvider = Provider<PracticeStats>((ref) {
  final assignments = ref.watch(assignmentListProvider);
  final team = ref.watch(teamCapacityProvider);

  final uniqueClients = assignments.map((a) => a.clientName).toSet().length;
  final activeEngagements = assignments
      .where((a) => a.status == AssignmentStatus.inProgress)
      .length;
  final overdueTasks = assignments
      .where((a) => a.status == AssignmentStatus.overdue)
      .length;

  final totalAssigned = team.fold<int>(0, (sum, m) => sum + m.assignedHours);
  final totalCapacity = team.fold<int>(0, (sum, m) => sum + m.capacityHours);
  final utilization = totalCapacity > 0
      ? totalAssigned / totalCapacity * 100
      : 0.0;

  return PracticeStats(
    totalClients: uniqueClients,
    activeEngagements: activeEngagements,
    overdueTasks: overdueTasks,
    teamUtilization: utilization,
  );
});

// ---------------------------------------------------------------------------
// Mock data — workflows
// ---------------------------------------------------------------------------

const _mockWorkflows = <WorkflowTemplate>[
  WorkflowTemplate(
    templateId: 'wf-001',
    name: 'ITR Filing Workflow',
    category: WorkflowCategory.itrFiling,
    estimatedHours: 12,
    deadline: WorkflowDeadlineRule(offsetDays: 30),
    tasks: [
      WorkflowTask(
        taskId: 'wf001-t1',
        name: 'Collect documents',
        description: 'Gather Form 16, 26AS, bank statements',
        requiredRole: StaffRole.articleClerk,
        estimatedHours: 2,
        dependsOn: [],
        checklistItems: ['Form 16', '26AS', 'Bank statements'],
      ),
      WorkflowTask(
        taskId: 'wf001-t2',
        name: 'Prepare computation',
        description: 'Compute total income and tax liability',
        requiredRole: StaffRole.junior,
        estimatedHours: 3,
        dependsOn: ['wf001-t1'],
        checklistItems: ['Income computed', 'Deductions verified'],
      ),
      WorkflowTask(
        taskId: 'wf001-t3',
        name: 'Review and file',
        description: 'Partner review and e-filing on IT portal',
        requiredRole: StaffRole.senior,
        estimatedHours: 4,
        dependsOn: ['wf001-t2'],
        checklistItems: ['Partner approved', 'Filed on portal'],
      ),
      WorkflowTask(
        taskId: 'wf001-t4',
        name: 'E-verify',
        description: 'Complete e-verification via Aadhaar OTP',
        requiredRole: StaffRole.junior,
        estimatedHours: 1,
        dependsOn: ['wf001-t3'],
        checklistItems: ['ITR-V generated', 'E-verified'],
      ),
    ],
  ),
  WorkflowTemplate(
    templateId: 'wf-002',
    name: 'GST Monthly Returns',
    category: WorkflowCategory.gstFiling,
    estimatedHours: 8,
    deadline: WorkflowDeadlineRule(offsetDays: 20),
    tasks: [
      WorkflowTask(
        taskId: 'wf002-t1',
        name: 'Download GSTR-2B',
        description: 'Download and reconcile ITC from GSTR-2B',
        requiredRole: StaffRole.articleClerk,
        estimatedHours: 2,
        dependsOn: [],
        checklistItems: ['GSTR-2B downloaded', 'ITC reconciled'],
      ),
      WorkflowTask(
        taskId: 'wf002-t2',
        name: 'Prepare GSTR-3B',
        description: 'Compute output tax, ITC, and net liability',
        requiredRole: StaffRole.junior,
        estimatedHours: 3,
        dependsOn: ['wf002-t1'],
        checklistItems: ['Output computed', 'ITC matched'],
      ),
      WorkflowTask(
        taskId: 'wf002-t3',
        name: 'File GSTR-3B',
        description: 'File on GST portal and make challan payment',
        requiredRole: StaffRole.senior,
        estimatedHours: 2,
        dependsOn: ['wf002-t2'],
        checklistItems: ['Filed', 'Challan paid'],
      ),
    ],
  ),
  WorkflowTemplate(
    templateId: 'wf-003',
    name: 'Audit Engagement',
    category: WorkflowCategory.audit,
    estimatedHours: 80,
    deadline: WorkflowDeadlineRule(offsetDays: 90),
    tasks: [
      WorkflowTask(
        taskId: 'wf003-t1',
        name: 'Engagement acceptance',
        description: 'Independence check and engagement letter',
        requiredRole: StaffRole.partner,
        estimatedHours: 4,
        dependsOn: [],
        checklistItems: ['Independence confirmed', 'Letter signed'],
      ),
      WorkflowTask(
        taskId: 'wf003-t2',
        name: 'Planning and risk assessment',
        description: 'Materiality, risk areas, audit plan',
        requiredRole: StaffRole.manager,
        estimatedHours: 12,
        dependsOn: ['wf003-t1'],
        checklistItems: ['Materiality set', 'Risks identified'],
      ),
      WorkflowTask(
        taskId: 'wf003-t3',
        name: 'Fieldwork',
        description: 'Vouching, verification, confirmations',
        requiredRole: StaffRole.senior,
        estimatedHours: 40,
        dependsOn: ['wf003-t2'],
        checklistItems: ['Vouching complete', 'Confirmations received'],
      ),
      WorkflowTask(
        taskId: 'wf003-t4',
        name: 'Reporting',
        description: 'Draft audit report and management letter',
        requiredRole: StaffRole.partner,
        estimatedHours: 16,
        dependsOn: ['wf003-t3'],
        checklistItems: ['Report drafted', 'Partner signed'],
      ),
    ],
  ),
  WorkflowTemplate(
    templateId: 'wf-004',
    name: 'Company Incorporation',
    category: WorkflowCategory.advisory,
    estimatedHours: 24,
    deadline: WorkflowDeadlineRule(offsetDays: 21),
    tasks: [
      WorkflowTask(
        taskId: 'wf004-t1',
        name: 'Name reservation',
        description: 'RUN name approval on MCA portal',
        requiredRole: StaffRole.junior,
        estimatedHours: 4,
        dependsOn: [],
        checklistItems: ['Name approved'],
      ),
      WorkflowTask(
        taskId: 'wf004-t2',
        name: 'Draft MOA/AOA',
        description: 'Prepare Memorandum and Articles',
        requiredRole: StaffRole.senior,
        estimatedHours: 8,
        dependsOn: ['wf004-t1'],
        checklistItems: ['MOA drafted', 'AOA drafted'],
      ),
      WorkflowTask(
        taskId: 'wf004-t3',
        name: 'File SPICe+',
        description: 'File incorporation form on MCA',
        requiredRole: StaffRole.senior,
        estimatedHours: 6,
        dependsOn: ['wf004-t2'],
        checklistItems: ['SPICe+ filed', 'DSC attached'],
      ),
      WorkflowTask(
        taskId: 'wf004-t4',
        name: 'Post-incorporation',
        description: 'PAN, TAN, bank account, GST registration',
        requiredRole: StaffRole.junior,
        estimatedHours: 6,
        dependsOn: ['wf004-t3'],
        checklistItems: ['PAN received', 'Bank opened'],
      ),
    ],
  ),
  WorkflowTemplate(
    templateId: 'wf-005',
    name: 'TDS Quarterly Returns',
    category: WorkflowCategory.tdsFiling,
    estimatedHours: 10,
    deadline: WorkflowDeadlineRule(offsetDays: 30),
    tasks: [
      WorkflowTask(
        taskId: 'wf005-t1',
        name: 'Collect TDS data',
        description: 'Gather deduction registers and challans',
        requiredRole: StaffRole.articleClerk,
        estimatedHours: 3,
        dependsOn: [],
        checklistItems: ['Challans collected', 'Register verified'],
      ),
      WorkflowTask(
        taskId: 'wf005-t2',
        name: 'Prepare return',
        description: 'Prepare 24Q/26Q in RPU software',
        requiredRole: StaffRole.junior,
        estimatedHours: 4,
        dependsOn: ['wf005-t1'],
        checklistItems: ['FVU validated', 'Return ready'],
      ),
      WorkflowTask(
        taskId: 'wf005-t3',
        name: 'File and verify',
        description: 'Upload on TRACES and generate receipts',
        requiredRole: StaffRole.senior,
        estimatedHours: 3,
        dependsOn: ['wf005-t2'],
        checklistItems: ['Filed on TRACES', 'Receipt downloaded'],
      ),
    ],
  ),
  WorkflowTemplate(
    templateId: 'wf-006',
    name: 'Annual Compliance Review',
    category: WorkflowCategory.accounting,
    estimatedHours: 16,
    deadline: WorkflowDeadlineRule(offsetDays: 45),
    tasks: [
      WorkflowTask(
        taskId: 'wf006-t1',
        name: 'Compliance checklist',
        description: 'Review all statutory due dates and filings',
        requiredRole: StaffRole.senior,
        estimatedHours: 4,
        dependsOn: [],
        checklistItems: ['Checklist prepared'],
      ),
      WorkflowTask(
        taskId: 'wf006-t2',
        name: 'Gap analysis',
        description: 'Identify missed or late filings',
        requiredRole: StaffRole.manager,
        estimatedHours: 6,
        dependsOn: ['wf006-t1'],
        checklistItems: ['Gaps documented'],
      ),
      WorkflowTask(
        taskId: 'wf006-t3',
        name: 'Remediation plan',
        description: 'Draft rectification actions and timelines',
        requiredRole: StaffRole.partner,
        estimatedHours: 6,
        dependsOn: ['wf006-t2'],
        checklistItems: ['Plan approved', 'Client notified'],
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Mock data — assignments
// ---------------------------------------------------------------------------

final _now = DateTime.now();

final _mockAssignments = <ClientAssignment>[
  ClientAssignment(
    assignmentId: 'asgn-001',
    clientName: 'Rajesh Kumar Sharma',
    staffName: 'Amit Verma',
    taskDescription: 'ITR-1 filing — AY 2026-27',
    deadline: _now.add(const Duration(days: 5)),
    status: AssignmentStatus.inProgress,
    staffRole: StaffRole.senior,
  ),
  ClientAssignment(
    assignmentId: 'asgn-002',
    clientName: 'ABC Infra Pvt Ltd',
    staffName: 'Neha Kapoor',
    taskDescription: 'Statutory audit — FY 2025-26',
    deadline: _now.add(const Duration(days: 30)),
    status: AssignmentStatus.inProgress,
    staffRole: StaffRole.manager,
  ),
  ClientAssignment(
    assignmentId: 'asgn-003',
    clientName: 'Priya Mehta',
    staffName: 'Ramesh Iyer',
    taskDescription: 'GSTR-3B Feb 2026',
    deadline: _now.subtract(const Duration(days: 2)),
    status: AssignmentStatus.overdue,
    staffRole: StaffRole.junior,
  ),
  ClientAssignment(
    assignmentId: 'asgn-004',
    clientName: 'TechVista Solutions LLP',
    staffName: 'Priya Nair',
    taskDescription: 'TDS 24Q — Q3 FY 2025-26',
    deadline: _now.add(const Duration(days: 12)),
    status: AssignmentStatus.pending,
    staffRole: StaffRole.junior,
  ),
  ClientAssignment(
    assignmentId: 'asgn-005',
    clientName: 'Mehta & Sons',
    staffName: 'Amit Verma',
    taskDescription: 'Monthly bookkeeping — Feb 2026',
    deadline: _now.subtract(const Duration(days: 1)),
    status: AssignmentStatus.overdue,
    staffRole: StaffRole.articleClerk,
  ),
  ClientAssignment(
    assignmentId: 'asgn-006',
    clientName: 'Bharat Electronics Ltd',
    staffName: 'Neha Kapoor',
    taskDescription: 'Transfer pricing documentation',
    deadline: _now.add(const Duration(days: 60)),
    status: AssignmentStatus.inProgress,
    staffRole: StaffRole.partner,
  ),
  ClientAssignment(
    assignmentId: 'asgn-007',
    clientName: 'GreenLeaf Organics LLP',
    staffName: 'Ramesh Iyer',
    taskDescription: 'GST registration amendment',
    deadline: _now.add(const Duration(days: 3)),
    status: AssignmentStatus.completed,
    staffRole: StaffRole.junior,
  ),
  ClientAssignment(
    assignmentId: 'asgn-008',
    clientName: 'Deepak Patel',
    staffName: 'Priya Nair',
    taskDescription: 'ITR-4 filing — AY 2026-27',
    deadline: _now.add(const Duration(days: 15)),
    status: AssignmentStatus.pending,
    staffRole: StaffRole.senior,
  ),
];

// ---------------------------------------------------------------------------
// Mock data — team members
// ---------------------------------------------------------------------------

const _mockTeamMembers = <TeamMember>[
  TeamMember(
    staffId: 'staff-001',
    name: 'Amit Verma',
    role: StaffRole.senior,
    assignedHours: 42,
    capacityHours: 40,
  ),
  TeamMember(
    staffId: 'staff-002',
    name: 'Neha Kapoor',
    role: StaffRole.manager,
    assignedHours: 38,
    capacityHours: 40,
  ),
  TeamMember(
    staffId: 'staff-003',
    name: 'Ramesh Iyer',
    role: StaffRole.junior,
    assignedHours: 28,
    capacityHours: 40,
  ),
  TeamMember(
    staffId: 'staff-004',
    name: 'Priya Nair',
    role: StaffRole.junior,
    assignedHours: 32,
    capacityHours: 40,
  ),
  TeamMember(
    staffId: 'staff-005',
    name: 'Suresh Reddy',
    role: StaffRole.articleClerk,
    assignedHours: 35,
    capacityHours: 35,
  ),
  TeamMember(
    staffId: 'staff-006',
    name: 'CA Rajiv Gupta',
    role: StaffRole.partner,
    assignedHours: 22,
    capacityHours: 30,
  ),
];
