import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';

/// Compact inline preview card for embedding a document reference in other
/// screens. Shows thumbnail/icon, file name, type badge, size, and OCR status.
class DocumentPreviewCard extends StatelessWidget {
  const DocumentPreviewCard({
    super.key,
    required this.document,
    this.isOcrProcessed = false,
  });

  final Document document;
  final bool isOcrProcessed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _fileTypeColor(document.fileType);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/documents/view/${document.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail / file type icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _fileTypeIcon(document.fileType),
                  color: typeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      document.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withAlpha(18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            document.fileType.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          document.fileSizeLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                        if (isOcrProcessed) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withAlpha(18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.document_scanner_rounded,
                                  size: 10,
                                  color: AppColors.secondary,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'OCR',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Quick preview arrow
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.neutral400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// File type helpers (duplicated locally to avoid coupling to document_tile)
// ---------------------------------------------------------------------------

Color _fileTypeColor(DocumentFileType type) {
  switch (type) {
    case DocumentFileType.pdf:
      return const Color(0xFFC62828);
    case DocumentFileType.excel:
      return const Color(0xFF1A7A3A);
    case DocumentFileType.word:
      return const Color(0xFF1565C0);
    case DocumentFileType.image:
      return const Color(0xFF6A1B9A);
    case DocumentFileType.zip:
      return const Color(0xFF4A5568);
  }
}

IconData _fileTypeIcon(DocumentFileType type) {
  switch (type) {
    case DocumentFileType.pdf:
      return Icons.picture_as_pdf_rounded;
    case DocumentFileType.excel:
      return Icons.table_chart_rounded;
    case DocumentFileType.word:
      return Icons.description_rounded;
    case DocumentFileType.image:
      return Icons.image_rounded;
    case DocumentFileType.zip:
      return Icons.folder_zip_rounded;
  }
}
