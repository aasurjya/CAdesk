import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ecosystem/domain/models/integration_connector.dart';

/// A card tile displaying a single integration connector with status and metrics.
class ConnectorTile extends StatelessWidget {
  const ConnectorTile({super.key, required this.connector});

  final IntegrationConnector connector;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar, name/subtitle, status chip
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      _categoryIcon(connector.category),
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connector.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          connector.provider != null
                              ? '${connector.category.label} \u2022 ${connector.provider}'
                              : connector.category.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: connector.status),
                ],
              ),
              const SizedBox(height: 8),

              // Bottom row: latency + last heartbeat
              Row(
                children: [
                  if (connector.status == ConnectorStatus.connected &&
                      connector.latencyMs != null) ...[
                    Icon(
                      Icons.speed_outlined,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${connector.latencyMs} ms',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (connector.lastHeartbeat != null) ...[
                    Icon(
                      Icons.access_time_outlined,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM, HH:mm')
                          .format(connector.lastHeartbeat!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _categoryIcon(ConnectorCategory category) {
  switch (category) {
    case ConnectorCategory.government:
      return Icons.account_balance_outlined;
    case ConnectorCategory.payment:
      return Icons.payment_outlined;
    case ConnectorCategory.esign:
      return Icons.draw_outlined;
    case ConnectorCategory.kyc:
      return Icons.video_call_outlined;
    case ConnectorCategory.messaging:
      return Icons.message_outlined;
    case ConnectorCategory.accounting:
      return Icons.calculate_outlined;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ConnectorStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
