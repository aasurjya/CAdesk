import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ca_gpt/domain/models/knowledge_article.dart';

/// Card displaying a single knowledge article / section search result.
class SectionResultCard extends StatelessWidget {
  const SectionResultCard({super.key, required this.article});

  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryChip(category: article.category),
                const Spacer(),
                if (article.isLatest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(26),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Latest',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              article.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              article.content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: article.sections
                  .map((s) => _SectionTag(label: s))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final KnowledgeCategory category;

  Color get _color {
    switch (category) {
      case KnowledgeCategory.incomeTax:
        return AppColors.primary;
      case KnowledgeCategory.gst:
        return AppColors.secondary;
      case KnowledgeCategory.tds:
        return AppColors.accent;
      case KnowledgeCategory.companiesAct:
        return const Color(0xFF6B46C1);
      case KnowledgeCategory.fema:
        return const Color(0xFFD4380D);
      case KnowledgeCategory.custom:
        return AppColors.neutral600;
    }
  }

  String get _label {
    switch (category) {
      case KnowledgeCategory.incomeTax:
        return 'Income Tax';
      case KnowledgeCategory.gst:
        return 'GST';
      case KnowledgeCategory.tds:
        return 'TDS';
      case KnowledgeCategory.companiesAct:
        return 'Companies Act';
      case KnowledgeCategory.fema:
        return 'FEMA';
      case KnowledgeCategory.custom:
        return 'Custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _SectionTag extends StatelessWidget {
  const _SectionTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Text(
        'Sec $label',
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.neutral600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
