/// Immutable model for the CMA Operating Statement (Form I).
///
/// Covers a single fiscal year and follows the standard CMA format
/// required by Indian banks for working capital / term loan proposals.
/// All monetary values are stored as integers in **paise** (1/100 rupee)
/// to avoid floating-point rounding errors in financial computations.
class CmaOperatingStatement {
  const CmaOperatingStatement({
    required this.year,
    required this.grossSales,
    required this.returnsAndDiscounts,
    required this.rawMaterials,
    required this.wages,
    required this.power,
    required this.storeItems,
    required this.repairsAndMaintenance,
    required this.otherManufacturing,
    required this.openingStock,
    required this.closingStock,
    required this.sellingExpenses,
    required this.adminExpenses,
    required this.financialCharges,
    required this.depreciation,
    required this.tax,
  });

  /// Returns a zero-filled instance for the given year (defaults 0).
  factory CmaOperatingStatement.empty() => const CmaOperatingStatement(
    year: 0,
    grossSales: 0,
    returnsAndDiscounts: 0,
    rawMaterials: 0,
    wages: 0,
    power: 0,
    storeItems: 0,
    repairsAndMaintenance: 0,
    otherManufacturing: 0,
    openingStock: 0,
    closingStock: 0,
    sellingExpenses: 0,
    adminExpenses: 0,
    financialCharges: 0,
    depreciation: 0,
    tax: 0,
  );

  /// Fiscal year (e.g. 2024 represents FY 2023-24).
  final int year;

  /// Gross sales / turnover in paise.
  final int grossSales;

  /// Sales returns and trade discounts in paise.
  final int returnsAndDiscounts;

  /// Cost of raw materials consumed in paise.
  final int rawMaterials;

  /// Wages and salaries (factory floor) in paise.
  final int wages;

  /// Power, fuel, and utility expenses in paise.
  final int power;

  /// Stores and spares consumed in paise.
  final int storeItems;

  /// Repairs and maintenance expenses in paise.
  final int repairsAndMaintenance;

  /// Other manufacturing / factory overheads in paise.
  final int otherManufacturing;

  /// Opening stock of work-in-progress and finished goods in paise.
  final int openingStock;

  /// Closing stock of work-in-progress and finished goods in paise.
  final int closingStock;

  /// Selling and distribution expenses in paise.
  final int sellingExpenses;

  /// General and administrative expenses in paise.
  final int adminExpenses;

  /// Interest and other financial charges in paise.
  final int financialCharges;

  /// Depreciation for the year in paise.
  final int depreciation;

  /// Income tax provision for the year in paise.
  final int tax;

  // ── Computed fields ──────────────────────────────────────────────────────

  /// Net sales after returns and discounts.
  int get netSales => grossSales - returnsAndDiscounts;

  /// Total cost of production (all manufacturing cost lines).
  int get costOfProduction =>
      rawMaterials +
      wages +
      power +
      storeItems +
      repairsAndMaintenance +
      otherManufacturing;

  /// Cost of goods sold = costOfProduction + openingStock - closingStock.
  int get costOfGoodsSold => costOfProduction + openingStock - closingStock;

  /// Profit before tax = netSales - COGS - opex - financial charges - depreciation.
  int get profitBeforeTax =>
      netSales -
      costOfGoodsSold -
      sellingExpenses -
      adminExpenses -
      financialCharges -
      depreciation;

  /// Profit after tax = profitBeforeTax - tax.
  int get profitAfterTax => profitBeforeTax - tax;

  CmaOperatingStatement copyWith({
    int? year,
    int? grossSales,
    int? returnsAndDiscounts,
    int? rawMaterials,
    int? wages,
    int? power,
    int? storeItems,
    int? repairsAndMaintenance,
    int? otherManufacturing,
    int? openingStock,
    int? closingStock,
    int? sellingExpenses,
    int? adminExpenses,
    int? financialCharges,
    int? depreciation,
    int? tax,
  }) {
    return CmaOperatingStatement(
      year: year ?? this.year,
      grossSales: grossSales ?? this.grossSales,
      returnsAndDiscounts: returnsAndDiscounts ?? this.returnsAndDiscounts,
      rawMaterials: rawMaterials ?? this.rawMaterials,
      wages: wages ?? this.wages,
      power: power ?? this.power,
      storeItems: storeItems ?? this.storeItems,
      repairsAndMaintenance:
          repairsAndMaintenance ?? this.repairsAndMaintenance,
      otherManufacturing: otherManufacturing ?? this.otherManufacturing,
      openingStock: openingStock ?? this.openingStock,
      closingStock: closingStock ?? this.closingStock,
      sellingExpenses: sellingExpenses ?? this.sellingExpenses,
      adminExpenses: adminExpenses ?? this.adminExpenses,
      financialCharges: financialCharges ?? this.financialCharges,
      depreciation: depreciation ?? this.depreciation,
      tax: tax ?? this.tax,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CmaOperatingStatement &&
        other.year == year &&
        other.grossSales == grossSales &&
        other.returnsAndDiscounts == returnsAndDiscounts &&
        other.rawMaterials == rawMaterials &&
        other.wages == wages &&
        other.power == power &&
        other.storeItems == storeItems &&
        other.repairsAndMaintenance == repairsAndMaintenance &&
        other.otherManufacturing == otherManufacturing &&
        other.openingStock == openingStock &&
        other.closingStock == closingStock &&
        other.sellingExpenses == sellingExpenses &&
        other.adminExpenses == adminExpenses &&
        other.financialCharges == financialCharges &&
        other.depreciation == depreciation &&
        other.tax == tax;
  }

  @override
  int get hashCode => Object.hash(
    year,
    grossSales,
    returnsAndDiscounts,
    rawMaterials,
    wages,
    power,
    storeItems,
    repairsAndMaintenance,
    otherManufacturing,
    openingStock,
    closingStock,
    sellingExpenses,
    adminExpenses,
    financialCharges,
    depreciation,
    tax,
  );
}
