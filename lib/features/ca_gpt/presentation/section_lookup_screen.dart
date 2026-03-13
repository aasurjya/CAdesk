import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ca_gpt/data/providers/ca_gpt_providers.dart';
import 'package:ca_app/features/ca_gpt/domain/services/section_lookup_service.dart';
import 'package:ca_app/features/ca_gpt/presentation/widgets/section_result_card.dart';

/// Screen for looking up Indian tax law sections by keyword or section number.
class SectionLookupScreen extends ConsumerStatefulWidget {
  const SectionLookupScreen({super.key});

  @override
  ConsumerState<SectionLookupScreen> createState() =>
      _SectionLookupScreenState();
}

class _SectionLookupScreenState extends ConsumerState<SectionLookupScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const _quickSearches = ['194C', '80C', '10(10D)', '44AD', '139(1)'];

  @override
  void initState() {
    super.initState();
    // Pre-populate with the 5 required default sections.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaults();
    });
  }

  void _loadDefaults() {
    final results = _quickSearches
        .expand((q) => SectionLookupService.lookupSection(q))
        .toSet()
        .toList();
    ref.read(sectionSearchResultsProvider.notifier).update(results);
  }

  void _search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _loadDefaults();
      return;
    }
    final results = SectionLookupService.lookupSection(trimmed);
    ref.read(sectionSearchResultsProvider.notifier).update(results);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(sectionSearchResultsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchHeader(
          controller: _searchController,
          onSearch: _search,
          theme: theme,
        ),
        _QuickChips(
          searches: _quickSearches,
          onTap: (q) {
            _searchController.text = q;
            _search(q);
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            results.isEmpty
                ? 'No results found'
                : '${results.length} result${results.length == 1 ? '' : 's'}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? _NoResults()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: results.length,
                  itemBuilder: (context, index) =>
                      SectionResultCard(article: results[index]),
                ),
        ),
      ],
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.onSearch,
    required this.theme,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SearchBar(
        controller: controller,
        hintText: 'Search section number or keyword…',
        leading: const Icon(Icons.search, color: AppColors.neutral400),
        trailing: [
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                onSearch('');
              },
            ),
        ],
        onSubmitted: onSearch,
        onChanged: (value) {
          if (value.isEmpty) onSearch('');
        },
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: const WidgetStatePropertyAll(AppColors.neutral50),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.neutral200),
          ),
        ),
      ),
    );
  }
}

class _QuickChips extends StatelessWidget {
  const _QuickChips({required this.searches, required this.onTap});

  final List<String> searches;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: searches.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = searches[index];
          return ActionChip(
            label: Text('Sec $label'),
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            backgroundColor: AppColors.primary.withAlpha(20),
            side: const BorderSide(color: AppColors.neutral200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => onTap(label),
          );
        },
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.neutral300),
          const SizedBox(height: 12),
          Text(
            'No matching sections found',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}
