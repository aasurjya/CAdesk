import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/presentation/form16/form16_currency.dart';
import 'package:ca_app/features/tds/presentation/form16/widgets/part_a_card.dart';
import 'package:ca_app/features/tds/presentation/form16/widgets/part_b_card.dart';

/// Detail viewer for a single Form 16, showing header info, Part A, and Part B.
class Form16ViewerScreen extends ConsumerWidget {
  const Form16ViewerScreen({super.key, required this.form16});

  final Form16Data form16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final address = form16.employerAddress;
    final addressStr = [
      address.line1,
      if (address.line2 != null) address.line2,
      address.city,
      address.state,
      address.pincode,
    ].join(', ');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Form 16',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(form16: form16),
            const SizedBox(height: 12),
            PartACard(
              partA: form16.partA,
              employerName: form16.employerName,
              employerTan: form16.employerTan,
              employerAddress: addressStr,
            ),
            const SizedBox(height: 12),
            PartBCard(partB: form16.partB),
            const SizedBox(height: 24),
            _DownloadButton(context: context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header card — employee info
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.form16});

  final Form16Data form16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(form16.employeeName),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        form16.employeeName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PAN: ${form16.employeePan}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _MetaRow('Employer TAN', form16.employerTan),
            const SizedBox(height: 4),
            _MetaRow('Assessment Year', form16.assessmentYear),
            const SizedBox(height: 4),
            _MetaRow('Certificate No.', form16.certificateNumber),
            const SizedBox(height: 4),
            _MetaRow('Total TDS', formatPaise(form16.partA.totalTaxDeposited)),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, 1).toUpperCase();
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Download button
// ---------------------------------------------------------------------------

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF download will be available soon')),
        );
      },
      icon: const Icon(Icons.download_rounded),
      label: const Text('Download PDF'),
    );
  }
}
