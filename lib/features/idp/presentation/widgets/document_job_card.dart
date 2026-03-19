import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/idp/domain/models/document_job.dart';

/// Card widget that displays summary information for a [DocumentJob].
class DocumentJobCard extends StatelessWidget {
  const DocumentJobCard({super.key, required this.job, this.onTap});

  final DocumentJob job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderRow(job: job),
              const SizedBox(height: 6),
              Text(
                job.clientName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _StatsRow(job: job),
              const SizedBox(height: 10),
              _FooterRow(job: job),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.job});

  final DocumentJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _DocTypeBadge(docType: job.documentType),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            job.fileName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _StatusChip(status: job.status),
      ],
    );
  }
}

class _DocTypeBadge extends StatelessWidget {
  const _DocTypeBadge({required this.docType});

  final String docType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        docType,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  static Color _bgColor(String s) {
    switch (s) {
      case 'Completed':
        return AppColors.success.withAlpha(25);
      case 'Review':
        return AppColors.accent.withAlpha(30);
      case 'Processing':
        return AppColors.warning.withAlpha(30);
      case 'Failed':
        return AppColors.error.withAlpha(25);
      default: // Queued
        return AppColors.neutral200;
    }
  }

  static Color _textColor(String s) {
    switch (s) {
      case 'Completed':
        return AppColors.success;
      case 'Review':
        return AppColors.accent;
      case 'Processing':
        return AppColors.warning;
      case 'Failed':
        return AppColors.error;
      default:
        return AppColors.neutral600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bgColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor(status),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.job});

  final DocumentJob job;

  @override
  Widget build(BuildContext context) {
    final hasProgress = job.totalFields > 0;
    return Row(
      children: [
        if (hasProgress) ...[
          _ConfidenceIndicator(score: job.confidenceScore),
          const SizedBox(width: 16),
        ],
        if (hasProgress) ...[
          _FieldsStat(
            extracted: job.extractedFields,
            total: job.totalFields,
            flagged: job.flaggedFields,
          ),
        ] else ...[
          const Text(
            'Waiting to start',
            style: TextStyle(fontSize: 12, color: AppColors.neutral400),
          ),
        ],
      ],
    );
  }
}

class _ConfidenceIndicator extends StatelessWidget {
  const _ConfidenceIndicator({required this.score});

  final double score;

  static Color _color(double v) {
    if (v >= 0.90) return AppColors.success;
    if (v >= 0.70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(score);
    final percent = (score * 100).round();
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score,
            strokeWidth: 3,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldsStat extends StatelessWidget {
  const _FieldsStat({
    required this.extracted,
    required this.total,
    required this.flagged,
  });

  final int extracted;
  final int total;
  final int flagged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$extracted / $total fields extracted',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        if (flagged > 0) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                size: 12,
                color: AppColors.warning,
              ),
              const SizedBox(width: 3),
              Text(
                '$flagged flagged for review',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({required this.job});

  final DocumentJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 12,
          color: AppColors.neutral400,
        ),
        const SizedBox(width: 4),
        Text(
          job.submittedDate,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 11,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: 3),
              Text(
                job.processingTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
