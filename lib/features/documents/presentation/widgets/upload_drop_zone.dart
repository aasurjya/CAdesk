import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Reusable dashed-border drop zone for file upload.
///
/// Displays an icon, instructional text, and a file-count indicator after
/// selection. On desktop, provides visual drag-over feedback.
class UploadDropZone extends StatefulWidget {
  const UploadDropZone({
    super.key,
    required this.onTap,
    this.selectedCount = 0,
  });

  final VoidCallback onTap;
  final int selectedCount;

  @override
  State<UploadDropZone> createState() => _UploadDropZoneState();
}

class _UploadDropZoneState extends State<UploadDropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _isDragOver ? AppColors.primary : AppColors.neutral300;
    final bgColor = _isDragOver
        ? AppColors.primary.withAlpha(8)
        : AppColors.neutral50;

    return DragTarget<Object>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAcceptWithDetails: (_) {
        setState(() => _isDragOver = false);
        widget.onTap();
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Drop files here or tap to browse',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF, Excel, Word, Images, ZIP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                if (widget.selectedCount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.selectedCount} file${widget.selectedCount > 1 ? 's' : ''} selected',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
