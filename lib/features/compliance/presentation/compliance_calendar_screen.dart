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
              ref
                  .read(complianceViewModeProvider.notifier)
                  .update(!isCalendarView);
            },
          ),
        ],
      ),
      body: isCalendarView ? const _CalendarView() : const _ListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDeadlineSheet(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showAddDeadlineSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    ComplianceCategory selectedCategory = ComplianceCategory.incomeTax;
    ComplianceFrequency selectedFrequency = ComplianceFrequency.annual;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Compliance Deadline',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g., GSTR-3B March 2026',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ComplianceCategory>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: ComplianceCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setSheetState(() => selectedCategory = v);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ComplianceFrequency>(
                initialValue: selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat_rounded),
                ),
                items: ComplianceFrequency.values
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.name[0].toUpperCase() +
                              f.name.substring(1)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setSheetState(() => selectedFrequency = v);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded),
                title: Text(
                  'Due: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                ),
                trailing: const Icon(Icons.edit_rounded, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setSheetState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    final deadline = ComplianceDeadline(
                      id: 'dl_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleController.text.trim(),
                      description: titleController.text.trim(),
                      category: selectedCategory,
                      dueDate: selectedDate,
                      applicableTo: const [],
                      isRecurring: selectedFrequency != ComplianceFrequency.annual,
                      frequency: selectedFrequency,
                      status: ComplianceStatus.upcoming,
                    );
                    ref
                        .read(allComplianceDeadlinesProvider.notifier)
                        .addDeadline(deadline);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deadline "${deadline.title}" added.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Add Deadline'),
                ),
              ),
            ],
          ),
        ),
      ),
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
    final deadlinesAsync = ref.watch(allComplianceDeadlinesProvider);
    final displayMonth = ref.watch(complianceDisplayMonthProvider);
    final deadlines = ref.watch(complianceMonthDeadlinesProvider);
    final dots = ref.watch(complianceCalendarDotsProvider);

    if (deadlinesAsync.isLoading && deadlines.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (deadlinesAsync.hasError && deadlines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Failed to load compliance data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(allComplianceDeadlinesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

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
                    final dl = deadlines[index];
                    return DeadlineTile(
                      deadline: dl,
                      onTap: () => _markComplete(context, ref, dl),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _markComplete(
    BuildContext context,
    WidgetRef ref,
    ComplianceDeadline deadline,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Completed?'),
        content: Text(
          'Mark "${deadline.title}" as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref
            .read(allComplianceDeadlinesProvider.notifier)
            .markCompleted(deadline);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${deadline.title}" marked as completed.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
}

// ---------------------------------------------------------------------------
// List View (all upcoming)
// ---------------------------------------------------------------------------

class _ListView extends ConsumerWidget {
  const _ListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlinesAsync = ref.watch(allComplianceDeadlinesProvider);
    final deadlines = ref.watch(upcomingDeadlinesProvider);
    final theme = Theme.of(context);

    if (deadlinesAsync.isLoading && deadlines.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (deadlinesAsync.hasError && deadlines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Failed to load compliance data',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(allComplianceDeadlinesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (deadlines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 80,
              color: AppColors.neutral200,
            ),
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
        final dl = deadlines[index];
        return DeadlineTile(
          deadline: dl,
          onTap: () => _markComplete(context, ref, dl),
        );
      },
    );
  }

  void _markComplete(
    BuildContext context,
    WidgetRef ref,
    ComplianceDeadline deadline,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Completed?'),
        content: Text('Mark "${deadline.title}" as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref
            .read(allComplianceDeadlinesProvider.notifier)
            .markCompleted(deadline);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${deadline.title}" marked as completed.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
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
              ref
                  .read(complianceMonthOffsetProvider.notifier)
                  .update(ref.read(complianceMonthOffsetProvider) - 1);
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
              ref
                  .read(complianceMonthOffsetProvider.notifier)
                  .update(ref.read(complianceMonthOffsetProvider) + 1);
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

    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    // Monday = 1, Sunday = 7; shift so Monday is column 0
    final startWeekday = firstDayOfMonth.weekday; // 1=Mon
    final daysInMonth = DateTime(
      displayMonth.year,
      displayMonth.month + 1,
      0,
    ).day;

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: dayLabels
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
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
                  displayMonth.year,
                  displayMonth.month,
                  dayNum,
                );
                final isToday = cellDate.isAtSameMomentAs(today);
                final dayDeadlines = dots[dayNum];

                return Expanded(
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary.withAlpha(26) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
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
                                .map(
                                  (d) => Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: d.category.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
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
            Icon(
              Icons.event_available_rounded,
              size: 64,
              color: AppColors.neutral200,
            ),
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
