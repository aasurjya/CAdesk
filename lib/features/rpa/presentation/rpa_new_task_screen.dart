import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/rpa/data/providers/rpa_providers.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/domain/services/automation_task_manager.dart';

/// Three-step wizard for creating and running a new RPA task.
///
/// Step 1: Portal selector (TRACES / GSTN / MCA)
/// Step 2: Task type chips based on selected portal
/// Step 3: Parameter form
class RpaNewTaskScreen extends ConsumerStatefulWidget {
  const RpaNewTaskScreen({super.key});

  @override
  ConsumerState<RpaNewTaskScreen> createState() => _RpaNewTaskScreenState();
}

class _RpaNewTaskScreenState extends ConsumerState<RpaNewTaskScreen> {
  int _step = 0;

  AutomationPortal _portal = AutomationPortal.traces;
  AutomationTaskType? _taskType;
  final _paramController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _tasksByPortal = <AutomationPortal, List<AutomationTaskType>>{
    AutomationPortal.traces: [
      AutomationTaskType.tracesDownload,
      AutomationTaskType.challanFetch,
    ],
    AutomationPortal.gstn: [AutomationTaskType.gstFilingStatus],
    AutomationPortal.mca: [AutomationTaskType.mcaPrefill],
    AutomationPortal.itd: [
      AutomationTaskType.itrStatus,
      AutomationTaskType.bulkPanVerify,
      AutomationTaskType.aisDownload,
    ],
    AutomationPortal.epfo: [],
  };

  static const _paramLabel = <AutomationPortal, String>{
    AutomationPortal.traces: 'TAN',
    AutomationPortal.gstn: 'GSTIN',
    AutomationPortal.mca: 'CIN',
    AutomationPortal.itd: 'PAN',
    AutomationPortal.epfo: 'UAN',
  };

  static const _taskTypeLabels = <AutomationTaskType, String>{
    AutomationTaskType.tracesDownload: 'Form 16 Download',
    AutomationTaskType.challanFetch: 'Challan Status',
    AutomationTaskType.gstFilingStatus: 'Filing Status',
    AutomationTaskType.mcaPrefill: 'Form Prefill',
    AutomationTaskType.itrStatus: 'ITR Status',
    AutomationTaskType.bulkPanVerify: 'Bulk PAN Verify',
    AutomationTaskType.aisDownload: 'AIS Download',
  };

  void _goNext() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _runTask();
    }
  }

  void _goBack() {
    if (_step > 0) setState(() => _step--);
  }

  void _runTask() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final type = _taskType;
    if (type == null) return;

    final paramKey = _paramLabel[_portal]?.toLowerCase() ?? 'param';
    final task = AutomationTaskManager.createTask(type, {
      paramKey: _paramController.text.trim(),
    });
    ref.read(rpaTaskListProvider.notifier).addTask(task);
    context.pushReplacement('/rpa/task', extra: task);
  }

  @override
  void dispose() {
    _paramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Automation Task'),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _goBack,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepIndicator(currentStep: _step),
            const SizedBox(height: 24),
            Expanded(child: _buildStep(theme)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: FilledButton(
            onPressed: _canAdvance ? _goNext : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(_step == 2 ? 'Run Automation' : 'Next'),
          ),
        ),
      ),
    );
  }

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return true;
      case 1:
        return _taskType != null;
      case 2:
        return _paramController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildStep(ThemeData theme) {
    switch (_step) {
      case 0:
        return _PortalStep(
          selected: _portal,
          onChanged: (p) => setState(() {
            _portal = p;
            _taskType = null;
          }),
        );
      case 1:
        final types = _tasksByPortal[_portal] ?? [];
        return _TaskTypeStep(
          types: types,
          selected: _taskType,
          labels: _taskTypeLabels,
          onChanged: (t) => setState(() => _taskType = t),
        );
      case 2:
        return _ParameterStep(
          formKey: _formKey,
          portal: _portal,
          taskType: _taskType!,
          paramLabel: _paramLabel[_portal] ?? 'Parameter',
          controller: _paramController,
          onChanged: (_) => setState(() {}),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Step 1 — portal selector
// ---------------------------------------------------------------------------

class _PortalStep extends StatelessWidget {
  const _PortalStep({required this.selected, required this.onChanged});

  final AutomationPortal selected;
  final ValueChanged<AutomationPortal> onChanged;

  static const _portals = [
    AutomationPortal.traces,
    AutomationPortal.gstn,
    AutomationPortal.mca,
  ];

  static const _labels = <AutomationPortal, String>{
    AutomationPortal.traces: 'TRACES',
    AutomationPortal.gstn: 'GSTN',
    AutomationPortal.mca: 'MCA',
  };

  static const _descriptions = <AutomationPortal, String>{
    AutomationPortal.traces: 'TDS/TCS portal — Form 16, challan verification',
    AutomationPortal.gstn: 'GST Network — filing status, returns dashboard',
    AutomationPortal.mca: 'Ministry of Corporate Affairs — form prefill',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Portal',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<AutomationPortal>(
          segments: _portals
              .map(
                (p) => ButtonSegment<AutomationPortal>(
                  value: p,
                  label: Text(_labels[p]!),
                ),
              )
              .toList(),
          selected: {selected},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(_labels[selected]!),
            subtitle: Text(_descriptions[selected] ?? ''),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — task type selector
// ---------------------------------------------------------------------------

class _TaskTypeStep extends StatelessWidget {
  const _TaskTypeStep({
    required this.types,
    required this.selected,
    required this.labels,
    required this.onChanged,
  });

  final List<AutomationTaskType> types;
  final AutomationTaskType? selected;
  final Map<AutomationTaskType, String> labels;
  final ValueChanged<AutomationTaskType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Task Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (types.isEmpty)
          Text(
            'No tasks available for this portal.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: types.map((type) {
              final isSelected = selected == type;
              return FilterChip(
                label: Text(labels[type] ?? type.name),
                selected: isSelected,
                onSelected: (_) => onChanged(type),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — parameter form
// ---------------------------------------------------------------------------

class _ParameterStep extends StatelessWidget {
  const _ParameterStep({
    required this.formKey,
    required this.portal,
    required this.taskType,
    required this.paramLabel,
    required this.controller,
    required this.onChanged,
  });

  final GlobalKey<FormState> formKey;
  final AutomationPortal portal;
  final AutomationTaskType taskType;
  final String paramLabel;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Parameters',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: paramLabel,
              hintText: _hintText(portal),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.tag_rounded),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: onChanged,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return '$paramLabel is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.smart_toy_rounded,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The bot will log in, extract data, and report '
                      'results automatically.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _hintText(AutomationPortal portal) {
    switch (portal) {
      case AutomationPortal.traces:
        return 'e.g. AAATA1234X';
      case AutomationPortal.gstn:
        return 'e.g. 27AABCU9603R1ZX';
      case AutomationPortal.mca:
        return 'e.g. U74999DL2020PTC123456';
      case AutomationPortal.itd:
        return 'e.g. ABCDE1234F';
      case AutomationPortal.epfo:
        return 'e.g. 100245789012';
    }
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  static const _labels = ['Portal', 'Task Type', 'Parameters'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Divider(
              color: i ~/ 2 < currentStep
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              thickness: 2,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final isActive = stepIdx == currentStep;
        final isDone = stepIdx < currentStep;
        return Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isDone || isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : Text(
                      '${stepIdx + 1}',
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              _labels[stepIdx],
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}
