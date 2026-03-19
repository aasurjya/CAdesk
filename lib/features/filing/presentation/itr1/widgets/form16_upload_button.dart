import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/data/providers/form16_prefill_provider.dart';
import 'package:ca_app/features/filing/presentation/itr1/widgets/form16_picker_sheet.dart';
import 'package:ca_app/features/tds/domain/models/form16_data.dart';

/// "Import Form 16" button displayed at the top of the Personal Info step.
///
/// Offers two options:
/// 1. "Pick from TDS records" — opens the existing [Form16PickerSheet]
/// 2. "Upload PDF" — placeholder for Form 16 PDF parser (WU 2.3)
///
/// On selection, prefills all wizard steps via the [Itr1FormDataNotifier].
class Form16UploadButton extends ConsumerWidget {
  const Form16UploadButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.primary.withAlpha(15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.upload_file_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Import Form 16',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Auto-populate all wizard steps from Form 16 data.',
              style: TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFromTdsRecords(context, ref),
                    icon: const Icon(Icons.list_alt_rounded, size: 16),
                    label: const Text('TDS Records'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _uploadPdf(context),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: const Text('Upload PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromTdsRecords(BuildContext context, WidgetRef ref) async {
    final form16 = await showModalBottomSheet<Form16Data>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const Form16PickerSheet(),
    );
    if (form16 == null || !context.mounted) return;

    final prefill = prefillFromForm16Data(form16);
    _applyPrefill(context, ref, prefill);
  }

  Future<void> _uploadPdf(BuildContext context) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF upload coming soon — use TDS Records for now.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _applyPrefill(
    BuildContext context,
    WidgetRef ref,
    Form16PrefillResult prefill,
  ) {
    final notifier = ref.read(itr1FormDataProvider.notifier);

    // Always apply salary
    notifier.updateSalaryIncome(prefill.salaryIncome);

    // Apply deductions if available
    if (prefill.deductions != null) {
      notifier.updateDeductions(prefill.deductions!);
    }

    // Apply house property if available
    if (prefill.housePropertyIncome != null) {
      notifier.updateHouseProperty(prefill.housePropertyIncome!);
    }

    // Apply other sources if available
    if (prefill.otherSourceIncome != null) {
      notifier.updateOtherSources(prefill.otherSourceIncome!);
    }

    // Apply TDS payment summary if available
    if (prefill.tdsPaymentSummary != null) {
      notifier.updateTdsPaymentSummary(prefill.tdsPaymentSummary!);
    }

    // Apply tax regime if available
    if (prefill.selectedRegime != null) {
      notifier.updateRegime(prefill.selectedRegime!);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prefilled from ${prefill.source}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
