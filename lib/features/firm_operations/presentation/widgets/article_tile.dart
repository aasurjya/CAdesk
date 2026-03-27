import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/firm_operations/domain/models/knowledge_article.dart';

/// Displays a knowledge base article preview card.
class ArticleTile extends StatelessWidget {
  const ArticleTile({super.key, required this.article});

  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => _showArticleDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge and date
              Row(
                children: [
                  _CategoryBadge(category: article.category),
                  const Spacer(),
                  Text(
                    _formatDate(article.updatedAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                article.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Content preview
              Text(
                article.content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Tags and author
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: article.tags
                          .take(3)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutral200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.neutral600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    article.author,
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

  void _showArticleDetail(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CategoryBadge(category: article.category),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${article.author} | Updated ${_formatDate(article.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    article.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: article.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            labelStyle: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                            ),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.08,
                            ),
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Colored badge for article category.
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final ArticleCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _categoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _categoryColor(ArticleCategory category) {
    switch (category) {
      case ArticleCategory.sop:
        return AppColors.primary;
      case ArticleCategory.template:
        return AppColors.secondary;
      case ArticleCategory.guide:
        return AppColors.accent;
      case ArticleCategory.circular:
        return AppColors.warning;
      case ArticleCategory.notification:
        return AppColors.error;
    }
  }
}
