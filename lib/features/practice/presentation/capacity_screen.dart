import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/data/providers/practice_providers.dart';
import 'package:ca_app/features/practice/presentation/widgets/capacity_bar.dart';

/// Screen showing team capacity and utilization bars.
class CapacityScreen extends ConsumerWidget {
  const CapacityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamCapacityProvider);
    final theme = Theme.of(context);

    // Sort: overloaded first, then by utilization descending
    final sorted = List<TeamMember>.from(team)
      ..sort((a, b) => b.utilization.compareTo(a.utilization));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Capacity Planning',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TeamSummary(team: sorted),
            const SizedBox(height: 16),
            _SectionHeader(
              title: 'Team Workload',
              icon: Icons.bar_chart_rounded,
            ),
            const SizedBox(height: 10),
            ...sorted.map(
              (member) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CapacityBar(
                  member: member,
                  onReassign: () => _showReassignSnackbar(context, member),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showReassignSnackbar(BuildContext context, TeamMember member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reassign tasks from ${member.name}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Team summary
// ---------------------------------------------------------------------------

class _TeamSummary extends StatelessWidget {
  const _TeamSummary({required this.team});

  final List<TeamMember> team;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalAssigned = team.fold<int>(0, (s, m) => s + m.assignedHours);
    final totalCapacity = team.fold<int>(0, (s, m) => s + m.capacityHours);
    final avgUtilization = totalCapacity > 0
        ? totalAssigned / totalCapacity * 100
        : 0.0;
    final overloaded = team.where((m) => m.utilization > 100).length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Team Members',
                    value: '${team.length}',
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Avg Utilization',
                    value: '${avgUtilization.toStringAsFixed(0)}%',
                    color: AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Overloaded',
                    value: '$overloaded',
                    color: overloaded > 0 ? AppColors.error : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
