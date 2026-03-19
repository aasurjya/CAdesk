import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';

/// Overview tab content for the Client 360 screen.
///
/// Displays contact information, services availed, quick actions,
/// and metadata. Extracted from [ClientDetailScreen] for reuse.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _ContactSection(client: client),
        const SizedBox(height: AppSpacing.lg),
        _ServicesSection(services: client.servicesAvailed),
        const SizedBox(height: AppSpacing.lg),
        const _QuickActionsSection(),
        const SizedBox(height: AppSpacing.lg),
        _MetadataSection(client: client),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Contact information card
// ---------------------------------------------------------------------------

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
            const SizedBox(height: AppSpacing.sm),
            if (client.phone != null)
              _ContactRow(
                icon: Icons.phone,
                label: 'Phone',
                value: client.phone!,
                onTap: () => launchUrl(Uri(scheme: 'tel', path: client.phone)),
              ),
            if (client.alternatePhone != null)
              _ContactRow(
                icon: Icons.phone_forwarded,
                label: 'Alternate',
                value: client.alternatePhone!,
                onTap: () =>
                    launchUrl(Uri(scheme: 'tel', path: client.alternatePhone)),
              ),
            if (client.email != null)
              _ContactRow(
                icon: Icons.email,
                label: 'Email',
                value: client.email!,
                onTap: () =>
                    launchUrl(Uri(scheme: 'mailto', path: client.email)),
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
              _ContactRow(icon: Icons.badge, label: 'TAN', value: client.tan!),
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
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.neutral400),
              const SizedBox(width: AppSpacing.sm),
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
                        color: onTap != null ? AppColors.primaryVariant : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
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

// ---------------------------------------------------------------------------
// Services chips
// ---------------------------------------------------------------------------

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.services});

  final List<ServiceType> services;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (services.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
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

// ---------------------------------------------------------------------------
// Quick actions (File ITR / GST / TDS)
// ---------------------------------------------------------------------------

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

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
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.receipt_long,
                label: 'File ITR',
                color: AppColors.primary,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.receipt,
                label: 'File GST',
                color: AppColors.secondary,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.description,
                label: 'File TDS',
                color: AppColors.accent,
                onTap: () {},
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
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xs,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: AppSpacing.xs),
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

// ---------------------------------------------------------------------------
// Metadata (dates, client-since)
// ---------------------------------------------------------------------------

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
        padding: const EdgeInsets.all(AppSpacing.md),
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
