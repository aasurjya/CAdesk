import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/rpa/data/providers/rpa_providers.dart';
import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/domain/services/automation_task_manager.dart';
import 'package:ca_app/features/rpa/presentation/widgets/script_card.dart';

/// Browsable catalogue of [AutomationScript]s with portal filter chips.
class RpaScriptLibraryScreen extends ConsumerStatefulWidget {
  const RpaScriptLibraryScreen({super.key});

  @override
  ConsumerState<RpaScriptLibraryScreen> createState() =>
      _RpaScriptLibraryScreenState();
}

class _RpaScriptLibraryScreenState
    extends ConsumerState<RpaScriptLibraryScreen> {
  AutomationPortal? _filter; // null = All

  @override
  Widget build(BuildContext context) {
    final scripts = ref.watch(rpaScriptListProvider);
    final theme = Theme.of(context);

    final filtered = _filter == null
        ? scripts
        : scripts.where((s) => s.targetPortal == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Script Library'),
      ),
      body: Column(
        children: [
          _FilterRow(
            selected: _filter,
            onChanged: (p) => setState(() => _filter = p),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No scripts for the selected portal.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisExtent: 200,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final script = filtered[index];
                      return ScriptCard(
                        script: script,
                        onRun: () => _runScript(context, script),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _runScript(BuildContext context, AutomationScript script) {
    final task = AutomationTaskManager.createTask(
      _taskTypeForPortal(script.targetPortal),
      const {'param': '{auto}'},
    );
    ref.read(rpaTaskListProvider.notifier).addTask(task);
    context.push('/rpa/task', extra: task);
  }

  static AutomationTaskType _taskTypeForPortal(AutomationPortal portal) {
    switch (portal) {
      case AutomationPortal.traces:
        return AutomationTaskType.tracesDownload;
      case AutomationPortal.gstn:
        return AutomationTaskType.gstFilingStatus;
      case AutomationPortal.mca:
        return AutomationTaskType.mcaPrefill;
      case AutomationPortal.itd:
        return AutomationTaskType.itrStatus;
      case AutomationPortal.epfo:
        return AutomationTaskType.bulkPanVerify;
    }
  }
}

// ---------------------------------------------------------------------------
// Filter row
// ---------------------------------------------------------------------------

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onChanged});

  final AutomationPortal? selected;
  final ValueChanged<AutomationPortal?> onChanged;

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          ..._portals.map((p) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_labels[p]!),
                selected: selected == p,
                onSelected: (_) => onChanged(selected == p ? null : p),
              ),
            );
          }),
        ],
      ),
    );
  }
}
