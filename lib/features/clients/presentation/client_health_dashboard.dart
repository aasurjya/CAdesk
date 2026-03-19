import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Mock data — cross-module client intelligence
// ---------------------------------------------------------------------------

class _ClientHealth {
  const _ClientHealth({
    required this.clientId,
    required this.name,
    required this.pan,
    required this.riskScore,
    required this.complianceItems,
    required this.invoices,
    required this.engagements,
    required this.pendingDocuments,
    required this.paymentHistory,
  });

  final String clientId;
  final String name;
  final String pan;
  final int riskScore;
  final List<_ComplianceItem> complianceItems;
  final List<_InvoiceItem> invoices;
  final List<_Engagement> engagements;
  final List<String> pendingDocuments;
  final List<_PaymentEntry> paymentHistory;
}

class _ComplianceItem {
  const _ComplianceItem({
    required this.module,
    required this.status,
    required this.dueDate,
    required this.icon,
  });

  final String module;
  final _ComplianceStatus status;
  final String dueDate;
  final IconData icon;
}

enum _ComplianceStatus {
  filed('Filed', AppColors.success),
  pending('Pending', AppColors.warning),
  overdue('Overdue', AppColors.error),
  notApplicable('N/A', AppColors.neutral400);

  const _ComplianceStatus(this.label, this.color);
  final String label;
  final Color color;
}

class _InvoiceItem {
  const _InvoiceItem({
    required this.number,
    required this.amount,
    required this.status,
    required this.date,
  });

  final String number;
  final double amount;
  final String status;
  final String date;
}

class _Engagement {
  const _Engagement({
    required this.name,
    required this.deadline,
    required this.progress,
    required this.assignedTo,
  });

  final String name;
  final String deadline;
  final double progress;
  final String assignedTo;
}

class _PaymentEntry {
  const _PaymentEntry({
    required this.date,
    required this.amount,
    required this.method,
  });

  final String date;
  final double amount;
  final String method;
}

_ClientHealth _mockHealth(String clientId) {
  return _ClientHealth(
    clientId: clientId,
    name: 'Rajesh Sharma',
    pan: 'ABCPS1234K',
    riskScore: 25,
    complianceItems: const [
      _ComplianceItem(
        module: 'ITR',
        status: _ComplianceStatus.filed,
        dueDate: '31 Jul 2025',
        icon: Icons.receipt_long_rounded,
      ),
      _ComplianceItem(
        module: 'GST',
        status: _ComplianceStatus.pending,
        dueDate: '20 Mar 2026',
        icon: Icons.receipt_rounded,
      ),
      _ComplianceItem(
        module: 'TDS',
        status: _ComplianceStatus.overdue,
        dueDate: '07 Mar 2026',
        icon: Icons.description_rounded,
      ),
      _ComplianceItem(
        module: 'ROC',
        status: _ComplianceStatus.notApplicable,
        dueDate: '-',
        icon: Icons.gavel_rounded,
      ),
    ],
    invoices: const [
      _InvoiceItem(
        number: 'INV-2026-042',
        amount: 35000,
        status: 'Outstanding',
        date: '01 Mar 2026',
      ),
      _InvoiceItem(
        number: 'INV-2025-198',
        amount: 18000,
        status: 'Paid',
        date: '15 Dec 2025',
      ),
      _InvoiceItem(
        number: 'INV-2025-156',
        amount: 25000,
        status: 'Paid',
        date: '01 Sep 2025',
      ),
    ],
    engagements: const [
      _Engagement(
        name: 'ITR Filing AY 2025-26',
        deadline: '31 Mar 2026',
        progress: 0.65,
        assignedTo: 'Ananya Desai',
      ),
      _Engagement(
        name: 'GST Returns (Monthly)',
        deadline: '20 Mar 2026',
        progress: 0.3,
        assignedTo: 'Rahul Kumar',
      ),
      _Engagement(
        name: 'Tax Planning FY 2025-26',
        deadline: '31 Mar 2026',
        progress: 0.9,
        assignedTo: 'Ananya Desai',
      ),
    ],
    pendingDocuments: [
      'Form 16 (FY 2025-26)',
      'Bank Statement - Jan-Mar 2026',
      'Capital Gains Statement',
      'Rent Agreement',
    ],
    paymentHistory: const [
      _PaymentEntry(date: '15 Dec 2025', amount: 18000, method: 'UPI'),
      _PaymentEntry(date: '01 Sep 2025', amount: 25000, method: 'NEFT'),
      _PaymentEntry(date: '20 Jun 2025', amount: 15000, method: 'UPI'),
    ],
  );
}

