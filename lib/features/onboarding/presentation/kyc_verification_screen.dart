import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// KYC verification step model
// ---------------------------------------------------------------------------

enum _KycDocType {
  pan('PAN Verification', Icons.credit_card_rounded, 'ABCDE1234F'),
  aadhaar('Aadhaar Verification', Icons.fingerprint_rounded, 'XXXX XXXX 5678'),
  bank(
    'Bank Account Verification',
    Icons.account_balance_rounded,
    'A/C: XXXX1234',
  ),
  gst('GST Registration', Icons.receipt_long_rounded, '27AABCU9603R1ZM');

  const _KycDocType(this.label, this.icon, this.hint);

  final String label;
  final IconData icon;
  final String hint;
}

enum _KycDocStatus { pending, uploaded, verifying, verified, failed }

extension _KycDocStatusX on _KycDocStatus {
  String get label {
    switch (this) {
      case _KycDocStatus.pending:
        return 'Pending';
      case _KycDocStatus.uploaded:
        return 'Uploaded';
      case _KycDocStatus.verifying:
        return 'Verifying';
      case _KycDocStatus.verified:
        return 'Verified';
      case _KycDocStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case _KycDocStatus.pending:
        return AppColors.neutral400;
      case _KycDocStatus.uploaded:
        return AppColors.primaryVariant;
      case _KycDocStatus.verifying:
        return AppColors.warning;
      case _KycDocStatus.verified:
        return AppColors.success;
      case _KycDocStatus.failed:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case _KycDocStatus.pending:
        return Icons.hourglass_empty_rounded;
      case _KycDocStatus.uploaded:
        return Icons.cloud_upload_rounded;
      case _KycDocStatus.verifying:
        return Icons.sync_rounded;
      case _KycDocStatus.verified:
        return Icons.check_circle_rounded;
      case _KycDocStatus.failed:
        return Icons.cancel_rounded;
    }
  }
}

/// KYC document collection and verification wizard.
///
/// Route: `/onboarding/kyc/:clientId`
class KycVerificationScreen extends ConsumerStatefulWidget {
  const KycVerificationScreen({required this.clientId, super.key});

  final String clientId;

  @override
  ConsumerState<KycVerificationScreen> createState() =>
      _KycVerificationScreenState();
}

class _KycVerificationScreenState extends ConsumerState<KycVerificationScreen> {
  final Map<_KycDocType, _KycDocStatus> _docStatuses = {
    _KycDocType.pan: _KycDocStatus.verified,
    _KycDocType.aadhaar: _KycDocStatus.uploaded,
    _KycDocType.bank: _KycDocStatus.pending,
    _KycDocType.gst: _KycDocStatus.pending,
  };

  int get _completedCount =>
      _docStatuses.values.where((s) => s == _KycDocStatus.verified).length;

  double get _progress => _completedCount / _KycDocType.values.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('KYC Verification', style: TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Client info & progress
            _ClientInfoCard(
              clientId: widget.clientId,
              progress: _progress,
              completedCount: _completedCount,
              totalCount: _KycDocType.values.length,
            ),
            const SizedBox(height: 20),

            // KYC steps
            ..._KycDocType.values.map((docType) {
              final status = _docStatuses[docType] ?? _KycDocStatus.pending;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _KycStepCard(
                  docType: docType,
                  status: status,
                  onUpload: () => _handleUpload(docType),
                  onVerify: () => _handleVerify(docType),
                  onRetry: () => _handleRetry(docType),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Submit button
            if (_completedCount == _KycDocType.values.length)
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('KYC verification completed successfully'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.pop();
                },
                icon: const Icon(Icons.verified_rounded, size: 18),
                label: const Text('Complete KYC'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Complete all ${_KycDocType.values.length} verification steps to finish KYC',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpload(_KycDocType docType) async {
    setState(() => _docStatuses[docType] = _KycDocStatus.uploaded);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${docType.label} document uploaded'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleVerify(_KycDocType docType) async {
    setState(() => _docStatuses[docType] = _KycDocStatus.verifying);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _docStatuses[docType] = _KycDocStatus.verified);
    }
  }

  void _handleRetry(_KycDocType docType) {
    setState(() => _docStatuses[docType] = _KycDocStatus.pending);
  }
}

// ---------------------------------------------------------------------------
// Client info card with progress
// ---------------------------------------------------------------------------

class _ClientInfoCard extends StatelessWidget {
  const _ClientInfoCard({
    required this.clientId,
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  final String clientId;
  final double progress;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client: $clientId',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$completedCount of $totalCount verifications complete',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: progress >= 1.0
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// KYC step card
// ---------------------------------------------------------------------------

class _KycStepCard extends StatelessWidget {
  const _KycStepCard({
    required this.docType,
    required this.status,
    required this.onUpload,
    required this.onVerify,
    required this.onRetry,
  });

  final _KycDocType docType;
  final _KycDocStatus status;
  final VoidCallback onUpload;
  final VoidCallback onVerify;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: status == _KycDocStatus.verified
              ? AppColors.success.withValues(alpha: 0.3)
              : status == _KycDocStatus.failed
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.neutral200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(docType.icon, size: 20, color: status.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docType.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        docType.hint,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 14, color: status.color),
                      const SizedBox(width: 4),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildAction() {
    switch (status) {
      case _KycDocStatus.pending:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: const Text('Upload Document'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        );
      case _KycDocStatus.uploaded:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onVerify,
            icon: const Icon(Icons.verified_rounded, size: 16),
            label: const Text('Verify Now'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryVariant,
            ),
          ),
        );
      case _KycDocStatus.verifying:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Verification in progress...',
              style: TextStyle(fontSize: 13, color: AppColors.neutral600),
            ),
          ],
        );
      case _KycDocStatus.verified:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColors.success,
            ),
            SizedBox(width: 6),
            Text(
              'Verification successful',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        );
      case _KycDocStatus.failed:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry Verification'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          ),
        );
    }
  }
}
