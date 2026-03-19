import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

enum _LawFilter { itAct, gstAct, financeAct, cbdtCirculars }

extension _LawFilterExt on _LawFilter {
  String get label => switch (this) {
    _LawFilter.itAct => 'IT Act',
    _LawFilter.gstAct => 'GST Act',
    _LawFilter.financeAct => 'Finance Act',
    _LawFilter.cbdtCirculars => 'CBDT Circulars',
  };
  Color get color => switch (this) {
    _LawFilter.itAct => AppColors.primary,
    _LawFilter.gstAct => AppColors.secondary,
    _LawFilter.financeAct => const Color(0xFF7C3AED),
    _LawFilter.cbdtCirculars => AppColors.accent,
  };
}

class _SearchResult {
  const _SearchResult({
    required this.title,
    required this.source,
    required this.filter,
    required this.snippet,
    required this.relevance,
  });

  final String title;
  final String source;
  final _LawFilter filter;
  final String snippet;
  final double relevance;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockResults = <_SearchResult>[
  const _SearchResult(
    title: 'Section 80C - Deduction for investments',
    source: 'Income Tax Act, 1961',
    filter: _LawFilter.itAct,
    snippet:
        'In computing the total income of an assessee, there shall be deducted the whole of the amount paid or deposited in the previous year...',
    relevance: 0.98,
  ),
  const _SearchResult(
    title: 'Section 80CCD - NPS contribution',
    source: 'Income Tax Act, 1961',
    filter: _LawFilter.itAct,
    snippet:
        'Where an assessee has in the previous year paid or deposited any amount in his account under a pension scheme notified...',
    relevance: 0.92,
  ),
  const _SearchResult(
    title: 'Circular 04/2025 - Revised 80C limits',
    source: 'CBDT Circular',
    filter: _LawFilter.cbdtCirculars,
    snippet:
        'The Central Board of Direct Taxes clarifies that the aggregate deduction under section 80C for AY 2026-27 remains Rs. 1,50,000...',
    relevance: 0.88,
  ),
  const _SearchResult(
    title: 'Section 16 - Input Tax Credit',
    source: 'GST Act, 2017',
    filter: _LawFilter.gstAct,
    snippet:
        'Every registered person shall be entitled to take credit of input tax charged on any supply of goods or services...',
    relevance: 0.85,
  ),
  const _SearchResult(
    title: 'Finance Act 2025 - Amendment to 194C',
    source: 'Finance Act, 2025',
    filter: _LawFilter.financeAct,
    snippet:
        'The Finance Act 2025 has amended section 194C to raise the TDS threshold for contractor payments from Rs. 30,000 to Rs. 50,000...',
    relevance: 0.81,
  ),
];

final _mockRecentSearches = <String>[
  'Section 80C deductions',
  'GST input tax credit',
  'TDS on rent 194I',
  'Capital gains indexation',
  'Advance tax installments',
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Tax law knowledge search screen.
class KnowledgeSearchScreen extends ConsumerStatefulWidget {
  const KnowledgeSearchScreen({super.key});

  @override
  ConsumerState<KnowledgeSearchScreen> createState() =>
      _KnowledgeSearchScreenState();
}

class _KnowledgeSearchScreenState extends ConsumerState<KnowledgeSearchScreen> {
  var _query = '';
  var _activeFilters = <_LawFilter>{};
  var _bookmarks = <String>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter results based on query and active filters
    final results = _mockResults.where((r) {
      final matchesQuery =
          _query.isEmpty ||
          r.title.toLowerCase().contains(_query.toLowerCase()) ||
          r.snippet.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter =
          _activeFilters.isEmpty || _activeFilters.contains(r.filter);
      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(
          'Knowledge Search',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search sections, circulars, case laws...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.neutral200),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Filters
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _LawFilter.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _LawFilter.values[index];
                final isActive = _activeFilters.contains(filter);
                return FilterChip(
                  label: Text(filter.label),
                  selected: isActive,
                  onSelected: (_) {
                    setState(() {
                      _activeFilters = isActive
                          ? (Set<_LawFilter>.of(_activeFilters)..remove(filter))
                          : (Set<_LawFilter>.of(_activeFilters)..add(filter));
                    });
                  },
                  selectedColor: filter.color.withAlpha(30),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? filter.color : AppColors.neutral600,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: _query.isEmpty && _activeFilters.isEmpty
                ? _RecentSearches(
                    searches: _mockRecentSearches,
                    onTap: (s) => setState(() => _query = s),
                  )
                : results.isEmpty
                ? const EmptyState(
                    message: 'No results found',
                    subtitle: 'Try different keywords or filters',
                    icon: Icons.search_off_rounded,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: results.length,
                    itemBuilder: (context, index) => _ResultCard(
                      result: results[index],
                      isBookmarked: _bookmarks.contains(results[index].title),
                      onBookmark: () {
                        final title = results[index].title;
                        setState(() {
                          _bookmarks = _bookmarks.contains(title)
                              ? (Set<String>.of(_bookmarks)..remove(title))
                              : (Set<String>.of(_bookmarks)..add(title));
                        });
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result card
// ---------------------------------------------------------------------------

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.isBookmarked,
    required this.onBookmark,
  });

  final _SearchResult result;
  final bool isBookmarked;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    result.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 20,
                    color: isBookmarked
                        ? AppColors.accent
                        : AppColors.neutral400,
                  ),
                  onPressed: onBookmark,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Row(
              children: [
                StatusBadge(
                  label: result.filter.label,
                  color: result.filter.color,
                ),
                const SizedBox(width: 8),
                Text(
                  result.source,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(result.relevance * 100).round()}% match',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              result.snippet,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent searches
// ---------------------------------------------------------------------------

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({required this.searches, required this.onTap});

  final List<String> searches;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          ...searches.map(
            (s) => ListTile(
              dense: true,
              leading: const Icon(
                Icons.history_rounded,
                size: 18,
                color: AppColors.neutral400,
              ),
              title: Text(
                s,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              onTap: () => onTap(s),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
