import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/ai/genui/widgets/genui_card.dart';
import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/dashboard/data/providers/ai_insights_provider.dart';

/// Dashboard section showing AI-generated insights.
class AiInsightsSection extends ConsumerWidget {
  const AiInsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final insightsAsync = ref.watch(aiInsightsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha(18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.accent,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral900,
                    ),
                  ),
                  Text(
                    'Personalized recommendations based on your practice data',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        insightsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (insights) {
            if (insights.isEmpty) return const SizedBox.shrink();
            return Column(
              children: insights
                  .map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GenUiCard(directive: d),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
