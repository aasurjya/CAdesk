import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/idp/domain/models/extracted_field.dart';

/// ListTile widget that displays an [ExtractedField] with confidence badge,
/// review status, and optional corrected-value indicator.
class ExtractedFieldTile extends StatelessWidget {
  const ExtractedFieldTile({super.key, required this.field});

  final ExtractedField field;

  static Color _confidenceColor(double c) {
    if (c >= 0.90) return AppColors.success;
    if (c >= 0.70) return AppColors.warning;
    return AppColors.error;
  }

  static Color _confidenceBg(double c) {
    if (c >= 0.90) return AppColors.success.withAlpha(20);
    if (c >= 0.70) return AppColors.warning.withAlpha(25);
    return AppColors.error.withAlpha(20);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidenceColor = _confidenceColor(field.confidence);
    final confidenceBg = _confidenceBg(field.confidence);
    final percent = (field.confidence * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.fieldName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    field.extractedValue,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  if (field.correctedValue != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.edit_rounded,
                          size: 12,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          field.correctedValue!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ConfidenceBadge(
                  percent: percent,
                  color: confidenceColor,
                  bg: confidenceBg,
                ),
                if (field.needsReview) ...[
                  const SizedBox(height: 6),
                  _NeedsReviewChip(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({
    required this.percent,
    required this.color,
    required this.bg,
  });

  final int percent;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _NeedsReviewChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Needs Review',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.warning,
        ),
      ),
    );
  }
}
