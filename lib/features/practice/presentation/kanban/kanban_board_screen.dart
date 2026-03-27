import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_card_detail_sheet.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_column.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_providers.dart';

/// Full-screen kanban board for task and engagement management.
///
/// Displays horizontally scrollable columns with drag-and-drop cards,
/// a filter bar, and a FAB to add new cards.
class KanbanBoardScreen extends ConsumerStatefulWidget {
  const KanbanBoardScreen({super.key});

  @override
  ConsumerState<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends ConsumerState<KanbanBoardScreen> {
  // ---------------------------------------------------------------------------
  // Add new card
  // ---------------------------------------------------------------------------

  void _addCard({String? columnId}) {
    final columns = ref.read(kanbanColumnsProvider);
    final targetColumn = columnId ?? columns.first.id;
    final newId = 'kb-${DateTime.now().millisecondsSinceEpoch}';

    final assignees = ref.read(kanbanAssigneesProvider);
    final defaultAssignee = assignees.isNotEmpty ? assignees.first : '';
    final newCard = KanbanCardData(
      id: newId,
      title: 'New Task',
      description: '',
      assignee: defaultAssignee,
      priority: KanbanPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      clientName: 'Unassigned',
      columnId: targetColumn,
      tags: const [],
      subtasks: const [],
    );

    ref.read(kanbanCardsProvider.notifier).addCard(newCard);

    // Open detail sheet for immediate editing.
    showKanbanCardDetailSheet(context, ref, newCard);
  }

  // ---------------------------------------------------------------------------
  // Filter sheet
  // ---------------------------------------------------------------------------

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _FilterSheet(),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final columns = ref.watch(kanbanColumnsProvider);
    final groupedCards = ref.watch(filteredKanbanCardsProvider);
    final filter = ref.watch(kanbanFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kanban Board',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Drag cards between columns to update status',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Filter badge
          Stack(
            children: [
              IconButton(
                onPressed: _showFilterSheet,
                icon: const Icon(Icons.filter_list_rounded),
                tooltip: 'Filter',
              ),
              if (filter.isActive)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Active filter chips
            if (filter.isActive) _ActiveFilterChips(filter: filter, ref: ref),

            // Kanban columns
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columns.map((column) {
                    final cards = groupedCards[column.id] ?? [];
                    return SizedBox(
                      height: MediaQuery.of(context).size.height - 180,
                      child: KanbanColumnWidget(
                        column: column,
                        cards: cards,
                        onCardDropped: (card) {
                          ref
                              .read(kanbanCardsProvider.notifier)
                              .moveCard(card.id, column.id);
                        },
                        onCardTap: (card) {
                          showKanbanCardDetailSheet(context, ref, card);
                        },
                        onAddCard: () => _addCard(columnId: column.id),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCard,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Card'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active filter chips — shown when filters are active
// ---------------------------------------------------------------------------

class _ActiveFilterChips extends StatelessWidget {
  const _ActiveFilterChips({required this.filter, required this.ref});

  final KanbanFilter filter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          if (filter.assignee != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Chip(
                label: Text(filter.assignee!),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () =>
                    ref.read(kanbanFilterProvider.notifier).setAssignee(null),
                labelStyle: const TextStyle(fontSize: 12),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (filter.clientName != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Chip(
                label: Text(filter.clientName!),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () =>
                    ref.read(kanbanFilterProvider.notifier).setClient(null),
                labelStyle: const TextStyle(fontSize: 12),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (filter.priority != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Chip(
                label: Text(filter.priority!.label),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () =>
                    ref.read(kanbanFilterProvider.notifier).setPriority(null),
                labelStyle: const TextStyle(fontSize: 12),
                visualDensity: VisualDensity.compact,
              ),
            ),
          TextButton(
            onPressed: () => ref.read(kanbanFilterProvider.notifier).clear(),
            child: const Text('Clear all', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bottom sheet
// ---------------------------------------------------------------------------

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(kanbanFilterProvider);
    final assignees = ref.watch(kanbanAssigneesProvider);
    final clients = ref.watch(kanbanClientsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filter Cards',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(kanbanFilterProvider.notifier).clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Assignee
          Text(
            'Staff Member',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: filter.assignee == null,
                onSelected: (_) =>
                    ref.read(kanbanFilterProvider.notifier).setAssignee(null),
                selectedColor: AppColors.primary.withAlpha(30),
              ),
              ...assignees.map((name) {
                return ChoiceChip(
                  label: Text(name),
                  selected: filter.assignee == name,
                  onSelected: (_) =>
                      ref.read(kanbanFilterProvider.notifier).setAssignee(name),
                  selectedColor: AppColors.primary.withAlpha(30),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Client
          Text(
            'Client',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: filter.clientName == null,
                onSelected: (_) =>
                    ref.read(kanbanFilterProvider.notifier).setClient(null),
                selectedColor: AppColors.primary.withAlpha(30),
              ),
              ...clients.map((name) {
                return ChoiceChip(
                  label: Text(name),
                  selected: filter.clientName == name,
                  onSelected: (_) =>
                      ref.read(kanbanFilterProvider.notifier).setClient(name),
                  selectedColor: AppColors.primary.withAlpha(30),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Priority
          Text(
            'Priority',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: filter.priority == null,
                onSelected: (_) =>
                    ref.read(kanbanFilterProvider.notifier).setPriority(null),
                selectedColor: AppColors.primary.withAlpha(30),
              ),
              ...KanbanPriority.values.map((p) {
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(p.label),
                    ],
                  ),
                  selected: filter.priority == p,
                  onSelected: (_) =>
                      ref.read(kanbanFilterProvider.notifier).setPriority(p),
                  selectedColor: p.color.withAlpha(30),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Apply
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
