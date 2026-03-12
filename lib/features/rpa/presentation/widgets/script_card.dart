import 'package:flutter/material.dart';

import 'package:ca_app/features/rpa/domain/models/automation_script.dart';
import 'package:ca_app/features/rpa/presentation/widgets/portal_badge.dart';

/// Grid card for a single [AutomationScript] in the script library.
class ScriptCard extends StatelessWidget {
  const ScriptCard({
    required this.script,
    required this.onRun,
    super.key,
  });

  final AutomationScript script;
  final VoidCallback onRun;

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _portalIcon(script.targetPortal),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                PortalBadge(portal: script.targetPortal),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              script.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${script.steps.length} steps'
              ' · ~${script.estimatedDurationSeconds}s',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onRun,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Run'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _portalIcon(AutomationPortal portal) {
    switch (portal) {
      case AutomationPortal.traces:
        return Icons.download_rounded;
      case AutomationPortal.gstn:
        return Icons.receipt_long_rounded;
      case AutomationPortal.mca:
        return Icons.business_rounded;
      case AutomationPortal.itd:
        return Icons.account_balance_rounded;
      case AutomationPortal.epfo:
        return Icons.people_rounded;
    }
  }
}
