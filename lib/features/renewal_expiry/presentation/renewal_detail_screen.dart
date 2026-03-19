import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

class _RenewalStep {
  const _RenewalStep({
    required this.title,
    required this.isCompleted,
    this.note,
  });

  final String title;
  final bool isCompleted;
  final String? note;
}

class _RequiredDoc {
  const _RequiredDoc({required this.name, required this.isUploaded});

  final String name;
  final bool isUploaded;
}

class _RenewalDetail {
  const _RenewalDetail({
    required this.id,
    required this.clientName,
    required this.registrationType,
    required this.registrationNo,
    required this.status,
    required this.expiryDate,
    required this.renewalFee,
    required this.autoRenewal,
    required this.steps,
    required this.requiredDocs,
  });

  final String id;
  final String clientName;
  final String registrationType;
  final String registrationNo;
  final String status;
  final String expiryDate;
  final double renewalFee;
  final bool autoRenewal;
  final List<_RenewalStep> steps;
  final List<_RequiredDoc> requiredDocs;
}

const _mockRenewal = _RenewalDetail(
  id: 'REN-2026-041',
  clientName: 'Pinnacle Infotech Solutions Pvt Ltd',
  registrationType: 'GST Registration',
  registrationNo: '27AAAPZ1234C1ZV',
  status: 'Expiring Soon',
  expiryDate: '15 Apr 2026',
  renewalFee: 2500,
  autoRenewal: false,
  steps: [
    _RenewalStep(
      title: 'Verify current registration details',
      isCompleted: true,
    ),
    _RenewalStep(title: 'Collect required documents', isCompleted: true),
    _RenewalStep(
      title: 'File renewal application on portal',
      isCompleted: false,
      note: 'Pending ARN generation',
    ),
    _RenewalStep(title: 'Pay renewal fee', isCompleted: false),
    _RenewalStep(title: 'Download renewed certificate', isCompleted: false),
  ],
  requiredDocs: [
    _RequiredDoc(name: 'PAN Card of Entity', isUploaded: true),
    _RequiredDoc(name: 'Address Proof (Electricity Bill)', isUploaded: true),
    _RequiredDoc(name: 'Board Resolution', isUploaded: false),
    _RequiredDoc(name: 'Authorized Signatory DSC', isUploaded: false),
  ],
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Registration/license renewal detail screen.
///
/// Route: `/renewal-expiry/detail/:renewalId`
class RenewalDetailScreen extends ConsumerWidget {
  const RenewalDetailScreen({required this.renewalId, super.key});

  final String renewalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = _mockRenewal;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(r.id),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(renewal: r),
          const SizedBox(height: 16),

          // Renewal process steps
          const SectionHeader(
            title: 'Renewal Process',
            icon: Icons.timeline_rounded,
          ),
          const SizedBox(height: 8),
          ...r.steps.asMap().entries.map(
            (entry) => _StepTile(
              step: entry.value,
              isLast: entry.key == r.steps.length - 1,
            ),
          ),
          const SizedBox(height: 20),

          // Required documents
          const SectionHeader(
            title: 'Required Documents',
            icon: Icons.folder_outlined,
          ),
          const SizedBox(height: 8),
          ...r.requiredDocs.map((d) => _DocumentRow(doc: d)),
          const SizedBox(height: 20),

          // Fee & auto-renewal
          const SectionHeader(
            title: 'Renewal Fee & Settings',
            icon: Icons.settings_rounded,
          ),
          const SizedBox(height: 8),
          _FeeAndToggleCard(fee: r.renewalFee, autoRenewal: r.autoRenewal),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.renewal});

  final _RenewalDetail renewal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (renewal.status) {
      'Active' => AppColors.success,
      'Expiring Soon' => AppColors.warning,
      'Expired' => AppColors.error,
      _ => AppColors.neutral400,
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    renewal.clientName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                StatusBadge(label: renewal.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.badge_outlined,
              text: renewal.registrationType,
            ),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.tag, text: renewal.registrationNo),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.event_rounded,
              text: 'Expires: ${renewal.expiryDate}',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.neutral600),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.isLast});

  final _RenewalStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isCompleted
                      ? AppColors.success
                      : AppColors.neutral200,
                ),
                child: Icon(
                  step.isCompleted ? Icons.check : Icons.circle,
                  size: step.isCompleted ? 14 : 8,
                  color: step.isCompleted ? Colors.white : AppColors.neutral400,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.isCompleted
                        ? AppColors.success
                        : AppColors.neutral200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: step.isCompleted
                          ? AppColors.neutral400
                          : AppColors.neutral900,
                    ),
                  ),
                  if (step.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.note!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.doc});

  final _RequiredDoc doc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            doc.isUploaded
                ? Icons.check_circle_rounded
                : Icons.upload_file_rounded,
            size: 20,
            color: doc.isUploaded ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              doc.name,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral900),
            ),
          ),
          if (!doc.isUploaded)
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Upload', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _FeeAndToggleCard extends StatelessWidget {
  const _FeeAndToggleCard({required this.fee, required this.autoRenewal});

  final double fee;
  final bool autoRenewal;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Renewal Fee',
                  style: TextStyle(color: AppColors.neutral600),
                ),
                Text(
                  '\u20B9${fee.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Auto-renewal',
                  style: TextStyle(color: AppColors.neutral600),
                ),
                Switch.adaptive(
                  value: autoRenewal,
                  onChanged: (_) {},
                  activeTrackColor: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
