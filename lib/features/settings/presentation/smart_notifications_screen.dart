import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

enum _Channel { push, email, whatsapp, sms }

extension _ChannelExt on _Channel {
  String get label => switch (this) {
    _Channel.push => 'Push',
    _Channel.email => 'Email',
    _Channel.whatsapp => 'WhatsApp',
    _Channel.sms => 'SMS',
  };
  IconData get icon => switch (this) {
    _Channel.push => Icons.notifications_active_rounded,
    _Channel.email => Icons.email_rounded,
    _Channel.whatsapp => Icons.chat_rounded,
    _Channel.sms => Icons.sms_rounded,
  };
}

class _NotificationRule {
  const _NotificationRule({
    required this.id,
    required this.trigger,
    required this.action,
    required this.channels,
    required this.isEnabled,
  });

  final String id;
  final String trigger;
  final String action;
  final List<_Channel> channels;
  final bool isEnabled;

  _NotificationRule copyWith({bool? isEnabled}) => _NotificationRule(
    id: id,
    trigger: trigger,
    action: action,
    channels: channels,
    isEnabled: isEnabled ?? this.isEnabled,
  );
}

class _NotificationHistory {
  const _NotificationHistory({
    required this.title,
    required this.channel,
    required this.sentAt,
    required this.recipient,
  });

  final String title;
  final _Channel channel;
  final String sentAt;
  final String recipient;
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockRules = <_NotificationRule>[
  const _NotificationRule(
    id: 'rule-1',
    trigger: 'ITR deadline approaching (7 days)',
    action: 'Notify client + assigned staff',
    channels: [_Channel.push, _Channel.email, _Channel.whatsapp],
    isEnabled: true,
  ),
  const _NotificationRule(
    id: 'rule-2',
    trigger: 'Invoice payment overdue (30 days)',
    action: 'Send payment reminder to client',
    channels: [_Channel.email, _Channel.sms],
    isEnabled: true,
  ),
  const _NotificationRule(
    id: 'rule-3',
    trigger: 'Compliance gap detected',
    action: 'Alert practice manager',
    channels: [_Channel.push],
    isEnabled: false,
  ),
  const _NotificationRule(
    id: 'rule-4',
    trigger: 'Advance tax installment due (3 days)',
    action: 'Notify client and CA',
    channels: [_Channel.push, _Channel.email],
    isEnabled: true,
  ),
];

final _mockHistory = <_NotificationHistory>[
  const _NotificationHistory(
    title: 'ITR deadline reminder sent',
    channel: _Channel.whatsapp,
    sentAt: '17 Mar, 09:00',
    recipient: 'Rajesh Sharma',
  ),
  const _NotificationHistory(
    title: 'Invoice #342 payment reminder',
    channel: _Channel.email,
    sentAt: '16 Mar, 18:00',
    recipient: 'Priya Traders LLP',
  ),
  const _NotificationHistory(
    title: 'Advance tax Q4 reminder',
    channel: _Channel.push,
    sentAt: '15 Mar, 08:30',
    recipient: 'All clients',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Smart notification preferences and rule builder screen.
class SmartNotificationsScreen extends ConsumerStatefulWidget {
  const SmartNotificationsScreen({super.key});

  @override
  ConsumerState<SmartNotificationsScreen> createState() =>
      _SmartNotificationsScreenState();
}

class _SmartNotificationsScreenState
    extends ConsumerState<SmartNotificationsScreen> {
  var _channelToggles = <_Channel, bool>{
    for (final c in _Channel.values) c: true,
  };
  var _rules = List<_NotificationRule>.of(_mockRules);

  @override
  Widget build(BuildContext context) {
    final channelToggles = _channelToggles;
    final rules = _rules;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Notifications',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Rules, channels & history',
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
          // Channel settings
          const SectionHeader(title: 'Channels', icon: Icons.tune_rounded),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: _Channel.values.map((ch) {
                  return SwitchListTile(
                    secondary: Icon(ch.icon, color: AppColors.primary),
                    title: Text(
                      ch.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: channelToggles[ch] ?? true,
                    onChanged: (val) {
                      setState(() {
                        _channelToggles = Map<_Channel, bool>.of(channelToggles)
                          ..[ch] = val;
                      });
                    },
                    activeTrackColor: AppColors.primary,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notification rules
          const SectionHeader(title: 'Rules', icon: Icons.rule_rounded),
          const SizedBox(height: 10),
          ...rules.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RuleCard(
                rule: entry.value,
                onToggle: (enabled) {
                  setState(() {
                    final updated = List<_NotificationRule>.of(rules);
                    updated[entry.key] = entry.value.copyWith(
                      isEnabled: enabled,
                    );
                    _rules = updated;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notification history
          const SectionHeader(title: 'History', icon: Icons.history_rounded),
          const SizedBox(height: 10),
          ..._mockHistory.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HistoryTile(history: h),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rule card
// ---------------------------------------------------------------------------

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule, required this.onToggle});

  final _NotificationRule rule;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rule.trigger,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Switch(
                  value: rule.isEnabled,
                  onChanged: onToggle,
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
            Text(
              rule.action,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: rule.channels
                  .map(
                    (ch) => Chip(
                      avatar: Icon(ch.icon, size: 14),
                      label: Text(ch.label),
                      labelStyle: const TextStyle(fontSize: 11),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History tile
// ---------------------------------------------------------------------------

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.history});

  final _NotificationHistory history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(history.channel.icon, color: AppColors.primary),
        title: Text(
          history.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${history.recipient}  •  ${history.sentAt}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.snooze_rounded,
            size: 18,
            color: AppColors.neutral400,
          ),
          tooltip: 'Snooze',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification snoozed')),
            );
          },
        ),
      ),
    );
  }
}
