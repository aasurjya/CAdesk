import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/gst/data/providers/gstr3b_wizard_providers.dart';
import 'package:ca_app/features/gst/domain/models/gstr3b/gstr3b_itc_claimed.dart';

/// Step 2: ITC Claimed (Table 4) -- ITC available, reversal, net.
class Gstr3bItcStep extends ConsumerStatefulWidget {
  const Gstr3bItcStep({super.key});

  @override
  ConsumerState<Gstr3bItcStep> createState() => _Gstr3bItcStepState();
}

class _Gstr3bItcStepState extends ConsumerState<Gstr3bItcStep> {
  // 4(A)(1) Import of goods
  final _importGoodsIgst = TextEditingController();
  final _importGoodsCess = TextEditingController();

  // 4(A)(2) Import of services
  final _importServicesIgst = TextEditingController();
  final _importServicesCess = TextEditingController();

  // 4(A)(3) Inward RCM
  final _rcmIgst = TextEditingController();
  final _rcmCgst = TextEditingController();
  final _rcmSgst = TextEditingController();
  final _rcmCess = TextEditingController();

  // 4(A)(5) All other ITC
  final _otherIgst = TextEditingController();
  final _otherCgst = TextEditingController();
  final _otherSgst = TextEditingController();
  final _otherCess = TextEditingController();

  // 4(B)(1) Reversed - Section 17(5)
  final _rev17Igst = TextEditingController();
  final _rev17Cgst = TextEditingController();
  final _rev17Sgst = TextEditingController();
  final _rev17Cess = TextEditingController();

