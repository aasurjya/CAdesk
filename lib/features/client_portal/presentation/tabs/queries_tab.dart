import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/client_portal/domain/models/client_query.dart';
import 'package:ca_app/features/client_portal/data/providers/client_portal_providers.dart';
import 'package:ca_app/features/client_portal/presentation/widgets/query_tile.dart';

/// Tab displaying client queries/tickets with status filtering.
class QueriesTab extends ConsumerWidget {
  const QueriesTab({super.key});

  static const _filters = <QueryStatus?>[
    null,
    QueryStatus.open,
    QueryStatus.inProgress,
    QueryStatus.awaitingClient,
    QueryStatus.resolved,
    QueryStatus.closed,
  ];

  static const _filterLabels = <String>[
    'All',
    'Open',
    'In Progress',
    'Awaiting',
    'Resolved',
    'Closed',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queries = ref.watch(filteredQueriesProvider);
    final activeFilter = ref.watch(queryStatusFilterProvider);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _QueriesBanner(),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = activeFilter == filter;
              return FilterChip(
                label: Text(
                  _filterLabels[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.neutral600,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => ref
                    .read(queryStatusFilterProvider.notifier)
                    .update(isSelected ? null : filter),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.neutral50,
                checkmarkColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.neutral200,
                ),
              );
            },
          ),
        ),
        // Summary row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${queries.length} ${queries.length == 1 ? 'query' : 'queries'}',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.neutral400),
              ),
              const Spacer(),
              _OpenCountBadge(ref: ref),
            ],
          ),
        ),
        // Queries list
        Expanded(
          child: queries.isEmpty
              ? const _EmptyQueries()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: queries.length,
                  itemBuilder: (context, index) =>
                      QueryTile(query: queries[index]),
                ),
        ),
      ],
    );
  }
}

class _QueriesBanner extends StatelessWidget {
  const _QueriesBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha(18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.support_agent_outlined,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Query tracker',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monitor open client queries, pending responses, and support workload with clearer grouping.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenCountBadge extends StatelessWidget {
  const _OpenCountBadge({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final allQueries = ref.watch(allQueriesProvider);
    final openCount = allQueries.where((q) => q.isOpen).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$openCount open',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _EmptyQueries extends StatelessWidget {
  const _EmptyQueries();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              size: 36,
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No queries found',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}
