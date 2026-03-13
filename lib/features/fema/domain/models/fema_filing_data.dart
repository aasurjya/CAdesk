/// FEMA filing / transaction types.
enum FemaType {
  odi('ODI'),
  fdi('FDI'),
  ecb('ECB'),
  apt('APT'),
  form15ca('Form-15CA'),
  form15cb('Form-15CB'),
  compounding('Compounding'),
  other('Other');

  const FemaType(this.label);

  final String label;
}

/// Immutable data-layer model for a FEMA filing / transaction record.
class FemaFilingData {
  const FemaFilingData({
    required this.id,
    required this.clientId,
    required this.filingType,
    required this.transactionDate,
    required this.amount,
    required this.currency,
    required this.status,
    this.approvalRequired = false,
    this.filingNumber,
    this.remarks,
  });

  final String id;
  final String clientId;
  final FemaType filingType;
  final DateTime transactionDate;

  /// Transaction amount as string to avoid floating-point issues.
  final String amount;

  /// ISO 4217 currency code (e.g. "USD", "EUR", "INR").
  final String currency;

  /// Whether RBI/AD bank approval is required before the transaction.
  final bool approvalRequired;

  /// Filing status (e.g. 'pending', 'filed', 'approved', 'compounding').
  final String status;

  /// Reference / SRN assigned after filing.
  final String? filingNumber;

  final String? remarks;

  FemaFilingData copyWith({
    String? id,
    String? clientId,
    FemaType? filingType,
    DateTime? transactionDate,
    String? amount,
    String? currency,
    bool? approvalRequired,
    String? status,
    String? filingNumber,
    String? remarks,
  }) {
    return FemaFilingData(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      filingType: filingType ?? this.filingType,
      transactionDate: transactionDate ?? this.transactionDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      approvalRequired: approvalRequired ?? this.approvalRequired,
      status: status ?? this.status,
      filingNumber: filingNumber ?? this.filingNumber,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FemaFilingData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FemaFilingData(id: $id, clientId: $clientId, '
      'filingType: ${filingType.name}, amount: $amount $currency, '
      'status: $status)';
}
