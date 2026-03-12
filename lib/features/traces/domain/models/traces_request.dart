/// Status of a TRACES request.
enum TracesRequestStatus {
  /// Request submitted, awaiting processing.
  submitted,

  /// Request is being processed by TRACES server.
  processing,

  /// Request completed and available for download.
  available,

  /// Request failed or rejected.
  failed,
}

/// Type of request made to the TRACES portal.
enum TracesRequestType {
  /// Form 16 (TDS certificate for salary).
  form16,

  /// Form 16A (TDS certificate for non-salary).
  form16A,

  /// Challan verification (OLTAS).
  challanVerification,

  /// TDS default / demand notice.
  tdsDefault,

  /// Justification report.
  justificationReport,
}

/// Immutable model representing a single TRACES portal request.
class TracesRequest {
  const TracesRequest({
    required this.id,
    required this.type,
    required this.tan,
    required this.financialYear,
    required this.quarter,
    required this.status,
    required this.requestDate,
    this.completionDate,
    this.panList = const [],
    this.errorMessage,
  });

  final String id;
  final TracesRequestType type;

  /// Tax Deduction Account Number (TAN) of the deductor.
  final String tan;

  /// Financial year ending year (e.g., 2026 for FY 2025-26).
  final int financialYear;

  /// Quarter (1-4).
  final int quarter;

  final TracesRequestStatus status;
  final DateTime requestDate;
  final DateTime? completionDate;

  /// List of PANs for which this request applies (for bulk download).
  final List<String> panList;

  /// Error message if the request failed.
  final String? errorMessage;

  TracesRequest copyWith({
    String? id,
    TracesRequestType? type,
    String? tan,
    int? financialYear,
    int? quarter,
    TracesRequestStatus? status,
    DateTime? requestDate,
    DateTime? completionDate,
    List<String>? panList,
    String? errorMessage,
  }) {
    return TracesRequest(
      id: id ?? this.id,
      type: type ?? this.type,
      tan: tan ?? this.tan,
      financialYear: financialYear ?? this.financialYear,
      quarter: quarter ?? this.quarter,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      completionDate: completionDate ?? this.completionDate,
      panList: panList ?? this.panList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TracesRequest) return false;
    if (other.id != id) return false;
    if (other.type != type) return false;
    if (other.tan != tan) return false;
    if (other.financialYear != financialYear) return false;
    if (other.quarter != quarter) return false;
    if (other.status != status) return false;
    if (other.requestDate != requestDate) return false;
    if (other.completionDate != completionDate) return false;
    if (other.errorMessage != errorMessage) return false;
    if (other.panList.length != panList.length) return false;
    for (var i = 0; i < panList.length; i++) {
      if (other.panList[i] != panList[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    tan,
    financialYear,
    quarter,
    status,
    requestDate,
    completionDate,
    errorMessage,
    Object.hashAll(panList),
  );
}
