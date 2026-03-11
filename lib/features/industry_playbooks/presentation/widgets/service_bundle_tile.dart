import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/service_bundle.dart';

/// ListTile-style widget displaying a [ServiceBundle].
class ServiceBundleTile extends StatelessWidget {
  const ServiceBundleTile({required this.bundle, super.key});

  final ServiceBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      color: AppColors.neutral50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: bundle.isPopular
              ? AppColors.accent.withAlpha(100)
              : AppColors.neutral200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(),
            const SizedBox(height: 6),
            Text(
              bundle.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            _buildBadgeRow(),
            const SizedBox(height: 8),
            _buildInclusionsCount(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  bundle.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              if (bundle.isPopular) ...[
                const SizedBox(width: 6),
                _PopularBadge(),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${_formatPrice(bundle.pricePerMonth)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const Text(
              '/month',
              style: TextStyle(fontSize: 10, color: AppColors.neutral400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeRow() {
    return Row(
      children: [
        _SlaChip(label: bundle.slaLabel),
        const SizedBox(width: 8),
        Text(
          '${bundle.turnaroundDays}-day turnaround',
          style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
        ),
      ],
    );
  }

  Widget _buildInclusionsCount() {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 14,
          color: AppColors.success,
        ),
        const SizedBox(width: 4),
        Text(
          '${bundle.inclusions.length} services included',
          style: const TextStyle(fontSize: 12, color: AppColors.success),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)}L';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }
}

class _PopularBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent.withAlpha(80)),
      ),
      child: const Text(
        '⭐ Popular',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _SlaChip extends StatelessWidget {
  const _SlaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
