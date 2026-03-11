import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/firm_operations/domain/models/staff_member.dart';
import 'package:ca_app/features/firm_operations/domain/models/knowledge_article.dart';
import 'package:ca_app/features/firm_operations/data/providers/firm_operations_providers.dart';
import 'package:ca_app/features/firm_operations/presentation/widgets/staff_card.dart';
import 'package:ca_app/features/firm_operations/presentation/widgets/kpi_summary_tile.dart';
import 'package:ca_app/features/firm_operations/presentation/widgets/article_tile.dart';

/// Main CA Firm Operations screen with tabs: Staff, KPIs, Knowledge Base.
class FirmOperationsScreen extends ConsumerWidget {
  const FirmOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Firm Operations'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Staff'),
              Tab(text: 'KPIs'),
              Tab(text: 'Knowledge Base'),
            ],
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.neutral400,
          ),
        ),
        body: const TabBarView(
          children: [_StaffTab(), _KpiTab(), _KnowledgeBaseTab()],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Staff tab
// ---------------------------------------------------------------------------

class _StaffTab extends ConsumerWidget {
  const _StaffTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(filteredStaffProvider);
    final selectedDesignation = ref.watch(staffDesignationFilterProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search staff by name, department, or email...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.neutral200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.neutral200),
              ),
            ),
            onChanged: (value) {
              ref.read(staffSearchQueryProvider.notifier).update(value);
            },
          ),
        ),
        // Designation filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _DesignationChip(
                label: 'All',
                isSelected: selectedDesignation == null,
                onTap: () {
                  ref
                      .read(staffDesignationFilterProvider.notifier)
                      .update(null);
                },
              ),
              ...StaffDesignation.values.map(
                (d) => _DesignationChip(
                  label: d.label,
                  isSelected: selectedDesignation == d,
                  onTap: () {
                    ref.read(staffDesignationFilterProvider.notifier).update(d);
                  },
                ),
              ),
            ],
          ),
        ),
        // Staff list
        Expanded(
          child: staff.isEmpty
              ? _buildEmptyState(
                  context,
                  Icons.people_outline,
                  'No staff found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: staff.length,
                  itemBuilder: (context, index) {
                    return StaffCard(staff: staff[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _DesignationChip extends StatelessWidget {
  const _DesignationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accent.withValues(alpha: 0.18),
        checkmarkColor: AppColors.accent,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.neutral600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// KPI tab
// ---------------------------------------------------------------------------

class _KpiTab extends ConsumerWidget {
  const _KpiTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(staffKpisProvider);

    if (kpis.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.bar_chart_outlined,
        'No KPI data available',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        return KpiSummaryTile(kpi: kpis[index]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Knowledge Base tab
// ---------------------------------------------------------------------------

class _KnowledgeBaseTab extends ConsumerWidget {
  const _KnowledgeBaseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(filteredArticlesProvider);
    final selectedCategory = ref.watch(articleCategoryFilterProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search articles, tags, or authors...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.neutral200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.neutral200),
              ),
            ),
            onChanged: (value) {
              ref.read(articleSearchQueryProvider.notifier).update(value);
            },
          ),
        ),
        // Category filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _CategoryChip(
                label: 'All',
                isSelected: selectedCategory == null,
                onTap: () {
                  ref.read(articleCategoryFilterProvider.notifier).update(null);
                },
              ),
              ...ArticleCategory.values.map(
                (c) => _CategoryChip(
                  label: c.label,
                  isSelected: selectedCategory == c,
                  onTap: () {
                    ref.read(articleCategoryFilterProvider.notifier).update(c);
                  },
                ),
              ),
            ],
          ),
        ),
        // Articles list
        Expanded(
          child: articles.isEmpty
              ? _buildEmptyState(
                  context,
                  Icons.article_outlined,
                  'No articles found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return ArticleTile(article: articles[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accent.withValues(alpha: 0.18),
        checkmarkColor: AppColors.accent,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.neutral600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared empty state
// ---------------------------------------------------------------------------

Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
  final theme = Theme.of(context);

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: AppColors.neutral200),
        const SizedBox(height: 16),
        Text(
          message,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    ),
  );
}