/// Cross-module client intelligence dashboard — the unified view showing
/// compliance status, invoices, engagements, documents, and risk score.
class ClientHealthDashboard extends ConsumerWidget {
  const ClientHealthDashboard({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = _mockHealth(clientId);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _HealthHeader(health: health),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _RiskScoreCard(score: health.riskScore, theme: theme),
                const SizedBox(height: 16),
                _ComplianceGrid(items: health.complianceItems),
                const SizedBox(height: 16),
                _EngagementsSection(engagements: health.engagements),
                const SizedBox(height: 16),
                _InvoicesSection(invoices: health.invoices),
                const SizedBox(height: 16),
                _PendingDocsSection(documents: health.pendingDocuments),
                const SizedBox(height: 16),
                _PaymentHistorySection(payments: health.paymentHistory),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HealthHeader extends StatelessWidget {
  const _HealthHeader({required this.health});

  final _ClientHealth health;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryVariant],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  health.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${health.pan} \u2022 Client Health Dashboard',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Risk score card
// ---------------------------------------------------------------------------

class _RiskScoreCard extends StatelessWidget {
  const _RiskScoreCard({required this.score, required this.theme});

  final int score;
  final ThemeData theme;

  Color get _color {
    if (score <= 30) return AppColors.success;
    if (score <= 60) return AppColors.warning;
    return AppColors.error;
  }

  String get _label {
    if (score <= 30) return 'Low Risk';
    if (score <= 60) return 'Medium Risk';
    return 'High Risk';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.neutral100,
                    valueColor: AlwaysStoppedAnimation(_color),
                  ),
                  Text(
                    '$score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk Score',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    _label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Based on compliance, payment, and engagement data',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
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
// Compliance grid
// ---------------------------------------------------------------------------

class _ComplianceGrid extends StatelessWidget {
  const _ComplianceGrid({required this.items});

  final List<_ComplianceItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compliance Status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: items
                  .map(
                    (item) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.status.color.withAlpha(12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: item.status.color.withAlpha(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(item.icon, size: 20, color: item.status.color),
                            const SizedBox(height: 6),
                            Text(
                              item.module,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.status.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: item.status.color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.dueDate,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Engagements section
// ---------------------------------------------------------------------------

class _EngagementsSection extends StatelessWidget {
  const _EngagementsSection({required this.engagements});

  final List<_Engagement> engagements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Engagements',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...engagements.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          e.deadline,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: e.progress,
                              minHeight: 6,
                              backgroundColor: AppColors.neutral100,
                              valueColor: AlwaysStoppedAnimation(
                                e.progress >= 0.8
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(e.progress * 100).toInt()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Assigned: ${e.assignedTo}',
                      style: theme.textTheme.labelSmall?.copyWith(
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
// Invoices section
// ---------------------------------------------------------------------------

class _InvoicesSection extends StatelessWidget {
  const _InvoicesSection({required this.invoices});

  final List<_InvoiceItem> invoices;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoices',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...invoices.map((inv) {
              final isOutstanding = inv.status == 'Outstanding';
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.receipt_outlined,
                  color: isOutstanding ? AppColors.warning : AppColors.success,
                  size: 20,
                ),
                title: Text(
                  inv.number,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  inv.date,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\u20B9${inv.amount.toInt()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      inv.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isOutstanding
                            ? AppColors.warning
                            : AppColors.success,
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
// Pending documents
// ---------------------------------------------------------------------------

class _PendingDocsSection extends StatelessWidget {
  const _PendingDocsSection({required this.documents});

  final List<String> documents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.warning.withAlpha(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pending_actions_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pending Documents (${documents.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...documents.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      size: 16,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(
                        'Request',
                        style: TextStyle(fontSize: 11),
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
// Payment history
// ---------------------------------------------------------------------------

class _PaymentHistorySection extends StatelessWidget {
  const _PaymentHistorySection({required this.payments});

  final List<_PaymentEntry> payments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment History',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...payments.map(
              (p) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 20,
                ),
                title: Text(
                  '\u20B9${p.amount.toInt()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  p.date,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                trailing: Text(
                  p.method,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
