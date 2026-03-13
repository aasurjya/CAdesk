import 'package:ca_app/features/practice/domain/models/workflow.dart';
import 'package:ca_app/features/practice/domain/repositories/practice_repository.dart';

class MockPracticeRepository implements PracticeRepository {
  static final List<Workflow> _seedWorkflows = [
    Workflow(
      id: 'wf-1',
      name: 'ITR Filing — Individual',
      description: 'Standard individual income tax return workflow',
      steps: const [
        'Collect Form 16',
        'Gather bank statements',
        'Review capital gains',
        'Prepare computation',
        'File return',
        'Share acknowledgement',
      ],
      estimatedDays: 3,
      category: WorkflowCategory.itrFiling,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Workflow(
      id: 'wf-2',
      name: 'GST Monthly Return',
      description: 'GSTR-3B monthly filing workflow',
      steps: const [
        'Download GSTR-2B',
        'Reconcile purchase register',
        'Prepare GSTR-3B',
        'Pay tax liability',
        'File GSTR-3B',
      ],
      estimatedDays: 2,
      category: WorkflowCategory.gstFiling,
      isActive: true,
      createdAt: DateTime(2024, 2, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Workflow(
      id: 'wf-3',
      name: 'TDS Quarterly Return',
      description: 'Form 24Q / 26Q quarterly TDS return',
      steps: const [
        'Compile deduction details',
        'Validate PAN data',
        'Prepare FVU file',
        'Upload to TRACES',
        'Generate Form 16/16A',
      ],
      estimatedDays: 4,
      category: WorkflowCategory.tdsFiling,
      isActive: true,
      createdAt: DateTime(2024, 3, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  final List<Workflow> _state = List.of(_seedWorkflows);

  @override
  Future<String> insertWorkflow(Workflow workflow) async {
    _state.add(workflow);
    return workflow.id;
  }

  @override
  Future<List<Workflow>> getAllWorkflows() async =>
      List.unmodifiable(_state);

  @override
  Future<List<Workflow>> getByCategory(WorkflowCategory category) async =>
      List.unmodifiable(_state.where((w) => w.category == category).toList());

  @override
  Future<Workflow?> getWorkflowById(String id) async {
    try {
      return _state.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> updateWorkflow(Workflow workflow) async {
    final idx = _state.indexWhere((w) => w.id == workflow.id);
    if (idx == -1) return false;
    final updated = List<Workflow>.of(_state)..[idx] = workflow;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteWorkflow(String id) async {
    final before = _state.length;
    _state.removeWhere((w) => w.id == id);
    return _state.length < before;
  }

  @override
  Future<List<Workflow>> getActiveWorkflows() async =>
      List.unmodifiable(_state.where((w) => w.isActive).toList());
}
