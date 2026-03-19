import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_card.dart';
import 'package:ca_app/features/practice/presentation/kanban/kanban_providers.dart';

/// A single column in the kanban board.
///
/// Accepts [Draggable] cards via [DragTarget] and displays them in a
/// scrollable list. Fixed width of 280px, full available height.
class KanbanColumnWidget extends StatefulWidget {
  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.cards,
    required this.onCardDropped,
    required this.onCardTap,
    required this.onAddCard,
  });

  final KanbanColumn column;
  final List<KanbanCardData> cards;
  final void Function(KanbanCardData card) onCardDropped;
  final void Function(KanbanCardData card) onCardTap;
  final VoidCallback onAddCard;

  @override
  State<KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<KanbanColumnWidget> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DragTarget<KanbanCardData>(
      onWillAcceptWithDetails: (details) {
        // Accept cards from other columns only.
        final accepted = details.data.columnId != widget.column.id;
        if (accepted && !_isDragOver) {
          setState(() => _isDragOver = true);
        }
        return accepted;
      },
      onLeave: (_) {
        if (_isDragOver) {
          setState(() => _isDragOver = false);
        }
      },
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        widget.onCardDropped(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: _isDragOver
                ? widget.column.color.withAlpha(15)
                : AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDragOver
                  ? widget.column.color.withAlpha(120)
                  : AppColors.neutral200,
              width: _isDragOver ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Column header
              _ColumnHeader(
                theme: theme,
                column: widget.column,
                cardCount: widget.cards.length,
                onAdd: widget.onAddCard,
              ),

              // Divider
              Divider(height: 1, color: AppColors.neutral200),

              // Card list
              Expanded(
                child: widget.cards.isEmpty
                    ? _EmptyColumnHint(isDragOver: _isDragOver)
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: widget.cards.length,
                        itemBuilder: (context, index) {
                          final card = widget.cards[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: KanbanCard(
                              card: card,
                              onTap: () => widget.onCardTap(card),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Column header
// ---------------------------------------------------------------------------

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({
    required this.theme,
    required this.column,
    required this.cardCount,
    required this.onAdd,
  });

  final ThemeData theme;
  final KanbanColumn column;
  final int cardCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: column.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              column.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: column.color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$cardCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: column.color,
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              padding: EdgeInsets.zero,
              color: AppColors.neutral400,
              tooltip: 'Add card',
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty column hint
// ---------------------------------------------------------------------------

class _EmptyColumnHint extends StatelessWidget {
  const _EmptyColumnHint({required this.isDragOver});

  final bool isDragOver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDragOver
                  ? Icons.move_down_rounded
                  : Icons.drag_indicator_rounded,
              size: 32,
              color: isDragOver ? AppColors.primary : AppColors.neutral300,
            ),
            const SizedBox(height: 8),
            Text(
              isDragOver ? 'Drop here' : 'No cards',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDragOver ? AppColors.primary : AppColors.neutral400,
                fontWeight: isDragOver ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
