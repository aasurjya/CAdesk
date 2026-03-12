import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice/data/providers/practice_providers.dart';
import 'package:ca_app/features/practice/presentation/widgets/assignment_tile.dart';

/// Screen listing client-staff assignments with filtering.
class AssignmentScreen extends ConsumerWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(assignmentFilterProvider);
    final assignments = ref.watch(filteredAssignmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assignments',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
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
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: AssignmentFilter.values.map((f) {
                  final isSelected = f == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(f)),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(assignmentFilterProvider.notifier).update(f);
                      },
                      selectedColor: AppColors.primary.withAlpha(30),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Assignment list
            Expanded(
              child: assignments.isEmpty
                  ? _EmptyFilterState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: assignments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return AssignmentTile(assignment: assignments[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssignSnackbar(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Assign Task'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
      ),
    );
  }

  static String _filterLabel(AssignmentFilter f) {
    switch (f) {
      case AssignmentFilter.all:
        return 'All';
      case AssignmentFilter.pending:
        return 'Pending';
      case AssignmentFilter.inProgress:
        return 'In Progress';
      case AssignmentFilter.completed:
        return 'Completed';
      case AssignmentFilter.overdue:
        return 'Overdue';
    }
  }

  void _showAssignSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task assignment form coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state for filtered results
// ---------------------------------------------------------------------------

class _EmptyFilterState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list_off_rounded,
            size: 48,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 12),
          Text(
            'No assignments match this filter',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
