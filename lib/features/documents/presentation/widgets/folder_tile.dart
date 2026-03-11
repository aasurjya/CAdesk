import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/documents/domain/models/document_folder.dart';

/// List tile for a [DocumentFolder].
class FolderTile extends StatelessWidget {
  const FolderTile({super.key, required this.folder});

  final DocumentFolder folder;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Folder icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.folderName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      folder.clientName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file_outlined,
                          size: 13,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${folder.documentCount} document${folder.documentCount == 1 ? '' : 's'}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _dateFormat.format(folder.lastModified),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.neutral400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
