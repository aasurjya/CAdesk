import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/traces/domain/models/traces_request.dart';

/// Tile widget for displaying a single TRACES request.
///
/// Shows: request type, TAN, status, date.
class TracesRequestTile extends StatelessWidget {
  const TracesRequestTile({super.key, required this.request});

  final TracesRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _iconForType(request.type),
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _labelForType(request.type),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                _StatusBadge(status: request.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MetaItem(label: 'TAN', value: request.tan),
                const SizedBox(width: 16),
                _MetaItem(
                  label: 'FY',
                  value: 'FY ${request.financialYear - 1}-'
                      '${request.financialYear.toString().substring(2)}',
                ),
                const SizedBox(width: 16),
                _MetaItem(label: 'Q', value: 'Q${request.quarter}'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Requested: ${_formatDate(request.requestDate)}'
              '${request.completionDate != null ? '  |  Completed: ${_formatDate(request.completionDate!)}' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            if (request.panList.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${request.panList.length} PAN(s) included',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
            if (request.errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                request.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TracesRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      TracesRequestStatus.submitted => ('Submitted', AppColors.accent),
      TracesRequestStatus.processing => ('Processing', AppColors.primary),
      TracesRequestStatus.available => ('Available', AppColors.success),
      TracesRequestStatus.failed => ('Failed', AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

IconData _iconForType(TracesRequestType type) {
  return switch (type) {
    TracesRequestType.form16 => Icons.description_rounded,
    TracesRequestType.form16A => Icons.description_outlined,
    TracesRequestType.challanVerification => Icons.verified_rounded,
    TracesRequestType.tdsDefault => Icons.warning_amber_rounded,
    TracesRequestType.justificationReport => Icons.summarize_rounded,
  };
}

String _labelForType(TracesRequestType type) {
  return switch (type) {
    TracesRequestType.form16 => 'Form 16',
    TracesRequestType.form16A => 'Form 16A',
    TracesRequestType.challanVerification => 'Challan Verification',
    TracesRequestType.tdsDefault => 'TDS Default',
    TracesRequestType.justificationReport => 'Justification Report',
  };
}

String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
