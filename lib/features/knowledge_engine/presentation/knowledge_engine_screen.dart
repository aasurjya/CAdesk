import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/knowledge_engine_providers.dart';
import '../domain/models/knowledge_article.dart';
import '../domain/models/sop_document.dart';
import 'widgets/knowledge_article_tile.dart';

class KnowledgeEngineScreen extends ConsumerStatefulWidget {
  const KnowledgeEngineScreen({super.key});

  @override
  ConsumerState<KnowledgeEngineScreen> createState() =>
      _KnowledgeEngineScreenState();
}

class _KnowledgeEngineScreenState extends ConsumerState<KnowledgeEngineScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(knowledgeSummaryProvider);
    final totalArticles = (summary['totalArticles'] as int?) ?? 0;
    final circulars = (summary['circulars'] as int?) ?? 0;
    final sops = (summary['sops'] as int?) ?? 0;
    final templates = (summary['templates'] as int?) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Knowledge Engine'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Articles'),
            Tab(text: 'SOPs'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _SummaryCard(
                  label: 'Total Articles',
                  count: totalArticles,
                  icon: Icons.library_books_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Circulars',
                  count: circulars,
                  icon: Icons.announcement_rounded,
                  color: AppColors.primaryVariant,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'SOPs',
                  count: sops,
                  icon: Icons.checklist_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                _SummaryCard(
                  label: 'Templates',
                  count: templates,
                  icon: Icons.description_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_ArticlesTab(), _SopsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Articles tab
// ---------------------------------------------------------------------------

class _ArticlesTab extends ConsumerWidget {
  const _ArticlesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(filteredArticlesProvider);
    final selected = ref.watch(knowledgeCategoryFilterProvider);

    return Column(
      children: [
        // Category filter chips
        _CategoryFilterBar(
          selected: selected,
          onSelected: (cat) {
            ref
                .read(knowledgeCategoryFilterProvider.notifier)
                .update(cat == selected ? null : cat);
          },
        ),

        // Articles list
        Expanded(
          child: articles.isEmpty
              ? const _EmptyState(message: 'No articles in this category')
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 80),
                  itemCount: articles.length,
                  itemBuilder: (context, index) =>
                      KnowledgeArticleTile(article: articles[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SOPs tab
// ---------------------------------------------------------------------------

class _SopsTab extends ConsumerWidget {
  const _SopsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sops = ref.watch(allSopDocumentsProvider);

    return sops.isEmpty
        ? const _EmptyState(message: 'No SOPs found')
        : ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: sops.length,
            itemBuilder: (context, index) => _SopDocumentTile(sop: sops[index]),
          );
  }
}

class _SopDocumentTile extends StatelessWidget {
  const _SopDocumentTile({required this.sop});

  final SopDocument sop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              // Row 1: title + version + active badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sop.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _VersionChip(version: sop.version),
                  if (sop.isActive) ...[
                    const SizedBox(width: 6),
                    _ActiveChip(),
                  ],
                ],
              ),
              const SizedBox(height: 4),

              // Module tag
              Row(
                children: [
                  Icon(
                    Icons.folder_rounded,
                    size: 12,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sop.module,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.update_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reviewed: '
                    '${sop.lastReviewedAt.day}/'
                    '${sop.lastReviewedAt.month}/'
                    '${sop.lastReviewedAt.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Steps preview
              Text(
                '${sop.steps.length} steps',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(height: 4),
              ...sop.steps
                  .take(3)
                  .toList()
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key + 1}.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral400,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral600,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (sop.steps.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '+ ${sop.steps.length - 3} more steps',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionChip extends StatelessWidget {
  const _VersionChip({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Text(
        version,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.neutral600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Active',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category filter bar
// ---------------------------------------------------------------------------

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.selected, required this.onSelected});

  final KnowledgeCategory? selected;
  final ValueChanged<KnowledgeCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = KnowledgeCategory.values;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = cat == selected;
          const color = AppColors.primary;

          return FilterChip(
            label: Text(cat.label),
            selected: isActive,
            onSelected: (_) => onSelected(cat),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : color,
            ),
            selectedColor: color,
            backgroundColor: color.withValues(alpha: 0.08),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 48,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
