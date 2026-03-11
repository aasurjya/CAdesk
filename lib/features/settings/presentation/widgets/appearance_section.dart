import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/settings/domain/models/app_settings.dart';
import 'package:ca_app/features/settings/data/providers/settings_providers.dart';
import 'package:ca_app/features/settings/presentation/widgets/settings_section_header.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({
    super.key,
    required this.settings,
    required this.notifier,
  });

  final AppSettings settings;
  final SettingsNotifier notifier;

  static const _currencies = ['INR', 'USD', 'EUR', 'GBP', 'AED'];
  static const _financialYears = ['2023-24', '2024-25', '2025-26', '2026-27'];

  IconData _themeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.wb_sunny_outlined;
      case AppThemeMode.dark:
        return Icons.nightlight_outlined;
    }
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Currency',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            RadioGroup<String>(
              groupValue: settings.defaultCurrency,
              onChanged: (value) {
                if (value != null) {
                  notifier.setDefaultCurrency(value);
                  Navigator.pop(ctx);
                }
              },
              child: Column(
                children: _currencies
                    .map((c) => RadioListTile<String>(
                          value: c,
                          title: Text(c),
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

  void _showFinancialYearPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Financial Year',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            RadioGroup<String>(
              groupValue: settings.defaultFinancialYear,
              onChanged: (value) {
                if (value != null) {
                  notifier.setDefaultFinancialYear(value);
                  Navigator.pop(ctx);
                }
              },
              child: Column(
                children: _financialYears
                    .map((y) => RadioListTile<String>(
                          value: y,
                          title: Text('FY $y'),
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
          title: 'APPEARANCE',
          icon: Icons.palette_outlined,
        ),
        RadioGroup<AppThemeMode>(
          groupValue: settings.themeMode,
          onChanged: (value) {
            if (value != null) notifier.setThemeMode(value);
          },
          child: Column(
            children: AppThemeMode.values
                .map(
                  (mode) => RadioListTile<AppThemeMode>(
                    value: mode,
                    title: Text(mode.label),
                    secondary: Icon(_themeModeIcon(mode), size: 22),
                    dense: true,
                  ),
                )
                .toList(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.language_outlined, size: 22),
          title: const Text('Language'),
          trailing: _TrailingValue(value: settings.language),
          onTap: () {},
          dense: true,
        ),
        ListTile(
          leading: const Icon(Icons.currency_rupee, size: 22),
          title: const Text('Default Currency'),
          trailing: _TrailingValue(value: settings.defaultCurrency),
          onTap: () => _showCurrencyPicker(context),
          dense: true,
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined, size: 22),
          title: const Text('Default Financial Year'),
          trailing: _TrailingValue(value: settings.defaultFinancialYear),
          onTap: () => _showFinancialYearPicker(context),
          dense: true,
        ),
      ],
    );
  }
}

class _TrailingValue extends StatelessWidget {
  const _TrailingValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(color: AppColors.neutral600, fontSize: 14),
        ),
        const Icon(
          Icons.chevron_right,
          size: 18,
          color: AppColors.neutral400,
        ),
      ],
    );
  }
}
