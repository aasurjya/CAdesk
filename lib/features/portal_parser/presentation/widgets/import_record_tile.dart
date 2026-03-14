import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_parser/domain/models/portal_import.dart';

/// A list tile displaying a single [PortalImport] record.
class ImportRecordTile extends StatelessWidget {
  const ImportRecordTile({super.key, required this.record, this.onTap});

  final PortalImport record;
  final VoidCallback? onTap;

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
              _StatusIcon(status: record.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.importType.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Client: ${record.clientId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral400,
                      ),
                    ),
                    if (record.parsedRecords != null)
                      Text(
                        '${record.parsedRecords} records parsed',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral400,
                        ),
                      ),
                    if (record.errorMessage != null)
                      Text(
                        record.errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusChip(status: record.status),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(record.importDate),
                    style: const TextStyle(
                      fontSize: 11,
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

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final ImportStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      ImportStatus.completed => (Icons.check_circle_rounded, AppColors.success),
      ImportStatus.parsing => (Icons.hourglass_top_rounded, AppColors.warning),
      ImportStatus.failed => (Icons.error_rounded, AppColors.error),
      ImportStatus.pending => (Icons.schedule_rounded, AppColors.neutral400),
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

  final ImportStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ImportStatus.completed => ('Completed', AppColors.success),
      ImportStatus.parsing => ('Parsing', AppColors.warning),
      ImportStatus.failed => ('Failed', AppColors.error),
      ImportStatus.pending => ('Pending', AppColors.neutral400),
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
