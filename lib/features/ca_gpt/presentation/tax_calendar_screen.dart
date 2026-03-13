import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ca_gpt/data/providers/ca_gpt_providers.dart';
import 'package:ca_app/features/ca_gpt/domain/services/tax_calendar_service.dart';
import 'package:ca_app/features/ca_gpt/presentation/widgets/deadline_event_chip.dart';

/// Calendar view showing monthly tax compliance deadlines.
class TaxCalendarScreen extends ConsumerWidget {
  const TaxCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDeadlines = ref.watch(calendarEventsProvider);
    final selectedMonth = ref.watch(selectedCalendarMonthProvider);
    final theme = Theme.of(context);

    final deadlinesInMonth =
        allDeadlines
            .where(
              (d) =>
                  d.date.year == selectedMonth.year &&
                  d.date.month == selectedMonth.month,
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        _MonthNavigator(selectedMonth: selectedMonth, ref: ref, theme: theme),
        _CalendarGrid(
          month: selectedMonth,
          deadlines: allDeadlines,
          theme: theme,
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Text(
                'Deadlines this month',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              const Spacer(),
              Text(
                '${deadlinesInMonth.length} total',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: deadlinesInMonth.isEmpty
              ? _NoDeadlines()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: deadlinesInMonth.length,
                  itemBuilder: (context, index) =>
                      DeadlineListTile(deadline: deadlinesInMonth[index]),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Month header with prev/next navigation
// ---------------------------------------------------------------------------

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.selectedMonth,
    required this.ref,
    required this.theme,
  });

  final DateTime selectedMonth;
  final WidgetRef ref;
  final ThemeData theme;

  static const _months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void _prev() {
    final current = ref.read(selectedCalendarMonthProvider);
    ref
        .read(selectedCalendarMonthProvider.notifier)
        .update(
          DateTime(
            current.month == 1 ? current.year - 1 : current.year,
            current.month == 1 ? 12 : current.month - 1,
          ),
        );
  }

  void _next() {
    final current = ref.read(selectedCalendarMonthProvider);
    ref
        .read(selectedCalendarMonthProvider.notifier)
        .update(
          DateTime(
            current.month == 12 ? current.year + 1 : current.year,
            current.month == 12 ? 1 : current.month + 1,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _prev,
            color: AppColors.primary,
          ),
          Expanded(
            child: Text(
              '${_months[selectedMonth.month]} ${selectedMonth.year}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _next,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar grid
// ---------------------------------------------------------------------------

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.deadlines,
    required this.theme,
  });

  final DateTime month;
  final List<TaxDeadline> deadlines;
  final ThemeData theme;

  static const _dayHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    // Monday = 1, Sunday = 7 in DateTime weekday
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          // Day-of-week header row
          Row(
            children: _dayHeaders.map((d) {
              return Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          ...List.generate(rows, (row) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNumber = cellIndex - startOffset + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 52));
                }
                final dayDeadlines = deadlines
                    .where(
                      (d) =>
                          d.date.year == month.year &&
                          d.date.month == month.month &&
                          d.date.day == dayNumber,
                    )
                    .toList();

                return Expanded(
                  child: _DayCell(
                    day: dayNumber,
                    deadlines: dayDeadlines,
                    theme: theme,
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.deadlines,
    required this.theme,
  });

  final int day;
  final List<TaxDeadline> deadlines;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday =
        today.day == day &&
        today.month ==
            (ModalRoute.of(context)?.settings.arguments as DateTime?)?.month;

    return Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.all(3),
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        color: deadlines.isNotEmpty
            ? AppColors.primary.withAlpha(8)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: deadlines.isNotEmpty
            ? Border.all(color: AppColors.primary.withAlpha(40))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$day',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isToday ? AppColors.primary : AppColors.neutral600,
            ),
          ),
          ...deadlines.take(2).map((d) => DeadlineEventChip(deadline: d)),
          if (deadlines.length > 2)
            Text(
              '+${deadlines.length - 2}',
              style: const TextStyle(fontSize: 9, color: AppColors.neutral400),
            ),
        ],
      ),
    );
  }
}

class _NoDeadlines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_available,
            size: 48,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 12),
          Text(
            'No deadlines this month',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}
