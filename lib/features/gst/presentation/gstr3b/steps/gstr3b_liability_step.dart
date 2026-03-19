import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr3b_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_tax_liability.dart';

/// Step 1: Tax Liability (Table 3.1) -- outward supplies breakdown.
class Gstr3bLiabilityStep extends ConsumerStatefulWidget {
  const Gstr3bLiabilityStep({super.key});

  @override
  ConsumerState<Gstr3bLiabilityStep> createState() =>
      _Gstr3bLiabilityStepState();
}

class _Gstr3bLiabilityStepState extends ConsumerState<Gstr3bLiabilityStep> {
  // 3.1(a) Outward taxable
  final _outwardIgstCtrl = TextEditingController();
  final _outwardCgstCtrl = TextEditingController();
  final _outwardSgstCtrl = TextEditingController();
  final _outwardCessCtrl = TextEditingController();

  // 3.1(b) Zero-rated
  final _zeroIgstCtrl = TextEditingController();
  final _zeroCessCtrl = TextEditingController();

  // 3.1(d) Inward RCM
  final _rcmIgstCtrl = TextEditingController();
  final _rcmCgstCtrl = TextEditingController();
  final _rcmSgstCtrl = TextEditingController();
  final _rcmCessCtrl = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _outwardIgstCtrl.dispose();
    _outwardCgstCtrl.dispose();
    _outwardSgstCtrl.dispose();
    _outwardCessCtrl.dispose();
    _zeroIgstCtrl.dispose();
    _zeroCessCtrl.dispose();
    _rcmIgstCtrl.dispose();
    _rcmCgstCtrl.dispose();
    _rcmSgstCtrl.dispose();
    _rcmCessCtrl.dispose();
    super.dispose();
  }

  void _initFromProvider() {
    final liability = ref.read(gstr3bFormDataProvider).taxLiability;
    _outwardIgstCtrl.text = _fmt(liability.outwardTaxable.igst);
    _outwardCgstCtrl.text = _fmt(liability.outwardTaxable.cgst);
    _outwardSgstCtrl.text = _fmt(liability.outwardTaxable.sgst);
    _outwardCessCtrl.text = _fmt(liability.outwardTaxable.cess);
    _zeroIgstCtrl.text = _fmt(liability.outwardZeroRated.igst);
    _zeroCessCtrl.text = _fmt(liability.outwardZeroRated.cess);
    _rcmIgstCtrl.text = _fmt(liability.inwardRcm.igst);
    _rcmCgstCtrl.text = _fmt(liability.inwardRcm.cgst);
    _rcmSgstCtrl.text = _fmt(liability.inwardRcm.sgst);
    _rcmCessCtrl.text = _fmt(liability.inwardRcm.cess);
  }

  String _fmt(double v) => v == 0 ? '' : v.toStringAsFixed(2);
  double _parse(TextEditingController c) => double.tryParse(c.text) ?? 0;

  void _save() {
    final zero = const Gstr3bTaxRow(igst: 0, cgst: 0, sgst: 0, cess: 0);
    final liability = Gstr3bTaxLiability(
      outwardTaxable: Gstr3bTaxRow(
        igst: _parse(_outwardIgstCtrl),
        cgst: _parse(_outwardCgstCtrl),
        sgst: _parse(_outwardSgstCtrl),
        cess: _parse(_outwardCessCtrl),
      ),
      outwardZeroRated: Gstr3bTaxRow(
        igst: _parse(_zeroIgstCtrl),
        cgst: 0,
        sgst: 0,
        cess: _parse(_zeroCessCtrl),
      ),
      otherOutward: zero,
      inwardRcm: Gstr3bTaxRow(
        igst: _parse(_rcmIgstCtrl),
        cgst: _parse(_rcmCgstCtrl),
        sgst: _parse(_rcmSgstCtrl),
        cess: _parse(_rcmCessCtrl),
      ),
      nonGstOutward: zero,
    );
    ref.read(gstr3bFormDataProvider.notifier).updateTaxLiability(liability);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tax liability saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initFromProvider();
      _initialized = true;
    }
    final liability = ref.watch(gstr3bFormDataProvider).taxLiability;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 3.1(a) Outward taxable
        _LiabilitySection(
          title: '3.1(a) Outward Taxable Supplies',
          subtitle: 'Other than zero-rated, nil-rated, exempt',
          children: [
            _TaxInputRow(label: 'IGST', controller: _outwardIgstCtrl),
            _TaxInputRow(label: 'CGST', controller: _outwardCgstCtrl),
            _TaxInputRow(label: 'SGST', controller: _outwardSgstCtrl),
            _TaxInputRow(label: 'Cess', controller: _outwardCessCtrl),
          ],
        ),
        const SizedBox(height: 12),

        // 3.1(b) Zero-rated
        _LiabilitySection(
          title: '3.1(b) Zero-Rated Supplies',
          subtitle: 'Exports + SEZ with IGST payment',
          children: [
            _TaxInputRow(label: 'IGST', controller: _zeroIgstCtrl),
            _TaxInputRow(label: 'Cess', controller: _zeroCessCtrl),
          ],
        ),
        const SizedBox(height: 12),

        // 3.1(d) Inward RCM
        _LiabilitySection(
          title: '3.1(d) Inward Supplies (RCM)',
          subtitle: 'Tax payable under reverse charge',
          children: [
            _TaxInputRow(label: 'IGST', controller: _rcmIgstCtrl),
            _TaxInputRow(label: 'CGST', controller: _rcmCgstCtrl),
            _TaxInputRow(label: 'SGST', controller: _rcmSgstCtrl),
            _TaxInputRow(label: 'Cess', controller: _rcmCessCtrl),
          ],
        ),
        const SizedBox(height: 16),

        // Total summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Tax Liability',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                CurrencyUtils.formatINR(liability.totalTaxLiability),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Save Liability'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Liability section card
// ---------------------------------------------------------------------------

class _LiabilitySection extends StatelessWidget {
  const _LiabilitySection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tax input row
// ---------------------------------------------------------------------------

class _TaxInputRow extends StatelessWidget {
  const _TaxInputRow({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral600,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: const OutlineInputBorder(),
                hintText: '0.00',
                hintStyle: TextStyle(color: AppColors.neutral300, fontSize: 13),
                prefixText: '\u20B9 ',
                prefixStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral600,
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
