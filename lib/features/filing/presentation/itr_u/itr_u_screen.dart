import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

class ItrUScreen extends StatelessWidget {
  const ItrUScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'ITR-U (Updated Return)',
          style: TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Section 139(8A) — Updated Return',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'An updated return can be filed within 24 months '
                      'from the end of the relevant assessment year to '
                      'correct errors or report additional income.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral600,
                      ),
                    ),
                    const Divider(height: 24),
                    _infoRow(
                      'Additional Tax',
                      'Filed within 12 months: 25% additional tax\n'
                          'Filed within 24 months: 50% additional tax',
                    ),
                    const SizedBox(height: 8),
                    _infoRow(
                      'Eligibility',
                      'Cannot be filed if original return was filed u/s 139(4) or 139(5)',
                    ),
                    const SizedBox(height: 8),
                    _infoRow(
                      'Reasons',
                      '• Return not filed previously\n'
                          '• Income not reported\n'
                          '• Wrong head of income\n'
                          '• Reduction of carry-forward loss\n'
                          '• Wrong rate of tax',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ITR-U filing wizard coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_document, size: 16),
                label: const Text('Start ITR-U Filing'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
          ),
        ),
      ],
    );
  }
}
