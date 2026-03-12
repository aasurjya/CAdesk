import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/rpa/data/providers/rpa_providers.dart';
import 'package:ca_app/features/rpa/domain/models/automation_task.dart';
import 'package:ca_app/features/rpa/presentation/widgets/automation_task_card.dart';

/// Main RPA dashboard showing stats and the task list.
class RpaDashboardScreen extends ConsumerWidget {
  const RpaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(rpaTaskListProvider);
    final theme = Theme.of(context);

    final totalTasks = tasks.length;
    final completedCount = tasks
        .where((t) => t.status == AutomationTaskStatus.completed)
        .length;
    final activeCount = tasks
        .where((t) => t.status == AutomationTaskStatus.running)
        .length;
    final successRate = totalTasks > 0
        ? (completedCount / totalTasks * 100).toStringAsFixed(0)
        : '0';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RPA Automation',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Portal bot execution centre',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/rpa/new'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Task'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatsRow(
            totalTasks: totalTasks,
            successRate: successRate,
            activeCount: activeCount,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Recent Tasks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/rpa/scripts'),
                child: const Text('Script Library'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No tasks yet. Tap + New Task to get started.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...tasks.map(
              (task) => AutomationTaskCard(
                task: task,
                onTap: () => context.push('/rpa/task', extra: task),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/rpa/new'),
        icon: const Icon(Icons.smart_toy_rounded),
        label: const Text('Run Bot'),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalTasks,
    required this.successRate,
    required this.activeCount,
  });

  final int totalTasks;
  final String successRate;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Tasks',
            value: '$totalTasks',
            icon: Icons.task_alt_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Success Rate',
            value: '$successRate%',
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Active',
            value: '$activeCount',
            icon: Icons.play_circle_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
