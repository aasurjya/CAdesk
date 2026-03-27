import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/data/providers/global_search_providers.dart';
import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';

/// Opens the global search overlay as a full-screen dialog.
///
/// Call this from any screen to present the spotlight-style search UI.
void showGlobalSearchOverlay(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close search',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const GlobalSearchOverlay();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Full-screen spotlight search overlay.
///
/// Searches across modules, clients, deadlines, and filings with
/// 300ms debounce. Results are grouped by category with color-coded
/// badges. Tapping a result navigates and closes the overlay.
class GlobalSearchOverlay extends ConsumerStatefulWidget {
  const GlobalSearchOverlay({super.key});

  @override
  ConsumerState<GlobalSearchOverlay> createState() =>
      _GlobalSearchOverlayState();
}

class _GlobalSearchOverlayState extends ConsumerState<GlobalSearchOverlay> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _keyboardFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when overlay opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(globalSearchQueryProvider.notifier).update(value);
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(globalSearchQueryProvider.notifier).update('');
  }

  void _navigateToResult(SearchResult result) {
    // Reset query state before closing.
    ref.read(globalSearchQueryProvider.notifier).update('');
    Navigator.of(context).pop();
    if (result.route != null) {
      context.push(result.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(globalSearchQueryProvider);
    final results = ref.watch(globalSearchResultsProvider);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          ref.read(globalSearchQueryProvider.notifier).update('');
          Navigator.of(context).pop();
        }
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: mediaQuery.size.height * 0.08,
            left: AppSpacing.md,
            right: AppSpacing.md,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: mediaQuery.size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SearchField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onQueryChanged,
                    onClear: _clearSearch,
                  ),
                  const Divider(height: 1, color: AppColors.neutral200),
                  Flexible(
                    child: _SearchBody(
                      query: query,
                      results: results,
                      theme: theme,
                      onResultTap: _navigateToResult,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search field
// ---------------------------------------------------------------------------

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search clients, modules, deadlines...',
          hintStyle: const TextStyle(color: AppColors.neutral400),
          prefixIcon: const Icon(Icons.search, color: AppColors.neutral400),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                key: const Key('search_clear_button'),
                icon: const Icon(Icons.close, color: AppColors.neutral400),
                onPressed: onClear,
              );
            },
          ),
          filled: true,
          fillColor: AppColors.neutral50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search body (empty state / no results / grouped results)
// ---------------------------------------------------------------------------

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.query,
    required this.results,
    required this.theme,
    required this.onResultTap,
  });

  final String query;
  final GlobalSearchResults results;
  final ThemeData theme;
  final ValueChanged<SearchResult> onResultTap;

  @override
  Widget build(BuildContext context) {
    // Empty query: show placeholder.
    if (query.isEmpty) {
      return const _EmptyQueryHint();
    }

    // Query present but no matches.
    if (results.isEmpty) {
      return _NoResultsMessage(query: query);
    }

    // Grouped results list.
    return ListView(
      key: const Key('search_results_list'),
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      shrinkWrap: true,
      children: [
        if (results.modules.isNotEmpty)
          _ResultSection(
            title: 'Modules',
            results: results.modules,
            onTap: onResultTap,
          ),
        if (results.clients.isNotEmpty)
          _ResultSection(
            title: 'Clients',
            results: results.clients,
            onTap: onResultTap,
          ),
        if (results.deadlines.isNotEmpty)
          _ResultSection(
            title: 'Deadlines',
            results: results.deadlines,
            onTap: onResultTap,
          ),
        if (results.filings.isNotEmpty)
          _ResultSection(
            title: 'Filings',
            results: results.filings,
            onTap: onResultTap,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty-query placeholder
// ---------------------------------------------------------------------------

class _EmptyQueryHint extends StatelessWidget {
  const _EmptyQueryHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 48, color: AppColors.neutral300),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Search clients, modules, deadlines...',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// No-results message
// ---------------------------------------------------------------------------

class _NoResultsMessage extends StatelessWidget {
  const _NoResultsMessage({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.neutral300),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "No results for '$query'",
            key: const Key('no_results_text'),
            style: const TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result section (category header + tiles)
// ---------------------------------------------------------------------------

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.results,
    required this.onTap,
  });

  final String title;
  final List<SearchResult> results;
  final ValueChanged<SearchResult> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxs,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral400,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...results.map((r) => _ResultTile(result: r, onTap: () => onTap(r))),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual result tile
// ---------------------------------------------------------------------------

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.onTap});

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: result.category.color.withAlpha(26),
              child: Icon(result.icon, size: 18, color: result.category.color),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral900,
                    ),
                  ),
                  Text(
                    result.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _CategoryBadge(category: result.category),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category badge pill
// ---------------------------------------------------------------------------

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final SearchResultCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: category.color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: category.color,
        ),
      ),
    );
  }
}
