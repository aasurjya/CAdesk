import 'package:flutter/material.dart';

import 'package:ca_app/features/filing/domain/models/filing_job.dart';

class BulkStatusUpdateSheet extends StatelessWidget {
  const BulkStatusUpdateSheet({
    required this.selectedIds,
    required this.onStatusSelected,
    super.key,
  });

  final List<String> selectedIds;
  final void Function(FilingJobStatus) onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status (${selectedIds.length} filings)',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...FilingJobStatus.values.map(
              (status) => ListTile(
                leading: Icon(status.icon, color: status.color),
                title: Text(status.label),
                dense: true,
                onTap: () => onStatusSelected(status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
