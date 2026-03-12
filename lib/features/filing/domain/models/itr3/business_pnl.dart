/// Immutable model for business Profit & Loss statement in ITR-3.
///
/// Used in Schedule P&L (Profit and Loss Account) for assessees
/// carrying on business or profession with books of accounts.
class BusinessPnl {
  const BusinessPnl({
    required this.revenue,
    required this.costOfGoods,
    required this.operatingExpenses,
    required this.depreciation,
    required this.otherExpenses,
  });

  factory BusinessPnl.empty() => const BusinessPnl(
    revenue: 0,
    costOfGoods: 0,
    operatingExpenses: 0,
    depreciation: 0,
    otherExpenses: 0,
  );

  /// Total revenue / turnover from business operations.
  final double revenue;

  /// Cost of goods sold (opening stock + purchases – closing stock).
  final double costOfGoods;

  /// Operating expenses (salaries, rent, utilities, etc.).
  final double operatingExpenses;

  /// Depreciation as per Income Tax Act (Section 32).
  final double depreciation;

  /// Other expenses not classified above.
  final double otherExpenses;

  /// Gross profit = Revenue – Cost of Goods.
  double get grossProfit => revenue - costOfGoods;

  /// Operating profit = Gross Profit – Operating Expenses – Depreciation.
  double get operatingProfit => grossProfit - operatingExpenses - depreciation;

  /// Net profit = Operating Profit – Other Expenses.
  double get netProfit => operatingProfit - otherExpenses;

  /// Total of all expense heads.
  double get totalExpenses =>
      costOfGoods + operatingExpenses + depreciation + otherExpenses;

  BusinessPnl copyWith({
    double? revenue,
    double? costOfGoods,
    double? operatingExpenses,
    double? depreciation,
    double? otherExpenses,
  }) {
    return BusinessPnl(
      revenue: revenue ?? this.revenue,
      costOfGoods: costOfGoods ?? this.costOfGoods,
      operatingExpenses: operatingExpenses ?? this.operatingExpenses,
      depreciation: depreciation ?? this.depreciation,
      otherExpenses: otherExpenses ?? this.otherExpenses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessPnl &&
        other.revenue == revenue &&
        other.costOfGoods == costOfGoods &&
        other.operatingExpenses == operatingExpenses &&
        other.depreciation == depreciation &&
        other.otherExpenses == otherExpenses;
  }

  @override
  int get hashCode => Object.hash(
    revenue,
    costOfGoods,
    operatingExpenses,
    depreciation,
    otherExpenses,
  );
}
