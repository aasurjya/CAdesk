import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/payroll_providers.dart';
import '../domain/models/statutory_return.dart';
import 'widgets/statutory_detail_sections.dart';
import 'widgets/statutory_file_sections.dart';

/// Detail screen for a statutory return (PF ECR, ESI, PT, TDS 24Q).
class StatutoryDetailScreen extends ConsumerWidget {
  const StatutoryDetailScreen({super.key, required this.returnId});

  final String returnId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returns = ref.watch(statutoryReturnsProvider);
    final record = returns.where((r) => r.id == returnId).firstOrNull;

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statutory Return')),
        body: const Center(child: Text('Return not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: record.returnType.color,
        foregroundColor: Colors.white,
        title: Text(
          record.returnType.label,
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatutoryStatusBanner(record: record),
            const SizedBox(height: 14),
            StatutoryDetailsCard(record: record),
            const SizedBox(height: 14),
            StatutoryContributionPreview(record: record),
            const SizedBox(height: 14),
            StatutoryChallanStatus(record: record),
            const SizedBox(height: 14),
            StatutoryFileStatus(record: record),
            const SizedBox(height: 14),
            if (record.returnType == StatutoryReturnType.tds24q)
              StatutoryFormLinkage(record: record),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: record.status != StatutoryReturnStatus.filed
          ? FloatingActionButton.extended(
              heroTag: 'statutory_file',
              onPressed: () => _onFileReturn(context, record),
              backgroundColor: record.returnType.color,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('File Return'),
            )
          : null,
    );
  }

  void _onFileReturn(BuildContext context, StatutoryReturn record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filing ${record.returnType.label} for ${record.period}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
