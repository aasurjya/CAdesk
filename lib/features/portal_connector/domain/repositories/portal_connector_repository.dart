import 'package:ca_app/features/portal_connector/domain/models/portal_credentials.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_response.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_session.dart';

/// Abstract contract for all portal API integrations.
///
/// Concrete implementations (real HTTP or mock) fulfil these operations.
/// This layer defines the domain interface — no HTTP details leak through.
abstract class PortalConnectorRepository {
  /// Send a [PortalRequest] to the target portal and return a [PortalResponse].
  Future<PortalResponse> send(PortalRequest request);

  /// Authenticate using [credentials] and return an active [PortalSession].
  Future<PortalSession> authenticate(PortalCredentials credentials);

  /// Invalidate / terminate the given [session] on the portal side.
  Future<void> logout(PortalSession session);

  /// Return `true` when [session] is still valid (active and not expired).
  Future<bool> isSessionValid(PortalSession session);
}
