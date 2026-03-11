import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/documents/domain/models/document.dart';

/// Colours associated with each file type.
Color _fileTypeColor(DocumentFileType type) {
  switch (type) {
    case DocumentFileType.pdf:
      return const Color(0xFFC62828); // red
    case DocumentFileType.excel:
      return const Color(0xFF1A7A3A); // green
    case DocumentFileType.word:
      return const Color(0xFF1565C0); // blue
    case DocumentFileType.image:
      return const Color(0xFF6A1B9A); // purple
    case DocumentFileType.zip:
      return const Color(0xFF4A5568); // neutral
  }
}

/// Icon associated with each file type.
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

/// List tile for a single [Document].
class DocumentTile extends StatelessWidget {
  const DocumentTile({super.key, required this.document});

  final Document document;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _fileTypeColor(document.fileType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _fileTypeIcon(document.fileType),
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (document.isSharedWithClient) ...[
                          const SizedBox(width: 6),
                          const Tooltip(
                            message: 'Shared with client',
                            child: Icon(
                              Icons.share_rounded,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Client name
                    Text(
                      document.clientName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Bottom row: category badge + meta
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Category badge
                        _CategoryBadge(category: document.category),

                        // File type label
                        _MetaChip(
                          label: document.fileType.label,
                          color: typeColor,
                        ),

                        // File size
                        Text(
                          document.fileSizeLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),

                        // Uploaded date
                        Text(
                          _dateFormat.format(document.uploadedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // More options
              IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.neutral400,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final DocumentCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
