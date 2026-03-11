import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';
import 'package:ca_app/features/settings/data/providers/settings_providers.dart';
import 'package:ca_app/features/settings/presentation/widgets/settings_section_header.dart';

class SecuritySection extends StatelessWidget {
  const SecuritySection({
    super.key,
    required this.settings,
    required this.notifier,
  });

  final AppSettings settings;
  final SettingsNotifier notifier;

  static const _lockOptions = [1, 2, 5, 10, 15, 30];

  void _showAutoLockPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Auto-Lock After',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            RadioGroup<int>(
              groupValue: settings.autoLockMinutes,
              onChanged: (value) {
                if (value != null) {
                  notifier.setAutoLockMinutes(value);
                  Navigator.pop(ctx);
                }
              },
              child: Column(
                children: _lockOptions
                    .map((minutes) => RadioListTile<int>(
                          value: minutes,
                          title: Text(
                            '$minutes minute${minutes == 1 ? '' : 's'}',
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'SECURITY',
          icon: Icons.security_outlined,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.fingerprint, size: 22),
          title: const Text('Biometric Unlock'),
          subtitle: const Text('Use fingerprint or Face ID to unlock'),
          value: settings.biometricEnabled,
          onChanged: (_) => notifier.toggleBiometric(),
          activeThumbColor: AppColors.primary,
          dense: true,
        ),
        ListTile(
          leading: const Icon(Icons.lock_clock_outlined, size: 22),
          title: const Text('Auto-Lock'),
          subtitle: Text(
            'Lock after ${settings.autoLockMinutes} minutes of inactivity',
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.neutral400,
          ),
          onTap: () => _showAutoLockPicker(context),
          dense: true,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.verified_user_outlined, size: 22),
          title: const Text('UDIN Generation'),
          subtitle: const Text('Auto-generate UDIN for applicable reports'),
          value: settings.udinEnabled,
          onChanged: (_) => notifier.toggleUdin(),
          activeThumbColor: AppColors.primary,
          dense: true,
        ),
      ],
    );
  }
}
