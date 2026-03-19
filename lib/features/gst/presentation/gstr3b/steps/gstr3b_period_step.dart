import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/gst/data/providers/gst_providers.dart';
import 'package:ca_app/features/gst/data/providers/gstr3b_wizard_providers.dart';

/// Step 0: Period & GSTIN selection for GSTR-3B.
class Gstr3bPeriodStep extends ConsumerWidget {
  const Gstr3bPeriodStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(gstr3bPeriodProvider);
    final selectedClientId = ref.watch(gstr3bSelectedClientProvider);
    final clients = ref.watch(gstClientsProvider);
    final periodLabel = DateFormat(
      'MMMM yyyy',
    ).format(DateTime(period.year, period.month));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Filing Period',
          icon: Icons.calendar_month_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                periodLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _pickPeriod(context, ref, period),
                icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                label: const Text('Change Period'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _SectionCard(
          title: 'Client / GSTIN',
          icon: Icons.business_rounded,
          child: DropdownButtonFormField<String>(
            initialValue: selectedClientId,
            decoration: const InputDecoration(
              labelText: 'Select Client',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_search_rounded),
            ),
            items: clients
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      '${c.businessName} (${c.gstin})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              ref.read(gstr3bSelectedClientProvider.notifier).select(val);
              if (val != null) {
                final client = clients.firstWhere((c) => c.id == val);
                ref
                    .read(gstr3bFormDataProvider.notifier)
                    .updateGstin(client.gstin);
                ref
                    .read(gstr3bFormDataProvider.notifier)
                    .updatePeriod(month: period.month, year: period.year);
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        _SectionCard(
          title: 'Return Type',
          icon: Icons.description_rounded,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'GSTR-3B',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Monthly summary return with tax payment',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutral600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickPeriod(
    BuildContext context,
    WidgetRef ref,
    ({int month, int year}) current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select filing period',
    );
    if (picked != null) {
      ref.read(gstr3bPeriodProvider.notifier).update((
        month: picked.month,
        year: picked.year,
      ));
      ref
          .read(gstr3bFormDataProvider.notifier)
          .updatePeriod(month: picked.month, year: picked.year);
    }
  }
}

// ---------------------------------------------------------------------------
// Section card
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
