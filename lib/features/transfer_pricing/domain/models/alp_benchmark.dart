import 'package:ca_app/features/transfer_pricing/domain/models/international_transaction.dart';

/// Immutable model for Arm's Length Price (ALP) benchmarking analysis.
///
/// The interquartile range (IQR) is the standard statistical tool used
/// to determine the ALP range from comparable uncontrolled transactions.
///
/// Tolerance range under Rule 10CA:
/// - General transactions: ±3% of ALP
/// - Wholesale trading transactions: ±1% of ALP
class AlpBenchmark {
  const AlpBenchmark({
    required this.method,
    required this.searchCriteria,
    required this.comparableCount,
    required this.interquartileLowerPaise,
    required this.interquartileMedianPaise,
    required this.interquartileUpperPaise,
    required this.selectedAlpPaise,
  });

  final AlpMethod method;

  /// Description of the search strategy used to identify comparables.
  final String searchCriteria;

  /// Number of comparable companies or transactions in the final set.
  final int comparableCount;

  /// Lower quartile (25th percentile) of the comparable range in paise.
  final int interquartileLowerPaise;

  /// Median (50th percentile) of the comparable range in paise.
  final int interquartileMedianPaise;

  /// Upper quartile (75th percentile) of the comparable range in paise.
  final int interquartileUpperPaise;

  /// Final selected ALP in paise (typically the median or a value within IQR).
  final int selectedAlpPaise;

  AlpBenchmark copyWith({
    AlpMethod? method,
    String? searchCriteria,
    int? comparableCount,
    int? interquartileLowerPaise,
    int? interquartileMedianPaise,
    int? interquartileUpperPaise,
    int? selectedAlpPaise,
  }) {
    return AlpBenchmark(
      method: method ?? this.method,
      searchCriteria: searchCriteria ?? this.searchCriteria,
      comparableCount: comparableCount ?? this.comparableCount,
      interquartileLowerPaise:
          interquartileLowerPaise ?? this.interquartileLowerPaise,
      interquartileMedianPaise:
          interquartileMedianPaise ?? this.interquartileMedianPaise,
      interquartileUpperPaise:
          interquartileUpperPaise ?? this.interquartileUpperPaise,
      selectedAlpPaise: selectedAlpPaise ?? this.selectedAlpPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlpBenchmark &&
        other.method == method &&
        other.searchCriteria == searchCriteria &&
        other.comparableCount == comparableCount &&
        other.interquartileLowerPaise == interquartileLowerPaise &&
        other.interquartileMedianPaise == interquartileMedianPaise &&
        other.interquartileUpperPaise == interquartileUpperPaise &&
        other.selectedAlpPaise == selectedAlpPaise;
  }

  @override
  int get hashCode => Object.hash(
    method,
    searchCriteria,
    comparableCount,
    interquartileLowerPaise,
    interquartileMedianPaise,
    interquartileUpperPaise,
    selectedAlpPaise,
  );
}
