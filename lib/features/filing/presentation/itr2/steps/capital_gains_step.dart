import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/domain/models/itr2/capital_gains_assets.dart';
import 'package:ca_app/features/filing/domain/models/itr2/schedule_cg.dart';
import 'package:ca_app/features/filing/presentation/itr2/widgets/cg_entry_cards.dart';

/// Capital gains step — the key ITR-2 differentiator (Schedule CG).
///
/// Sections:
/// - STCG on listed equity/MF (Section 111A @ 20%)
/// - LTCG on listed equity/MF (Section 112A @ 12.5% over 1.25L)
/// - STCG on other assets (slab rate)
/// - LTCG on property (Section 112 @ 20% with indexation)
/// - Summary: total STCG, LTCG, losses to carry forward
class CapitalGainsStep extends ConsumerStatefulWidget {
  const CapitalGainsStep({super.key});

  @override
  ConsumerState<CapitalGainsStep> createState() => _CapitalGainsStepState();
}

class _CapitalGainsStepState extends ConsumerState<CapitalGainsStep> {
  // -------------------------------------------------------------------------
  // Persist updated ScheduleCg to provider
  // -------------------------------------------------------------------------

  void _persistCg(ScheduleCg cg) {
    ref.read(itr2FormDataProvider.notifier).updateScheduleCg(cg);
  }

  // -------------------------------------------------------------------------
  // Add entry helpers
  // -------------------------------------------------------------------------

  void _addEquityStcg() {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final updated = cg.copyWith(
      equityStcgEntries: [
        ...cg.equityStcgEntries,
        const EquityStcgEntry(
          description: '',
          salePrice: 0,
          costOfAcquisition: 0,
          transferExpenses: 0,
        ),
      ],
    );
    _persistCg(updated);
  }

  void _addEquityLtcg() {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final updated = cg.copyWith(
      equityLtcgEntries: [
        ...cg.equityLtcgEntries,
        const EquityLtcgEntry(
          description: '',
          salePrice: 0,
          costOfAcquisition: 0,
          fmvOn31Jan2018: 0,
          transferExpenses: 0,
        ),
      ],
    );
    _persistCg(updated);
  }

  void _addOtherStcg() {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final updated = cg.copyWith(
      otherStcgEntries: [
        ...cg.otherStcgEntries,
        const OtherStcgEntry(
          description: '',
          salePrice: 0,
          costOfAcquisition: 0,
          transferExpenses: 0,
        ),
      ],
    );
    _persistCg(updated);
  }

  void _addPropertyLtcg() {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final updated = cg.copyWith(
      propertyLtcgEntries: [
        ...cg.propertyLtcgEntries,
        PropertyLtcgEntry(
          description: '',
          salePrice: 0,
          indexedCostOfAcquisition: 0,
          improvementCost: 0,
          transferExpenses: 0,
          acquisitionDate: DateTime(2015, 1, 1),
        ),
      ],
    );
    _persistCg(updated);
  }

  // -------------------------------------------------------------------------
  // Remove entry helpers
  // -------------------------------------------------------------------------

  void _removeEquityStcg(int index) {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final list = [...cg.equityStcgEntries]..removeAt(index);
    _persistCg(cg.copyWith(equityStcgEntries: list));
  }

  void _removeEquityLtcg(int index) {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final list = [...cg.equityLtcgEntries]..removeAt(index);
    _persistCg(cg.copyWith(equityLtcgEntries: list));
  }

  void _removeOtherStcg(int index) {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final list = [...cg.otherStcgEntries]..removeAt(index);
    _persistCg(cg.copyWith(otherStcgEntries: list));
  }

  void _removePropertyLtcg(int index) {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final list = [...cg.propertyLtcgEntries]..removeAt(index);
    _persistCg(cg.copyWith(propertyLtcgEntries: list));
  }

  // -------------------------------------------------------------------------
  // Update entry helpers
  // -------------------------------------------------------------------------

  void _updateEquityStcg(int index, EquityStcgEntry entry) {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final list = [...cg.equityStcgEntries]..[index] = entry;
    _persistCg(cg.copyWith(equityStcgEntries: list));
  }

  void _updateEquityLtcg(int index, EquityLtcgEntry entry) {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final list = [...cg.equityLtcgEntries]..[index] = entry;
    _persistCg(cg.copyWith(equityLtcgEntries: list));
  }

