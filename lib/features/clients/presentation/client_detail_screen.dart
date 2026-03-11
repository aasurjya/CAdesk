import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/presentation/widgets/client_avatar.dart';
import 'package:ca_app/features/clients/presentation/widgets/client_health_card.dart';
import 'package:ca_app/features/clients/presentation/widgets/edit_client_sheet.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientByIdProvider(clientId));

    if (client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Client')),
        body: const Center(child: Text('Client not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _HeroAppBar(client: client),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ClientHealthCard(clientId: client.id),
                const SizedBox(height: 20),
                _ContactSection(client: client),
                const SizedBox(height: 20),
                _ServicesSection(services: client.servicesAvailed),
                const SizedBox(height: 20),
                _QuickActionsSection(client: client),
                const SizedBox(height: 20),
                _DocumentsSection(),
                const SizedBox(height: 20),
                _NotesSection(notes: client.notes),
                const SizedBox(height: 20),
                _MetadataSection(client: client),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'client_detail_fab',
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => EditClientSheet(client: client),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(client.status);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryVariant,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClientAvatar(
                  initials: client.initials,
                  clientType: client.clientType,
                  radius: 36,
                  fontSize: 22,
                ),
                const SizedBox(height: 12),
                Text(
                  client.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      client.pan,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: client.clientType.color.withAlpha(60),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        client.clientType.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(60),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        client.status.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return AppColors.success;
      case ClientStatus.inactive:
        return AppColors.neutral400;
      case ClientStatus.prospect:
        return AppColors.warning;
    }
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            if (client.phone != null)
              _ContactRow(
                icon: Icons.phone,
                label: 'Phone',
                value: client.phone!,
                onTap: () => launchUrl(
                    Uri(scheme: 'tel', path: client.phone)),
              ),
            if (client.alternatePhone != null)
              _ContactRow(
                icon: Icons.phone_forwarded,
                label: 'Alternate',
                value: client.alternatePhone!,
                onTap: () => launchUrl(
                    Uri(scheme: 'tel', path: client.alternatePhone)),
              ),
            if (client.email != null)
              _ContactRow(
                icon: Icons.email,
                label: 'Email',
                value: client.email!,
                onTap: () => launchUrl(
                    Uri(scheme: 'mailto', path: client.email)),
              ),
            if (client.fullAddress.isNotEmpty)
              _ContactRow(
                icon: Icons.location_on,
                label: 'Address',
                value: client.fullAddress,
              ),
            if (client.gstin != null)
              _ContactRow(
                icon: Icons.assignment,
                label: 'GSTIN',
                value: client.gstin!,
              ),
            if (client.tan != null)
              _ContactRow(
                icon: Icons.badge,
                label: 'TAN',
                value: client.tan!,
              ),
            if (client.aadhaar != null)
              _ContactRow(
                icon: Icons.fingerprint,
                label: 'Aadhaar',
                value: client.aadhaar!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.neutral400),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: onTap != null
                            ? AppColors.primaryVariant
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: AppColors.neutral400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.services});

  final List<ServiceType> services;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services Availed',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services.map((service) {
                return Chip(
                  avatar: Icon(
                    _serviceIcon(service),
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    service.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppColors.primary.withAlpha(15),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _serviceIcon(ServiceType service) {
    switch (service) {
      case ServiceType.itrFiling:
        return Icons.receipt_long;
      case ServiceType.gstFiling:
        return Icons.receipt;
      case ServiceType.tds:
        return Icons.description;
      case ServiceType.audit:
        return Icons.verified;
      case ServiceType.roc:
        return Icons.gavel;
      case ServiceType.payroll:
        return Icons.payments;
      case ServiceType.bookkeeping:
        return Icons.menu_book;
    }
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.client});

  final Client client;

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Quick Actions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.email_outlined,
                label: 'Send Email',
                color: AppColors.primary,
                onTap: client.email != null
                    ? () => launchUrl(
                          Uri(scheme: 'mailto', path: client.email),
                        )
                    : () => _showSnackBar(
                          context,
                          'No email on file for ${client.name}',
                        ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.phone_outlined,
                label: 'Call',
                color: AppColors.secondary,
                onTap: client.phone != null
                    ? () => launchUrl(
                          Uri(scheme: 'tel', path: client.phone),
                        )
                    : () => _showSnackBar(
                          context,
                          'No phone on file for ${client.name}',
                        ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.task_alt,
                label: 'Add Task',
                color: AppColors.accent,
                onTap: () => _showSnackBar(
                  context,
                  'Task added for ${client.name}',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.receipt_long_outlined,
                label: 'Invoice',
                color: AppColors.success,
                onTap: () => _showSnackBar(
                  context,
                  'Opening billing for ${client.name}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  static const _placeholderDocs = [
    _DocItem(name: 'PAN Card', icon: Icons.credit_card),
    _DocItem(name: 'Aadhaar Card', icon: Icons.fingerprint),
    _DocItem(name: 'Form 16', icon: Icons.description),
    _DocItem(name: 'Bank Statement', icon: Icons.account_balance),
    _DocItem(name: 'GST Certificate', icon: Icons.verified_user),
  ];

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Documents',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Upload',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_placeholderDocs.length, (index) {
              final doc = _placeholderDocs[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(doc.icon,
                      size: 18, color: AppColors.neutral600),
                ),
                title: Text(
                  doc.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(Icons.download,
                    size: 18, color: AppColors.neutral400),
                onTap: () {},
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DocItem {
  const _DocItem({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({this.notes});

  final String? notes;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note, size: 20),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notes ?? 'No notes added yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: notes != null
                    ? AppColors.neutral600
                    : AppColors.neutral400,
                fontStyle:
                    notes == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      color: AppColors.neutral50,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (client.dateOfBirth != null)
              _MetaRow(
                label: 'Date of Birth',
                value: dateFormat.format(client.dateOfBirth!),
              ),
            if (client.dateOfIncorporation != null)
              _MetaRow(
                label: 'Date of Incorporation',
                value: dateFormat.format(client.dateOfIncorporation!),
              ),
            _MetaRow(
              label: 'Client since',
              value: dateFormat.format(client.createdAt),
            ),
            _MetaRow(
              label: 'Last updated',
              value: dateFormat.format(client.updatedAt),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
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
              fontWeight: FontWeight.w500,
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}
