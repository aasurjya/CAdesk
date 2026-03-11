import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/compliance/data/providers/compliance_providers.dart';
import 'package:ca_app/features/compliance/presentation/widgets/deadline_tile.dart';

/// Full compliance calendar screen with month navigation,
/// calendar grid, and deadline list.
class ComplianceCalendarScreen extends ConsumerWidget {
  const ComplianceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCalendarView = ref.watch(complianceViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compliance',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isCalendarView
                  ? Icons.view_list_rounded
                  : Icons.calendar_month_rounded,
            ),
            tooltip: isCalendarView ? 'List View' : 'Calendar View',
            onPressed: () {
              ref.read(complianceViewModeProvider.notifier).update(
                  !isCalendarView);
            },
          ),
        ],
      ),
      body: isCalendarView
          ? const _CalendarView()
          : const _ListView(),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar View
// ---------------------------------------------------------------------------

class _CalendarView extends ConsumerWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayMonth = ref.watch(complianceDisplayMonthProvider);
    final deadlines = ref.watch(complianceMonthDeadlinesProvider);
    final dots = ref.watch(complianceCalendarDotsProvider);

    return Column(
      children: [
        // Month navigation
        _MonthNavigation(displayMonth: displayMonth, ref: ref),
        // Calendar grid
        _CalendarGrid(displayMonth: displayMonth, dots: dots),
        const Divider(height: 1),
        // Deadline list below calendar
        Expanded(
          child: deadlines.isEmpty
              ? _EmptyDeadlines(displayMonth: displayMonth)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: deadlines.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    return DeadlineTile(deadline: deadlines[index]);
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// List View (all upcoming)
// ---------------------------------------------------------------------------

class _ListView extends ConsumerWidget {
  const _ListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlines = ref.watch(upcomingDeadlinesProvider);
    final theme = Theme.of(context);

    if (deadlines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_rounded,
                size: 80, color: AppColors.neutral200),
            const SizedBox(height: 16),
            Text(
              'No upcoming deadlines',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: deadlines.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        return DeadlineTile(deadline: deadlines[index]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Month navigation bar
// ---------------------------------------------------------------------------

class _MonthNavigation extends StatelessWidget {
  const _MonthNavigation({required this.displayMonth, required this.ref});

  final DateTime displayMonth;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormat('MMMM yyyy').format(displayMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {
              ref.read(complianceMonthOffsetProvider.notifier).update(
                  ref.read(complianceMonthOffsetProvider) - 1);
            },
          ),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {
              ref.read(complianceMonthOffsetProvider.notifier).update(
                  ref.read(complianceMonthOffsetProvider) + 1);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar grid with deadline dots
// ---------------------------------------------------------------------------

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.displayMonth, required this.dots});

  final DateTime displayMonth;
  final Map<int, List<ComplianceDeadline>> dots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final firstDayOfMonth =
        DateTime(displayMonth.year, displayMonth.month, 1);
    // Monday = 1, Sunday = 7; shift so Monday is column 0
    final startWeekday = firstDayOfMonth.weekday; // 1=Mon
    final daysInMonth =
        DateTime(displayMonth.year, displayMonth.month + 1, 0).day;

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          // Day cells
          ...List.generate(_rowCount(startWeekday, daysInMonth), (rowIndex) {
            return Row(
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;
                final dayNum = cellIndex - (startWeekday - 1) + 1;

                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 44));
                }

                final cellDate = DateTime(
                    displayMonth.year, displayMonth.month, dayNum);
                final isToday = cellDate.isAtSameMomentAs(today);
                final dayDeadlines = dots[dayNum];

                return Expanded(
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withAlpha(26)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.neutral900,
                          ),
                        ),
                        if (dayDeadlines != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: dayDeadlines
                                .take(3)
                                .map((d) => Container(
                                      width: 5,
                                      height: 5,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: BoxDecoration(
                                        color: d.category.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  int _rowCount(int startWeekday, int daysInMonth) {
    final totalCells = (startWeekday - 1) + daysInMonth;
    return (totalCells / 7).ceil();
  }
}

// ---------------------------------------------------------------------------
// Empty state for a month with no deadlines
// ---------------------------------------------------------------------------

class _EmptyDeadlines extends StatelessWidget {
  const _EmptyDeadlines({required this.displayMonth});

  final DateTime displayMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = DateFormat('MMMM').format(displayMonth);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_rounded,
                size: 64, color: AppColors.neutral200),
            const SizedBox(height: 12),
            Text(
              'No deadlines in $monthName',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