  void _updateOtherStcg(int index, OtherStcgEntry entry) {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final list = [...cg.otherStcgEntries]..[index] = entry;
    _persistCg(cg.copyWith(otherStcgEntries: list));
  }

  void _updatePropertyLtcg(int index, PropertyLtcgEntry entry) {
    final cg = ref.read(itr2FormDataProvider).scheduleCg;
    final list = [...cg.propertyLtcgEntries]..[index] = entry;
    _persistCg(cg.copyWith(propertyLtcgEntries: list));
  }

  // -------------------------------------------------------------------------
  // Section header
  // -------------------------------------------------------------------------

  Widget _sectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Summary row
  // -------------------------------------------------------------------------

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    final isNegative = value < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? AppColors.primary : AppColors.neutral600,
            ),
          ),
          Text(
            CurrencyUtils.formatINR(value),
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: isNegative ? AppColors.error : AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cg = ref.watch(itr2FormDataProvider).scheduleCg;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- STCG on Listed Equity (Section 111A) ---
          _sectionHeader(
            'STCG — Listed Equity / MF (Sec 111A)',
            'Tax rate: 20% flat',
          ),
          for (int i = 0; i < cg.equityStcgEntries.length; i++)
            EquityStcgCard(
              index: i,
              entry: cg.equityStcgEntries[i],
              onUpdate: (e) => _updateEquityStcg(i, e),
              onRemove: () => _removeEquityStcg(i),
            ),
          CgAddAssetButton(label: 'Add Equity STCG', onPressed: _addEquityStcg),

          // --- LTCG on Listed Equity (Section 112A) ---
          _sectionHeader(
            'LTCG — Listed Equity / MF (Sec 112A)',
            'Tax rate: 12.5% above \u20b91.25L exemption',
          ),
          for (int i = 0; i < cg.equityLtcgEntries.length; i++)
            EquityLtcgCard(
              index: i,
              entry: cg.equityLtcgEntries[i],
              onUpdate: (e) => _updateEquityLtcg(i, e),
              onRemove: () => _removeEquityLtcg(i),
            ),
          CgAddAssetButton(label: 'Add Equity LTCG', onPressed: _addEquityLtcg),

          // --- STCG on Other Assets ---
          _sectionHeader(
            'STCG — Other Assets',
            'Unlisted shares, jewellery, etc. Taxed at slab rates.',
          ),
          for (int i = 0; i < cg.otherStcgEntries.length; i++)
            OtherStcgCard(
              index: i,
              entry: cg.otherStcgEntries[i],
              onUpdate: (e) => _updateOtherStcg(i, e),
              onRemove: () => _removeOtherStcg(i),
            ),
          CgAddAssetButton(label: 'Add Other STCG', onPressed: _addOtherStcg),

          // --- LTCG on Property (Section 112) ---
          _sectionHeader(
            'LTCG — Immovable Property (Sec 112)',
            '20% with indexation (pre-23-Jul-2024) / 12.5% without',
          ),
          for (int i = 0; i < cg.propertyLtcgEntries.length; i++)
            PropertyLtcgCard(
              index: i,
              entry: cg.propertyLtcgEntries[i],
              onUpdate: (e) => _updatePropertyLtcg(i, e),
              onRemove: () => _removePropertyLtcg(i),
            ),
          CgAddAssetButton(
            label: 'Add Property LTCG',
            onPressed: _addPropertyLtcg,
          ),

          // --- Summary ---
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Capital Gains Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                  const Divider(height: 12),
                  _summaryRow('STCG (Sec 111A)', cg.totalStcg111A),
                  _summaryRow('STCG (Other)', cg.totalStcgOther),
                  _summaryRow('Total STCG', cg.netStcg, bold: true),
                  const Divider(height: 10),
                  _summaryRow('LTCG (Sec 112A)', cg.totalLtcg112A),
                  _summaryRow('LTCG (Property)', cg.totalLtcgOnProperty),
                  _summaryRow('LTCG (Other)', cg.totalLtcgOther),
                  _summaryRow('Total LTCG', cg.netLtcg, bold: true),
                  const Divider(height: 10),
                  _summaryRow(
                    'Net STCG (after set-off)',
                    cg.netStcgAfterSetOff,
                    bold: true,
                  ),
                  _summaryRow(
                    'Net LTCG (after set-off)',
                    cg.netLtcgAfterSetOff,
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
