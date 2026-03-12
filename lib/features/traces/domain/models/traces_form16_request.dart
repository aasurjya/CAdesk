/// Type of certificate / report being requested from TRACES.
///
/// - [form16]             — TDS certificate for salary income (Part A + B)
/// - [form16a]            — TDS certificate for non-salary income
/// - [form16b]            — TDS certificate for immovable property sale
/// - [justificationReport]— Report explaining TDS demand / short deductions
enum Form16RequestType {
  form16,
  form16a,
  form16b,
  justificationReport,
}

/// Lifecycle status of a TRACES download request.
///
/// - [submitted]  — Request has been submitted and is awaiting processing
/// - [processing] — TRACES is generating the file (code "P")
/// - [available]  — File is ready for download (code "A")
/// - [downloaded] — File has already been downloaded by the user
/// - [failed]     — TRACES could not fulfil the request (code "F")
enum Form16RequestStatus {
  submitted,
  processing,
  available,
  downloaded,
  failed,
}

/// Immutable record of a Form 16 / Form 16A download request on TRACES.
///
/// [pan] is `null` for bulk requests that cover all deductees under a TAN.
/// [downloadUrl] is `null` until the request reaches [Form16RequestStatus.available].
class TracesForm16Request {
  const TracesForm16Request({
    required this.requestId,
    required this.tan,
    required this.financialYear,
    required this.requestType,
    required this.status,
    required this.requestedAt,
    this.pan,
    this.downloadUrl,
  });

  /// Unique identifier assigned by TRACES for this request.
  final String requestId;

  /// TAN of the deductor for whom the certificate is requested.
  final String tan;

  /// PAN of the deductee, or `null` for bulk (all-deductee) requests.
  final String? pan;

  /// Financial year (e.g. 2024 represents FY 2024-25).
  final int financialYear;

  /// Type of certificate / report being requested.
  final Form16RequestType requestType;

  /// Current lifecycle status of the request.
  final Form16RequestStatus status;

  /// URL from which the generated file can be downloaded, once available.
  final String? downloadUrl;

  /// UTC timestamp when the request was submitted to TRACES.
  final DateTime requestedAt;

  /// Returns a new [TracesForm16Request] with selected fields replaced.
  TracesForm16Request copyWith({
    String? requestId,
    String? tan,
    String? pan,
    int? financialYear,
    Form16RequestType? requestType,
    Form16RequestStatus? status,
    String? downloadUrl,
    DateTime? requestedAt,
  }) {
    return TracesForm16Request(
      requestId: requestId ?? this.requestId,
      tan: tan ?? this.tan,
      pan: pan ?? this.pan,
      financialYear: financialYear ?? this.financialYear,
      requestType: requestType ?? this.requestType,
      status: status ?? this.status,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TracesForm16Request &&
        other.requestId == requestId &&
        other.tan == tan &&
        other.pan == pan &&
        other.financialYear == financialYear &&
        other.requestType == requestType &&
        other.status == status &&
        other.downloadUrl == downloadUrl &&
        other.requestedAt == requestedAt;
  }

  @override
  int get hashCode => Object.hash(
        requestId,
        tan,
        pan,
        financialYear,
        requestType,
        status,
        downloadUrl,
        requestedAt,
      );
}
