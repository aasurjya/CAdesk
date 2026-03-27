import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';

/// Card displaying the ESG pillar scores and metadata for a single disclosure.
class EsgScoreCard extends StatelessWidget {
  const EsgScoreCard({super.key, required this.disclosure});

  final EsgDisclosure disclosure;

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  Color _statusColor(String status) {
    switch (status) {
      case 'Filed':
        return AppColors.success;
      case 'Published':
        return AppColors.secondary;
      case 'Under Review':
        return AppColors.warning;
      case 'Draft':
        return AppColors.neutral400;
      default:
        return AppColors.neutral400;
    }
  }

  Color _sebiCategoryColor(String category) {
    switch (category) {
      case 'BRSR Core':
        return AppColors.primary;
      case 'Listed Top 1000':
        return AppColors.accent;
      case 'Voluntary':
        return AppColors.secondary;
      default:
        return AppColors.neutral600;
    }
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: AppColors.surface,
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 4),
            _buildSubtitle(theme),
            const SizedBox(height: 12),
            _buildScoreBars(),
            const SizedBox(height: 12),
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            disclosure.clientName,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _SebiCategoryBadge(
          category: disclosure.sebiCategory,
          color: _sebiCategoryColor(disclosure.sebiCategory),
        ),
        const SizedBox(width: 6),
        _StatusChip(
          status: disclosure.status,
          color: _statusColor(disclosure.status),
        ),
      ],
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    return Text(
      '${disclosure.disclosureType} · ${disclosure.reportingYear}',
      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.neutral600),
    );
  }

  Widget _buildScoreBars() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _ScoreBar(
                label: 'E',
                score: disclosure.environmentScore,
                color: AppColors.success,
              ),
              const SizedBox(height: 6),
              _ScoreBar(
                label: 'S',
                score: disclosure.socialScore,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 6),
              _ScoreBar(
                label: 'G',
                score: disclosure.governanceScore,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _OverallScore(score: disclosure.overallScore),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    if (disclosure.pendingItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        const Icon(
          Icons.pending_actions_outlined,
          size: 14,
          color: AppColors.warning,
        ),
        const SizedBox(width: 4),
        Text(
          '${disclosure.pendingItems.length} pending item'
          '${disclosure.pendingItems.length == 1 ? '' : 's'}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SebiCategoryBadge extends StatelessWidget {
  const _SebiCategoryBadge({required this.category, required this.color});

  final String category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 7,
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 30,
          child: Text(
            score.toStringAsFixed(0),
            textAlign: TextAlign.end,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverallScore extends StatelessWidget {
  const _OverallScore({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          score.toStringAsFixed(0),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '/100',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}
