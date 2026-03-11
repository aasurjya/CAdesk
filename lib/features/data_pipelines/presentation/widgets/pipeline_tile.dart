import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/data_pipeline.dart';

/// A card tile displaying a single data pipeline with source icon and status.
class PipelineTile extends StatelessWidget {
  const PipelineTile({super.key, required this.pipeline});

  final DataPipeline pipeline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM, HH:mm');

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
              // Top row: icon, name, status chip
              Row(
                children: [
                  _SourceIcon(sourceType: pipeline.sourceType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pipeline.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pipeline.sourceType.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: pipeline.status),
                ],
              ),
              const SizedBox(height: 10),

              // Bottom row: records, errors, last sync
              Row(
                children: [
                  _MetaItem(
                    icon: Icons.sync_rounded,
                    label: 'Records: ${pipeline.recordsProcessed}',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 16),
                  _MetaItem(
                    icon: Icons.error_outline_rounded,
                    label: 'Errors: ${pipeline.errorCount}',
                    color: pipeline.errorCount > 0
                        ? AppColors.error
                        : AppColors.neutral400,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(pipeline.lastSync),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),

              // Error message if present
              if (pipeline.errorMessage != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pipeline.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontSize: 11,
                          ),
                          maxLines: 1,
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

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _SourceIcon extends StatelessWidget {
  const _SourceIcon({required this.sourceType});

  final PipelineSourceType sourceType;

  IconData get _icon {
    switch (sourceType) {
      case PipelineSourceType.form16:
      case PipelineSourceType.form26as:
        return Icons.description_rounded;
      case PipelineSourceType.zerodha:
      case PipelineSourceType.groww:
      case PipelineSourceType.angelOne:
      case PipelineSourceType.karvy:
        return Icons.show_chart_rounded;
      case PipelineSourceType.cams:
      case PipelineSourceType.kfintech:
        return Icons.account_balance_wallet_rounded;
      case PipelineSourceType.tally:
      case PipelineSourceType.zohoBooks:
      case PipelineSourceType.quickbooks:
      case PipelineSourceType.sap:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_icon, size: 20, color: AppColors.primary),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PipelineStatus status;

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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
