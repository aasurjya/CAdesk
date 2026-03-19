import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/documents/data/providers/document_viewer_providers.dart';

/// Displays a single OCR-extracted field with label, editable value,
/// confidence score badge, and source indicator.
class OcrFieldTile extends StatelessWidget {
  const OcrFieldTile({
    super.key,
    required this.field,
    required this.onValueChanged,
  });

  final OcrField field;
  final ValueChanged<String> onValueChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidenceColor = _confidenceColor(field.confidence);
    final confidencePercent = (field.confidence * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row with confidence badge
          Row(
            children: [
              Expanded(
                child: Text(
                  field.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: confidenceColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$confidencePercent%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: confidenceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Editable value
          TextFormField(
            initialValue: field.value,
            onChanged: onValueChanged,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.neutral900,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.neutral200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.neutral200),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Source indicator
          Text(
            'Source: ${field.source}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static Color _confidenceColor(double confidence) {
    if (confidence >= 0.9) return AppColors.success;
    if (confidence >= 0.7) return AppColors.warning;
    return AppColors.error;
  }
}
