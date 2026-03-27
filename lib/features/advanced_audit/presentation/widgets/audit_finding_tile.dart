import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/advanced_audit/domain/models/audit_finding.dart';

/// A tile displaying an audit finding with severity color and status.
class AuditFindingTile extends StatelessWidget {
  const AuditFindingTile({super.key, required this.finding, this.onTap});

  final AuditFinding finding;
  final VoidCallback? onTap;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    finding.severity.icon,
                    size: 20,
                    color: finding.severity.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      finding.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: finding.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                finding.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SeverityBadge(severity: finding.severity),
                  const SizedBox(width: 8),
                  _CategoryChip(category: finding.category),
                  const Spacer(),
                  Text(
                    _dateFormat.format(finding.reportedDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              if (finding.managementResponse != null) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.reply,
                        size: 14,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          finding.managementResponse!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final FindingSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: severity.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        severity.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: severity.color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final FindingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final FindingCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
