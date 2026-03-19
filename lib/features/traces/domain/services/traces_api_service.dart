import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';

// ---------------------------------------------------------------------------
// Result models
// ---------------------------------------------------------------------------

/// Result of verifying a TDS challan against the TRACES portal.
class TracesChallanResult {
  const TracesChallanResult({
    required this.challan,
    required this.isVerified,
    this.errorMessage,
  });

  /// The challan details returned by TRACES.
  final TracesChallanStatus challan;

  /// Whether the challan was verified and matched in TRACES records.
  final bool isVerified;

  /// Non-null when [isVerified] is false; explains the verification failure.
  final String? errorMessage;

  TracesChallanResult copyWith({
    TracesChallanStatus? challan,
    bool? isVerified,
    String? errorMessage,
  }) {
    return TracesChallanResult(
      challan: challan ?? this.challan,
      isVerified: isVerified ?? this.isVerified,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TracesChallanResult &&
          runtimeType == other.runtimeType &&
          challan == other.challan &&
          isVerified == other.isVerified;

  @override
  int get hashCode => Object.hash(challan, isVerified);
}

/// Status response when polling a Form 16 download request.
class TracesForm16Status {
  const TracesForm16Status({
    required this.requestId,
    required this.status,
    this.downloadUrl,
    this.processedAt,
    this.errorMessage,
  });

  final String requestId;
  final Form16RequestStatus status;

  /// Download URL populated when [status] is [Form16RequestStatus.available].
  final String? downloadUrl;

  /// Timestamp when TRACES finished processing the request.
  final DateTime? processedAt;

  /// Error description when [status] is [Form16RequestStatus.failed].
  final String? errorMessage;

  TracesForm16Status copyWith({
    String? requestId,
    Form16RequestStatus? status,
    String? downloadUrl,
    DateTime? processedAt,
    String? errorMessage,
  }) {
    return TracesForm16Status(
      requestId: requestId ?? this.requestId,
      status: status ?? this.status,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      processedAt: processedAt ?? this.processedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TracesForm16Status &&
          runtimeType == other.runtimeType &&
          requestId == other.requestId &&
          status == other.status;

  @override
  int get hashCode => Object.hash(requestId, status);
}

// ---------------------------------------------------------------------------
// Abstract service interface
// ---------------------------------------------------------------------------

/// Abstract interface for TRACES portal API integration.
///
/// Implementations:
/// - [MockTracesApiService] — deterministic in-memory mock for tests / dev.
/// - A real HTTP implementation (future work) that calls the TRACES portal.
///
/// All methods throw [TracesApiException] on portal errors, allowing callers
/// to handle authentication failures, rate limits, and server errors uniformly.
abstract class TracesApiService {
  /// Verifies a TDS challan on the TRACES portal.
  ///
  /// Parameters:
  /// - [tan]           — 10-character TAN of the deductor
  /// - [bsrCode]       — 7-digit BSR code of the bank branch
  /// - [challanSerial] — 5-digit serial number assigned by the bank
  ///
  /// Returns a [TracesChallanResult] with the verification outcome.
  Future<TracesChallanResult> verifyTdsChallan(
    String tan,
    String bsrCode,
    String challanSerial,
  );

  /// Submits a Form 16 download request to TRACES.
  ///
  /// - [tan]           — TAN of the deductor
  /// - [financialYear] — Financial year string (e.g. "2024-25")
  ///
  /// Returns the [TracesForm16Request] tracking record.
  Future<TracesForm16Request> requestForm16(String tan, String financialYear);

  /// Polls the status of a previously submitted Form 16 request.
  ///
  /// - [requestId] — The ID returned by [requestForm16].
  Future<TracesForm16Status> getForm16Status(String requestId);

  /// Downloads the generated Form 16 file as a byte array.
  ///
  /// Should only be called once [getForm16Status] returns
  /// [Form16RequestStatus.available].
  ///
  /// - [requestId] — The ID returned by [requestForm16].
  ///
  /// Returns the raw PDF bytes.
  Future<List<int>> downloadForm16(String requestId);
}

// ---------------------------------------------------------------------------
// Exception type
// ---------------------------------------------------------------------------

/// Exception thrown by [TracesApiService] implementations when the TRACES
/// portal returns an error or the request cannot be completed.
class TracesApiException implements Exception {
  const TracesApiException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  final String message;

  /// HTTP status code, if the error originated from an HTTP response.
  final int? statusCode;

  /// Underlying exception that triggered this error, if any.
  final Object? cause;

  @override
  String toString() =>
      'TracesApiException: $message'
      '${statusCode != null ? ' (HTTP $statusCode)' : ''}'
      '${cause != null ? ' — $cause' : ''}';
}

// ---------------------------------------------------------------------------
// Mock implementation
// ---------------------------------------------------------------------------

/// Deterministic in-memory mock implementation of [TracesApiService].
///
/// Behaviour contract:
/// - [verifyTdsChallan]: always returns a verified, matched challan.
/// - [requestForm16]: always returns a request with
///   [Form16RequestStatus.available] and a mock download URL.
/// - [getForm16Status]: returns [Form16RequestStatus.available] for any
///   previously issued request ID.
/// - [downloadForm16]: returns a 4-byte placeholder PDF sentinel.
///
/// No network calls are made.
class MockTracesApiService implements TracesApiService {
  const MockTracesApiService();

  @override
  Future<TracesChallanResult> verifyTdsChallan(
    String tan,
    String bsrCode,
    String challanSerial,
  ) {
    const depositedAmount = 50000; // 500.00 rupees in paise
    final challan = TracesChallanStatus(
      bsrCode: bsrCode,
      challanDate: DateTime(2024, 6, 15),
      challanSerial: challanSerial,
      tan: tan,
      section: '192',
      depositedAmount: depositedAmount,
      status: ChallanBookingStatus.matched,
      consumedAmount: depositedAmount,
      balanceAmount: 0,
    );
    return Future.value(
      TracesChallanResult(challan: challan, isVerified: true),
    );
  }

  @override
  Future<TracesForm16Request> requestForm16(String tan, String financialYear) {
    final requestId = 'MOCK-F16-$tan-${financialYear.replaceAll('-', '')}';
    return Future.value(
      TracesForm16Request(
        requestId: requestId,
        tan: tan,
        financialYear: _financialYearToInt(financialYear),
        requestType: Form16RequestType.form16,
        status: Form16RequestStatus.available,
        downloadUrl: 'https://traces.gov.in/mock/download/$requestId',
        requestedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<TracesForm16Status> getForm16Status(String requestId) {
    return Future.value(
      TracesForm16Status(
        requestId: requestId,
        status: Form16RequestStatus.available,
        downloadUrl: 'https://traces.gov.in/mock/download/$requestId',
        processedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<int>> downloadForm16(String requestId) {
    // Minimal 4-byte PDF sentinel (%PDF)
    return Future.value(<int>[0x25, 0x50, 0x44, 0x46]);
  }

  /// Converts a "YYYY-YY" financial year string to the starting year int.
  ///
  /// e.g. "2024-25" → 2024
  int _financialYearToInt(String fy) {
    final parts = fy.split('-');
    if (parts.isEmpty) return 0;
    return int.tryParse(parts[0]) ?? 0;
  }
}
