import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/roadmap_modules/data/providers/roadmap_modules_providers.dart';
import 'package:ca_app/features/roadmap_modules/domain/models/roadmap_module_models.dart';

class RoadmapModuleScreen extends ConsumerStatefulWidget {
  const RoadmapModuleScreen({required this.moduleId, super.key});

  final String moduleId;

  @override
  ConsumerState<RoadmapModuleScreen> createState() => _RoadmapModuleScreenState();
}

class _RoadmapModuleScreenState extends ConsumerState<RoadmapModuleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final module = ref.watch(roadmapModuleProvider(widget.moduleId));
    final summary = ref.watch(roadmapModuleSummaryProvider(widget.moduleId));
    final theme = Theme.of(context);

    if (module == null || summary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Module not found')),
        body: Center(
          child: Text(
            'No module configuration found for ${widget.moduleId}.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              module.subtitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.neutral100),
              ),
              child: TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Workboard'),
                  Tab(text: 'Automations'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _HeroCard(module: module),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                children: [
                  _SummaryCard(
                    label: 'Items',
                    value: summary.totalItems.toString(),
                    icon: Icons.view_kanban_outlined,
                    color: module.accentColor,
                  ),
                  const SizedBox(width: 8),
                  _SummaryCard(
                    label: 'Active',
                    value: summary.activeItems.toString(),
                    icon: Icons.play_circle_outline_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _SummaryCard(
                    label: 'At Risk',
                    value: summary.atRiskItems.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  _SummaryCard(
                    label: 'Automations',
                    value: summary.enabledAutomations.toString(),
                    icon: Icons.bolt_outlined,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _WorkboardTab(module: module),
                  _AutomationsTab(module: module),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.module});

  final RoadmapModuleDefinition module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: module.accentColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(module.icon, color: module.accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.heroTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.heroDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkboardTab extends StatelessWidget {
  const _WorkboardTab({required this.module});

  final RoadmapModuleDefinition module;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        Text(
          'Key metrics',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
        ),
        const SizedBox(height: 10),
        ...module.metrics.map((metric) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MetricTile(metric: metric),
            )),
        const SizedBox(height: 8),
        Text(
          'Delivery workboard',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
        ),
        const SizedBox(height: 10),
        ...module.workItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _WorkItemTile(item: item),
            )),
      ],
    );
  }
}

class _AutomationsTab extends ConsumerWidget {
  const _AutomationsTab({required this.module});

  final RoadmapModuleDefinition module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        Text(
          'Enabled automations',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
        ),
        const SizedBox(height: 10),
        ...module.automations.map((automation) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AutomationTile(
                moduleId: module.id,
                automation: automation,
                onChanged: (enabled) {
                  ref
                      .read(roadmapModulesProvider.notifier)
                      .toggleAutomation(module.id, automation.id, enabled);
                },
              ),
            )),
        const SizedBox(height: 8),
        Text(
          'Quick wins',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
        ),
        const SizedBox(height: 10),
        ...module.quickWins.map((win) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _QuickWinTile(text: win),
            )),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final RoadmapMetric metric;

  @override
  Widget build(BuildContext context) {
    final trendColor = switch (metric.trend) {
      RoadmapMetricTrend.up => AppColors.success,
      RoadmapMetricTrend.steady => AppColors.accent,
      RoadmapMetricTrend.down => AppColors.warning,
    };
    final trendIcon = switch (metric.trend) {
      RoadmapMetricTrend.up => Icons.trending_up_rounded,
      RoadmapMetricTrend.steady => Icons.trending_flat_rounded,
      RoadmapMetricTrend.down => Icons.trending_down_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: trendColor.withAlpha(18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(trendIcon, size: 16, color: trendColor),
                const SizedBox(width: 4),
                Text(
                  metric.delta,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkItemTile extends StatelessWidget {
  const _WorkItemTile({required this.item});

  final RoadmapWorkItem item;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    final label = _statusLabel(item.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withAlpha(18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Owner: ${item.owner}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
              ),
              Text(
                item.dueLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: item.progress,
              backgroundColor: AppColors.neutral100,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral600,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _AutomationTile extends StatelessWidget {
  const _AutomationTile({
    required this.moduleId,
    required this.automation,
    required this.onChanged,
  });

  final String moduleId;
  final RoadmapAutomation automation;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: SwitchListTile.adaptive(
        value: automation.enabled,
        onChanged: onChanged,
        title: Text(
          automation.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                automation.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Trigger: ${automation.trigger}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Outcome: ${automation.outcome}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
              ),
            ],
          ),
        ),
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

class _QuickWinTile extends StatelessWidget {
  const _QuickWinTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral600,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(RoadmapItemStatus status) {
  switch (status) {
    case RoadmapItemStatus.onTrack:
      return AppColors.success;
    case RoadmapItemStatus.planned:
      return AppColors.primary;
    case RoadmapItemStatus.atRisk:
      return AppColors.warning;
    case RoadmapItemStatus.blocked:
      return AppColors.error;
    case RoadmapItemStatus.completed:
      return AppColors.accent;
  }
}

String _statusLabel(RoadmapItemStatus status) {
  switch (status) {
    case RoadmapItemStatus.onTrack:
      return 'On Track';
    case RoadmapItemStatus.planned:
      return 'Planned';
    case RoadmapItemStatus.atRisk:
      return 'At Risk';
    case RoadmapItemStatus.blocked:
      return 'Blocked';
    case RoadmapItemStatus.completed:
      return 'Completed';
  }
}
