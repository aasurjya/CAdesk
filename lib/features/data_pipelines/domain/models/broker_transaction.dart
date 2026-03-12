/// Broker identity — identifies the source platform of the transaction.
enum Broker {
  zerodha,
  upstox,
  iciciDirect,
  hdfcSec,
  angelOne,
  cams,
  kfintech,
  nsdl,
  cdsl,
}

/// Asset class of the traded instrument.
enum AssetType {
  equity,
  mutualFund,
  ncd,
  bond,
  etf,
  derivative,
  commodity,
}

/// Type of transaction.
enum TransactionType {
  buy,
  sell,
  dividend,
  bonus,
  split,
  merger,
  redemption,
}

/// Immutable model representing a single broker transaction.
///
/// All monetary values are stored in **paise** (₹1 = 100 paise) to avoid
/// floating-point rounding errors. Quantity is [double] to support fractional
/// mutual fund units.
class BrokerTransaction {
  const BrokerTransaction({
    required this.transactionId,
    required this.broker,
    required this.assetType,
    required this.isin,
    required this.scripName,
    required this.transactionType,
    required this.date,
    required this.quantity,
    required this.price,
    required this.amount,
    required this.brokerage,
    required this.stt,
    required this.otherCharges,
    required this.exchange,
  });

  /// Unique identifier from the broker (trade ID / order ID).
  final String transactionId;

  /// Source broker or RTA.
  final Broker broker;

  /// Asset class of the instrument.
  final AssetType assetType;

  /// ISIN (nullable for instruments without an ISIN, e.g. some commodities).
  final String? isin;

  /// Human-readable name of the instrument.
  final String scripName;

  /// Transaction type.
  final TransactionType transactionType;

  /// Trade date (date portion only; time-of-day is not used in tax calculations).
  final DateTime date;

  /// Number of units traded (fractional for mutual fund units).
  final double quantity;

  /// Price per unit in paise.
  final int price;

  /// Gross transaction amount in paise (quantity × price, before charges).
  final int amount;

  /// Brokerage charged in paise.
  final int brokerage;

  /// Securities Transaction Tax in paise.
  final int stt;

  /// Other statutory charges (stamp duty, SEBI fees, GST on brokerage) in paise.
  final int otherCharges;

  /// Exchange on which the trade was executed (e.g. 'NSE', 'BSE'). Nullable for MF.
  final String? exchange;

  /// Returns a new [BrokerTransaction] with the specified fields replaced.
  BrokerTransaction copyWith({
    String? transactionId,
    Broker? broker,
    AssetType? assetType,
    String? isin,
    String? scripName,
    TransactionType? transactionType,
    DateTime? date,
    double? quantity,
    int? price,
    int? amount,
    int? brokerage,
    int? stt,
    int? otherCharges,
    String? exchange,
  }) {
    return BrokerTransaction(
      transactionId: transactionId ?? this.transactionId,
      broker: broker ?? this.broker,
      assetType: assetType ?? this.assetType,
      isin: isin ?? this.isin,
      scripName: scripName ?? this.scripName,
      transactionType: transactionType ?? this.transactionType,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      brokerage: brokerage ?? this.brokerage,
      stt: stt ?? this.stt,
      otherCharges: otherCharges ?? this.otherCharges,
      exchange: exchange ?? this.exchange,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BrokerTransaction &&
        other.transactionId == transactionId &&
        other.broker == broker &&
        other.assetType == assetType &&
        other.isin == isin &&
        other.scripName == scripName &&
        other.transactionType == transactionType &&
        other.date == date &&
        other.quantity == quantity &&
        other.price == price &&
        other.amount == amount &&
        other.brokerage == brokerage &&
        other.stt == stt &&
        other.otherCharges == otherCharges &&
        other.exchange == exchange;
  }

  @override
  int get hashCode => Object.hash(
    transactionId,
    broker,
    assetType,
    isin,
    scripName,
    transactionType,
    date,
    quantity,
    price,
    amount,
    brokerage,
    stt,
    otherCharges,
    exchange,
  );
}
