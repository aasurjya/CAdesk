import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

enum _BotStatus { running, idle, error }

extension _BotStatusExt on _BotStatus {
  String get label => switch (this) {
    _BotStatus.running => 'Running',
    _BotStatus.idle => 'Idle',
    _BotStatus.error => 'Error',
  };
  Color get color => switch (this) {
    _BotStatus.running => AppColors.success,
    _BotStatus.idle => AppColors.neutral400,
    _BotStatus.error => AppColors.error,
  };
}

class _RpaBot {
  const _RpaBot({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.lastRun,
    required this.successCount,
    required this.failCount,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final _BotStatus status;
  final String lastRun;
  final int successCount;
  final int failCount;
  final IconData icon;
}

class _LogEntry {
  const _LogEntry({
    required this.botName,
    required this.message,
    required this.timestamp,
    required this.isError,
  });

  final String botName;
  final String message;
  final String timestamp;
  final bool isError;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockBots = <_RpaBot>[
  const _RpaBot(
    id: 'traces-f16',
    name: 'TRACES Form 16',
    description: 'Auto-download Form 16 from TRACES portal for all clients',
    status: _BotStatus.running,
    lastRun: '17 Mar 2026, 08:30',
    successCount: 142,
    failCount: 3,
    icon: Icons.description_rounded,
  ),
  const _RpaBot(
    id: 'gst-status',
    name: 'GST Filing Status',
    description: 'Check GSTR-3B filing status across all GSTINs',
    status: _BotStatus.idle,
    lastRun: '16 Mar 2026, 22:00',
    successCount: 87,
    failCount: 0,
    icon: Icons.receipt_long_rounded,
  ),
  const _RpaBot(
    id: 'mca-prefill',
    name: 'MCA Prefill',
    description: 'Prefill MCA annual return forms from company master data',
    status: _BotStatus.error,
    lastRun: '16 Mar 2026, 14:15',
    successCount: 31,
    failCount: 5,
    icon: Icons.business_rounded,
  ),
  const _RpaBot(
    id: 'epfo-ecr',
    name: 'EPFO ECR Upload',
    description: 'Upload ECR challan data to EPFO unified portal',
    status: _BotStatus.idle,
    lastRun: '15 Mar 2026, 10:00',
    successCount: 56,
    failCount: 1,
    icon: Icons.account_balance_rounded,
  ),
];

final _mockLogs = <_LogEntry>[
  const _LogEntry(
    botName: 'TRACES Form 16',
    message: 'Downloaded 24 Form 16s for batch AY 2026-27',
    timestamp: '08:32',
    isError: false,
  ),
  const _LogEntry(
    botName: 'MCA Prefill',
    message: 'Login failed: CAPTCHA verification timeout',
    timestamp: '14:16',
    isError: true,
  ),
  const _LogEntry(
    botName: 'GST Filing Status',
    message: 'Checked 87 GSTINs, all GSTR-3B filed for Feb 2026',
    timestamp: '22:01',
    isError: false,
  ),
  const _LogEntry(
    botName: 'EPFO ECR Upload',
    message: 'Uploaded ECR for 56 establishments, 1 rejected',
    timestamp: '10:05',
    isError: false,
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// RPA bot status dashboard showing bot states and execution logs.
class RpaDashboardScreen extends ConsumerWidget {
  const RpaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final runningCount = _mockBots
        .where((b) => b.status == _BotStatus.running)
        .length;
    final errorCount = _mockBots
        .where((b) => b.status == _BotStatus.error)
        .length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RPA Dashboard',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Portal automation bots',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Row(
            children: [
              SummaryCard(
                label: 'Total Bots',
                value: '${_mockBots.length}',
                icon: Icons.smart_toy_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Running',
                value: '$runningCount',
                icon: Icons.play_circle_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              SummaryCard(
                label: 'Errors',
                value: '$errorCount',
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bot list
          const SectionHeader(title: 'Bots', icon: Icons.smart_toy_rounded),
          const SizedBox(height: 10),
          ..._mockBots.map(
            (bot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BotCard(bot: bot),
            ),
          ),
          const SizedBox(height: 24),

          // Execution logs
          const SectionHeader(
            title: 'Execution Logs',
            icon: Icons.terminal_rounded,
          ),
          const SizedBox(height: 10),
          ..._mockLogs.map(
            (log) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LogTile(log: log),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bot card
// ---------------------------------------------------------------------------

class _BotCard extends StatelessWidget {
  const _BotCard({required this.bot});

  final _RpaBot bot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
                    color: bot.status.color.withAlpha(18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(bot.icon, color: bot.status.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bot.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        bot.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: bot.status.label, color: bot.status.color),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                _BotMeta(
                  icon: Icons.schedule_rounded,
                  label: 'Last run',
                  value: bot.lastRun,
                ),
                const Spacer(),
                _BotMeta(
                  icon: Icons.check_circle_outline,
                  label: 'Success',
                  value: '${bot.successCount}',
                ),
                const SizedBox(width: 16),
                _BotMeta(
                  icon: Icons.error_outline,
                  label: 'Failed',
                  value: '${bot.failCount}',
                ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Triggering ${bot.name}...')),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary.withAlpha(18),
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Run Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BotMeta extends StatelessWidget {
  const _BotMeta({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.neutral400),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
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
// Log tile
// ---------------------------------------------------------------------------

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final _LogEntry log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              log.isError
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              size: 18,
              color: log.isError ? AppColors.error : AppColors.success,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.botName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    log.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              log.timestamp,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
