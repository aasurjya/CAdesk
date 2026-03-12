import 'package:ca_app/features/portal_connector/domain/models/portal_credentials.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_response.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_session.dart';
import 'package:ca_app/features/portal_connector/domain/repositories/portal_connector_repository.dart';
import 'package:ca_app/features/portal_connector/domain/services/portal_session_manager.dart';

/// Mock implementation of [PortalConnectorRepository].
///
/// Returns realistic stub responses without making real HTTP calls.
/// Intended for development, testing, and UI prototyping until real
/// portal integrations are wired in.
class MockPortalConnectorRepository implements PortalConnectorRepository {
  MockPortalConnectorRepository._();

  /// Singleton instance.
  static final MockPortalConnectorRepository instance =
      MockPortalConnectorRepository._();

  // ---------------------------------------------------------------------------
  // PortalConnectorRepository implementation
  // ---------------------------------------------------------------------------

  @override
  Future<PortalResponse> send(PortalRequest request) async {
    final body = _mockBody(request.portal, request.endpoint);
    return PortalResponse(
      requestId: request.requestId,
      portal: request.portal,
      statusCode: 200,
      body: body,
      headers: const {'content-type': 'application/json'},
      latencyMs: _simulatedLatencyMs(request.portal),
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<PortalSession> authenticate(PortalCredentials credentials) async {
    return PortalSessionManager.createSession(credentials, DateTime.now());
  }

  @override
  Future<void> logout(PortalSession session) async {
    // No remote state to clear in mock.
  }

  @override
  Future<bool> isSessionValid(PortalSession session) async {
    return session.isActive && !session.isExpired(DateTime.now());
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Returns a realistic JSON stub for the given [portal] and [endpoint].
  static String _mockBody(Portal portal, String endpoint) {
    switch (portal) {
      case Portal.itd:
        return _itdBody(endpoint);
      case Portal.gstn:
        return _gstnBody(endpoint);
      case Portal.traces:
        return _tracesBody(endpoint);
      case Portal.mca:
        return _mcaBody(endpoint);
      case Portal.epfo:
        return _epfoBody(endpoint);
      case Portal.nic:
        return '{"status":"ok","portal":"NIC"}';
    }
  }

  static String _itdBody(String endpoint) {
    if (endpoint == '/itr/v1/status') {
      return '{"status":"processed","refund":5000,"assessmentYear":"2024-25"}';
    }
    return '{"status":"ok","portal":"ITD","endpoint":"$endpoint"}';
  }

  static String _gstnBody(String endpoint) {
    if (endpoint == '/gst/returns/gstr1') {
      return '{"ack":"AA123","status":"filed","period":"032024"}';
    }
    return '{"status":"ok","portal":"GSTN","endpoint":"$endpoint"}';
  }

  static String _tracesBody(String endpoint) {
    if (endpoint == '/api/v1/form16') {
      return '{"status":"available","downloadUrl":"mock://form16","pan":"ABCDE1234F"}';
    }
    return '{"status":"ok","portal":"TRACES","endpoint":"$endpoint"}';
  }

  static String _mcaBody(String endpoint) {
    return '{"status":"ok","portal":"MCA","endpoint":"$endpoint"}';
  }

  static String _epfoBody(String endpoint) {
    return '{"status":"ok","portal":"EPFO","endpoint":"$endpoint"}';
  }

  /// Simulate realistic per-portal latency (ms).
  static int _simulatedLatencyMs(Portal portal) {
    switch (portal) {
      case Portal.itd:
        return 320;
      case Portal.gstn:
        return 280;
      case Portal.traces:
        return 450;
      case Portal.mca:
        return 250;
      case Portal.epfo:
        return 390;
      case Portal.nic:
        return 200;
    }
  }
}
