import 'package:flutter/foundation.dart' show listEquals;

/// Immutable model for presumptive income from goods carriage under Section 44AE.
///
/// Section 44AE applies to assessees owning up to 10 goods carriages at any
/// time during the previous year. Income is deemed at ₹7,500 per vehicle per
/// month (or part of month) of operation.
class GoodsCarriageIncome44AE {
  const GoodsCarriageIncome44AE({
    required this.numberOfVehicles,
    required this.monthsOperatedPerVehicle,
  });

  factory GoodsCarriageIncome44AE.empty() => const GoodsCarriageIncome44AE(
    numberOfVehicles: 0,
    monthsOperatedPerVehicle: [],
  );

  /// Total number of goods carriage vehicles owned.
  final int numberOfVehicles;

  /// Number of months each vehicle was operated during the year.
  ///
  /// Length should equal [numberOfVehicles]. Each entry is 1–12.
  final List<int> monthsOperatedPerVehicle;

  /// Maximum number of vehicles allowed for Section 44AE eligibility.
  static const int maxVehicles = 10;

  /// Deemed income per vehicle per month under Section 44AE.
  static const double incomePerVehiclePerMonth = 7500;

  /// Presumptive income computed as per Section 44AE.
  ///
  /// Sum of (₹7,500 x months operated) for each vehicle.
  double get presumptiveIncome {
    double total = 0;
    for (final months in monthsOperatedPerVehicle) {
      total += incomePerVehiclePerMonth * months;
    }
    return total;
  }

  GoodsCarriageIncome44AE copyWith({
    int? numberOfVehicles,
    List<int>? monthsOperatedPerVehicle,
  }) {
    return GoodsCarriageIncome44AE(
      numberOfVehicles: numberOfVehicles ?? this.numberOfVehicles,
      monthsOperatedPerVehicle:
          monthsOperatedPerVehicle ?? this.monthsOperatedPerVehicle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoodsCarriageIncome44AE &&
        other.numberOfVehicles == numberOfVehicles &&
        listEquals(other.monthsOperatedPerVehicle, monthsOperatedPerVehicle);
  }

  @override
  int get hashCode =>
      Object.hash(numberOfVehicles, Object.hashAll(monthsOperatedPerVehicle));
}
