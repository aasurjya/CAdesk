import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/dashboard/data/providers/cross_module_providers.dart';
import 'package:ca_app/features/dashboard/presentation/widgets/activity_feed_widget.dart';
import 'package:ca_app/features/dashboard/presentation/widgets/ai_insights_section.dart';
import 'package:ca_app/features/dashboard/presentation/widgets/compliance_deadline_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CADesk',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Daily practice overview',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.neutral100),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.primary,
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutral100),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withAlpha(24),
                    child: const Text(
                      'CA',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Lead Partner',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _crossAxisCount(constraints.maxWidth);
          final horizontalPadding = constraints.maxWidth >= 900 ? 24.0 : 16.0;

          return RefreshIndicator(
            onRefresh: () async {
              // Allow downstream providers to react to pull-to-refresh.
              // A short delay gives visual feedback that the refresh occurred.
              await Future<void>.delayed(const Duration(milliseconds: 300));
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                24,
              ),
              children: [
                const _GreetingSection(),
                const SizedBox(height: 20),
                const _OverviewHeroCard(),
                const SizedBox(height: 24),
                const AiInsightsSection(),
                const SizedBox(height: 24),
                _QuickActionsGrid(crossAxisCount: crossAxisCount),
                const SizedBox(height: 24),
                _DeadlinesSection(compact: constraints.maxWidth < 720),
                const SizedBox(height: 24),
                const _ActivitySection(),
              ],
            ),
          );
        },
      ),
    );
  }

  int _crossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 720) return 4;
    if (width >= 560) return 2;
    return 2;
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good ${_greetingTime()}!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Here’s your firm performance snapshot for today.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          today,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }

  String _greetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _OverviewHeroCard extends ConsumerWidget {
  const _OverviewHeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final kpi = ref.watch(dashboardKpiProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.neutral100),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Light Mode Workspace',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Keep deadlines, filings, and client work visible in one calm workspace.',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Prioritized actions, urgent filings, and recent progress are grouped for faster decision making.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.neutral100),
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _OverviewStat(
                  label: 'Due this week',
                  value: kpi.upcomingDeadlines.toString().padLeft(2, '0'),
                  color: AppColors.primary,
                ),
                _OverviewStat(
                  label: 'ITR pending',
                  value: kpi.itrPendingCount.toString().padLeft(2, '0'),
                  color: AppColors.accent,
                ),
                _OverviewStat(
                  label: 'GST pending',
                  value: kpi.gstReturnsPendingCount.toString().padLeft(2, '0'),
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
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

    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.crossAxisCount});

  final int crossAxisCount;

  static const _actions = <_QuickAction>[
    _QuickAction(
      icon: Icons.receipt_long_rounded,
      label: 'File ITR',
      subtitle: 'Prepare and submit returns',
      color: AppColors.primary,
      route: '/',
    ),
    _QuickAction(
      icon: Icons.receipt_rounded,
      label: 'File GST',
      subtitle: 'Stay ahead of GST deadlines',
      color: AppColors.secondary,
      route: '/gst',
    ),
    _QuickAction(
      icon: Icons.description_outlined,
      label: 'File TDS',
      subtitle: 'Review challans and returns',
      color: AppColors.accent,
      route: '/tds',
    ),
    _QuickAction(
      icon: Icons.person_add_alt_1_rounded,
      label: 'New Client',
      subtitle: 'Start onboarding workflow',
      color: AppColors.success,
      route: '/clients',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Quick Actions',
          subtitle: 'Jump into the most-used workflows with fewer taps.',
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: crossAxisCount >= 4 ? 1.15 : 1.26,
          ),
          itemCount: _actions.length,
          itemBuilder: (context, index) {
            final action = _actions[index];

            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.go(action.route),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: action.color.withAlpha(18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(action.icon, color: action.color, size: 22),
                      ),
                      const Spacer(),
                      Text(
                        action.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final String route;
}

/// Wrapper section that renders [ComplianceDeadlineWidget] with a section
/// title and optional "View All" action.
class _DeadlinesSection extends StatelessWidget {
  const _DeadlinesSection({required this.compact});

  // ignore: unused_field
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Upcoming Deadlines',
          subtitle:
              'Track high-priority statutory due dates before they become urgent.',
          actionLabel: 'View All',
          onAction: () => context.go('/compliance'),
        ),
        const SizedBox(height: 12),
        const ComplianceDeadlineWidget(),
      ],
    );
  }
}

/// Wrapper section that renders [ActivityFeedWidget] with a section title
/// and optional "View All" action.
class _ActivitySection extends StatelessWidget {
  const _ActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Recent Activity',
          subtitle:
              'A quick timeline of filings, payments, and client actions.',
          actionLabel: 'View All',
          onAction: () => context.go('/tasks'),
        ),
        const SizedBox(height: 12),
        const ActivityFeedWidget(),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: 12),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}
