import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9');

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

enum ResidentialStatus {
  resident('Resident', AppColors.success),
  nri('Non-Resident (NRI)', AppColors.primary),
  rnor('RNOR', AppColors.warning);

  const ResidentialStatus(this.label, this.color);
  final String label;
  final Color color;
}

class _DaysInIndia {
  const _DaysInIndia({required this.fy, required this.days});

  final String fy;
  final int days;
}

class _IncomeItem {
  const _IncomeItem({
    required this.source,
    required this.category,
    required this.amount,
    required this.isTaxable,
  });

  final String source;
  final String category;
  final double amount;
  final bool isTaxable;
}

class _DtaaDetail {
  const _DtaaDetail({
    required this.country,
    required this.articleRef,
    required this.rate,
    required this.isApplicable,
  });

  final String country;
  final String articleRef;
  final double rate;
  final bool isApplicable;
}

class _MockNriTax {
  const _MockNriTax({
    required this.clientName,
    required this.pan,
    required this.passportNo,
    required this.countryOfResidence,
    required this.assessmentYear,
    required this.residentialStatus,
    required this.daysHistory,
    required this.incomeItems,
    required this.dtaaDetails,
    required this.hasTrc,
    required this.hasForm10f,
    required this.section90Relief,
    required this.section91Relief,
  });

  final String clientName;
  final String pan;
  final String passportNo;
  final String countryOfResidence;
  final String assessmentYear;
  final ResidentialStatus residentialStatus;
  final List<_DaysInIndia> daysHistory;
  final List<_IncomeItem> incomeItems;
  final List<_DtaaDetail> dtaaDetails;
  final bool hasTrc;
  final bool hasForm10f;
  final double section90Relief;
  final double section91Relief;

  double get totalTaxableIncome =>
      incomeItems.where((i) => i.isTaxable).fold(0.0, (s, i) => s + i.amount);
  int get currentYearDays =>
      daysHistory.isNotEmpty ? daysHistory.first.days : 0;
}

