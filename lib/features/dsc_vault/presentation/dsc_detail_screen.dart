import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

enum DscClass {
  class2('Class 2'),
  class3('Class 3');

  const DscClass(this.label);
  final String label;
}

class _PortalAssociation {
  const _PortalAssociation({
    required this.portal,
    required this.isRegistered,
    required this.lastUsed,
  });

  final String portal;
  final bool isRegistered;
  final DateTime? lastUsed;
}

class _UsageEntry {
  const _UsageEntry({
    required this.description,
    required this.portal,
    required this.date,
  });

  final String description;
  final String portal;
  final DateTime date;
}

class _MockDsc {
  const _MockDsc({
    required this.id,
    required this.holderName,
    required this.pan,
    required this.dscClass,
    required this.issuer,
    required this.serialNumber,
    required this.validFrom,
    required this.validTo,
    required this.portalAssociations,
    required this.usageHistory,
    required this.renewalReminderDays,
  });

  final String id;
  final String holderName;
  final String pan;
  final DscClass dscClass;
  final String issuer;
  final String serialNumber;
  final DateTime validFrom;
  final DateTime validTo;
  final List<_PortalAssociation> portalAssociations;
  final List<_UsageEntry> usageHistory;
  final int renewalReminderDays;

  int get daysToExpiry => validTo.difference(DateTime.now()).inDays;

  bool get isExpired => daysToExpiry < 0;

  bool get isExpiringSoon => !isExpired && daysToExpiry <= 30;

  Color get expiryColor {
    if (isExpired) return AppColors.error;
    if (daysToExpiry <= 30) return AppColors.error;
    if (daysToExpiry <= 90) return AppColors.warning;
    return AppColors.success;
  }
}

