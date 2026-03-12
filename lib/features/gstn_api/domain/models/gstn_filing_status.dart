/// Return type for GSTN filings.
enum GstnReturnType {
  gstr1,
  gstr3b,
  gstr9,
  gstr9c,
}

/// Filing lifecycle status as tracked by the GSTN portal.
///
/// Mirrors the status codes returned by the GSTN API:
/// NF = notFiled, SAV = saved, SUB = submitted, CNF = filed,
/// PRO = processed, REJ = rejected.
enum GstnReturnStatus {
  notFiled,
  saved,
  submitted,
  filed,
  processed,
  rejected,
}

/// Immutable snapshot of a GSTN return's filing state.
class GstnFilingStatus {
  const GstnFilingStatus({
    required this.gstin,
    required this.returnType,
    required this.period,
    required this.status,
    this.arn,
    this.filedAt,
    this.processedAt,
    this.errorMessage,
  });

  /// 15-character GST Identification Number.
  final String gstin;

  /// The return category (GSTR-1, GSTR-3B, etc.).
  final GstnReturnType returnType;

  /// Filing period in MMYYYY format, e.g. "032024" for March 2024.
  final String period;

  /// Acknowledgement Reference Number, set once the return is filed.
  final String? arn;

  /// Current status of the return in the GSTN lifecycle.
  final GstnReturnStatus status;

  /// Timestamp when the return was filed (status became filed).
  final DateTime? filedAt;

  /// Timestamp when GSTN finished processing the return.
  final DateTime? processedAt;

  /// Human-readable error message when status is rejected.
  final String? errorMessage;

  GstnFilingStatus copyWith({
    String? gstin,
    GstnReturnType? returnType,
    String? period,
    String? arn,
    GstnReturnStatus? status,
    DateTime? filedAt,
    DateTime? processedAt,
    String? errorMessage,
  }) {
    return GstnFilingStatus(
      gstin: gstin ?? this.gstin,
      returnType: returnType ?? this.returnType,
      period: period ?? this.period,
      arn: arn ?? this.arn,
      status: status ?? this.status,
      filedAt: filedAt ?? this.filedAt,
      processedAt: processedAt ?? this.processedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GstnFilingStatus &&
          runtimeType == other.runtimeType &&
          gstin == other.gstin &&
          returnType == other.returnType &&
          period == other.period &&
          status == other.status &&
          arn == other.arn &&
          filedAt == other.filedAt &&
          processedAt == other.processedAt &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        gstin,
        returnType,
        period,
        status,
        arn,
        filedAt,
        processedAt,
        errorMessage,
      );
}
