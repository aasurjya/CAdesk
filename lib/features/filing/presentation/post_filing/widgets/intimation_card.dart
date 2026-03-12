import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

class IntimationCard extends StatelessWidget {
  const IntimationCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock — no intimation received yet
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mail_outline, size: 16, color: AppColors.neutral400),
                const SizedBox(width: 8),
                const Text(
                  'No Intimation Received',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Intimation u/s 143(1) is typically issued within 9 months '
              'of filing. Once received, it will appear here with the '
              'income comparison and demand/refund details.',
              style: TextStyle(fontSize: 12, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}
