import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr3b_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_exempt_supplies.dart';

/// Step 3: Exempt Supplies (Table 5) -- nil-rated, exempt, non-GST.
class Gstr3bExemptStep extends ConsumerStatefulWidget {
  const Gstr3bExemptStep({super.key});

  @override
  ConsumerState<Gstr3bExemptStep> createState() => _Gstr3bExemptStepState();
}

class _Gstr3bExemptStepState extends ConsumerState<Gstr3bExemptStep> {
  final _interExempt = TextEditingController();
  final _intraExempt = TextEditingController();
  final _interNilRated = TextEditingController();
  final _intraNilRated = TextEditingController();
  final _interNonGst = TextEditingController();
  final _intraNonGst = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _interExempt.dispose();
    _intraExempt.dispose();
    _interNilRated.dispose();
    _intraNilRated.dispose();
    _interNonGst.dispose();
    _intraNonGst.dispose();
    super.dispose();
  }

  String _fmt(double v) => v == 0 ? '' : v.toStringAsFixed(2);
  double _p(TextEditingController c) => double.tryParse(c.text) ?? 0;

  void _initFromProvider() {
    final exempt = ref.read(gstr3bFormDataProvider).exemptSupplies;
    _interExempt.text = _fmt(exempt.interStateExempt);
    _intraExempt.text = _fmt(exempt.intraStateExempt);
    _interNilRated.text = _fmt(exempt.interStateNilRated);
    _intraNilRated.text = _fmt(exempt.intraStateNilRated);
    _interNonGst.text = _fmt(exempt.interStateNonGst);
    _intraNonGst.text = _fmt(exempt.intraStateNonGst);
  }

  void _save() {
    final exempt = Gstr3bExemptSupplies(
      interStateExempt: _p(_interExempt),
      intraStateExempt: _p(_intraExempt),
      interStateNilRated: _p(_interNilRated),
      intraStateNilRated: _p(_intraNilRated),
      interStateNonGst: _p(_interNonGst),
      intraStateNonGst: _p(_intraNonGst),
    );
    ref.read(gstr3bFormDataProvider.notifier).updateExemptSupplies(exempt);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exempt supplies saved'),
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
    final exempt = ref.watch(gstr3bFormDataProvider).exemptSupplies;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Exempt
        _ExemptSection(
          title: 'Exempt Supplies',
          subtitle: 'Supplies exempt under GST law',
          icon: Icons.shield_rounded,
          children: [
            _AmountRow(label: 'Inter-State', controller: _interExempt),
            _AmountRow(label: 'Intra-State', controller: _intraExempt),
          ],
        ),
        const SizedBox(height: 12),

        // Nil-rated
        _ExemptSection(
          title: 'Nil-Rated Supplies',
          subtitle: 'GST rate = 0% (e.g. grains in bulk)',
          icon: Icons.do_not_disturb_on_rounded,
          children: [
            _AmountRow(label: 'Inter-State', controller: _interNilRated),
            _AmountRow(label: 'Intra-State', controller: _intraNilRated),
          ],
        ),
        const SizedBox(height: 12),

        // Non-GST
        _ExemptSection(
          title: 'Non-GST Supplies',
          subtitle: 'Petroleum, alcohol, etc.',
          icon: Icons.block_rounded,
          children: [
            _AmountRow(label: 'Inter-State', controller: _interNonGst),
            _AmountRow(label: 'Intra-State', controller: _intraNonGst),
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
          child: Column(
            children: [
              _SummaryRow(label: 'Total Exempt', value: exempt.totalExempt),
              _SummaryRow(
                label: 'Total Nil-Rated',
                value: exempt.totalNilRated,
              ),
              _SummaryRow(label: 'Total Non-GST', value: exempt.totalNonGst),
              const Divider(height: 16),
              _SummaryRow(
                label: 'Grand Total',
                value: exempt.grandTotal,
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Save Exempt Supplies'),
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
// Section card
// ---------------------------------------------------------------------------

class _ExemptSection extends StatelessWidget {
  const _ExemptSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Column(
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
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Amount input row
// ---------------------------------------------------------------------------

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final double value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            CurrencyUtils.formatINR(value),
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
