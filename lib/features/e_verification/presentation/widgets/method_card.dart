import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_method.dart';

/// A selectable card for a verification method with icon, name, description,
/// and optional recommended badge.
class MethodCard extends StatelessWidget {
  const MethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
    this.isRecommended = false,
    super.key,
  });

  final VerificationMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected ? AppColors.primary : AppColors.neutral200;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(8)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          method.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Recommended',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (method) {
      case VerificationMethod.evcNetBanking:
        return Icons.account_balance;
      case VerificationMethod.evcBankAccount:
        return Icons.account_balance_wallet;
      case VerificationMethod.aadhaarOtp:
        return Icons.phone_android;
      case VerificationMethod.dsc:
        return Icons.key;
    }
  }

  Color get _iconColor {
    switch (method) {
      case VerificationMethod.evcNetBanking:
        return AppColors.primary;
      case VerificationMethod.evcBankAccount:
        return AppColors.secondary;
      case VerificationMethod.aadhaarOtp:
        return AppColors.accent;
      case VerificationMethod.dsc:
        return const Color(0xFF7C3AED);
    }
  }
}
