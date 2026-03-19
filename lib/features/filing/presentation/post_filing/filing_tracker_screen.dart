import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum ReturnCategory { itr, gst, tds }

extension ReturnCategoryX on ReturnCategory {
  String get label => switch (this) {
    ReturnCategory.itr => 'ITR',
    ReturnCategory.gst => 'GST',
    ReturnCategory.tds => 'TDS',
  };

  Color get color => switch (this) {
    ReturnCategory.itr => const Color(0xFF1565C0),
    ReturnCategory.gst => const Color(0xFF2E7D32),
    ReturnCategory.tds => const Color(0xFF6A1B9A),
  };

  IconData get icon => switch (this) {
    ReturnCategory.itr => Icons.account_balance_rounded,
    ReturnCategory.gst => Icons.receipt_long_rounded,
    ReturnCategory.tds => Icons.content_paste_search_rounded,
  };
}

enum VerificationStatus { verified, pending, notRequired }

extension VerificationStatusX on VerificationStatus {
  String get label => switch (this) {
    VerificationStatus.verified => 'Verified',
    VerificationStatus.pending => 'Pending',
    VerificationStatus.notRequired => 'N/A',
  };

  Color get color => switch (this) {
    VerificationStatus.verified => AppColors.success,
    VerificationStatus.pending => AppColors.warning,
    VerificationStatus.notRequired => AppColors.neutral400,
  };
}

enum ProcessingStatus { processed, underProcessing, defective, nil }

extension ProcessingStatusX on ProcessingStatus {
  String get label => switch (this) {
    ProcessingStatus.processed => 'Processed',
    ProcessingStatus.underProcessing => 'Under Processing',
    ProcessingStatus.defective => 'Defective',
    ProcessingStatus.nil => '—',
  };

  Color get color => switch (this) {
    ProcessingStatus.processed => AppColors.success,
    ProcessingStatus.underProcessing => AppColors.secondary,
    ProcessingStatus.defective => AppColors.error,
    ProcessingStatus.nil => AppColors.neutral400,
  };
}

enum RefundStatus { issued, pending, nil, adjusted }

extension RefundStatusX on RefundStatus {
  String get label => switch (this) {
    RefundStatus.issued => 'Issued',
    RefundStatus.pending => 'Pending',
    RefundStatus.nil => 'N/A',
    RefundStatus.adjusted => 'Adjusted',
  };

  Color get color => switch (this) {
    RefundStatus.issued => AppColors.success,
    RefundStatus.pending => AppColors.warning,
    RefundStatus.nil => AppColors.neutral400,
    RefundStatus.adjusted => AppColors.secondary,
  };
}

class FiledReturn {
  const FiledReturn({
    required this.clientName,
    required this.pan,
    required this.returnType,
    required this.category,
    required this.assessmentYear,
    required this.ackNumber,
    required this.filedAt,
    required this.verification,
    required this.processing,
    required this.refund,
  });

  final String clientName;
  final String pan;
  final String returnType;
  final ReturnCategory category;
  final String assessmentYear;
  final String ackNumber;
  final DateTime filedAt;
  final VerificationStatus verification;
  final ProcessingStatus processing;
  final RefundStatus refund;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _categoryFilterProvider =
    NotifierProvider<_CategoryFilterNotifier, ReturnCategory?>(
      _CategoryFilterNotifier.new,
    );

class _CategoryFilterNotifier extends Notifier<ReturnCategory?> {
  @override
  ReturnCategory? build() => null;

