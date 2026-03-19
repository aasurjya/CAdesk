import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/today/presentation/widgets/kanban_card.dart';

/// Configuration for a single kanban column.
@immutable
class KanbanColumnData {
  const KanbanColumnData({
    required this.title,
    required this.color,
    required this.deadlines,
  });

  final String title;
  final Color color;
  final List<ComplianceDeadline> deadlines;
}

/// A horizontally scrollable kanban board with 4 deadline columns.
///
/// Columns: Overdue (red), Due Today (orange), This Week (blue), Later (grey).
/// Each column scrolls vertically and displays deadline cards.
class KanbanBoard extends StatelessWidget {
  const KanbanBoard({
    super.key,
    required this.columns,
    this.columnWidth = 280,
    this.onDeadlineTap,
  });

  /// The four column definitions (Overdue, Due Today, This Week, Later).
  final List<KanbanColumnData> columns;

  /// Width of each column. 280 on phone, can be overridden for tablet.
  final double columnWidth;

  /// Callback when a deadline card is tapped.
  final ValueChanged<ComplianceDeadline>? onDeadlineTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < columns.length; i++) ...[
            SizedBox(
              width: columnWidth,
              child: _KanbanColumn(
                data: columns[i],
                onDeadlineTap: onDeadlineTap,
              ),
            ),
            if (i < columns.length - 1) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({required this.data, this.onDeadlineTap});

  final KanbanColumnData data;
  final ValueChanged<ComplianceDeadline>? onDeadlineTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ColumnHeader(
          title: data.title,
          color: data.color,
          count: data.deadlines.length,
        ),
        const SizedBox(height: AppSpacing.xs),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: data.deadlines.isEmpty
                ? _EmptyColumn(color: data.color)
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.deadlines.length,
                    itemBuilder: (context, index) {
                      final deadline = data.deadlines[index];
                      return KanbanCard(
                        deadline: deadline,
                        onTap: onDeadlineTap != null
                            ? () => onDeadlineTap!(deadline)
                            : null,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({
    required this.title,
    required this.color,
    required this.count,
  });

  final String title;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyColumn extends StatelessWidget {
  const _EmptyColumn({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        'No items',
        style: TextStyle(fontSize: 12, color: color.withAlpha(128)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
