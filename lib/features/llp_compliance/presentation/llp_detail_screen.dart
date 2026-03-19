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

class _Partner {
  const _Partner({
    required this.name,
    required this.din,
    required this.designation,
    required this.capitalContribution,
    required this.profitShare,
  });

  final String name;
  final String din;
  final String designation;
  final double capitalContribution;
  final double profitShare;
}

enum FormStatus {
  filed('Filed', AppColors.success),
  pending('Pending', AppColors.warning),
  overdue('Overdue', AppColors.error);

  const FormStatus(this.label, this.color);
  final String label;
  final Color color;
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

class _PartnerChange {
  const _PartnerChange({
    required this.description,
    required this.date,
    required this.formFiled,
  });

  final String description;
  final DateTime date;
  final String formFiled;
}

class _MockLlp {
  const _MockLlp({
    required this.id,
    required this.name,
    required this.llpin,
    required this.incorporationDate,
    required this.registeredOffice,
    required this.partners,
    required this.form11Status,
    required this.form8Status,
    required this.complianceCalendar,
    required this.partnerChanges,
  });

  final String id;
  final String name;
  final String llpin;
  final DateTime incorporationDate;
  final String registeredOffice;
  final List<_Partner> partners;
  final FormStatus form11Status;
  final FormStatus form8Status;
  final List<_ComplianceItem> complianceCalendar;
  final List<_PartnerChange> partnerChanges;
}

final _mockLlp = _MockLlp(
  id: 'llp-001',
  name: 'Sharma & Associates LLP',
  llpin: 'AAB-1234',
  incorporationDate: DateTime(2020, 7, 10),
  registeredOffice: '402, Maker Chambers V, Nariman Point, Mumbai - 400021',
  partners: const [
    _Partner(
      name: 'CA Vikram Sharma',
      din: '07123456',
      designation: 'Designated Partner',
      capitalContribution: 5000000,
      profitShare: 40,
    ),
    _Partner(
      name: 'CA Priya Mehta',
      din: '08234567',
      designation: 'Designated Partner',
      capitalContribution: 3000000,
      profitShare: 35,
    ),
    _Partner(
      name: 'Rajesh Kumar',
      din: '09345678',
      designation: 'Partner',
      capitalContribution: 2000000,
      profitShare: 25,
    ),
  ],
  form11Status: FormStatus.filed,
  form8Status: FormStatus.pending,
  complianceCalendar: [
    _ComplianceItem(
      title: 'Form 11 (Annual Return)',
      dueDate: DateTime(2026, 5, 30),
      isCompleted: true,
    ),
    _ComplianceItem(
      title: 'Form 8 (Statement of Account)',
      dueDate: DateTime(2026, 10, 30),
      isCompleted: false,
    ),
    _ComplianceItem(
      title: 'Income Tax Return',
      dueDate: DateTime(2026, 10, 31),
      isCompleted: false,
    ),
    _ComplianceItem(
      title: 'Tax Audit (if applicable)',
      dueDate: DateTime(2026, 10, 31),
      isCompleted: false,
    ),
  ],
  partnerChanges: [
    _PartnerChange(
      description: 'Rajesh Kumar admitted as Partner',
      date: DateTime(2025, 4, 1),
      formFiled: 'Form 4',
    ),
    _PartnerChange(
      description: 'Capital contribution increased by CA Vikram Sharma',
      date: DateTime(2025, 8, 15),
      formFiled: 'Form 3',
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// LLP entity detail view with partner details and compliance tracking.
///
/// Route: `/llp-compliance/detail/:llpId`
class LlpDetailScreen extends ConsumerWidget {
  const LlpDetailScreen({required this.llpId, super.key});

  final String llpId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final llp = _mockLlp;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(llp.name, style: const TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EntityInfoCard(llp: llp),
            const SizedBox(height: 16),
            _PartnersCard(partners: llp.partners),
            const SizedBox(height: 16),
            _FormStatusCard(llp: llp),
            const SizedBox(height: 16),
            _ComplianceCalendarCard(items: llp.complianceCalendar),
            const SizedBox(height: 16),
            _PartnerChangesCard(changes: llp.partnerChanges),
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
  const _EntityInfoCard({required this.llp});

  final _MockLlp llp;

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
            _DetailRow(label: 'LLP Name', value: llp.name),
            _DetailRow(label: 'LLPIN', value: llp.llpin),
            _DetailRow(
              label: 'Incorporated',
              value: _dateFmt.format(llp.incorporationDate),
            ),
            _DetailRow(label: 'Reg. Office', value: llp.registeredOffice),
            _DetailRow(
              label: 'Partners',
              value: '${llp.partners.length} partners',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Partners card
// ---------------------------------------------------------------------------

class _PartnersCard extends StatelessWidget {
  const _PartnersCard({required this.partners});

  final List<_Partner> partners;

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
              'Partner Details',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...partners.map(
              (partner) => Container(
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
                        const Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: AppColors.primaryVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            partner.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            partner.designation,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DIN',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.neutral400,
                                ),
                              ),
                              Text(
                                partner.din,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
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
                                'Capital',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.neutral400,
                                ),
                              ),
                              Text(
                                _currencyFmt.format(
                                  partner.capitalContribution,
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
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
                                'Profit %',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.neutral400,
                                ),
                              ),
                              Text(
                                '${partner.profitShare}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
// Form status
// ---------------------------------------------------------------------------

class _FormStatusCard extends StatelessWidget {
  const _FormStatusCard({required this.llp});

  final _MockLlp llp;

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
              'Annual Filing Status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _FormStatusRow(
              formName: 'Form 11 — Annual Return',
              status: llp.form11Status,
            ),
            const SizedBox(height: 8),
            _FormStatusRow(
              formName: 'Form 8 — Statement of Account',
              status: llp.form8Status,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormStatusRow extends StatelessWidget {
  const _FormStatusRow({required this.formName, required this.status});

  final String formName;
  final FormStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          status == FormStatus.filed
              ? Icons.check_circle_rounded
              : status == FormStatus.pending
              ? Icons.schedule_rounded
              : Icons.warning_rounded,
          size: 18,
          color: status.color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            formName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
        ),
      ],
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
// Partner changes
// ---------------------------------------------------------------------------

class _PartnerChangesCard extends StatelessWidget {
  const _PartnerChangesCard({required this.changes});

  final List<_PartnerChange> changes;

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
              'Partner Changes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...changes.map(
              (change) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.swap_horiz_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            change.description,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_dateFmt.format(change.date)} | ${change.formFiled}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.neutral400,
                            ),
                          ),
                        ],
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
