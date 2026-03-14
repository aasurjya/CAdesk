import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_export/domain/models/export_job.dart';

/// A list tile displaying a single [ExportJob] with its type, status
/// and progress information.
class ExportJobTile extends StatelessWidget {
  const ExportJobTile({
    super.key,
    required this.job,
    this.onTap,
    this.onDownload,
  });

  final ExportJob job;
  final VoidCallback? onTap;

  /// Called when the user taps the download icon on a completed job.
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _TypeIcon(type: job.exportType, status: job.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.exportType.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Client: ${job.clientId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral400,
                      ),
                    ),
                    if (job.status == ExportJobStatus.processing)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: LinearProgressIndicator(
                          backgroundColor: AppColors.neutral200,
                          color: AppColors.primary,
                          minHeight: 3,
                        ),
                      ),
                    if (job.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          job.errorMessage!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.error,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (job.status == ExportJobStatus.completed &&
                      job.filePath != null)
                    IconButton(
                      onPressed: onDownload,
                      icon: const Icon(
                        Icons.download_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      tooltip: 'Download',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    _StatusChip(status: job.status),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yy, HH:mm').format(job.createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type, required this.status});

  final ExportType type;
  final ExportJobStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ExportJobStatus.completed => AppColors.success,
      ExportJobStatus.processing => AppColors.primary,
      ExportJobStatus.failed => AppColors.error,
      ExportJobStatus.queued => AppColors.neutral400,
    };

    final icon = switch (type) {
      ExportType.itrXml => Icons.description_rounded,
      ExportType.gstrJson => Icons.receipt_long_rounded,
      ExportType.tdsFvu => Icons.account_balance_rounded,
      ExportType.form16Pdf => Icons.picture_as_pdf_rounded,
      ExportType.form16aPdf => Icons.picture_as_pdf_rounded,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ExportJobStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ExportJobStatus.completed => (AppColors.success, 'Done'),
      ExportJobStatus.processing => (AppColors.primary, 'Processing'),
      ExportJobStatus.failed => (AppColors.error, 'Failed'),
      ExportJobStatus.queued => (AppColors.neutral400, 'Queued'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
