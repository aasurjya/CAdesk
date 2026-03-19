import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/widgets.dart';

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

class _ScoreComponent {
  const _ScoreComponent({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.icon,
    required this.details,
  });

  final String name;
  final int score;
  final int maxScore;
  final IconData icon;
  final String details;

  double get percentage => score / maxScore;

  Color get color {
    if (percentage >= 0.9) return AppColors.success;
    if (percentage >= 0.7) return AppColors.primary;
    if (percentage >= 0.5) return AppColors.accent;
    return AppColors.error;
  }
}

class _ImprovementAction {
  const _ImprovementAction({
    required this.action,
    required this.impact,
    required this.priority,
  });

  final String action;
  final String impact;
  final String priority; // High, Medium, Low
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _mockComponents = <_ScoreComponent>[
  const _ScoreComponent(
    name: 'Compliance History',
    score: 92,
    maxScore: 100,
    icon: Icons.history_rounded,
    details:
        'Based on last 3 years filing track record across IT, GST, TDS, and ROC.',
  ),
  const _ScoreComponent(
    name: 'Filing Accuracy',
    score: 87,
    maxScore: 100,
    icon: Icons.fact_check_rounded,
    details:
        'Measures revised return frequency, notice count, and error-free submissions.',
  ),
  const _ScoreComponent(
    name: 'Response Timeliness',
    score: 78,
    maxScore: 100,
    icon: Icons.timer_rounded,
    details:
        'Average time to respond to ITD notices, GST queries, and assessment orders.',
  ),
  const _ScoreComponent(
    name: 'Data Quality',
    score: 95,
    maxScore: 100,
    icon: Icons.data_usage_rounded,
    details:
        'PAN verification rate, GSTIN validation, and client data completeness.',
  ),
];

final _mockActions = <_ImprovementAction>[
  const _ImprovementAction(
    action: 'Reduce average notice response time from 12 to 7 days',
    impact: '+8 points on Response Timeliness',
    priority: 'High',
  ),
  const _ImprovementAction(
    action: 'File all pending GSTR-9 annual returns for FY 2024-25',
    impact: '+3 points on Compliance History',
    priority: 'High',
  ),
  const _ImprovementAction(
    action: 'Implement pre-submission validation for ITR forms',
    impact: '+5 points on Filing Accuracy',
    priority: 'Medium',
  ),
  const _ImprovementAction(
    action: 'Complete PAN verification for 12 remaining clients',
    impact: '+2 points on Data Quality',
    priority: 'Low',
  ),
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _overallGrade(int score) {
  if (score >= 95) return 'A+';
  if (score >= 90) return 'A';
  if (score >= 80) return 'B';
  if (score >= 70) return 'C';
  return 'D';
}

Color _gradeColor(String grade) {
  switch (grade) {
    case 'A+':
    case 'A':
      return AppColors.success;
    case 'B':
      return AppColors.primary;
    case 'C':
      return AppColors.accent;
    default:
      return AppColors.error;
  }
}

Color _priorityColor(String priority) {
  switch (priority) {
    case 'High':
      return AppColors.error;
    case 'Medium':
      return AppColors.accent;
    default:
      return AppColors.neutral400;
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Regulatory trust score screen showing compliance ratings.
class TrustScoreScreen extends ConsumerWidget {
  const TrustScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final overallScore =
        (_mockComponents.fold<int>(0, (s, c) => s + c.score) /
                _mockComponents.length)
            .round();
    final grade = _overallGrade(overallScore);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trust Score',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Regulatory compliance rating',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall grade card
          _OverallGradeCard(score: overallScore, grade: grade),
          const SizedBox(height: 24),

          // Score components
          const SectionHeader(
            title: 'Score Components',
            icon: Icons.pie_chart_rounded,
          ),
          const SizedBox(height: 10),
          ..._mockComponents.map(
            (component) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ScoreCard(component: component),
            ),
          ),
          const SizedBox(height: 24),

          // Improvement actions
          const SectionHeader(
            title: 'Improvement Actions',
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 10),
          ..._mockActions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActionCard(action: action),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overall grade card
// ---------------------------------------------------------------------------

class _OverallGradeCard extends StatelessWidget {
  const _OverallGradeCard({required this.score, required this.grade});

  final int score;
  final String grade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _gradeColor(grade);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withAlpha(18), AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Grade circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 4),
              ),
              child: Center(
                child: Text(
                  grade,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Trust Score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$score / 100',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: AppColors.neutral200,
                      color: color,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score component card
// ---------------------------------------------------------------------------

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.component});

  final _ScoreComponent component;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: component.color.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(component.icon, color: component.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    component.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${component.score}/${component.maxScore}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: component.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: component.percentage,
                backgroundColor: AppColors.neutral100,
                color: component.color,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              component.details,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Improvement action card
// ---------------------------------------------------------------------------

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final _ImprovementAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    action.action,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: action.priority,
                  color: _priorityColor(action.priority),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                action.impact,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
