/// Supported government portals for API integration.
enum Portal { itd, gstn, traces, mca, epfo, nic }

/// HTTP methods supported by portal APIs.
enum HttpMethod { get, post, put }

/// Immutable model representing an outbound request to a government portal.
class PortalRequest {
  const PortalRequest({
    required this.requestId,
    required this.portal,
    required this.endpoint,
    required this.method,
    required this.headers,
    required this.body,
    this.timeoutSeconds = 30,
    this.retryCount = 0,
  });

  /// Unique identifier for correlation / logging.
  final String requestId;

  /// Target portal.
  final Portal portal;

  /// API endpoint path (e.g. `/itr/v1/status`).
  final String endpoint;

  /// HTTP method.
  final HttpMethod method;

  /// Request headers.
  final Map<String, String> headers;

  /// Request body as a JSON string. Empty string for GET requests.
  final String body;

  /// Timeout in seconds (default 30).
  final int timeoutSeconds;

  /// Number of retries already attempted (default 0).
  final int retryCount;

  PortalRequest copyWith({
    String? requestId,
    Portal? portal,
    String? endpoint,
    HttpMethod? method,
    Map<String, String>? headers,
    String? body,
    int? timeoutSeconds,
    int? retryCount,
  }) {
    return PortalRequest(
      requestId: requestId ?? this.requestId,
      portal: portal ?? this.portal,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortalRequest &&
          runtimeType == other.runtimeType &&
          requestId == other.requestId &&
          portal == other.portal &&
          endpoint == other.endpoint &&
          method == other.method &&
          body == other.body &&
          timeoutSeconds == other.timeoutSeconds &&
          retryCount == other.retryCount;

  @override
  int get hashCode => Object.hash(
    requestId,
    portal,
    endpoint,
    method,
    body,
    timeoutSeconds,
    retryCount,
  );
}
