import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/filing/data/providers/form16_prefill_provider.dart';
import 'package:ca_app/features/tds/domain/models/form16_data.dart';

/// Bottom sheet that displays available Form 16 records for the user to pick.
///
/// Returns the selected [Form16Data] via `Navigator.pop` or `null` if
/// the user dismisses the sheet without selecting.
class Form16PickerSheet extends ConsumerStatefulWidget {
  const Form16PickerSheet({super.key});

  /// Shows the sheet and returns the selected [Form16Data], or null.
  static Future<Form16Data?> show(BuildContext context) {
    return showModalBottomSheet<Form16Data>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const Form16PickerSheet(),
    );
  }

  @override
  ConsumerState<Form16PickerSheet> createState() => _Form16PickerSheetState();
}

class _Form16PickerSheetState extends ConsumerState<Form16PickerSheet> {
  String? _selectedFy;

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(form16ListProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Derive unique assessment years for the filter dropdown.
    final assessmentYears = allRecords
        .map((r) => r.assessmentYear)
        .toSet()
        .toList()
      ..sort();

    // Filter records by selected AY if one is chosen.
    final filtered = _selectedFy == null
        ? allRecords
        : allRecords.where((r) => r.assessmentYear == _selectedFy).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Form 16',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // FY filter dropdown
              if (assessmentYears.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedFy,
                    decoration: const InputDecoration(
                      labelText: 'Assessment Year',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        child: Text('All Years'),
                      ),
                      ...assessmentYears.map(
                        (ay) => DropdownMenuItem(
                          value: ay,
                          child: Text(ay),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _selectedFy = value),
                  ),
                ),
              // Records list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No Form 16 records found.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final record = filtered[index];
                          return _Form16Tile(
                            record: record,
                            onTap: () => Navigator.of(context).pop(record),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Individual tile for a Form 16 record
// ---------------------------------------------------------------------------

class _Form16Tile extends StatelessWidget {
  const _Form16Tile({
    required this.record,
    required this.onTap,
  });

  final Form16Data record;
  final VoidCallback onTap;

  String _formatPeriod() {
    final from = record.periodFrom;
    final to = record.periodTo;
    return '${_monthYear(from)} - ${_monthYear(to)}';
  }

  static String _monthYear(DateTime dt) {
    const months = [
      '',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
      'Jan',
      'Feb',
      'Mar',
    ];
    final monthIndex = dt.month;
    final label =
        monthIndex <= 12 && monthIndex >= 1 ? months[monthIndex] : '?';
    return '$label ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.description_outlined,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        record.employeeName,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.employerName,
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'PAN: ${record.employeePan}  |  TAN: ${record.employerTan}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '${record.assessmentYear}  |  ${_formatPeriod()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
