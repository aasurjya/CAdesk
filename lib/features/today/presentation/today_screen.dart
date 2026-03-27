import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/search_action.dart';
import 'package:ca_app/features/compliance/data/providers/compliance_providers.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/today/presentation/widgets/kanban_board.dart';
import 'package:ca_app/features/today/presentation/widgets/today_list_view.dart';

/// View mode for the Today screen.
enum TodayViewMode { list, board }

/// The "Today" tab screen — a daily digest of compliance obligations.
///
/// Groups deadlines into: Overdue, Due Today, This Week, and Later.
/// Supports both a flat list view and a kanban board view.
/// Provides a shortcut to the full Compliance Calendar.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  TodayViewMode _viewMode = TodayViewMode.list;

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == TodayViewMode.list
          ? TodayViewMode.board
          : TodayViewMode.list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allDeadlines =
        ref.watch(allComplianceDeadlinesProvider).asData?.value ?? [];
    final grouped = groupDeadlines(allDeadlines);
    final dateFormatter = DateFormat('d MMM yyyy');
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(
              dateFormatter.format(now),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('today_view_toggle'),
            icon: Icon(
              _viewMode == TodayViewMode.list
                  ? Icons.view_kanban_outlined
                  : Icons.view_agenda_outlined,
            ),
            tooltip: _viewMode == TodayViewMode.list
                ? 'Switch to board view'
                : 'Switch to list view',
            onPressed: _toggleViewMode,
          ),
          const SearchAction(),
        ],
      ),
      body: _viewMode == TodayViewMode.list
          ? TodayListView(grouped: grouped)
          : _TodayBoardView(grouped: grouped),
    );
  }
}

/// Groups deadlines into four buckets by due date.
GroupedDeadlines groupDeadlines(List<ComplianceDeadline> allDeadlines) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final endOfWeek = today.add(Duration(days: 7 - today.weekday));

  final overdue =
      allDeadlines
          .where(
            (d) =>
                d.computedStatus != ComplianceStatus.completed &&
                d.dueDate.isBefore(today),
          )
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  final dueToday =
      allDeadlines
          .where(
            (d) =>
                d.computedStatus != ComplianceStatus.completed &&
                d.dueDate.year == today.year &&
                d.dueDate.month == today.month &&
                d.dueDate.day == today.day,
          )
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  final thisWeek =
      allDeadlines
          .where(
            (d) =>
                d.computedStatus != ComplianceStatus.completed &&
                d.dueDate.isAfter(today) &&
                !d.dueDate.isAfter(endOfWeek),
          )
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  final later =
      allDeadlines
          .where(
            (d) =>
                d.computedStatus != ComplianceStatus.completed &&
                d.dueDate.isAfter(endOfWeek),
          )
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  return GroupedDeadlines(
    overdue: overdue,
    dueToday: dueToday,
    thisWeek: thisWeek,
    later: later,
  );
}

/// Immutable container for grouped deadline lists.
@immutable
class GroupedDeadlines {
  const GroupedDeadlines({
    required this.overdue,
    required this.dueToday,
    required this.thisWeek,
    required this.later,
  });

  final List<ComplianceDeadline> overdue;
  final List<ComplianceDeadline> dueToday;
  final List<ComplianceDeadline> thisWeek;
  final List<ComplianceDeadline> later;
}

// ---------------------------------------------------------------------------
// Board / kanban view
// ---------------------------------------------------------------------------

class _TodayBoardView extends StatelessWidget {
  const _TodayBoardView({required this.grouped});

  final GroupedDeadlines grouped;

  @override
  Widget build(BuildContext context) {
    final columns = [
      KanbanColumnData(
        title: 'Overdue',
        color: AppColors.error,
        deadlines: grouped.overdue,
      ),
      KanbanColumnData(
        title: 'Due Today',
        color: AppColors.accent,
        deadlines: grouped.dueToday,
      ),
      KanbanColumnData(
        title: 'This Week',
        color: AppColors.primaryVariant,
        deadlines: grouped.thisWeek,
      ),
      KanbanColumnData(
        title: 'Later',
        color: AppColors.neutral400,
        deadlines: grouped.later,
      ),
    ];

    return Column(
      children: [
        Expanded(child: KanbanBoard(columns: columns)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: OutlinedButton.icon(
            onPressed: () => context.push('/compliance'),
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('View Full Calendar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