final _mockDsc = _MockDsc(
  id: 'dsc-001',
  holderName: 'CA Anand Verma',
  pan: 'ABCPV1234K',
  dscClass: DscClass.class3,
  issuer: 'eMudhra Limited',
  serialNumber: 'DSC-2025-MH-0098765',
  validFrom: DateTime(2025, 4, 1),
  validTo: DateTime(2027, 3, 31),
  renewalReminderDays: 30,
  portalAssociations: [
    _PortalAssociation(
      portal: 'Income Tax (ITD)',
      isRegistered: true,
      lastUsed: DateTime(2026, 3, 10),
    ),
    _PortalAssociation(
      portal: 'MCA (Ministry of Corporate Affairs)',
      isRegistered: true,
      lastUsed: DateTime(2026, 2, 28),
    ),
    _PortalAssociation(
      portal: 'GST Portal',
      isRegistered: true,
      lastUsed: DateTime(2026, 1, 15),
    ),
    _PortalAssociation(portal: 'TRACES', isRegistered: false, lastUsed: null),
  ],
  usageHistory: [
    _UsageEntry(
      description: 'ITR filed for FY 2025-26 — Bharat Industries',
      portal: 'ITD',
      date: DateTime(2026, 3, 10),
    ),
    _UsageEntry(
      description: 'AOC-4 signed — NeoFinTech Solutions',
      portal: 'MCA',
      date: DateTime(2026, 2, 28),
    ),
    _UsageEntry(
      description: 'GSTR-9 annual return signed',
      portal: 'GST',
      date: DateTime(2026, 1, 15),
    ),
    _UsageEntry(
      description: 'ITR-6 filed for FY 2024-25 — Global Pharma',
      portal: 'ITD',
      date: DateTime(2025, 10, 31),
    ),
    _UsageEntry(
      description: 'DIR-3 KYC — personal compliance',
      portal: 'MCA',
      date: DateTime(2025, 9, 15),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// DSC certificate detail view with portal associations and usage history.
///
/// Route: `/dsc-vault/detail/:dscId`
class DscDetailScreen extends ConsumerWidget {
  const DscDetailScreen({required this.dscId, super.key});

  final String dscId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsc = _mockDsc;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'DSC — ${dsc.holderName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CertificateHeaderCard(dsc: dsc),
            const SizedBox(height: 16),
            _CertificateInfoCard(dsc: dsc),
            const SizedBox(height: 16),
            _PortalAssociationsCard(associations: dsc.portalAssociations),
            const SizedBox(height: 16),
            _UsageHistoryCard(entries: dsc.usageHistory),
            const SizedBox(height: 16),
            _RenewalCard(dsc: dsc),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Certificate header
// ---------------------------------------------------------------------------

class _CertificateHeaderCard extends StatelessWidget {
  const _CertificateHeaderCard({required this.dsc});

  final _MockDsc dsc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: dsc.expiryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: dsc.expiryColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 28,
                  color: dsc.expiryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dsc.holderName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        dsc.dscClass.label,
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
                    color: dsc.expiryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dsc.isExpired
                        ? 'Expired'
                        : dsc.isExpiringSoon
                        ? '${dsc.daysToExpiry}d left'
                        : '${dsc.daysToExpiry}d valid',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: dsc.expiryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: dsc.isExpired
                  ? 1.0
                  : 1 -
                        (dsc.daysToExpiry /
                            dsc.validTo.difference(dsc.validFrom).inDays),
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation(dsc.expiryColor),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valid from: ${_dateFmt.format(dsc.validFrom)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral400,
                  ),
                ),
                Text(
                  'Valid to: ${_dateFmt.format(dsc.validTo)}',
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
    );
  }
}

// ---------------------------------------------------------------------------
// Certificate info
// ---------------------------------------------------------------------------

class _CertificateInfoCard extends StatelessWidget {
  const _CertificateInfoCard({required this.dsc});

  final _MockDsc dsc;

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
            _DetailRow(label: 'Holder', value: dsc.holderName),
            _DetailRow(label: 'PAN', value: dsc.pan),
            _DetailRow(label: 'Class', value: dsc.dscClass.label),
            _DetailRow(label: 'Issuer', value: dsc.issuer),
            _DetailRow(label: 'Serial No.', value: dsc.serialNumber),
            _DetailRow(
              label: 'Valid From',
              value: _dateFmt.format(dsc.validFrom),
            ),
            _DetailRow(label: 'Valid To', value: _dateFmt.format(dsc.validTo)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Portal associations
// ---------------------------------------------------------------------------

class _PortalAssociationsCard extends StatelessWidget {
  const _PortalAssociationsCard({required this.associations});

  final List<_PortalAssociation> associations;

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
              'Portal Associations',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...associations.map(
              (assoc) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      assoc.isRegistered
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: assoc.isRegistered
                          ? AppColors.success
                          : AppColors.neutral300,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assoc.portal,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (assoc.lastUsed != null)
                            Text(
                              'Last used: ${_dateFmt.format(assoc.lastUsed!)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.neutral400,
                              ),
                            )
                          else
                            const Text(
                              'Not registered',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.neutral400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!assoc.isRegistered)
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Register DSC on ${assoc.portal}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 12),
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
// Usage history
// ---------------------------------------------------------------------------

class _UsageHistoryCard extends StatelessWidget {
  const _UsageHistoryCard({required this.entries});

  final List<_UsageEntry> entries;

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
              'Recent Signings',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.draw_rounded,
                      size: 16,
                      color: AppColors.primaryVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.description,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.portal,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _dateFmt.format(entry.date),
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
// Renewal reminder card
// ---------------------------------------------------------------------------

class _RenewalCard extends StatelessWidget {
  const _RenewalCard({required this.dsc});

  final _MockDsc dsc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.accent.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Renewal Reminder',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reminder set for ${dsc.renewalReminderDays} days before expiry. '
              'You will be notified on ${_dateFmt.format(dsc.validTo.subtract(Duration(days: dsc.renewalReminderDays)))}.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Renewal reminder settings updated'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit Reminder'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
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
