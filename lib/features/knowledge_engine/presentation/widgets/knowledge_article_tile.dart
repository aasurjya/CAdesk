import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/knowledge_engine/domain/models/knowledge_article.dart';

/// A card tile displaying a single knowledge article with category and tags.
class KnowledgeArticleTile extends StatelessWidget {
  const KnowledgeArticleTile({super.key, required this.article});

  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _categoryColor(article.category);

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
              // Row 1: category icon + title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      article.category.icon,
                      size: 18,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                article.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (article.isPinned) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.push_pin_rounded,
                                size: 14,
                                color: AppColors.accent,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          article.category.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content summary
              Text(
                article.content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Tags row
              if (article.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: article.tags
                      .take(4)
                      .map((tag) => _TagChip(tag: tag))
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Footer: view count + last updated
              Row(
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${article.viewCount} views',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.update_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    article.timeAgo,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'by ${article.author}',
                    style: theme.textTheme.labelSmall?.copyWith(
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

  Color _categoryColor(KnowledgeCategory category) {
    return switch (category) {
      KnowledgeCategory.circulars => AppColors.primary,
      KnowledgeCategory.caselaw => AppColors.error,
      KnowledgeCategory.sop => AppColors.secondary,
      KnowledgeCategory.templates => AppColors.accent,
      KnowledgeCategory.precedents => AppColors.warning,
      KnowledgeCategory.faqs => AppColors.primaryVariant,
    };
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Text(
        tag,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutral600,
              fontSize: 10,
            ),
      ),
    );
  }
}