  void set(ReturnCategory? value) => state = value;
}

final _allReturnsProvider = Provider<List<FiledReturn>>((ref) {
  return [
    FiledReturn(
      clientName: 'Rajesh Kumar',
      pan: 'ABCPK1234D',
      returnType: 'ITR-1',
      category: ReturnCategory.itr,
      assessmentYear: 'AY 2026-27',
      ackNumber: 'CPC/2026/ITR1/00234567',
      filedAt: DateTime.now().subtract(const Duration(days: 5)),
      verification: VerificationStatus.verified,
      processing: ProcessingStatus.processed,
      refund: RefundStatus.issued,
    ),
    FiledReturn(
      clientName: 'Priya Sharma',
      pan: 'BPXPS5678G',
      returnType: 'ITR-2',
      category: ReturnCategory.itr,
      assessmentYear: 'AY 2026-27',
      ackNumber: 'CPC/2026/ITR2/00345678',
      filedAt: DateTime.now().subtract(const Duration(days: 3)),
      verification: VerificationStatus.pending,
      processing: ProcessingStatus.underProcessing,
      refund: RefundStatus.pending,
    ),
    FiledReturn(
      clientName: 'ABC Enterprises',
      pan: '27AAAPZ1234C1ZV',
      returnType: 'GSTR-1',
      category: ReturnCategory.gst,
      assessmentYear: 'Feb 2026',
      ackNumber: 'GST/2026/R1/00987654',
      filedAt: DateTime.now().subtract(const Duration(days: 10)),
      verification: VerificationStatus.notRequired,
      processing: ProcessingStatus.processed,
      refund: RefundStatus.nil,
    ),
    FiledReturn(
      clientName: 'ABC Enterprises',
      pan: '27AAAPZ1234C1ZV',
      returnType: 'GSTR-3B',
      category: ReturnCategory.gst,
      assessmentYear: 'Feb 2026',
      ackNumber: 'GST/2026/3B/00876543',
      filedAt: DateTime.now().subtract(const Duration(days: 8)),
      verification: VerificationStatus.notRequired,
      processing: ProcessingStatus.processed,
      refund: RefundStatus.nil,
    ),
    FiledReturn(
      clientName: 'Mehta & Co.',
      pan: 'AABFM5678P',
      returnType: 'TDS 24Q',
      category: ReturnCategory.tds,
      assessmentYear: 'Q3 FY25-26',
      ackNumber: 'TDS/2026/24Q/00654321',
      filedAt: DateTime.now().subtract(const Duration(days: 15)),
      verification: VerificationStatus.notRequired,
      processing: ProcessingStatus.processed,
      refund: RefundStatus.nil,
    ),
    FiledReturn(
      clientName: 'Sunita Devi',
      pan: 'DRVSD3456A',
      returnType: 'ITR-1',
      category: ReturnCategory.itr,
      assessmentYear: 'AY 2026-27',
      ackNumber: 'CPC/2026/ITR1/00456789',
      filedAt: DateTime.now().subtract(const Duration(days: 1)),
      verification: VerificationStatus.verified,
      processing: ProcessingStatus.defective,
      refund: RefundStatus.nil,
    ),
  ];
});

final _filteredReturnsProvider = Provider<List<FiledReturn>>((ref) {
  final allReturns = ref.watch(_allReturnsProvider);
  final filter = ref.watch(_categoryFilterProvider);
  if (filter == null) return allReturns;
  return allReturns.where((r) => r.category == filter).toList();
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class FilingTrackerScreen extends ConsumerWidget {
  const FilingTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returns = ref.watch(_filteredReturnsProvider);
    final allReturns = ref.watch(_allReturnsProvider);
    final theme = Theme.of(context);

    final verifiedCount = allReturns
        .where((r) => r.verification == VerificationStatus.verified)
        .length;
    final processedCount = allReturns
        .where((r) => r.processing == ProcessingStatus.processed)
        .length;
    final pendingVerify = allReturns
        .where((r) => r.verification == VerificationStatus.pending)
        .length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filing Tracker',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'All filed returns in one view',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _StatCard(
                  label: 'Total',
                  value: '${allReturns.length}',
                  icon: Icons.description_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Verified',
                  value: '$verifiedCount',
                  icon: Icons.verified_rounded,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Processed',
                  value: '$processedCount',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Pending',
                  value: '$pendingVerify',
                  icon: Icons.pending_rounded,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),

          // Category filter
          _CategoryFilterBar(
            selected: ref.watch(_categoryFilterProvider),
            onSelected: (c) {
              final current = ref.read(_categoryFilterProvider);
              ref
                  .read(_categoryFilterProvider.notifier)
                  .set(c == current ? null : c);
            },
          ),

          // Returns list
          Expanded(
            child: returns.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 80,
                    ),
                    itemCount: returns.length,
                    itemBuilder: (context, index) =>
                        _FiledReturnCard(filedReturn: returns[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filed return card
// ---------------------------------------------------------------------------

class _FiledReturnCard extends StatelessWidget {
  const _FiledReturnCard({required this.filedReturn});

  final FiledReturn filedReturn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: filedReturn.category.color, width: 3),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  filedReturn.category.icon,
                  size: 20,
                  color: filedReturn.category.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${filedReturn.returnType} - ${filedReturn.clientName}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${filedReturn.pan} | ${filedReturn.assessmentYear}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Ack number
            Text(
              'Ack: ${filedReturn.ackNumber}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.neutral400,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),

            // Status badges
            Row(
              children: [
                _StatusBadge(
                  label: 'Verify',
                  value: filedReturn.verification.label,
                  color: filedReturn.verification.color,
                ),
                const SizedBox(width: 6),
                _StatusBadge(
                  label: 'Process',
                  value: filedReturn.processing.label,
                  color: filedReturn.processing.color,
                ),
                const SizedBox(width: 6),
                _StatusBadge(
                  label: 'Refund',
                  value: filedReturn.refund.label,
                  color: filedReturn.refund.color,
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
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
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

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.selected, required this.onSelected});

  final ReturnCategory? selected;
  final ValueChanged<ReturnCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: ReturnCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = ReturnCategory.values[index];
          final isActive = cat == selected;

          return FilterChip(
            label: Text(cat.label),
            selected: isActive,
            onSelected: (_) => onSelected(cat),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : cat.color,
            ),
            selectedColor: cat.color,
            backgroundColor: cat.color.withValues(alpha: 0.08),
            side: BorderSide(color: cat.color.withValues(alpha: 0.3)),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
          const SizedBox(height: 12),
          Text(
            'No returns match the selected filter',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
