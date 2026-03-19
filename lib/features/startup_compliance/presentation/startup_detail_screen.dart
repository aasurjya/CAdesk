import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _dateFmt = DateFormat('dd MMM yyyy');
final _currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9');

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

enum DpiitStatus {
  recognised('Recognised', AppColors.success),
  applied('Applied', AppColors.warning),
  notApplied('Not Applied', AppColors.neutral400);

  const DpiitStatus(this.label, this.color);
  final String label;
  final Color color;
}

class _InvestorRound {
  const _InvestorRound({
    required this.round,
    required this.investor,
    required this.amount,
    required this.date,
    required this.valuation,
  });

  final String round;
  final String investor;
  final double amount;
  final DateTime date;
  final double valuation;
}

class _ComplianceItem {
  const _ComplianceItem({
    required this.title,
    required this.dueDate,
    required this.isCompleted,
  });

  final String title;
  final DateTime dueDate;
  final bool isCompleted;
}

class _MockStartup {
  const _MockStartup({
    required this.id,
    required this.entityName,
    required this.cin,
    required this.incorporationDate,
    required this.sector,
    required this.dpiitStatus,
    required this.dpiitNumber,
    required this.angelTaxApplicable,
    required this.section80iacEligible,
    required this.investorRounds,
    required this.complianceCalendar,
  });

  final String id;
  final String entityName;
  final String cin;
  final DateTime incorporationDate;
  final String sector;
  final DpiitStatus dpiitStatus;
  final String dpiitNumber;
  final bool angelTaxApplicable;
  final bool section80iacEligible;
  final List<_InvestorRound> investorRounds;
  final List<_ComplianceItem> complianceCalendar;
}

final _mockStartup = _MockStartup(
  id: 'startup-001',
  entityName: 'NeoFinTech Solutions Pvt Ltd',
  cin: 'U72200MH2024PTC412345',
  incorporationDate: DateTime(2024, 3, 15),
  sector: 'FinTech / Digital Payments',
  dpiitStatus: DpiitStatus.recognised,
  dpiitNumber: 'DIPP12345',
  angelTaxApplicable: false,
  section80iacEligible: true,
  investorRounds: [
    _InvestorRound(
      round: 'Seed',
      investor: 'AngelFund Partners',
      amount: 15000000,
      date: DateTime(2024, 6, 1),
      valuation: 50000000,
    ),
    _InvestorRound(
      round: 'Pre-Series A',
      investor: 'Venture Capital India',
      amount: 80000000,
      date: DateTime(2025, 2, 20),
      valuation: 300000000,
    ),
  ],
  complianceCalendar: [
    _ComplianceItem(
      title: 'Annual Return (MGT-7A)',
      dueDate: DateTime(2026, 6, 30),
      isCompleted: false,
    ),
    _ComplianceItem(
      title: 'Board Meeting — Q1',
      dueDate: DateTime(2026, 4, 30),
      isCompleted: true,
    ),
    _ComplianceItem(
      title: 'Statutory Audit',
      dueDate: DateTime(2026, 9, 30),
      isCompleted: false,
    ),
    _ComplianceItem(
      title: 'Income Tax Return',
      dueDate: DateTime(2026, 10, 31),
      isCompleted: false,
    ),
    _ComplianceItem(
      title: 'Board Meeting — Q2',
      dueDate: DateTime(2026, 7, 31),
      isCompleted: false,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Startup entity detail view with compliance calendar and investor tracking.
///
/// Route: `/startup-compliance/detail/:startupId`
class StartupDetailScreen extends ConsumerWidget {
  const StartupDetailScreen({required this.startupId, super.key});

  final String startupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = _mockStartup;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(startup.entityName, style: const TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EntityInfoCard(startup: startup),
            const SizedBox(height: 16),
            _DpiitCard(startup: startup),
            const SizedBox(height: 16),
            _TaxBenefitsCard(startup: startup),
            const SizedBox(height: 16),
            _InvestorRoundsCard(rounds: startup.investorRounds),
            const SizedBox(height: 16),
            _ComplianceCalendarCard(items: startup.complianceCalendar),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Entity info
// ---------------------------------------------------------------------------

class _EntityInfoCard extends StatelessWidget {
  const _EntityInfoCard({required this.startup});

  final _MockStartup startup;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(label: 'Entity', value: startup.entityName),
            _DetailRow(label: 'CIN', value: startup.cin),
            _DetailRow(
              label: 'Incorporated',
              value: _dateFmt.format(startup.incorporationDate),
            ),
            _DetailRow(label: 'Sector', value: startup.sector),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DPIIT recognition
// ---------------------------------------------------------------------------

class _DpiitCard extends StatelessWidget {
  const _DpiitCard({required this.startup});

  final _MockStartup startup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: startup.dpiitStatus.color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: startup.dpiitStatus.color.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              startup.dpiitStatus == DpiitStatus.recognised
                  ? Icons.verified_rounded
                  : Icons.pending_rounded,
              size: 28,
              color: startup.dpiitStatus.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DPIIT Recognition',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Status: ${startup.dpiitStatus.label}',
                    style: TextStyle(
                      fontSize: 12,
                      color: startup.dpiitStatus.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (startup.dpiitNumber.isNotEmpty)
                    Text(
                      'Reg No: ${startup.dpiitNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tax benefits
// ---------------------------------------------------------------------------

class _TaxBenefitsCard extends StatelessWidget {
  const _TaxBenefitsCard({required this.startup});

  final _MockStartup startup;

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
              'Tax Benefits & Applicability',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _BenefitRow(
              title: 'Angel Tax — Section 56(2)(viib)',
              subtitle: startup.angelTaxApplicable
                  ? 'Applicable — shares issued above FMV'
                  : 'Not applicable — DPIIT exemption',
              isPositive: !startup.angelTaxApplicable,
            ),
            const SizedBox(height: 8),
            _BenefitRow(
              title: 'Section 80-IAC — Tax Holiday',
              subtitle: startup.section80iacEligible
                  ? 'Eligible — 3 consecutive years of 100% deduction'
                  : 'Not eligible — conditions not met',
              isPositive: startup.section80iacEligible,
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.title,
    required this.subtitle,
    required this.isPositive,
  });

  final String title;
  final String subtitle;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isPositive ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
          size: 18,
          color: isPositive ? AppColors.success : AppColors.warning,
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
                subtitle,
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
// Investor rounds
// ---------------------------------------------------------------------------

class _InvestorRoundsCard extends StatelessWidget {
  const _InvestorRoundsCard({required this.rounds});

  final List<_InvestorRound> rounds;

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
              'Investor Rounds',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...rounds.map(
              (round) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            round.round,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            round.investor,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.neutral400,
                                ),
                              ),
                              Text(
                                _currencyFmt.format(round.amount),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Valuation',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.neutral400,
                                ),
                              ),
                              Text(
                                _currencyFmt.format(round.valuation),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _dateFmt.format(round.date),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
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
// Compliance calendar
// ---------------------------------------------------------------------------

class _ComplianceCalendarCard extends StatelessWidget {
  const _ComplianceCalendarCard({required this.items});

  final List<_ComplianceItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = items.where((i) => i.isCompleted).length;

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
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: AppColors.primaryVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Compliance Calendar',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$completedCount / ${items.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      item.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: item.isCompleted
                          ? AppColors.success
                          : AppColors.neutral300,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.isCompleted
                              ? AppColors.neutral400
                              : AppColors.neutral900,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      _dateFmt.format(item.dueDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral400,
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
