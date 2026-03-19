import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum EformStatus { uploaded, processing, accepted, rejected }

extension EformStatusX on EformStatus {
  String get label => switch (this) {
    EformStatus.uploaded => 'Uploaded',
    EformStatus.processing => 'Processing',
    EformStatus.accepted => 'Accepted',
    EformStatus.rejected => 'Rejected',
  };

  Color get color => switch (this) {
    EformStatus.uploaded => AppColors.secondary,
    EformStatus.processing => AppColors.warning,
    EformStatus.accepted => AppColors.success,
    EformStatus.rejected => AppColors.error,
  };

  IconData get icon => switch (this) {
    EformStatus.uploaded => Icons.cloud_upload_rounded,
    EformStatus.processing => Icons.hourglass_top_rounded,
    EformStatus.accepted => Icons.check_circle_rounded,
    EformStatus.rejected => Icons.cancel_rounded,
  };
}

class EformUpload {
  const EformUpload({
    required this.formName,
    required this.companyName,
    required this.cin,
    required this.status,
    required this.uploadedAt,
    required this.srn,
  });

  final String formName;
  final String companyName;
  final String cin;
  final EformStatus status;
  final DateTime uploadedAt;
  final String srn;
}

class VerificationRequest {
  const VerificationRequest({
    required this.type,
    required this.value,
    required this.name,
    required this.isVerified,
    required this.verifiedAt,
  });

  final String type;
  final String value;
  final String name;
  final bool isVerified;
  final DateTime? verifiedAt;
}

class NameReservation {
  const NameReservation({
    required this.proposedName,
    required this.status,
    required this.statusColor,
    required this.appliedAt,
    required this.srn,
  });

  final String proposedName;
  final String status;
  final Color statusColor;
  final DateTime appliedAt;
  final String srn;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _mcaApiUpProvider = Provider<bool>((ref) => true);

final _eformUploadsProvider = Provider<List<EformUpload>>((ref) {
  return [
    EformUpload(
      formName: 'AOC-4',
      companyName: 'ABC Pvt Ltd',
      cin: 'U72200MH2020PTC123456',
      status: EformStatus.accepted,
      uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
      srn: 'SRN-2026-0045678',
    ),
    EformUpload(
      formName: 'MGT-7A',
      companyName: 'XYZ Solutions Pvt Ltd',
      cin: 'U74999DL2019PTC345678',
      status: EformStatus.processing,
      uploadedAt: DateTime.now().subtract(const Duration(hours: 8)),
      srn: 'SRN-2026-0049012',
    ),
    EformUpload(
      formName: 'DIR-12',
      companyName: 'ABC Pvt Ltd',
      cin: 'U72200MH2020PTC123456',
      status: EformStatus.rejected,
      uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
      srn: 'SRN-2026-0047890',
    ),
  ];
});

final _verificationsProvider = Provider<List<VerificationRequest>>((ref) {
  return [
    VerificationRequest(
      type: 'DIN',
      value: '08765432',
      name: 'Ramesh Agarwal',
      isVerified: true,
      verifiedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    VerificationRequest(
      type: 'DPIN',
      value: '05432109',
      name: 'Suresh Mehta',
      isVerified: true,
      verifiedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    VerificationRequest(
      type: 'DIN',
      value: '09876543',
      name: 'Pending Director',
      isVerified: false,
      verifiedAt: null,
    ),
  ];
});

final _nameReservationsProvider = Provider<List<NameReservation>>((ref) {
  return [
    NameReservation(
      proposedName: 'InnovateTech Solutions',
      status: 'Approved',
      statusColor: AppColors.success,
      appliedAt: DateTime.now().subtract(const Duration(days: 15)),
      srn: 'SRN-RUN-2026-001234',
    ),
    NameReservation(
      proposedName: 'GreenLeaf Organics',
      status: 'Under Review',
      statusColor: AppColors.warning,
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      srn: 'SRN-RUN-2026-004567',
    ),
  ];
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class McaApiStatusScreen extends ConsumerWidget {
  const McaApiStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUp = ref.watch(_mcaApiUpProvider);
    final eforms = ref.watch(_eformUploadsProvider);
    final verifications = ref.watch(_verificationsProvider);
    final reservations = ref.watch(_nameReservationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MCA API Status',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Ministry of Corporate Affairs',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner
          _StatusBanner(isUp: isUp),
          const SizedBox(height: 16),

          // E-form uploads
          _SectionHeader(
            title: 'E-Form Uploads',
            icon: Icons.upload_file_rounded,
          ),
          const SizedBox(height: 10),
          ...eforms.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EformTile(eform: e),
            ),
          ),
          const SizedBox(height: 16),

          // DIN/DPIN verification
          _SectionHeader(
            title: 'DIN/DPIN Verification',
            icon: Icons.verified_user_rounded,
          ),
          const SizedBox(height: 10),
          ...verifications.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _VerificationTile(verification: v),
            ),
          ),
          const SizedBox(height: 16),

          // Name reservation
          _SectionHeader(
            title: 'Name Reservations (RUN)',
            icon: Icons.badge_rounded,
          ),
          const SizedBox(height: 10),
          ...reservations.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _NameReservationTile(reservation: r),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status banner
// ---------------------------------------------------------------------------

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.isUp});

  final bool isUp;

  @override
  Widget build(BuildContext context) {
    final color = isUp ? AppColors.success : AppColors.error;
    final label = isUp ? 'MCA V3 portal is operational' : 'MCA portal is down';
    final icon = isUp ? Icons.check_circle_rounded : Icons.error_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// E-form tile
// ---------------------------------------------------------------------------

class _EformTile extends StatelessWidget {
  const _EformTile({required this.eform});

  final EformUpload eform;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(eform.status.icon, size: 20, color: eform.status.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${eform.formName} - ${eform.companyName}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        eform.cin,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: eform.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    eform.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: eform.status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'SRN: ${eform.srn}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.neutral400,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Verification tile
// ---------------------------------------------------------------------------

class _VerificationTile extends StatelessWidget {
  const _VerificationTile({required this.verification});

  final VerificationRequest verification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = verification.isVerified
        ? AppColors.success
        : AppColors.warning;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            verification.isVerified
                ? Icons.verified_rounded
                : Icons.pending_rounded,
            size: 18,
            color: color,
          ),
        ),
        title: Text(
          '${verification.type}: ${verification.value}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(
          verification.name,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        trailing: Text(
          verification.isVerified ? 'Verified' : 'Pending',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        dense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Name reservation tile
// ---------------------------------------------------------------------------

class _NameReservationTile extends StatelessWidget {
  const _NameReservationTile({required this.reservation});

  final NameReservation reservation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: reservation.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.badge_rounded,
            size: 18,
            color: reservation.statusColor,
          ),
        ),
        title: Text(
          reservation.proposedName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'SRN: ${reservation.srn}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
            fontFamily: 'monospace',
            fontSize: 10,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: reservation.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            reservation.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: reservation.statusColor,
            ),
          ),
        ),
        dense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
