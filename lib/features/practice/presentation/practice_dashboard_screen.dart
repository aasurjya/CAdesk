import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/data/providers/practice_providers.dart';

/// Main dashboard for Practice Management.
class PracticeDashboardScreen extends ConsumerWidget {
  const PracticeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(practiceStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practice Management',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Workflows, assignments & capacity',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
            _KpiRow(stats: stats),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Quick Links',
              icon: Icons.rocket_launch_rounded,
            ),
            const SizedBox(height: 10),
            _QuickLinkGrid(
              links: [
                _QuickLink(
                  label: 'Workflows',
                  icon: Icons.account_tree_rounded,
                  color: AppColors.primary,
                  onTap: () => context.push('/practice/workflows'),
                ),
                _QuickLink(
                  label: 'Assignments',
                  icon: Icons.assignment_ind_rounded,
                  color: AppColors.secondary,
                  onTap: () => context.push('/practice/assignments'),
                ),
                _QuickLink(
                  label: 'Capacity',
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.accent,
                  onTap: () => context.push('/practice/capacity'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// KPI row
// ---------------------------------------------------------------------------

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.stats});

  final PracticeStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _KpiCard(
          label: 'Active Clients',
          value: '${stats.totalClients}',
          icon: Icons.people_outline_rounded,
          color: AppColors.primary,
        ),
        _KpiCard(
          label: 'Engagements',
          value: '${stats.activeEngagements}',
          icon: Icons.work_outline_rounded,
          color: AppColors.secondary,
        ),
        _KpiCard(
          label: 'Overdue Tasks',
          value: '${stats.overdueTasks}',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
        ),
        _KpiCard(
          label: 'Team Utilization',
          value: '${stats.teamUtilization.toStringAsFixed(0)}%',
          icon: Icons.groups_rounded,
          color: AppColors.accent,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick links
// ---------------------------------------------------------------------------

class _QuickLink {
  const _QuickLink({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _QuickLinkGrid extends StatelessWidget {
  const _QuickLinkGrid({required this.links});

  final List<_QuickLink> links;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: links.map((link) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: link == links.last ? 0 : 10),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: link.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 12,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: link.color.withAlpha(18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(link.icon, color: link.color, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        link.label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
