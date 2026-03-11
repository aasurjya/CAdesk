import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';
import 'package:ca_app/features/settings/data/providers/settings_providers.dart';
import 'package:ca_app/features/settings/presentation/widgets/settings_section_header.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({
    super.key,
    required this.settings,
    required this.notifier,
  });

  final AppSettings settings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final notificationsOn = settings.notificationsEnabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'NOTIFICATIONS',
          icon: Icons.notifications_outlined,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications, size: 22),
          title: const Text('Push Notifications'),
          subtitle: const Text('Enable all in-app notifications'),
          value: notificationsOn,
          onChanged: (_) => notifier.toggleNotifications(),
          activeThumbColor: AppColors.primary,
          dense: true,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.email_outlined, size: 22),
          title: const Text('Email Notifications'),
          subtitle: const Text('Task reminders and compliance alerts'),
          value: settings.emailNotifications && notificationsOn,
          onChanged: notificationsOn
              ? (_) => notifier.toggleEmailNotifications()
              : null,
          activeThumbColor: AppColors.primary,
          dense: true,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.sms_outlined, size: 22),
          title: const Text('SMS Notifications'),
          subtitle: const Text('Critical deadline alerts via SMS'),
          value: settings.smsNotifications && notificationsOn,
          onChanged: notificationsOn
              ? (_) => notifier.toggleSmsNotifications()
              : null,
          activeThumbColor: AppColors.primary,
          dense: true,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.chat_outlined, size: 22),
          title: const Text('WhatsApp Notifications'),
          subtitle: const Text('Client updates via WhatsApp Business'),
          value: settings.whatsappNotifications && notificationsOn,
          onChanged: notificationsOn
              ? (_) => notifier.toggleWhatsappNotifications()
              : null,
          activeThumbColor: AppColors.primary,
          dense: true,
        ),
      ],
    );
  }
}
