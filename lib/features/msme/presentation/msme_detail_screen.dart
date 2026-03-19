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

enum MsmeCategory {
  micro('Micro', AppColors.success),
  small('Small', AppColors.primaryVariant),
  medium('Medium', AppColors.warning);

  const MsmeCategory(this.label, this.color);
  final String label;
  final Color color;
}

class _VendorPayment {
  const _VendorPayment({
    required this.vendorName,
    required this.invoiceDate,
    required this.dueDate,
    required this.amount,
    required this.isPaid,
    required this.paidDate,
  });

  final String vendorName;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final double amount;
  final bool isPaid;
  final DateTime? paidDate;

  int get agingDays {
    final reference = isPaid ? paidDate! : DateTime.now();
    return reference.difference(invoiceDate).inDays;
  }

  bool get isOverdue45 =>
      !isPaid && DateTime.now().difference(dueDate).inDays > 0;

  double get interestOnDelay {
    if (!isPaid || paidDate == null) return 0;
    final delayDays = paidDate!.difference(dueDate).inDays;
    if (delayDays <= 0) return 0;
    // 3x bank rate (approx 18% p.a.)
    return amount * 0.18 * delayDays / 365;
  }
}

class _MockMsme {
  const _MockMsme({
    required this.id,
    required this.entityName,
    required this.udyamNumber,
    required this.category,
    required this.dateOfRegistration,
    required this.nic2DigitCode,
    required this.activityType,
    required this.vendorPayments,
  });

  final String id;
  final String entityName;
  final String udyamNumber;
  final MsmeCategory category;
  final DateTime dateOfRegistration;
  final String nic2DigitCode;
  final String activityType;
  final List<_VendorPayment> vendorPayments;

  int get totalPayments => vendorPayments.length;
  int get overduePayments => vendorPayments.where((p) => p.isOverdue45).length;
  double get totalOutstanding =>
      vendorPayments.where((p) => !p.isPaid).fold(0.0, (s, p) => s + p.amount);
  double get totalInterest =>
      vendorPayments.fold(0.0, (s, p) => s + p.interestOnDelay);
}

final _mockMsme = _MockMsme(
  id: 'msme-001',
  entityName: 'PrecisionParts India Pvt Ltd',
  udyamNumber: 'UDYAM-MH-01-0012345',
  category: MsmeCategory.small,
  dateOfRegistration: DateTime(2023, 6, 15),
  nic2DigitCode: '25',
  activityType: 'Manufacturing — Metal Products',
  vendorPayments: [
    _VendorPayment(
      vendorName: 'Steel Corp India',
      invoiceDate: DateTime(2026, 1, 5),
      dueDate: DateTime(2026, 2, 19),
      amount: 850000,
      isPaid: true,
      paidDate: DateTime(2026, 3, 10),
    ),
    _VendorPayment(
      vendorName: 'Bolt & Nut Supplies',
      invoiceDate: DateTime(2026, 1, 20),
      dueDate: DateTime(2026, 3, 6),
      amount: 125000,
      isPaid: false,
      paidDate: null,
    ),
    _VendorPayment(
      vendorName: 'ElectroCoat Pvt Ltd',
      invoiceDate: DateTime(2026, 2, 1),
      dueDate: DateTime(2026, 3, 18),
      amount: 340000,
      isPaid: false,
      paidDate: null,
    ),
    _VendorPayment(
      vendorName: 'PackRight Solutions',
      invoiceDate: DateTime(2026, 2, 15),
      dueDate: DateTime(2026, 4, 1),
      amount: 95000,
      isPaid: true,
      paidDate: DateTime(2026, 3, 5),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// MSME entity detail with payment tracker and 45-day compliance monitoring.
///
/// Route: `/msme/detail/:msmeId`
class MsmeDetailScreen extends ConsumerWidget {
  const MsmeDetailScreen({required this.msmeId, super.key});

  final String msmeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final msme = _mockMsme;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(msme.entityName, style: const TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _UdyamCard(msme: msme),
            const SizedBox(height: 16),
            _PaymentSummaryCard(msme: msme),
            const SizedBox(height: 16),
            _Section43bBanner(),
            const SizedBox(height: 16),
            _VendorPaymentList(payments: msme.vendorPayments),
            const SizedBox(height: 16),
            _InterestComputationCard(msme: msme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Udyam registration card
// ---------------------------------------------------------------------------

class _UdyamCard extends StatelessWidget {
  const _UdyamCard({required this.msme});

  final _MockMsme msme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: msme.category.color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: msme.category.color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_rounded,
                  size: 24,
                  color: msme.category.color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msme.entityName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        msme.udyamNumber,
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
                    color: msme.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    msme.category.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: msme.category.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Registered',
              value: _dateFmt.format(msme.dateOfRegistration),
            ),
            _DetailRow(label: 'NIC Code', value: msme.nic2DigitCode),
            _DetailRow(label: 'Activity', value: msme.activityType),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment summary
// ---------------------------------------------------------------------------

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({required this.msme});

  final _MockMsme msme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _MiniStat(
              label: 'Total',
              value: '${msme.totalPayments}',
              color: AppColors.primary,
            ),
            _MiniStat(
              label: 'Overdue',
              value: '${msme.overduePayments}',
              color: AppColors.error,
            ),
            _MiniStat(
              label: 'Outstanding',
              value: _currencyFmt.format(msme.totalOutstanding),
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section 43B(h) banner
// ---------------------------------------------------------------------------

class _Section43bBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gavel_rounded, size: 18, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Section 43B(h): Payments to MSME vendors must be made '
              'within 45 days of acceptance. Overdue payments are '
              'disallowed as deduction for the payer.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.warning,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vendor payment list
// ---------------------------------------------------------------------------

class _VendorPaymentList extends StatelessWidget {
  const _VendorPaymentList({required this.payments});

  final List<_VendorPayment> payments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor Payment Aging',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...payments.map((p) {
              final isOverdue = p.isOverdue45;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? AppColors.error.withValues(alpha: 0.04)
                      : AppColors.neutral50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOverdue
                        ? AppColors.error.withValues(alpha: 0.3)
                        : AppColors.neutral200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.vendorName,
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
                            color:
                                (p.isPaid
                                        ? AppColors.success
                                        : isOverdue
                                        ? AppColors.error
                                        : AppColors.warning)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.isPaid
                                ? 'Paid'
                                : isOverdue
                                ? 'Overdue'
                                : 'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: p.isPaid
                                  ? AppColors.success
                                  : isOverdue
                                  ? AppColors.error
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currencyFmt.format(p.amount),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Due: ${_dateFmt.format(p.dueDate)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Aging: ${p.agingDays} days',
                      style: TextStyle(
                        fontSize: 11,
                        color: p.agingDays > 45
                            ? AppColors.error
                            : AppColors.neutral400,
                        fontWeight: p.agingDays > 45
                            ? FontWeight.w600
                            : FontWeight.w400,
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
// Interest computation
// ---------------------------------------------------------------------------

class _InterestComputationCard extends StatelessWidget {
  const _InterestComputationCard({required this.msme});

  final _MockMsme msme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.error.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calculate_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Interest on Delayed Payments',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Compound interest at 3x bank rate (approx. 18% p.a.) '
              'on delayed payments beyond 45 days.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Total Interest Liability: ',
                    style: TextStyle(fontSize: 13, color: AppColors.neutral600),
                  ),
                  Text(
                    _currencyFmt.format(msme.totalInterest),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.error,
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
