import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/audit/data/providers/audit_providers.dart';

/// Tile displaying a single audit report: client name, form type badge,
/// assessment year, status chip, and completion percentage.
class AuditReportTile extends StatelessWidget {
  const AuditReportTile({required this.report, required this.onTap, super.key});

  final AuditReportSummary report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  _StatusChip(status: report.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _FormTypeBadge(formType: report.formType),
                  const SizedBox(width: 10),
                  Text(
                    'AY ${report.assessmentYear}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(report.completionPercent * 100).round()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _completionColor(report.completionPercent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: report.completionPercent,
                  backgroundColor: AppColors.neutral100,
                  color: _completionColor(report.completionPercent),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _completionColor(double percent) {
    if (percent >= 1.0) return AppColors.success;
    if (percent >= 0.5) return AppColors.secondary;
    return AppColors.warning;
  }
}

class _FormTypeBadge extends StatelessWidget {
  const _FormTypeBadge({required this.formType});

  final AuditFormType formType;

  @override
  Widget build(BuildContext context) {
    final color = formType == AuditFormType.form3cd
        ? AppColors.primary
        : const Color(0xFF7C3AED);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        formType.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AuditReportStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _statusColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (status) {
      case AuditReportStatus.draft:
        return AppColors.neutral400;
      case AuditReportStatus.review:
        return AppColors.warning;
      case AuditReportStatus.finalized:
        return AppColors.secondary;
      case AuditReportStatus.filed:
        return AppColors.success;
    }
  }
}
