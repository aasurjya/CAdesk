import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/domain/services/automation_script_builder.dart';
import 'package:ca_app/features/rpa/domain/services/automation_task_manager.dart';
import 'package:ca_app/features/rpa/domain/services/portal_automation_service.dart';

// ---------------------------------------------------------------------------
// Service providers
// ---------------------------------------------------------------------------

/// Returns the static [AutomationScriptBuilder] class reference.
/// All methods on [AutomationScriptBuilder] are static, so the type itself
/// is the "instance."
final rpaScriptBuilderProvider = Provider<AutomationScriptBuilder>((_) {
  throw UnimplementedError(
    'AutomationScriptBuilder has only static methods — '
    'call them directly rather than through this provider.',
  );
});

/// Returns the static [AutomationTaskManager] class reference.
/// All methods on [AutomationTaskManager] are static.
final rpaTaskManagerProvider = Provider<AutomationTaskManager>((_) {
  throw UnimplementedError(
    'AutomationTaskManager has only static methods — '
    'call them directly rather than through this provider.',
  );
});

/// Returns the singleton [PortalAutomationService] instance.
final rpaPortalServiceProvider = Provider<PortalAutomationService>(
  (_) => PortalAutomationService.instance,
);

// ---------------------------------------------------------------------------
// Task list
// ---------------------------------------------------------------------------

final rpaTaskListProvider =
    NotifierProvider<RpaTaskListNotifier, List<AutomationTask>>(
      RpaTaskListNotifier.new,
    );

class RpaTaskListNotifier extends Notifier<List<AutomationTask>> {
  @override
  List<AutomationTask> build() => List.unmodifiable(_mockTasks);

  /// Prepends [task] to the task list (immutable — returns a new list).
  void addTask(AutomationTask task) {
    state = List.unmodifiable([task, ...state]);
  }

  /// Replaces the task with matching [taskId] with [updated].
  void updateTask(AutomationTask updated) {
    state = List.unmodifiable([
      for (final t in state)
        if (t.taskId == updated.taskId) updated else t,
    ]);
  }
}

final _now = DateTime.now();

final _mockTasks = <AutomationTask>[
  AutomationTask(
    taskId: 'task-mock-001',
    name: 'TRACES Form 16 Download',
    taskType: AutomationTaskType.tracesDownload,
    portal: AutomationPortal.traces,
    parameters: const {'tan': 'AAATA1234X', 'fy': '2024-25'},
    status: AutomationTaskStatus.completed,
    startedAt: _now.subtract(const Duration(hours: 2)),
    completedAt: _now.subtract(const Duration(hours: 1, minutes: 57)),
    retryCount: 0,
    maxRetries: 3,
    resultData: '{"requestId":"TRC-20240301-001","status":"Success"}',
    errorMessage: null,
  ),
  AutomationTask(
    taskId: 'task-mock-002',
    name: 'GST Filing Status Check',
    taskType: AutomationTaskType.gstFilingStatus,
    portal: AutomationPortal.gstn,
    parameters: const {'gstin': '27AABCU9603R1ZX', 'period': '032026'},
    status: AutomationTaskStatus.completed,
    startedAt: _now.subtract(const Duration(hours: 1)),
    completedAt: _now.subtract(const Duration(minutes: 58)),
    retryCount: 0,
    maxRetries: 3,
    resultData: '{"gstr1":"Filed","gstr3b":"Filed"}',
    errorMessage: null,
  ),
  AutomationTask(
    taskId: 'task-mock-003',
    name: 'MCA Form Prefill',
    taskType: AutomationTaskType.mcaPrefill,
    portal: AutomationPortal.mca,
    parameters: const {'cin': 'U74999DL2020PTC123456', 'form': 'AOC-4'},
    status: AutomationTaskStatus.running,
    startedAt: _now.subtract(const Duration(minutes: 5)),
    completedAt: null,
    retryCount: 0,
    maxRetries: 3,
    resultData: null,
    errorMessage: null,
  ),
  const AutomationTask(
    taskId: 'task-mock-004',
    name: 'Challan Status Verification',
    taskType: AutomationTaskType.challanFetch,
    portal: AutomationPortal.traces,
    parameters: {'tan': 'AAATA1234X', 'bsrCode': '0002390'},
    status: AutomationTaskStatus.queued,
    startedAt: null,
    completedAt: null,
    retryCount: 0,
    maxRetries: 3,
    resultData: null,
    errorMessage: null,
  ),
];

// ---------------------------------------------------------------------------
// Script library
// ---------------------------------------------------------------------------

final rpaScriptListProvider = Provider<List<AutomationScript>>((ref) {
  return List.unmodifiable(_buildMockScripts());
});

List<AutomationScript> _buildMockScripts() {
  final tracesForm16 = AutomationScriptBuilder.buildTracesForm16Script(
    '{tan}',
    DateTime.now().year - 1,
    ['{pan}'],
  );
  final challanStatus = AutomationScriptBuilder.buildChallanStatusScript(
    '{tan}',
    '{bsrCode}',
    '{challanDate}',
  );
  final gstStatus = AutomationScriptBuilder.buildGstFilingStatusScript(
    '{gstin}',
    '{period}',
  );
  final mcaPrefill = AutomationScriptBuilder.buildMcaFormPrefillScript(
    '{cin}',
    'AOC-4',
    const {'companyName': '{companyName}', 'registeredOffice': '{address}'},
  );
  return [tracesForm16, challanStatus, gstStatus, mcaPrefill];
}
