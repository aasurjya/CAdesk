import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/settings/presentation/widgets/settings_section_header.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(
          title: 'ABOUT',
          icon: Icons.info_outlined,
        ),
        const ListTile(
          leading: Icon(Icons.apps, size: 22),
          title: Text('App Version'),
          trailing: Text(
            'v0.1.0',
            style: TextStyle(color: AppColors.neutral600, fontSize: 14),
          ),
          dense: true,
        ),
        const ListTile(
          leading: Icon(Icons.build_outlined, size: 22),
          title: Text('Build Number'),
          trailing: Text(
            '100',
            style: TextStyle(color: AppColors.neutral600, fontSize: 14),
          ),
          dense: true,
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined, size: 22),
          title: const Text('Open-Source Licences'),
          trailing: const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.neutral400,
          ),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'CADesk',
            applicationVersion: 'v0.1.0',
          ),
          dense: true,
        ),
        ListTile(
          leading: const Icon(Icons.policy_outlined, size: 22),
          title: const Text('Privacy Policy'),
          trailing: const Icon(
            Icons.open_in_new,
            size: 16,
            color: AppColors.neutral400,
          ),
          onTap: () {},
          dense: true,
        ),
        ListTile(
          leading: const Icon(Icons.gavel_outlined, size: 22),
          title: const Text('Terms of Service'),
          trailing: const Icon(
            Icons.open_in_new,
            size: 16,
            color: AppColors.neutral400,
          ),
          onTap: () {},
          dense: true,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '© 2026 CADesk. Made with love for Indian CAs.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
