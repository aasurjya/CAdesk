import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/practice_benchmarking/data/providers/practice_benchmarking_providers.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/growth_score.dart';
import 'package:ca_app/features/practice_benchmarking/presentation/widgets/benchmark_card.dart';
import 'package:ca_app/features/practice_benchmarking/presentation/widgets/growth_score_tile.dart';

/// Main screen for the Practice Benchmarking module.
///
/// Shows an overall growth score summary, a tabbed view of benchmark metrics
/// with category filtering, and growth score dimension tiles.
class PracticeBenchmarkingScreen extends ConsumerStatefulWidget {
  const PracticeBenchmarkingScreen({super.key});

  @override
  ConsumerState<PracticeBenchmarkingScreen> createState() =>
      _PracticeBenchmarkingScreenState();
}

class _PracticeBenchmarkingScreenState
    extends ConsumerState<PracticeBenchmarkingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overall = ref.watch(overallGrowthScoreProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.neutral900,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practice Benchmarking',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Anonymous peer comparisons',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _OverallScoreCard(overall: overall, theme: theme),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabBar: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.neutral400,
                  indicatorColor: AppColors.primary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Benchmarks'),
                    Tab(text: 'Growth Scores'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [_BenchmarksTab(), _GrowthScoresTab()],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overall growth score card
// ---------------------------------------------------------------------------

class _OverallScoreCard extends StatelessWidget {
  const _OverallScoreCard({required this.overall, required this.theme});

  final GrowthScore overall;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final scoreColor = overall.isAbovePeerAverage
        ? AppColors.success
        : AppColors.warning;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _ScoreCircle(overall: overall, scoreColor: scoreColor),
          const SizedBox(width: 20),
          Expanded(
            child: _ScoreSummary(
              overall: overall,
              scoreColor: scoreColor,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.overall, required this.scoreColor});

  final GrowthScore overall;
  final Color scoreColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(
        painter: _CirclePainter(
          fraction: overall.scoreFraction,
          color: scoreColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${overall.score.toInt()}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: scoreColor,
                  height: 1.1,
                ),
              ),
              const Text(
                '/100',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  const _CirclePainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const startAngle = -3.14159 / 2; // top
    final sweepAngle = 2 * 3.14159 * fraction;

    final trackPaint = Paint()
      ..color = AppColors.neutral200
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return oldDelegate.fraction != fraction || oldDelegate.color != color;
  }
}

class _ScoreSummary extends StatelessWidget {
  const _ScoreSummary({
    required this.overall,
    required this.scoreColor,
    required this.theme,
  });

  final GrowthScore overall;
  final Color scoreColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              overall.dimension,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(width: 8),
            _GradeChip(grade: overall.grade, color: scoreColor),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.people_alt_outlined,
              size: 13,
              color: AppColors.neutral400,
            ),
            const SizedBox(width: 4),
            Text(
              'Peer avg: ${overall.peerAverage.toInt()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              overall.isAbovePeerAverage
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 13,
              color: scoreColor,
            ),
            Text(
              '${(overall.score - overall.peerAverage).abs().toStringAsFixed(0)} pts ${overall.isAbovePeerAverage ? "above" : "below"}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          overall.insight,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral600,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({required this.grade, required this.color});

  final String grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        grade,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Benchmarks tab
// ---------------------------------------------------------------------------

class _BenchmarksTab extends ConsumerWidget {
  const _BenchmarksTab();

  static const _categories = [
    'All',
    'Financial',
    'Operational',
    'Client',
    'Technology',
    'Team',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedBenchmarkCategoryProvider);
    final metrics = ref.watch(filteredBenchmarkMetricsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _CategoryFilterChips(
            categories: _categories,
            selected: selected,
            onSelected: (cat) {
              ref
                  .read(selectedBenchmarkCategoryProvider.notifier)
                  .select(cat == 'All' ? null : cat);
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => BenchmarkCard(metric: metrics[index]),
              childCount: metrics.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryFilterChips extends StatelessWidget {
  const _CategoryFilterChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive =
              (cat == 'All' && selected == null) ||
              (cat != 'All' && selected == cat);
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.neutral200,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.surface : AppColors.neutral600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Growth scores tab
// ---------------------------------------------------------------------------

class _GrowthScoresTab extends ConsumerWidget {
  const _GrowthScoresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(dimensionGrowthScoresProvider);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => GrowthScoreTile(score: scores[index]),
              childCount: scores.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SliverPersistentHeaderDelegate for the tab bar
// ---------------------------------------------------------------------------

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.tabBar});

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.surface, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
