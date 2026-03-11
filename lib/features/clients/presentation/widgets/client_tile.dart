import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/clients/presentation/widgets/client_avatar.dart';

class ClientTile extends StatelessWidget {
  const ClientTile({
    super.key,
    required this.client,
    this.onTap,
    this.onCall,
    this.onEmail,
  });

  final Client client;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onEmail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(client.id),
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.success,
        icon: Icons.phone,
        label: 'Call',
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: AppColors.primary,
        icon: Icons.email,
        label: 'Email',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onCall?.call();
        } else {
          onEmail?.call();
        }
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClientAvatar(
                  initials: client.initials,
                  clientType: client.clientType,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              client.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusDot(status: client.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            client.pan,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.neutral400,
                              fontFamily: 'monospace',
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ClientTypeBadge(clientType: client.clientType),
                        ],
                      ),
                      if (client.servicesAvailed.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _ServiceIcons(services: client.servicesAvailed),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final ClientStatus status;

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    switch (status) {
      case ClientStatus.active:
        dotColor = AppColors.success;
      case ClientStatus.inactive:
        dotColor = AppColors.neutral400;
      case ClientStatus.prospect:
        dotColor = AppColors.warning;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ClientTypeBadge extends StatelessWidget {
  const _ClientTypeBadge({required this.clientType});

  final ClientType clientType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: clientType.color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        clientType.label,
        style: TextStyle(
          color: clientType.color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ServiceIcons extends StatelessWidget {
  const _ServiceIcons({required this.services});

  final List<ServiceType> services;

  static const _serviceIconMap = <ServiceType, IconData>{
    ServiceType.itrFiling: Icons.receipt_long,
    ServiceType.gstFiling: Icons.receipt,
    ServiceType.tds: Icons.description,
    ServiceType.audit: Icons.verified,
    ServiceType.roc: Icons.gavel,
    ServiceType.payroll: Icons.payments,
    ServiceType.bookkeeping: Icons.menu_book,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: services.map((service) {
        return Tooltip(
          message: service.label,
          child: Icon(
            _serviceIconMap[service] ?? Icons.miscellaneous_services,
            size: 14,
            color: AppColors.neutral400,
          ),
        );
      }).toList(),
    );
  }
}
