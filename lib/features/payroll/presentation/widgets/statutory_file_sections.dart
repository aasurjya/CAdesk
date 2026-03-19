import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/statutory_return.dart';

/// File generation status tile.
class StatutoryFileStatus extends StatelessWidget {
  const StatutoryFileStatus({super.key, required this.record});

  final StatutoryReturn record;

  @override
  Widget build(BuildContext context) {
    final isFiled = record.status == StatutoryReturnStatus.filed;
    final fileName = _fileNameForType(record.returnType, record.period);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: ListTile(
        leading: Icon(
          isFiled ? Icons.file_present_rounded : Icons.file_copy_outlined,
          color: isFiled ? AppColors.success : AppColors.neutral400,
        ),
        title: Text(
          fileName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          isFiled ? 'Filed and acknowledged' : 'Ready for generation',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download_rounded, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloading $fileName...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  String _fileNameForType(StatutoryReturnType type, String period) {
    final sanitized = period.replaceAll(' ', '_').replaceAll('\u2013', '-');
    switch (type) {
      case StatutoryReturnType.pfEcr:
        return 'ECR_$sanitized.txt';
      case StatutoryReturnType.esiReturn:
        return 'ESI_Return_$sanitized.xlsx';
      case StatutoryReturnType.ptReturn:
        return 'PT_Return_$sanitized.pdf';
      case StatutoryReturnType.tds24q:
        return 'Form24Q_$sanitized.fvu';
    }
  }
}

/// Form linkage section for TDS 24Q returns.
class StatutoryFormLinkage extends StatelessWidget {
  const StatutoryFormLinkage({super.key, required this.record});

  final StatutoryReturn record;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.link_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Form Linkage',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            _LinkRow('Form 24Q', 'Quarterly TDS on Salary', true),
            _LinkRow('Form 26Q', 'TDS on Non-Salary Payments', false),
            _LinkRow(
              'Form 16',
              'Annual TDS Certificate (Part A & B)',
              record.status == StatutoryReturnStatus.filed,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow(this.formName, this.description, this.isAvailable);

  final String formName;
  final String description;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isAvailable
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 16,
            color: isAvailable ? AppColors.success : AppColors.neutral300,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
