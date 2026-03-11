import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_circular.dart';

/// Card widget displaying the key details of a [RegulatoryCircular].
class CircularCard extends StatelessWidget {
  const CircularCard({super.key, required this.circular});

  final RegulatoryCircular circular;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderRow(circular: circular),
            const SizedBox(height: 8),
            Text(
              circular.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              circular.summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            _KeyChangesList(keyChanges: circular.keyChanges),
            const SizedBox(height: 10),
            _FooterRow(circular: circular),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.circular});

  final RegulatoryCircular circular;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IssuingBodyBadge(issuingBody: circular.issuingBody),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            circular.circularNumber,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _ImpactChip(impactLevel: circular.impactLevel),
      ],
    );
  }
}

class _IssuingBodyBadge extends StatelessWidget {
  const _IssuingBodyBadge({required this.issuingBody});

  final String issuingBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        issuingBody,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ImpactChip extends StatelessWidget {
  const _ImpactChip({required this.impactLevel});

  final String impactLevel;

  Color get _backgroundColor {
    switch (impactLevel) {
      case 'High':
        return AppColors.error.withAlpha(20);
      case 'Medium':
        return AppColors.warning.withAlpha(20);
      default:
        return AppColors.success.withAlpha(20);
    }
  }

  Color get _textColor {
    switch (impactLevel) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        impactLevel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}

class _KeyChangesList extends StatelessWidget {
  const _KeyChangesList({required this.keyChanges});

  final List<String> keyChanges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayChanges = keyChanges.length > 2
        ? keyChanges.sublist(0, 2)
        : keyChanges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: displayChanges
          .map(
            (change) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5, right: 6),
                    child: CircleAvatar(
                      radius: 2.5,
                      backgroundColor: AppColors.neutral400,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      change,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({required this.circular});

  final RegulatoryCircular circular;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Icon(
          Icons.people_outline_rounded,
          size: 14,
          color: AppColors.neutral400,
        ),
        const SizedBox(width: 4),
        Text(
          '${circular.affectedClientsCount} clients',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(
          Icons.calendar_today_rounded,
          size: 14,
          color: AppColors.neutral400,
        ),
        const SizedBox(width: 4),
        Text(
          'Effective: ${circular.effectiveDate}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        const Spacer(),
        _CategoryChip(category: circular.category),
        const SizedBox(width: 8),
        Text(
          circular.issueDate,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
