import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/settings/data/providers/settings_providers.dart';
import 'package:ca_app/features/settings/presentation/widgets/appearance_section.dart';
import 'package:ca_app/features/settings/presentation/widgets/notifications_section.dart';
import 'package:ca_app/features/settings/presentation/widgets/security_section.dart';
import 'package:ca_app/features/settings/presentation/widgets/firm_profile_section.dart';
import 'package:ca_app/features/settings/presentation/widgets/about_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppearanceSection(settings: settings, notifier: notifier),
          const Divider(height: 1),
          NotificationsSection(settings: settings, notifier: notifier),
          const Divider(height: 1),
          SecuritySection(settings: settings, notifier: notifier),
          const Divider(height: 1),
          FirmProfileSection(settings: settings, notifier: notifier),
          const Divider(height: 1),
          const AboutSection(),
        ],
      ),
    );
  }
}
