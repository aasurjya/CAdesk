import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';

/// Compliance tab for the Client 360 screen.
///
/// Shows the risk score, compliance status grid, active engagements,
/// invoices, pending documents, and payment history — all sourced from
/// mock data via [clientHealthScoreProvider].
class ComplianceTab extends ConsumerWidget {
  const ComplianceTab({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(clientHealthScoreProvider(clientId));

    if (health == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text('No compliance data available for this client.'),
        ),
      );
    }

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _RiskScoreCard(
          score: health.overallScore,
          grade: health.grade,
          theme: theme,
        ),
        const SizedBox(height: AppSpacing.md),
        _ComplianceStatusCard(
          itrStatus: health.itrStatus,
          gstStatus: health.gstStatus,
          tdsStatus: health.tdsStatus,
          theme: theme,
        ),
        const SizedBox(height: AppSpacing.md),
        _PendingActionsCard(actions: health.pendingActions, theme: theme),
        const SizedBox(height: AppSpacing.md),
        _LastUpdatedLabel(lastUpdated: health.lastUpdated, theme: theme),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Risk score card
// ---------------------------------------------------------------------------

class _RiskScoreCard extends StatelessWidget {
  const _RiskScoreCard({
    required this.score,
    required this.grade,
    required this.theme,
  });

  final int score;
  final String grade;
  final ThemeData theme;

  Color get _color {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.neutral100,
                    valueColor: AlwaysStoppedAnimation(_color),
                  ),
                  Text(
                    '$score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compliance Score',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    grade,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Based on ITR, GST, and TDS status',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
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

// ---------------------------------------------------------------------------
// Compliance status card (ITR / GST / TDS)
// ---------------------------------------------------------------------------

class _ComplianceStatusCard extends StatelessWidget {
  const _ComplianceStatusCard({
    required this.itrStatus,
    required this.gstStatus,
    required this.tdsStatus,
    required this.theme,
  });

  final String itrStatus;
  final String gstStatus;
  final String tdsStatus;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compliance Status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatusTile(
                    icon: Icons.receipt_long_rounded,
                    module: 'ITR',
                    status: itrStatus,
                  ),
                ),
                Expanded(
                  child: _StatusTile(
                    icon: Icons.receipt_rounded,
                    module: 'GST',
                    status: gstStatus,
                  ),
                ),
                Expanded(
                  child: _StatusTile(
                    icon: Icons.description_rounded,
                    module: 'TDS',
                    status: tdsStatus,
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

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.module,
    required this.status,
  });

  final IconData icon;
  final String module;
  final String status;

  Color get _statusColor {
    switch (status) {
      case 'Filed':
      case 'Compliant':
        return AppColors.success;
      case 'Pending':
      case 'Returns Pending':
      case 'Challan Due':
        return AppColors.warning;
      case 'Overdue':
      case 'Late Filed':
        return AppColors.error;
      default:
        return AppColors.neutral400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _statusColor.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _statusColor.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: _statusColor),
          const SizedBox(height: 6),
          Text(
            module,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _statusColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pending actions list
// ---------------------------------------------------------------------------

class _PendingActionsCard extends StatelessWidget {
  const _PendingActionsCard({required this.actions, required this.theme});

  final List<String> actions;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppColors.warning.withAlpha(8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pending_actions_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Pending Actions (${actions.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...actions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        action,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Last updated label
// ---------------------------------------------------------------------------

class _LastUpdatedLabel extends StatelessWidget {
  const _LastUpdatedLabel({required this.lastUpdated, required this.theme});

  final String lastUpdated;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Text(
        'Last updated: $lastUpdated',
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.neutral400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