final _mockData = _MockNriTax(
  clientName: 'Rajiv Kapoor',
  pan: 'ABCPK5678L',
  passportNo: 'Z1234567',
  countryOfResidence: 'United States',
  assessmentYear: 'AY 2026-27',
  residentialStatus: ResidentialStatus.nri,
  daysHistory: const [
    _DaysInIndia(fy: 'FY 2025-26', days: 95),
    _DaysInIndia(fy: 'FY 2024-25', days: 110),
    _DaysInIndia(fy: 'FY 2023-24', days: 45),
    _DaysInIndia(fy: 'FY 2022-23', days: 80),
  ],
  incomeItems: const [
    _IncomeItem(
      source: 'House Property — Mumbai flat',
      category: 'India-sourced',
      amount: 960000,
      isTaxable: true,
    ),
    _IncomeItem(
      source: 'FD Interest — SBI',
      category: 'India-sourced',
      amount: 340000,
      isTaxable: true,
    ),
    _IncomeItem(
      source: 'Capital Gains — MF',
      category: 'India-sourced',
      amount: 520000,
      isTaxable: true,
    ),
    _IncomeItem(
      source: 'US Salary Income',
      category: 'Foreign',
      amount: 8500000,
      isTaxable: false,
    ),
  ],
  dtaaDetails: const [
    _DtaaDetail(
      country: 'United States',
      articleRef: 'Article 10 — Dividends',
      rate: 15,
      isApplicable: true,
    ),
    _DtaaDetail(
      country: 'United States',
      articleRef: 'Article 11 — Interest',
      rate: 15,
      isApplicable: true,
    ),
    _DtaaDetail(
      country: 'United States',
      articleRef: 'Article 13 — Capital Gains',
      rate: 0,
      isApplicable: false,
    ),
  ],
  hasTrc: true,
  hasForm10f: false,
  section90Relief: 125000,
  section91Relief: 0,
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// NRI tax computation detail with residential status and DTAA benefits.
///
/// Route: `/nri-tax/computation/:clientId`
class NriComputationScreen extends ConsumerWidget {
  const NriComputationScreen({required this.clientId, super.key});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = _mockData;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'NRI Tax — ${data.clientName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResidentialStatusCard(data: data),
            const SizedBox(height: 16),
            _DaysInIndiaCard(days: data.daysHistory),
            const SizedBox(height: 16),
            _IncomeCard(items: data.incomeItems),
            const SizedBox(height: 16),
            _DtaaCard(details: data.dtaaDetails),
            const SizedBox(height: 16),
            _TrcForm10fCard(data: data),
            const SizedBox(height: 16),
            _ReliefComputationCard(data: data),
            const SizedBox(height: 24),
            _ActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Residential status
// ---------------------------------------------------------------------------

class _ResidentialStatusCard extends StatelessWidget {
  const _ResidentialStatusCard({required this.data});

  final _MockNriTax data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: data.residentialStatus.color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: data.residentialStatus.color.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flight_takeoff_rounded,
                  size: 24,
                  color: data.residentialStatus.color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.clientName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${data.pan} | ${data.assessmentYear}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: data.residentialStatus.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data.residentialStatus.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: data.residentialStatus.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Passport', value: data.passportNo),
            _DetailRow(label: 'Country', value: data.countryOfResidence),
            _DetailRow(
              label: 'Days in India',
              value: '${data.currentYearDays} days (current FY)',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Days in India calculator
// ---------------------------------------------------------------------------

class _DaysInIndiaCard extends StatelessWidget {
  const _DaysInIndiaCard({required this.days});

  final List<_DaysInIndia> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Days in India — History',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'NRI if < 182 days in India. RNOR if additional conditions met.',
              style: TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
            const SizedBox(height: 12),
            ...days.map((d) {
              final isOver = d.days >= 182;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        d.fy,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: d.days / 365,
                        backgroundColor: AppColors.neutral200,
                        valueColor: AlwaysStoppedAnimation(
                          isOver ? AppColors.error : AppColors.success,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${d.days} days',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOver ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Income categorization
// ---------------------------------------------------------------------------

class _IncomeCard extends StatelessWidget {
  const _IncomeCard({required this.items});

  final List<_IncomeItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taxableTotal = items
        .where((i) => i.isTaxable)
        .fold(0.0, (s, i) => s + i.amount);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Income Categorization',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Taxable: ${_currencyFmt.format(taxableTotal)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      item.isTaxable
                          ? Icons.fiber_manual_record
                          : Icons.remove_circle_outline,
                      size: 10,
                      color: item.isTaxable
                          ? AppColors.error
                          : AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.source} (${item.category})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      _currencyFmt.format(item.amount),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DTAA benefits
// ---------------------------------------------------------------------------

class _DtaaCard extends StatelessWidget {
  const _DtaaCard({required this.details});

  final List<_DtaaDetail> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DTAA Benefits — ${details.isNotEmpty ? details.first.country : ""}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...details.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      d.isApplicable
                          ? Icons.check_circle_rounded
                          : Icons.remove_circle_outline_rounded,
                      size: 18,
                      color: d.isApplicable
                          ? AppColors.success
                          : AppColors.neutral300,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        d.articleRef,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      d.isApplicable ? '${d.rate}%' : 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: d.isApplicable
                            ? AppColors.primary
                            : AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TRC / Form 10F tracker
// ---------------------------------------------------------------------------

class _TrcForm10fCard extends StatelessWidget {
  const _TrcForm10fCard({required this.data});

  final _MockNriTax data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Requirements',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _DocRequirementRow(
              title: 'Tax Residency Certificate (TRC)',
              isAvailable: data.hasTrc,
              description: data.hasTrc
                  ? 'Obtained from ${data.countryOfResidence}'
                  : 'Required for DTAA benefits',
            ),
            const SizedBox(height: 8),
            _DocRequirementRow(
              title: 'Form 10F',
              isAvailable: data.hasForm10f,
              description: data.hasForm10f
                  ? 'Filed on income tax portal'
                  : 'Must be filed to claim DTAA relief',
            ),
          ],
        ),
      ),
    );
  }
}

class _DocRequirementRow extends StatelessWidget {
  const _DocRequirementRow({
    required this.title,
    required this.isAvailable,
    required this.description,
  });

  final String title;
  final bool isAvailable;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isAvailable
              ? Icons.check_circle_rounded
              : Icons.warning_amber_rounded,
          size: 18,
          color: isAvailable ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section 90/91 relief computation
// ---------------------------------------------------------------------------

class _ReliefComputationCard extends StatelessWidget {
  const _ReliefComputationCard({required this.data});

  final _MockNriTax data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.secondary.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relief Computation',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ReliefBox(
                  label: 'Section 90',
                  sublabel: 'DTAA Relief',
                  amount: data.section90Relief,
                ),
                const SizedBox(width: 12),
                _ReliefBox(
                  label: 'Section 91',
                  sublabel: 'Unilateral Relief',
                  amount: data.section91Relief,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReliefBox extends StatelessWidget {
  const _ReliefBox({
    required this.label,
    required this.sublabel,
    required this.amount,
  });

  final String label;
  final String sublabel;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
            const SizedBox(height: 4),
            Text(
              _currencyFmt.format(amount),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
              ),
            ),
            Text(
              sublabel,
              style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _showSnack(context, 'NRI computation exported'),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: const Text('Export Computation'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showSnack(context, 'Form 10F filing initiated'),
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('File Form 10F'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryVariant,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
