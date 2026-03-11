import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/activity_log.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/security_alert.dart';
import 'package:ca_app/features/staff_monitoring/data/providers/staff_monitoring_providers.dart';
import 'package:ca_app/features/staff_monitoring/presentation/widgets/activity_log_tile.dart';
import 'package:ca_app/features/staff_monitoring/presentation/widgets/access_restriction_tile.dart';
import 'package:ca_app/features/staff_monitoring/presentation/widgets/security_alert_tile.dart';

class StaffMonitoringScreen extends ConsumerStatefulWidget {
  const StaffMonitoringScreen({super.key});

  @override
  ConsumerState<StaffMonitoringScreen> createState() =>
      _StaffMonitoringScreenState();
}

class _StaffMonitoringScreenState extends ConsumerState<StaffMonitoringScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unresolvedCount = ref.watch(unresolvedAlertCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Staff Monitoring',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Activity'),
            const Tab(text: 'Restrictions'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Alerts'),
                  if (unresolvedCount > 0) ...[
                    const SizedBox(width: 6),
                    _AlertBadge(count: unresolvedCount),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_ActivityTab(), _RestrictionsTab(), _AlertsTab()],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity tab
// ---------------------------------------------------------------------------

class _ActivityTab extends ConsumerWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(filteredActivityLogsProvider);
    final selectedType = ref.watch(activityTypeFilterProvider);

    return Column(
      children: [
        _ActivityFilterBar(selected: selectedType),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                '${logs.length} log${logs.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: logs.isEmpty
              ? const _EmptyState(
                  icon: Icons.history,
                  message: 'No activity logs match the filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: logs.length,
                  itemBuilder: (context, index) =>
                      ActivityLogTile(log: logs[index]),
                ),
        ),
      ],
    );
  }
}

class _ActivityFilterBar extends ConsumerWidget {
  const _ActivityFilterBar({required this.selected});

  final ActivityType? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () =>
                ref.read(activityTypeFilterProvider.notifier).update(null),
          ),
          ...ActivityType.values.map(
            (type) => _FilterChip(
              label: type.label,
              isSelected: selected == type,
              onTap: () =>
                  ref.read(activityTypeFilterProvider.notifier).update(type),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Restrictions tab
// ---------------------------------------------------------------------------

class _RestrictionsTab extends ConsumerWidget {
  const _RestrictionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restrictions = ref.watch(allRestrictionsProvider);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: restrictions.length,
      itemBuilder: (context, index) =>
          AccessRestrictionTile(restriction: restrictions[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Alerts tab
// ---------------------------------------------------------------------------

class _AlertsTab extends ConsumerWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(filteredAlertsProvider);
    final selectedSeverity = ref.watch(alertSeverityFilterProvider);

    return Column(
      children: [
        _SeverityFilterBar(selected: selectedSeverity),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                '${alerts.length} alert${alerts.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: alerts.isEmpty
              ? const _EmptyState(
                  icon: Icons.shield_outlined,
                  message: 'No security alerts',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) =>
                      SecurityAlertTile(alert: alerts[index]),
                ),
        ),
      ],
    );
  }
}

class _SeverityFilterBar extends ConsumerWidget {
  const _SeverityFilterBar({required this.selected});

  final AlertSeverity? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () =>
                ref.read(alertSeverityFilterProvider.notifier).update(null),
          ),
          ...AlertSeverity.values.map(
            (severity) => _FilterChip(
              label: severity.label,
              isSelected: selected == severity,
              onTap: () => ref
                  .read(alertSeverityFilterProvider.notifier)
                  .update(severity),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withAlpha(30),
        checkmarkColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  const _AlertBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: AppColors.neutral200),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}
