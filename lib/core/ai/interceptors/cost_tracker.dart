import 'package:ca_app/core/ai/models/ai_error.dart';
import 'package:ca_app/core/ai/models/ai_usage.dart';

/// Tracks per-request cost estimation and enforces daily/monthly budget limits.
///
/// Immutable state — each tracked request produces a new snapshot.
class CostTracker {
  CostTracker({
    this.dailyBudgetUsd = 10.0,
    this.monthlyBudgetUsd = 200.0,
    List<CostEntry> entries = const [],
  }) : _entries = List.unmodifiable(entries);

  final double dailyBudgetUsd;
  final double monthlyBudgetUsd;
  final List<CostEntry> _entries;

  List<CostEntry> get entries => _entries;

  /// Estimated USD cost for a given usage.
  ///
  /// Default pricing based on Claude 3.5 Sonnet rates.
  static double estimateCost(AiUsage usage) {
    const inputPricePerMillion = 3.0; // USD per million input tokens
    const outputPricePerMillion = 15.0; // USD per million output tokens

    return (usage.promptTokens * inputPricePerMillion / 1000000) +
        (usage.completionTokens * outputPricePerMillion / 1000000);
  }

  /// Returns a new [CostTracker] with the given usage recorded.
  ///
  /// Throws [RateLimitError] if adding this usage would exceed the budget.
  CostTracker trackUsage(AiUsage usage) {
    final cost = estimateCost(usage);
    final now = DateTime.now();

    final todayEntries = _entries.where((e) => _isSameDay(e.timestamp, now));
    final dailySpent = todayEntries.fold<double>(
      0.0,
      (sum, e) => sum + e.costUsd,
    );

    if (dailySpent + cost > dailyBudgetUsd) {
      throw RateLimitError(
        'Daily AI budget exceeded: \$${(dailySpent + cost).toStringAsFixed(4)} '
        '> \$$dailyBudgetUsd',
      );
    }

    final monthEntries = _entries.where((e) => _isSameMonth(e.timestamp, now));
    final monthlySpent = monthEntries.fold<double>(
      0.0,
      (sum, e) => sum + e.costUsd,
    );

    if (monthlySpent + cost > monthlyBudgetUsd) {
      throw RateLimitError(
        'Monthly AI budget exceeded: \$${(monthlySpent + cost).toStringAsFixed(4)} '
        '> \$$monthlyBudgetUsd',
      );
    }

    final entry = CostEntry(
      costUsd: cost,
      usage: usage,
      timestamp: now,
    );

    return CostTracker(
      dailyBudgetUsd: dailyBudgetUsd,
      monthlyBudgetUsd: monthlyBudgetUsd,
      entries: [..._entries, entry],
    );
  }

  /// Total cost for today.
  double get dailySpent {
    final now = DateTime.now();
    return _entries
        .where((e) => _isSameDay(e.timestamp, now))
        .fold<double>(0.0, (sum, e) => sum + e.costUsd);
  }

  /// Total cost for this month.
  double get monthlySpent {
    final now = DateTime.now();
    return _entries
        .where((e) => _isSameMonth(e.timestamp, now))
        .fold<double>(0.0, (sum, e) => sum + e.costUsd);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}

/// A single cost tracking entry.
class CostEntry {
  const CostEntry({
    required this.costUsd,
    required this.usage,
    required this.timestamp,
  });

  final double costUsd;
  final AiUsage usage;
  final DateTime timestamp;
}
