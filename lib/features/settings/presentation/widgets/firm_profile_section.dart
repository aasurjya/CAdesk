import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';
import 'package:ca_app/features/settings/data/providers/settings_providers.dart';
import 'package:ca_app/features/settings/presentation/widgets/settings_section_header.dart';

class FirmProfileSection extends StatelessWidget {
  const FirmProfileSection({
    super.key,
    required this.settings,
    required this.notifier,
  });

  final AppSettings settings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'FIRM PROFILE',
          icon: Icons.business_outlined,
        ),
        _EditableTile(
          icon: Icons.account_balance_outlined,
          title: 'Firm Name',
          value: settings.firmName,
          onSave: notifier.setFirmName,
          inputLabel: 'Firm Name',
        ),
        _EditableTile(
          icon: Icons.location_on_outlined,
          title: 'Firm Address',
          value: settings.firmAddress,
          onSave: notifier.setFirmAddress,
          inputLabel: 'Address',
          maxLines: 3,
        ),
        _EditableTile(
          icon: Icons.receipt_long_outlined,
          title: 'GSTIN',
          value: settings.firmGstin,
          onSave: notifier.setFirmGstin,
          inputLabel: 'GSTIN',
        ),
        _EditableTile(
          icon: Icons.badge_outlined,
          title: 'CA Registration No.',
          value: settings.caRegistrationNumber,
          onSave: notifier.setCaRegistrationNumber,
          inputLabel: 'Registration Number',
        ),
      ],
    );
  }
}

class _EditableTile extends StatelessWidget {
  const _EditableTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onSave,
    required this.inputLabel,
    this.maxLines = 1,
  });

  final IconData icon;
  final String title;
  final String value;
  final ValueChanged<String> onSave;
  final String inputLabel;
  final int maxLines;

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: value);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: inputLabel),
          maxLines: maxLines,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) onSave(trimmed);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title),
      subtitle: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.neutral600),
      ),
      trailing: const Icon(
        Icons.edit_outlined,
        size: 18,
        color: AppColors.neutral400,
      ),
      onTap: () => _showEditDialog(context),
      dense: true,
    );
  }
}
