import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum AuthType { oauth2, apiKey, basic, jwt }

extension AuthTypeX on AuthType {
  String get label => switch (this) {
    AuthType.oauth2 => 'OAuth 2.0',
    AuthType.apiKey => 'API Key',
    AuthType.basic => 'Basic Auth',
    AuthType.jwt => 'JWT Bearer',
  };
}

enum SyncFrequency { realtime, hourly, daily, weekly, manual }

extension SyncFrequencyX on SyncFrequency {
  String get label => switch (this) {
    SyncFrequency.realtime => 'Real-time',
    SyncFrequency.hourly => 'Hourly',
    SyncFrequency.daily => 'Daily',
    SyncFrequency.weekly => 'Weekly',
    SyncFrequency.manual => 'Manual',
  };
}

class DataMapping {
  const DataMapping({
    required this.sourceField,
    required this.targetField,
    required this.transform,
  });

  final String sourceField;
  final String targetField;
  final String? transform;
}

class IntegrationDetail {
  const IntegrationDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.baseUrl,
    required this.authType,
    required this.syncFrequency,
    required this.isConnected,
    required this.lastSync,
    required this.mappings,
  });

  final String id;
  final String name;
  final String description;
  final String baseUrl;
  final AuthType authType;
  final SyncFrequency syncFrequency;
  final bool isConnected;
  final DateTime? lastSync;
  final List<DataMapping> mappings;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _integrationDetailProvider = Provider.family<IntegrationDetail, String>((
  ref,
  integrationId,
) {
  return IntegrationDetail(
    id: integrationId,
    name: 'Tally Prime',
    description: 'Accounting data sync for trial balance, P&L, and ledgers',
    baseUrl: 'https://tallyprime.local:9000/api/v1',
    authType: AuthType.basic,
    syncFrequency: SyncFrequency.daily,
    isConnected: true,
    lastSync: DateTime.now().subtract(const Duration(hours: 6)),
    mappings: const [
      DataMapping(
        sourceField: 'LedgerName',
        targetField: 'account_name',
        transform: 'trim + lowercase',
      ),
      DataMapping(
        sourceField: 'ClosingBalance',
        targetField: 'balance',
        transform: 'parseDecimal',
      ),
      DataMapping(
        sourceField: 'VoucherDate',
        targetField: 'transaction_date',
        transform: 'dd-MMM-yyyy -> ISO 8601',
      ),
      DataMapping(
        sourceField: 'PartyGSTIN',
        targetField: 'gstin',
        transform: null,
      ),
      DataMapping(
        sourceField: 'VoucherType',
        targetField: 'entry_type',
        transform: 'mapEnum(sales,purchase,journal)',
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class IntegrationDetailScreen extends ConsumerWidget {
  const IntegrationDetailScreen({super.key, required this.integrationId});

  final String integrationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_integrationDetailProvider(integrationId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Integration settings',
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
          // Connection status
          _ConnectionBanner(
            isConnected: detail.isConnected,
            lastSync: detail.lastSync,
          ),
          const SizedBox(height: 16),

          // Endpoint config
          const _SectionHeader(
            title: 'API Configuration',
            icon: Icons.settings_ethernet_rounded,
          ),
          const SizedBox(height: 10),
          _ConfigCard(detail: detail),
          const SizedBox(height: 16),

          // Auth settings
          const _SectionHeader(
            title: 'Authentication',
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 10),
          _AuthCard(authType: detail.authType),
          const SizedBox(height: 16),

          // Sync frequency
          const _SectionHeader(
            title: 'Sync Settings',
            icon: Icons.sync_rounded,
          ),
          const SizedBox(height: 10),
          _SyncCard(frequency: detail.syncFrequency),
          const SizedBox(height: 16),

          // Data mapping
          _SectionHeader(
            title: 'Data Mapping (${detail.mappings.length})',
            icon: Icons.compare_arrows_rounded,
          ),
          const SizedBox(height: 10),
          ...detail.mappings.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MappingTile(mapping: m),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.wifi_tethering_rounded, size: 18),
                  label: const Text('Test Connection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: const Text('Sync Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Connection banner
// ---------------------------------------------------------------------------

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.isConnected, required this.lastSync});

  final bool isConnected;
  final DateTime? lastSync;

  String _timeAgo(DateTime? dt) {
    if (dt == null) return 'Never';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle_rounded : Icons.error_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
              Text(
                'Last sync: ${_timeAgo(lastSync)}',
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Config card
// ---------------------------------------------------------------------------

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({required this.detail});

  final IntegrationDetail detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _Row(label: 'Base URL', value: detail.baseUrl),
            const Divider(height: 16),
            _Row(label: 'Description', value: detail.description),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Auth card
// ---------------------------------------------------------------------------

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.authType});

  final AuthType authType;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.key_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        title: Text(authType.label),
        subtitle: const Text('Credentials securely stored'),
        trailing: const Icon(Icons.edit_outlined, size: 18),
        dense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sync card
// ---------------------------------------------------------------------------

class _SyncCard extends StatelessWidget {
  const _SyncCard({required this.frequency});

  final SyncFrequency frequency;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.timer_outlined,
            size: 18,
            color: AppColors.secondary,
          ),
        ),
        title: Text(frequency.label),
        subtitle: const Text('Next sync based on schedule'),
        trailing: const Icon(Icons.edit_outlined, size: 18),
        dense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mapping tile
// ---------------------------------------------------------------------------

class _MappingTile extends StatelessWidget {
  const _MappingTile({required this.mapping});

  final DataMapping mapping;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mapping.sourceField,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Source',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.neutral300,
                ),
                if (mapping.transform != null)
                  Text(
                    mapping.transform!,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mapping.targetField,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Target',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

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
