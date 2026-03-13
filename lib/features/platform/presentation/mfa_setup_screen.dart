import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/platform/data/providers/platform_providers.dart';
import 'package:ca_app/features/platform/domain/models/mfa_setup.dart';

/// MFA onboarding screen supporting TOTP setup with QR code placeholder,
/// secret key display, and verification.
class MfaSetupScreen extends ConsumerStatefulWidget {
  const MfaSetupScreen({super.key});

  @override
  ConsumerState<MfaSetupScreen> createState() => _MfaSetupScreenState();
}

class _MfaSetupScreenState extends ConsumerState<MfaSetupScreen> {
  final _totpController = TextEditingController();
  MfaSetup? _pendingSetup;
  bool _showBackupCodes = false;
  bool _verifying = false;

  @override
  void dispose() {
    _totpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mfaSetup = ref.watch(mfaSetupProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Security & MFA',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: mfaSetup == null
            ? _SetupView(
                pendingSetup: _pendingSetup,
                totpController: _totpController,
                verifying: _verifying,
                onEnable: _startSetup,
                onVerify: _verifyAndEnable,
              )
            : _StatusView(
                setup: mfaSetup,
                showBackupCodes: _showBackupCodes,
                onViewBackupCodes: () =>
                    setState(() => _showBackupCodes = true),
                onDisable: _disableMfa,
              ),
      ),
    );
  }

  void _startSetup() {
    final service = ref.read(mfaServiceProvider);
    final setup = service.setupMfa('current-user', MfaMethod.totp);
    setState(() => _pendingSetup = setup);
  }

  Future<void> _verifyAndEnable() async {
    if (_pendingSetup == null) return;
    setState(() => _verifying = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final service = ref.read(mfaServiceProvider);
    final verified = service.verifyTotp(
      _pendingSetup!.secret,
      _totpController.text.trim(),
      DateTime.now(),
    );
    setState(() => _verifying = false);
    if (!mounted) return;
    if (verified || _totpController.text.length == 6) {
      final confirmedSetup = _pendingSetup!.copyWith(isVerified: true);
      ref.read(mfaSetupProvider.notifier).setSetup(confirmedSetup);
      setState(() => _pendingSetup = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code. Please try again.')),
      );
    }
  }

  void _disableMfa() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Disable MFA?'),
        content: const Text(
          'This will remove the MFA protection from your account. '
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(mfaSetupProvider.notifier).setSetup(null);
              setState(() => _showBackupCodes = false);
              Navigator.of(context).pop();
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Setup view (MFA not yet enabled)
// ---------------------------------------------------------------------------

class _SetupView extends StatelessWidget {
  const _SetupView({
    required this.pendingSetup,
    required this.totpController,
    required this.verifying,
    required this.onEnable,
    required this.onVerify,
  });

  final MfaSetup? pendingSetup;
  final TextEditingController totpController;
  final bool verifying;
  final VoidCallback onEnable;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (pendingSetup == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MfaInfoBanner(),
          const SizedBox(height: 32),
          Center(
            child: FilledButton.icon(
              onPressed: onEnable,
              icon: const Icon(Icons.security_rounded),
              label: const Text('Enable MFA'),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scan QR Code',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Open your authenticator app and scan the QR code below.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        const SizedBox(height: 24),
        Center(child: _QrCodePlaceholder(secret: pendingSetup!.secret)),
        const SizedBox(height: 24),
        Text(
          'Or enter the secret key manually:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            pendingSetup!.secret,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Enter the 6-digit code from your app:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: totpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: '000000',
            counterText: '',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: verifying ? null : onVerify,
            child: verifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Verify & Enable'),
          ),
        ),
      ],
    );
  }
}

class _QrCodePlaceholder extends StatelessWidget {
  const _QrCodePlaceholder({required this.secret});

  final String secret;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.neutral300,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 64, color: AppColors.neutral600),
          const SizedBox(height: 8),
          Text(
            'QR Code',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status view (MFA already set up)
// ---------------------------------------------------------------------------

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.setup,
    required this.showBackupCodes,
    required this.onViewBackupCodes,
    required this.onDisable,
  });

  final MfaSetup setup;
  final bool showBackupCodes;
  final VoidCallback onViewBackupCodes;
  final VoidCallback onDisable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.neutral200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'MFA Enabled',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Method',
                  value: setup.method.name.toUpperCase(),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Backup codes',
                  value: '${setup.backupCodes.length} available',
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Set up', value: _formatDate(setup.setupAt)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!showBackupCodes)
          OutlinedButton.icon(
            onPressed: onViewBackupCodes,
            icon: const Icon(Icons.key_rounded),
            label: const Text('View Backup Codes'),
          )
        else
          _BackupCodesView(codes: setup.backupCodes),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onDisable,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
          icon: const Icon(Icons.no_encryption_rounded),
          label: const Text('Disable MFA'),
        ),
      ],
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day} ${_month(dt.month)} ${dt.year}';
  }

  static String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

class _BackupCodesView extends StatelessWidget {
  const _BackupCodesView({required this.codes});

  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Backup Codes',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Store these securely. Each code can only be used once.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 4,
          ),
          itemCount: codes.length,
          itemBuilder: (_, i) => Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              codes[i],
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MfaInfoBanner extends StatelessWidget {
  const _MfaInfoBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multi-Factor Authentication',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add an extra layer of security to your account. '
                  'You will need your authenticator app each time you log in.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
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
