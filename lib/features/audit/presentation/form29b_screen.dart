import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Form 29B screen for Section 115JB MAT computation.
/// Provides book profit fields, adjustments, and MAT calculation result.
class Form29bScreen extends ConsumerStatefulWidget {
  const Form29bScreen({super.key});

  @override
  ConsumerState<Form29bScreen> createState() => _Form29bScreenState();
}

class _Form29bScreenState extends ConsumerState<Form29bScreen> {
  // All amounts in paise internally, displayed as rupees
  int _netProfitPaise = 0;
  final List<_AdjustmentEntry> _additions = [
    const _AdjustmentEntry(
      description: 'Provision for income tax',
      amountPaise: 0,
    ),
    const _AdjustmentEntry(
      description: 'Net deferred tax liability',
      amountPaise: 0,
    ),
    const _AdjustmentEntry(
      description: 'Donations and charities',
      amountPaise: 0,
    ),
  ];
  final List<_AdjustmentEntry> _deductions = [
    const _AdjustmentEntry(description: 'Exempt capital gains', amountPaise: 0),
    const _AdjustmentEntry(
      description: 'Brought forward losses & depreciation',
      amountPaise: 0,
    ),
  ];

  int get _totalAdditions =>
      _additions.fold(0, (sum, e) => sum + e.amountPaise);
  int get _totalDeductions =>
      _deductions.fold(0, (sum, e) => sum + e.amountPaise);
  int get _bookProfit {
    final bp = _netProfitPaise + _totalAdditions - _totalDeductions;
    return bp < 0 ? 0 : bp;
  }

  int get _matLiability => (_bookProfit * 0.15).truncate();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          'Form 29B - MAT Computation',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoBanner(),
          const SizedBox(height: 16),

          // Net profit
          const _SectionLabel(label: 'Net Profit as per P&L'),
          const SizedBox(height: 8),
          _AmountField(
            label: 'Net Profit',
            onChanged: (paise) => setState(() => _netProfitPaise = paise),
          ),
          const SizedBox(height: 20),

          // Additions
          const _SectionLabel(label: 'Add-backs (Additions to Book Profit)'),
          const SizedBox(height: 8),
          ..._additions.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AmountField(
                label: entry.value.description,
                onChanged: (paise) => setState(
                  () => _additions[entry.key] = _AdjustmentEntry(
                    description: entry.value.description,
                    amountPaise: paise,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Deductions
          const _SectionLabel(label: 'Deductions from Book Profit'),
          const SizedBox(height: 8),
          ..._deductions.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AmountField(
                label: entry.value.description,
                onChanged: (paise) => setState(
                  () => _deductions[entry.key] = _AdjustmentEntry(
                    description: entry.value.description,
                    amountPaise: paise,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Result card
          _MatResultCard(
            bookProfitPaise: _bookProfit,
            matLiabilityPaise: _matLiability,
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _saveDraft(context),
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Draft'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Form 29B finalized'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Finalize'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _saveDraft(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal models and widgets
// ---------------------------------------------------------------------------

class _AdjustmentEntry {
  const _AdjustmentEntry({
    required this.description,
    required this.amountPaise,
  });

  final String description;
  final int amountPaise;
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'MAT = 15% of book profit per Sec 115JB. '
              'Credit can be carried forward for 15 years (Sec 115JAA).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.neutral900,
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.label, required this.onChanged});

  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        prefixText: '\u20B9 ',
      ),
      onChanged: (value) {
        final rupees = int.tryParse(value) ?? 0;
        onChanged(rupees * 100); // convert to paise
      },
    );
  }
}

class _MatResultCard extends StatelessWidget {
  const _MatResultCard({
    required this.bookProfitPaise,
    required this.matLiabilityPaise,
  });

  final int bookProfitPaise;
  final int matLiabilityPaise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.neutral50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MAT Computation Result',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            _ResultRow(
              label: 'Book Profit (Sec 115JB)',
              amountPaise: bookProfitPaise,
            ),
            const Divider(height: 16),
            _ResultRow(
              label: 'MAT Liability (15%)',
              amountPaise: matLiabilityPaise,
              highlight: true,
            ),
            const SizedBox(height: 8),
            _ResultRow(
              label: 'MAT Credit Available',
              amountPaise: matLiabilityPaise,
            ),
            const SizedBox(height: 4),
            Text(
              'Carry-forward: 15 years (Sec 115JAA)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.amountPaise,
    this.highlight = false,
  });

  final String label;
  final int amountPaise;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        Text(
          _formatPaise(amountPaise),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.primary : AppColors.neutral900,
          ),
        ),
      ],
    );
  }

  static String _formatPaise(int paise) {
    final rupees = paise ~/ 100;
    final remainder = paise % 100;
    // Indian number formatting
    final rupeesStr = _indianFormat(rupees);
    if (remainder == 0) return '\u20B9$rupeesStr';
    return '\u20B9$rupeesStr.${remainder.toString().padLeft(2, '0')}';
  }

  static String _indianFormat(int value) {
    if (value < 1000) return value.toString();
    final str = value.toString();
    final len = str.length;
    final buffer = StringBuffer();
    // Last 3 digits
    buffer.write(str.substring(len - 3));
    // Remaining in pairs from right
    var pos = len - 3;
    while (pos > 0) {
      final start = (pos - 2) < 0 ? 0 : pos - 2;
      buffer.write(',');
      buffer.write(str.substring(start, pos));
      pos = start;
    }
    // Reverse the segments
    final parts = buffer.toString().split(',').reversed;
    return parts.join(',');
  }
}
