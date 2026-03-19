import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Groups form fields under a titled section with consistent spacing.
///
/// When [icon] is provided, renders a [SectionHeader]-style title row.
/// Otherwise renders a simpler text-only title.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(theme),
        const SizedBox(height: 8),
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          children[i],
        ],
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    if (icon != null) {
      return Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.neutral900,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.neutral900,
      ),
    );
  }
}