  // 4(B)(2) Reversed - Others
  final _revOtherIgst = TextEditingController();
  final _revOtherCgst = TextEditingController();
  final _revOtherSgst = TextEditingController();
  final _revOtherCess = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    for (final c in [
      _importGoodsIgst,
      _importGoodsCess,
      _importServicesIgst,
      _importServicesCess,
      _rcmIgst,
      _rcmCgst,
      _rcmSgst,
      _rcmCess,
      _otherIgst,
      _otherCgst,
      _otherSgst,
      _otherCess,
      _rev17Igst,
      _rev17Cgst,
      _rev17Sgst,
      _rev17Cess,
      _revOtherIgst,
      _revOtherCgst,
      _revOtherSgst,
      _revOtherCess,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmt(double v) => v == 0 ? '' : v.toStringAsFixed(2);
  double _p(TextEditingController c) => double.tryParse(c.text) ?? 0;

  void _initFromProvider() {
    final itc = ref.read(gstr3bFormDataProvider).itcClaimed;
    _importGoodsIgst.text = _fmt(itc.importGoods.igst);
    _importGoodsCess.text = _fmt(itc.importGoods.cess);
    _importServicesIgst.text = _fmt(itc.importServices.igst);
    _importServicesCess.text = _fmt(itc.importServices.cess);
    _rcmIgst.text = _fmt(itc.inwardRcm.igst);
    _rcmCgst.text = _fmt(itc.inwardRcm.cgst);
    _rcmSgst.text = _fmt(itc.inwardRcm.sgst);
    _rcmCess.text = _fmt(itc.inwardRcm.cess);
    _otherIgst.text = _fmt(itc.otherItc.igst);
    _otherCgst.text = _fmt(itc.otherItc.cgst);
    _otherSgst.text = _fmt(itc.otherItc.sgst);
    _otherCess.text = _fmt(itc.otherItc.cess);
    _rev17Igst.text = _fmt(itc.reversedSection17_5.igst);
    _rev17Cgst.text = _fmt(itc.reversedSection17_5.cgst);
    _rev17Sgst.text = _fmt(itc.reversedSection17_5.sgst);
    _rev17Cess.text = _fmt(itc.reversedSection17_5.cess);
    _revOtherIgst.text = _fmt(itc.reversedOthers.igst);
    _revOtherCgst.text = _fmt(itc.reversedOthers.cgst);
    _revOtherSgst.text = _fmt(itc.reversedOthers.sgst);
    _revOtherCess.text = _fmt(itc.reversedOthers.cess);
  }

  void _save() {
    const zero = ItcRow(igst: 0, cgst: 0, sgst: 0, cess: 0);

    final importGoods = ItcRow(
      igst: _p(_importGoodsIgst),
      cgst: 0,
      sgst: 0,
      cess: _p(_importGoodsCess),
    );
    final importServices = ItcRow(
      igst: _p(_importServicesIgst),
      cgst: 0,
      sgst: 0,
      cess: _p(_importServicesCess),
    );
    final rcm = ItcRow(
      igst: _p(_rcmIgst),
      cgst: _p(_rcmCgst),
      sgst: _p(_rcmSgst),
      cess: _p(_rcmCess),
    );
    final other = ItcRow(
      igst: _p(_otherIgst),
      cgst: _p(_otherCgst),
      sgst: _p(_otherSgst),
      cess: _p(_otherCess),
    );
    final rev17 = ItcRow(
      igst: _p(_rev17Igst),
      cgst: _p(_rev17Cgst),
      sgst: _p(_rev17Sgst),
      cess: _p(_rev17Cess),
    );
    final revOther = ItcRow(
      igst: _p(_revOtherIgst),
      cgst: _p(_revOtherCgst),
      sgst: _p(_revOtherSgst),
      cess: _p(_revOtherCess),
    );

    // Net = available - reversed
    final totalAvailIgst =
        importGoods.igst + importServices.igst + rcm.igst + other.igst;
    final totalAvailCgst = rcm.cgst + other.cgst;
    final totalAvailSgst = rcm.sgst + other.sgst;
    final totalAvailCess =
        importGoods.cess + importServices.cess + rcm.cess + other.cess;

    final net = ItcRow(
      igst: totalAvailIgst - rev17.igst - revOther.igst,
      cgst: totalAvailCgst - rev17.cgst - revOther.cgst,
      sgst: totalAvailSgst - rev17.sgst - revOther.sgst,
      cess: totalAvailCess - rev17.cess - revOther.cess,
    );

    final itc = Gstr3bItcClaimed(
      importGoods: importGoods,
      importServices: importServices,
      inwardRcm: rcm,
      isd: zero,
      otherItc: other,
      reversedSection17_5: rev17,
      reversedOthers: revOther,
      netItcAvailable: net,
      ineligibleRule38: zero,
      ineligibleOthers: zero,
    );

    ref.read(gstr3bFormDataProvider.notifier).updateItcClaimed(itc);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ITC details saved'),
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
    final itc = ref.watch(gstr3bFormDataProvider).itcClaimed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 4(A)(1) Import of goods
        _ItcSection(
          title: '4(A)(1) Import of Goods',
          children: [
            _TaxField(label: 'IGST', controller: _importGoodsIgst),
            _TaxField(label: 'Cess', controller: _importGoodsCess),
          ],
        ),
        const SizedBox(height: 12),

        // 4(A)(2) Import of services
        _ItcSection(
          title: '4(A)(2) Import of Services',
          children: [
            _TaxField(label: 'IGST', controller: _importServicesIgst),
            _TaxField(label: 'Cess', controller: _importServicesCess),
          ],
        ),
        const SizedBox(height: 12),

        // 4(A)(3) Inward RCM
        _ItcSection(
          title: '4(A)(3) Inward RCM',
          children: [
            _TaxField(label: 'IGST', controller: _rcmIgst),
            _TaxField(label: 'CGST', controller: _rcmCgst),
            _TaxField(label: 'SGST', controller: _rcmSgst),
            _TaxField(label: 'Cess', controller: _rcmCess),
          ],
        ),
        const SizedBox(height: 12),

        // 4(A)(5) All other ITC
        _ItcSection(
          title: '4(A)(5) All Other ITC',
          children: [
            _TaxField(label: 'IGST', controller: _otherIgst),
            _TaxField(label: 'CGST', controller: _otherCgst),
            _TaxField(label: 'SGST', controller: _otherSgst),
            _TaxField(label: 'Cess', controller: _otherCess),
          ],
        ),
        const SizedBox(height: 12),

        // 4(B)(1) Reversed
        _ItcSection(
          title: '4(B)(1) Reversed -- Section 17(5)',
          children: [
            _TaxField(label: 'IGST', controller: _rev17Igst),
            _TaxField(label: 'CGST', controller: _rev17Cgst),
            _TaxField(label: 'SGST', controller: _rev17Sgst),
            _TaxField(label: 'Cess', controller: _rev17Cess),
          ],
        ),
        const SizedBox(height: 12),

        // 4(B)(2) Reversed - Others
        _ItcSection(
          title: '4(B)(2) Reversed -- Others',
          children: [
            _TaxField(label: 'IGST', controller: _revOtherIgst),
            _TaxField(label: 'CGST', controller: _revOtherCgst),
            _TaxField(label: 'SGST', controller: _revOtherSgst),
            _TaxField(label: 'Cess', controller: _revOtherCess),
          ],
        ),
        const SizedBox(height: 16),

        // Net ITC summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Available ITC',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.neutral600,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatINR(itc.totalAvailableItc),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Reversed',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                  Text(
                    '- ${CurrencyUtils.formatINR(itc.totalReversedItc)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Net ITC Available',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.neutral900,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatINR(itc.netItcAvailable.totalItc),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2B reconciliation hint
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.sync_alt_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ITC amounts should match your GSTR-2B reconciliation.',
                    style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                  ),
                ),
              ],
            ),
          ),
        ),

        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Save ITC Details'),
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
// ITC Section card
// ---------------------------------------------------------------------------

class _ItcSection extends StatelessWidget {
  const _ItcSection({required this.title, required this.children});

  final String title;
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
              fontSize: 13,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tax input field
// ---------------------------------------------------------------------------

class _TaxField extends StatelessWidget {
  const _TaxField({required this.label, required this.controller});

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
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(),
                hintText: '0.00',
                hintStyle: TextStyle(color: AppColors.neutral300, fontSize: 13),
                prefixText: '\u20B9 ',
                prefixStyle: TextStyle(
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
