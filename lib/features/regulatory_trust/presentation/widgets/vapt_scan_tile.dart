import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/vapt_scan.dart';

/// A card tile displaying a single VAPT scan with finding counts and status.
class VaptScanTile extends StatelessWidget {
  const VaptScanTile({super.key, required this.scan});

  final VaptScan scan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: title and status chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      scan.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: scan.status),
                ],
              ),
              const SizedBox(height: 4),

              // Subtitle: scope or vendor
              if (scan.scope != null || scan.vendor != null) ...[
                Text(
                  scan.scope ?? scan.vendor!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
              ],

              // Finding counts row
              if (scan.totalFindings > 0 ||
                  scan.status == VaptScanStatus.completed ||
                  scan.status == VaptScanStatus.remediation) ...[
                Row(
                  children: [
                    _FindingBadge(
                      label: 'Critical',
                      count: scan.criticalFindings,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    _FindingBadge(
                      label: 'High',
                      count: scan.highFindings,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    _FindingBadge(
                      label: 'Med',
                      count: scan.mediumFindings,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    _FindingBadge(
                      label: 'Low',
                      count: scan.lowFindings,
                      color: AppColors.neutral400,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Bottom row: scan date, remediation deadline, vendor
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(scan.scanDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  if (scan.remediationDeadline != null) ...[
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 12,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Fix by: ${dateFormat.format(scan.remediationDeadline!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (scan.vendor != null && scan.scope != null) ...[
                    const Icon(
                      Icons.business_outlined,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scan.vendor!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final VaptScanStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.label),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: status.color,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      backgroundColor: status.color.withValues(alpha: 0.10),
      side: BorderSide(color: status.color.withValues(alpha: 0.3)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _FindingBadge extends StatelessWidget {
  const _FindingBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
