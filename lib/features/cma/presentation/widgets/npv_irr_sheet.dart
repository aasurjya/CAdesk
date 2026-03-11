import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../data/providers/cma_providers.dart';

/// NPV / IRR calculator bottom sheet for project viability analysis.
class NpvIrrSheet extends StatefulWidget {
  const NpvIrrSheet({super.key});

  @override
  State<NpvIrrSheet> createState() => _NpvIrrSheetState();
}

class _NpvIrrSheetState extends State<NpvIrrSheet> {
  final _investmentCtrl = TextEditingController(text: '10000000');
  final _discountRateCtrl = TextEditingController(text: '12');
  int _years = 5;

  // One controller per year — rebuilt when _years changes.
  late List<TextEditingController> _cashFlowCtrls;

  @override
  void initState() {
    super.initState();
    _cashFlowCtrls = _buildCashFlowCtrls(_years);
  }

  List<TextEditingController> _buildCashFlowCtrls(int count) {
    return List.generate(
      count,
      (i) => TextEditingController(
        text: _cashFlowCtrls.length > i ? _cashFlowCtrls[i].text : '3000000',
      ),
    );
  }

  void _setYears(int newYears) {
    final updated = <TextEditingController>[];
    for (int i = 0; i < newYears; i++) {
      if (i < _cashFlowCtrls.length) {
        updated.add(_cashFlowCtrls[i]);
      } else {
        updated.add(TextEditingController(text: '3000000'));
      }
    }
    // Dispose excess controllers.
    for (int i = newYears; i < _cashFlowCtrls.length; i++) {
      _cashFlowCtrls[i].dispose();
    }
    setState(() {
      _cashFlowCtrls = updated;
      _years = newYears;
    });
  }

  @override
  void dispose() {
    _investmentCtrl.dispose();
    _discountRateCtrl.dispose();
    for (final c in _cashFlowCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Parsed values ---
  double get _investment => double.tryParse(_investmentCtrl.text) ?? 0;
  double get _discountRate => double.tryParse(_discountRateCtrl.text) ?? 12;

  List<double> get _cashFlows =>
      _cashFlowCtrls.map((c) => double.tryParse(c.text) ?? 0).toList();

  // --- Computed ---
  double get _npvVal => CmaCalculator.npv(
    initialInvestment: _investment,
    annualCashFlows: _cashFlows,
    discountRatePercent: _discountRate,
  );

  double get _irrVal => _investment > 0
      ? CmaCalculator.irr(
          initialInvestment: _investment,
          annualCashFlows: _cashFlows,
        )
      : 0;

  double get _payback => CmaCalculator.paybackPeriod(
    initialInvestment: _investment,
    annualCashFlows: _cashFlows,
  );

  String get _verdict {
    if (_npvVal > 0 && _irrVal > _discountRate) return 'Viable';
    if (_npvVal >= 0) return 'Marginal';
    return 'Not Viable';
  }

  Color get _verdictColor {
    if (_verdict == 'Viable') return AppColors.success;
    if (_verdict == 'Marginal') return AppColors.warning;
    return AppColors.error;
  }

  Color get _npvColor => _npvVal >= 0 ? AppColors.success : AppColors.error;
  Color get _irrColor =>
      _irrVal >= _discountRate ? AppColors.success : AppColors.error;

  String _formatInr(double v) {
    final abs = v.abs();
    final prefix = v < 0 ? '-' : '';
    if (abs >= 10000000) {
      return '$prefix₹${(abs / 10000000).toStringAsFixed(2)} Cr';
    }
    if (abs >= 100000) return '$prefix₹${(abs / 100000).toStringAsFixed(2)} L';
    return '$prefix₹${abs.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _SheetHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    _sheetTitle('Project Viability (NPV / IRR)'),
                    const SizedBox(height: 20),
                    _buildTopInputs(),
                    const SizedBox(height: 16),
                    _buildYearSlider(),
                    const SizedBox(height: 16),
                    const _SectionLabel('Annual Cash Flows'),
                    const SizedBox(height: 10),
                    _buildCashFlowFields(),
                    const SizedBox(height: 20),
                    _buildResultsCard(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Input widgets
  // ---------------------------------------------------------------------------

  Widget _buildTopInputs() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildField(
            controller: _investmentCtrl,
            label: 'Initial Investment (₹)',
            keyboard: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildField(
            controller: _discountRateCtrl,
            label: 'Discount Rate',
            suffix: '%',
            keyboard: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  Widget _buildYearSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Projection Years:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_years years',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: _years.toDouble(),
          min: 2,
          max: 10,
          divisions: 8,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.neutral200,
          label: '$_years yr',
          onChanged: (v) => _setYears(v.round()),
        ),
      ],
    );
  }

  Widget _buildCashFlowFields() {
    return Column(
      children: List.generate(_years, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildField(
            controller: _cashFlowCtrls[i],
            label: 'Year ${i + 1} Cash Flow (₹)',
            keyboard: TextInputType.number,
          ),
        );
      }),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    required TextInputType keyboard,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  // ---------------------------------------------------------------------------
  // Results card
  // ---------------------------------------------------------------------------

  Widget _buildResultsCard() {
    final paybackText = _payback == double.infinity
        ? 'N/A'
        : '${_payback.toStringAsFixed(1)} yrs';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          // Verdict banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _verdictColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _verdict,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Metrics row
          Row(
            children: [
              _MetricBox(
                label: 'NPV',
                value: _formatInr(_npvVal),
                color: _npvColor,
                subtitle: _npvVal >= 0
                    ? 'Positive return'
                    : 'Value destructive',
              ),
              const SizedBox(width: 10),
              _MetricBox(
                label: 'IRR',
                value: '${_irrVal.toStringAsFixed(1)}%',
                color: _irrColor,
                subtitle: _irrVal >= _discountRate
                    ? '> Hurdle rate'
                    : '< Hurdle rate',
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Payback period
          _SingleMetric(
            label: 'Payback Period',
            value: paybackText,
            icon: Icons.timer_rounded,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _sheetTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.neutral900,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.color,
    required this.subtitle,
  });

  final String label;
  final String value;
  final Color color;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: color.withAlpha(180)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleMetric extends StatelessWidget {
  const _SingleMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.neutral600),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
