import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

class ReconciliationScreen extends StatelessWidget {
  const ReconciliationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          '26AS / AIS Reconciliation',
          style: TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Tax Data',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            _ImportCard(
              title: 'Form 26AS',
              subtitle: 'TDS/TCS credits, advance tax, refunds',
              icon: Icons.description_outlined,
            ),
            SizedBox(height: 8),
            _ImportCard(
              title: 'Annual Information Statement (AIS)',
              subtitle: 'Salary, interest, dividends, securities, purchases',
              icon: Icons.analytics_outlined,
            ),
            SizedBox(height: 24),
            Text(
              'Reconciliation Results',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.compare_arrows,
                        size: 48,
                        color: AppColors.neutral300,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Import 26AS or AIS data to begin reconciliation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The engine will automatically match income entries, '
                      'identify discrepancies, and highlight under-reported '
                      'or over-reported amounts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 12,
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

class _ImportCard extends StatelessWidget {
  const _ImportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const OutlinedButton(
          onPressed: null,
          child: Text('Coming Soon', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
