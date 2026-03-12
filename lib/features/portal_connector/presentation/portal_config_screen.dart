import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_connector/data/providers/portal_connector_providers.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';

/// Configuration screen for a single portal's credentials and sync settings.
class PortalConfigScreen extends ConsumerStatefulWidget {
  const PortalConfigScreen({super.key});

  @override
  ConsumerState<PortalConfigScreen> createState() => _PortalConfigScreenState();
}

class _PortalConfigScreenState extends ConsumerState<PortalConfigScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiKeyController = TextEditingController();
  bool _testResult = false;
  bool _isTesting = false;
  bool _showTestResult = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portal = ref.watch(selectedPortalProvider);
    final configs = ref.watch(portalConfigProvider);
    final config = configs[portal] ?? PortalConfig(portal: portal);
    final connections = ref.watch(portalConnectionsProvider);
    final connection = connections.firstWhere(
      (c) => c.portal == portal,
      orElse: () => PortalConnectionInfo(
        portal: portal,
        status: PortalConnectionStatus.disconnected,
        hasCredentials: false,
      ),
    );
    final theme = Theme.of(context);

    // Sync controllers with config on first build
    if (_usernameController.text.isEmpty && config.username.isNotEmpty) {
      _usernameController.text = config.username;
    }
    if (_apiKeyController.text.isEmpty && config.apiKey.isNotEmpty) {
      _apiKeyController.text = config.apiKey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _portalName(portal),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Portal Configuration',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ConnectionStatusBanner(connection: connection),
            const SizedBox(height: 20),
            _SectionLabel(label: 'Credentials'),
            const SizedBox(height: 8),
            _StyledTextField(
              controller: _usernameController,
              label: 'Username / Login ID',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 12),
            _StyledTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_rounded,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            _StyledTextField(
              controller: _apiKeyController,
              label: 'API Key (optional)',
              icon: Icons.vpn_key_rounded,
            ),
            const SizedBox(height: 20),
            _SectionLabel(label: 'Sync Frequency'),
            const SizedBox(height: 8),
            _SyncFrequencySelector(
              selected: config.syncFrequency,
              onChanged: (freq) {
                final updated = config.copyWith(syncFrequency: freq);
                ref
                    .read(portalConfigProvider.notifier)
                    .updateConfig(portal, updated);
              },
            ),
            const SizedBox(height: 20),
            if (connection.lastSyncAt != null) ...[
              _InfoRow(
                label: 'Last Successful Sync',
                value: _formatDateTime(connection.lastSyncAt!),
              ),
              const SizedBox(height: 16),
            ],
            _TestConnectionButton(
              isTesting: _isTesting,
              onPressed: () => _handleTestConnection(portal),
            ),
            if (_showTestResult) ...[
              const SizedBox(height: 12),
              _TestResultIndicator(success: _testResult),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _handleSave(portal, config),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save Configuration'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTestConnection(Portal portal) async {
    setState(() {
      _isTesting = true;
      _showTestResult = false;
    });

    await ref.read(portalConnectionsProvider.notifier).testConnection(portal);

    final connections = ref.read(portalConnectionsProvider);
    final conn = connections.firstWhere((c) => c.portal == portal);

    setState(() {
      _isTesting = false;
      _showTestResult = true;
      _testResult = conn.status == PortalConnectionStatus.connected;
    });
  }

  void _handleSave(Portal portal, PortalConfig config) {
    final updated = config.copyWith(
      username: _usernameController.text,
      apiKey: _apiKeyController.text,
      hasPassword: _passwordController.text.isNotEmpty,
    );
    ref.read(portalConfigProvider.notifier).updateConfig(portal, updated);

    if (updated.hasPassword) {
      ref
          .read(portalConnectionsProvider.notifier)
          .updateConnection(
            PortalConnectionInfo(
              portal: portal,
              status: PortalConnectionStatus.disconnected,
              hasCredentials: true,
            ),
          );
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Configuration saved')));
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _ConnectionStatusBanner extends StatelessWidget {
  const _ConnectionStatusBanner({required this.connection});

  final PortalConnectionInfo connection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = connection.status == PortalConnectionStatus.connected;
    final color = isConnected ? AppColors.success : AppColors.neutral400;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            isConnected ? 'Connected' : 'Not Connected',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _SyncFrequencySelector extends StatelessWidget {
  const _SyncFrequencySelector({
    required this.selected,
    required this.onChanged,
  });

  final SyncFrequency selected;
  final ValueChanged<SyncFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SyncFrequency.values.map((freq) {
        final isSelected = freq == selected;
        return ChoiceChip(
          label: Text(freq.label),
          selected: isSelected,
          onSelected: (_) => onChanged(freq),
        );
      }).toList(),
    );
  }
}

class _TestConnectionButton extends StatelessWidget {
  const _TestConnectionButton({
    required this.isTesting,
    required this.onPressed,
  });

  final bool isTesting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isTesting ? null : onPressed,
      icon: isTesting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.wifi_tethering_rounded, size: 18),
      label: Text(isTesting ? 'Testing...' : 'Test Connection'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _TestResultIndicator extends StatelessWidget {
  const _TestResultIndicator({required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = success ? AppColors.success : AppColors.error;
    final text = success ? 'Connection successful' : 'Connection failed';
    final icon = success ? Icons.check_circle_rounded : Icons.error_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _portalName(Portal portal) {
  switch (portal) {
    case Portal.itd:
      return 'Income Tax (ITD)';
    case Portal.gstn:
      return 'GST Network';
    case Portal.traces:
      return 'TRACES';
    case Portal.mca:
      return 'MCA Portal';
    case Portal.epfo:
      return 'EPFO';
    case Portal.nic:
      return 'NIC';
  }
}

String _formatDateTime(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final y = dt.year;
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$d/$m/$y $h:$min';
}
