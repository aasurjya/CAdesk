import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';

/// Immutable model representing the response from a government portal API call.
class PortalResponse {
  const PortalResponse({
    required this.requestId,
    required this.portal,
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.latencyMs,
    required this.timestamp,
    this.errorMessage,
  });

  /// Matches the originating [PortalRequest.requestId].
  final String requestId;

  /// Portal that issued this response.
  final Portal portal;

  /// HTTP status code.
  final int statusCode;

  /// Raw JSON response body.
  final String body;

  /// Response headers.
  final Map<String, String> headers;

  /// Round-trip latency in milliseconds.
  final int latencyMs;

  /// Time the response was received.
  final DateTime timestamp;

  /// Human-readable error message when the request failed (nullable).
  final String? errorMessage;

  /// `true` when [statusCode] is in the 200–299 range.
  bool get isSuccess => statusCode >= 200 && statusCode <= 299;

  PortalResponse copyWith({
    String? requestId,
    Portal? portal,
    int? statusCode,
    String? body,
    Map<String, String>? headers,
    int? latencyMs,
    DateTime? timestamp,
    String? errorMessage,
  }) {
    return PortalResponse(
      requestId: requestId ?? this.requestId,
      portal: portal ?? this.portal,
      statusCode: statusCode ?? this.statusCode,
      body: body ?? this.body,
      headers: headers ?? this.headers,
      latencyMs: latencyMs ?? this.latencyMs,
      timestamp: timestamp ?? this.timestamp,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortalResponse &&
          runtimeType == other.runtimeType &&
          requestId == other.requestId &&
          portal == other.portal &&
          statusCode == other.statusCode &&
          body == other.body &&
          latencyMs == other.latencyMs &&
          timestamp == other.timestamp &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
    requestId,
    portal,
    statusCode,
    body,
    latencyMs,
    timestamp,
    errorMessage,
  );
}
