import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../data/providers/cma_providers.dart';

/// Interactive EMI / Loan calculator bottom sheet with MPBF and DSCR sections.
class LoanCalculatorSheet extends StatefulWidget {
  const LoanCalculatorSheet({super.key});

  @override
  State<LoanCalculatorSheet> createState() => _LoanCalculatorSheetState();
}

class _LoanCalculatorSheetState extends State<LoanCalculatorSheet> {
  // --- Loan inputs ---
  final _amountCtrl = TextEditingController(text: '5000000');
  final _rateCtrl = TextEditingController(text: '9.5');
  double _tenureMonths = 60;

  // --- MPBF inputs ---
  final _currentAssetsCtrl = TextEditingController(text: '0');
  final _currentLiabCtrl = TextEditingController(text: '0');
  final _bankBorrowCtrl = TextEditingController(text: '0');

  // --- DSCR inputs ---
  final _ebitdaCtrl = TextEditingController(text: '0');

  // --- Amortization toggle ---
  bool _showAmortization = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _currentAssetsCtrl.dispose();
    _currentLiabCtrl.dispose();
    _bankBorrowCtrl.dispose();
    _ebitdaCtrl.dispose();
    super.dispose();
  }

  // --- Parsed values ---
  double get _principal => double.tryParse(_amountCtrl.text) ?? 0;
  double get _rate => double.tryParse(_rateCtrl.text) ?? 0;
  int get _tenure => _tenureMonths.round();
  double get _currentAssets => double.tryParse(_currentAssetsCtrl.text) ?? 0;
  double get _currentLiab => double.tryParse(_currentLiabCtrl.text) ?? 0;
  double get _bankBorrow => double.tryParse(_bankBorrowCtrl.text) ?? 0;
  double get _ebitda => double.tryParse(_ebitdaCtrl.text) ?? 0;

  // --- Computed values ---
  double get _monthlyEmi => CmaCalculator.emi(
    principal: _principal,
    annualRatePercent: _rate,
    tenureMonths: _tenure,
  );

  double get _totalInterestVal => CmaCalculator.totalInterest(
    principal: _principal,
    annualRatePercent: _rate,
    tenureMonths: _tenure,
  );

  double get _totalPayment => _monthlyEmi * _tenure;

  double get _mpbfVal => CmaCalculator.mpbf(
    currentAssets: _currentAssets,
    currentLiabilities: _currentLiab,
    existingBankBorrowings: _bankBorrow,
  );

  double get _dscrVal => CmaCalculator.dscr(
    ebitda: _ebitda,
    annualEmi: _monthlyEmi * 12,
    annualInterest: _principal * _rate / 100,
  );

  String get _dscrStatusLabel => CmaCalculator.dscrStatus(_dscrVal);

  Color get _dscrColor {
    if (_dscrVal >= 1.5) return AppColors.success;
    if (_dscrVal >= 1.25) return AppColors.warning;
    if (_dscrVal >= 1.0) return AppColors.accent;
    return AppColors.error;
  }

  List<AmortizationRow> get _schedule => CmaCalculator.amortizationSchedule(
    principal: _principal,
    annualRatePercent: _rate,
    tenureMonths: _tenure,
  );

  // --- Formatters ---
  String _formatInr(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)} Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(2)} L';
    return '₹${v.toStringAsFixed(0)}';
  }

  final _emiFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
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
                    _sheetTitle('Loan & EMI Calculator'),
                    const SizedBox(height: 20),
                    _buildLoanInputs(),
                    const SizedBox(height: 16),
                    _buildResultCard(),
                    const SizedBox(height: 16),
                    _buildRatioBar(),
                    const SizedBox(height: 20),
                    _SectionHeader(title: 'MPBF Calculator'),
                    const SizedBox(height: 12),
                    _buildMpbfInputs(),
                    const SizedBox(height: 12),
                    _buildMpbfResult(),
                    const SizedBox(height: 20),
                    _SectionHeader(title: 'DSCR Analysis'),
                    const SizedBox(height: 12),
                    _buildDscrInput(),
                    const SizedBox(height: 12),
                    _buildDscrResult(),
                    const SizedBox(height: 20),
                    _buildAmortizationToggle(),
                    if (_showAmortization) ...[
                      const SizedBox(height: 12),
                      _buildAmortizationTable(),
                    ],
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
  // Loan input widgets
  // ---------------------------------------------------------------------------

  Widget _buildLoanInputs() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _amountCtrl,
                label: 'Loan Amount',
                prefix: '₹',
                keyboard: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _rateCtrl,
                label: 'Rate',
                suffix: '%',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Tenure',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_tenure mo / ${(_tenure / 12).toStringAsFixed(1)} yr',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: _tenureMonths,
          min: 6,
          max: 240,
          divisions: 234,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.neutral200,
          label: '$_tenure months',
          onChanged: (v) => setState(() => _tenureMonths = v),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? suffix,
    required TextInputType keyboard,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
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
  // Result card
  // ---------------------------------------------------------------------------

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'Monthly EMI',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _emiFormat.format(_monthlyEmi),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ResultMetric(
                label: 'Total Interest',
                value: _formatInr(_totalInterestVal),
                color: const Color(0xFFFFCCCC),
              ),
              _ResultMetric(
                label: 'Total Payment',
                value: _formatInr(_totalPayment),
                color: Colors.white,
              ),
              _ResultMetric(
                label: 'Principal',
                value: _formatInr(_principal),
                color: const Color(0xFFCCE5FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Interest / Principal ratio bar
  // ---------------------------------------------------------------------------

  Widget _buildRatioBar() {
    final total = _principal + _totalInterestVal;
    final principalFraction = total > 0 ? _principal / total : 0.5;
    final interestFraction = 1.0 - principalFraction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Principal vs Interest Breakdown',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              Flexible(
                flex: (principalFraction * 1000).round(),
                child: Container(height: 16, color: AppColors.primary),
              ),
              Flexible(
                flex: (interestFraction * 1000).round(),
                child: Container(height: 16, color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _Legend(color: AppColors.primary, label: 'Principal'),
            const SizedBox(width: 16),
            _Legend(color: AppColors.error, label: 'Interest'),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MPBF section
  // ---------------------------------------------------------------------------

  Widget _buildMpbfInputs() {
    return Column(
      children: [
        _buildTextField(
          controller: _currentAssetsCtrl,
          label: 'Current Assets (₹)',
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _currentLiabCtrl,
                label: 'Current Liabilities (₹)',
                keyboard: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller: _bankBorrowCtrl,
                label: 'Existing Bank Borrowings (₹)',
                keyboard: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMpbfResult() {
    return _ResultTile(
      icon: Icons.account_balance_rounded,
      label: 'Maximum Permissible Bank Finance (MPBF)',
      value: _formatInr(_mpbfVal),
      subtitle: 'Tandon Committee Method II (75% of working capital gap)',
      color: AppColors.secondary,
    );
  }

  // ---------------------------------------------------------------------------
  // DSCR section
  // ---------------------------------------------------------------------------

  Widget _buildDscrInput() {
    return _buildTextField(
      controller: _ebitdaCtrl,
      label: 'Annual EBITDA (₹)',
      keyboard: TextInputType.number,
    );
  }

  Widget _buildDscrResult() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _dscrColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dscrColor.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: _dscrColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DSCR (Debt Service Coverage Ratio)',
                  style: TextStyle(fontSize: 12, color: AppColors.neutral400),
                ),
                Text(
                  _ebitda > 0 ? _dscrVal.toStringAsFixed(2) : '—',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _dscrColor,
                  ),
                ),
              ],
            ),
          ),
          if (_ebitda > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _dscrColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _dscrStatusLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Amortization table
  // ---------------------------------------------------------------------------

  Widget _buildAmortizationToggle() {
    return OutlinedButton.icon(
      onPressed: () => setState(() => _showAmortization = !_showAmortization),
      icon: Icon(
        _showAmortization
            ? Icons.keyboard_arrow_up_rounded
            : Icons.table_rows_rounded,
      ),
      label: Text(
        _showAmortization ? 'Hide Schedule' : 'View Amortization (first 12 mo)',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildAmortizationTable() {
    final rows = _schedule.take(12).toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    final inrFmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          AppColors.primary.withAlpha(15),
        ),
        columnSpacing: 16,
        headingTextStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 11,
          color: AppColors.neutral600,
        ),
        columns: const [
          DataColumn(label: Text('Mo')),
          DataColumn(label: Text('EMI'), numeric: true),
          DataColumn(label: Text('Principal'), numeric: true),
          DataColumn(label: Text('Interest'), numeric: true),
          DataColumn(label: Text('Balance'), numeric: true),
        ],
        rows: rows
            .map(
              (r) => DataRow(
                cells: [
                  DataCell(Text(r.month.toString())),
                  DataCell(Text(inrFmt.format(r.emi))),
                  DataCell(Text(inrFmt.format(r.principal))),
                  DataCell(Text(inrFmt.format(r.interest))),
                  DataCell(Text(inrFmt.format(r.balance))),
                ],
              ),
            )
            .toList(),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withAlpha(180)),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral400,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
