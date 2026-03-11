import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ai_automation/data/providers/ai_automation_providers.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';
import 'package:ca_app/features/ai_automation/domain/models/bank_reconciliation.dart';
import 'package:ca_app/features/ai_automation/domain/models/anomaly_alert.dart';
import 'package:ca_app/features/ai_automation/presentation/widgets/scan_result_tile.dart';
import 'package:ca_app/features/ai_automation/presentation/widgets/reconciliation_tile.dart';
import 'package:ca_app/features/ai_automation/presentation/widgets/anomaly_alert_tile.dart';
import 'package:ca_app/features/ai_automation/presentation/widgets/ai_demo_cards.dart';
import 'package:ca_app/features/ai_automation/presentation/widgets/live_demo_sheet.dart';

/// AI & Automation dashboard with summary cards and recent activity.
class AiDashboardScreen extends ConsumerWidget {
  const AiDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automationCounts = ref.watch(automationInsightCountsProvider);
    final automationInsights = ref.watch(automationInsightsProvider);
    final scanCounts = ref.watch(scanCountsProvider);
    final reconCounts = ref.watch(reconCountsProvider);
    final anomalyCounts = ref.watch(anomalyCountsProvider);
    final recentScans = ref.watch(filteredScanResultsProvider);
    final recentRecons = ref.watch(filteredReconciliationsProvider);
    final recentAlerts = ref.watch(filteredAnomalyAlertsProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showLiveDemoSheet(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.play_circle_rounded),
          label: const Text(
            'Live AI Demo',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          elevation: 4,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI & Automation',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                'Smart operations cockpit',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.neutral100),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                color: AppColors.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshing AI insights...')),
                  );
                },
              ),
            ),
          ],
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
                child: const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Core AI'),
                    Tab(text: 'Scans'),
                    Tab(text: 'Reconciliation'),
                    Tab(text: 'Anomalies'),
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
          child: TabBarView(
            children: [
              _CoreAutomationTab(
                counts: automationCounts,
                insights: automationInsights,
              ),
              _ScansTab(
                counts: scanCounts,
                scans: recentScans,
              ),
              _ReconciliationTab(
                counts: reconCounts,
                reconciliations: recentRecons,
              ),
              _AnomaliesTab(
                ref: ref,
                counts: anomalyCounts,
                alerts: recentAlerts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoreAutomationTab extends StatelessWidget {
  const _CoreAutomationTab({
    required this.counts,
    required this.insights,
  });

  final Map<String, int> counts;
  final List<AutomationInsight> insights;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        const _InsightBanner(
          title: 'Automation overview',
          description:
              'Track AI queues, high-priority interventions, and smart next actions in one place.',
          icon: Icons.auto_awesome_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          title: 'Core AI Operations',
          icon: Icons.auto_awesome_rounded,
          iconColor: AppColors.primary,
          stats: [
            _StatItem('Total', '${counts['all'] ?? 0}'),
            _StatItem('Attention', '${counts['attention'] ?? 0}'),
            _StatItem('Blocked', '${counts['blocked'] ?? 0}'),
            _StatItem('On Track', '${counts['onTrack'] ?? 0}'),
          ],
        ),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Live Automation Queue',
          count: insights.length,
        ),
        const SizedBox(height: 8),
        ...insights.map(
          (insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AutomationInsightTile(insight: insight),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Scans Tab
// ---------------------------------------------------------------------------

class _ScansTab extends StatelessWidget {
  const _ScansTab({required this.counts, required this.scans});

  final Map<String, int> counts;
  final List<AiScanResult> scans;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        const _InsightBanner(
          title: 'Document extraction flow',
          description:
              'Review scan throughput, extraction quality, and documents that need attention.',
          icon: Icons.document_scanner_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          title: 'Document Scans',
          icon: Icons.document_scanner_rounded,
          iconColor: AppColors.primary,
          stats: [
            _StatItem('Total', '${counts['all'] ?? 0}'),
            _StatItem('Completed', '${counts['completed'] ?? 0}'),
            _StatItem('Processing', '${counts['processing'] ?? 0}'),
            _StatItem('Review', '${counts['review'] ?? 0}'),
          ],
        ),
        const SizedBox(height: 20),
        const AiScanDemoCard(),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Recent Scans',
          count: scans.length,
        ),
        const SizedBox(height: 8),
        ...scans.map((scan) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ScanResultTile(
                scanResult: scan,
                onTap: () => _showScanDetail(context, scan),
              ),
            )),
      ],
    );
  }

  void _showScanDetail(BuildContext context, AiScanResult scan) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    scan.documentName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${scan.documentType.label}  •  ${scan.clientName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Extracted Data',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...scan.extractedData.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                e.key,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.value,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Reconciliation Tab
// ---------------------------------------------------------------------------

class _ReconciliationTab extends StatelessWidget {
  const _ReconciliationTab({
    required this.counts,
    required this.reconciliations,
  });

  final Map<String, int> counts;
  final List<BankReconciliation> reconciliations;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        const _InsightBanner(
          title: 'Reconciliation command center',
          description:
              'See auto-matched volume, unresolved items, and recently balanced accounts.',
          icon: Icons.account_balance_rounded,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          title: 'Bank Reconciliation',
          icon: Icons.account_balance_rounded,
          iconColor: AppColors.secondary,
          stats: [
            _StatItem('Total', '${counts['all'] ?? 0}'),
            _StatItem('Auto', '${counts['autoMatched'] ?? 0}'),
            _StatItem('Manual', '${counts['manual'] ?? 0}'),
            _StatItem('Unmatched', '${counts['unmatched'] ?? 0}'),
          ],
        ),
        const SizedBox(height: 20),
        const AiReconDemoCard(),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Recent Matches',
          count: reconciliations.length,
        ),
        const SizedBox(height: 8),
        ...reconciliations.map((recon) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReconciliationTile(reconciliation: recon),
            )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Anomalies Tab
// ---------------------------------------------------------------------------

class _AnomaliesTab extends StatelessWidget {
  const _AnomaliesTab({
    required this.ref,
    required this.counts,
    required this.alerts,
  });

  final WidgetRef ref;
  final Map<String, int> counts;
  final List<AnomalyAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        const _InsightBanner(
          title: 'Anomaly monitoring',
          description:
              'Prioritize risk alerts quickly with clearer severity context and resolution flow.',
          icon: Icons.warning_amber_rounded,
          color: AppColors.accent,
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          title: 'Anomaly Detection',
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.accent,
          stats: [
            _StatItem('Total', '${counts['all'] ?? 0}'),
            _StatItem('Unresolved', '${counts['unresolved'] ?? 0}'),
            _StatItem('Resolved', '${counts['resolved'] ?? 0}'),
            _StatItem('Critical', '${counts['critical'] ?? 0}'),
          ],
        ),
        const SizedBox(height: 20),
        const AiAnomalyDemoCard(),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Recent Alerts',
          count: alerts.length,
        ),
        const SizedBox(height: 8),
        ...alerts.map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AnomalyAlertTile(
                alert: alert,
                onResolve: () => _resolveAlert(context, alert),
              ),
            )),
      ],
    );
  }

  void _resolveAlert(BuildContext context, AnomalyAlert alert) {
    final allAlerts = ref.read(allAnomalyAlertsProvider);
    final updated = allAlerts.map((a) {
      if (a.id == alert.id) {
        return a.copyWith(isResolved: true);
      }
      return a;
    }).toList();
    ref.read(allAnomalyAlertsProvider.notifier).update(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Alert for ${alert.clientName} resolved'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(allAnomalyAlertsProvider.notifier).update(allAlerts);
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Widgets
// ---------------------------------------------------------------------------

class _StatItem {
  const _StatItem(this.label, this.value);

  final String label;
  final String value;
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(18),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
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
                    description,
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
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.stats,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_StatItem> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: stats
                  .map((stat) => Expanded(
                        child: Column(
                          children: [
                            Text(
                              stat.value,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutral900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stat.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.neutral400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AutomationInsightTile extends StatelessWidget {
  const _AutomationInsightTile({required this.insight});

  final AutomationInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: insight.color.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(insight.icon, color: insight.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insight.clientName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: insight.status.color.withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        insight.status.icon,
                        size: 14,
                        color: insight.status.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        insight.status.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: insight.status.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              insight.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.metricLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insight.metricValue,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: insight.color.withAlpha(12),
                    foregroundColor: insight.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(insight.actionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

