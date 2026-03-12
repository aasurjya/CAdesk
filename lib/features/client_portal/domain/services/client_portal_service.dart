import 'dart:math';

import 'package:ca_app/features/client_portal/domain/models/portal_client.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document.dart';

/// Stateless singleton service for client portal domain operations.
///
/// All methods are pure functions — they return new immutable objects and
/// never mutate their inputs.
class ClientPortalService {
  ClientPortalService._();

  static final ClientPortalService instance = ClientPortalService._();

  static final Random _random = Random.secure();

  // ---------------------------------------------------------------------------
  // Client management
  // ---------------------------------------------------------------------------

  /// Creates a new [PortalClient] with [PortalStatus.invited] status.
  ///
  /// Generates a unique [PortalClient.clientId] using a secure random UUID.
  PortalClient inviteClient(
    String pan,
    String name,
    String email,
    String mobile,
    String caFirmId,
  ) {
    return PortalClient(
      clientId: _generateId(),
      pan: pan,
      name: name,
      email: email,
      mobile: mobile,
      portalStatus: PortalStatus.invited,
      caFirmId: caFirmId,
      totalDocuments: 0,
    );
  }

  /// Returns a copy of [client] with a fresh invite token and an expiry
  /// set 72 hours from now.
  PortalClient generateInviteToken(PortalClient client) {
    final token = _generateId();
    final expiry = DateTime.now().add(const Duration(hours: 72));
    return client.copyWith(
      inviteToken: token,
      inviteExpiry: expiry,
    );
  }

  /// Activates the portal for [client] when [token] matches and has not expired.
  ///
  /// Throws [ArgumentError] if the token is wrong or the invite has expired.
  PortalClient activatePortal(PortalClient client, String token) {
    if (client.inviteToken != token) {
      throw ArgumentError('Invalid invite token.');
    }
    final expiry = client.inviteExpiry;
    if (expiry == null || expiry.isBefore(DateTime.now())) {
      throw ArgumentError('Invite token has expired.');
    }
    return client.copyWith(portalStatus: PortalStatus.active);
  }

  // ---------------------------------------------------------------------------
  // Document sharing
  // ---------------------------------------------------------------------------

  /// Creates a [SharedDocument] for [clientId] with the given fields.
  ///
  /// [caFirmId] defaults to empty string; callers should supply it when known.
  SharedDocument shareDocument(
    String clientId,
    String documentId,
    String title,
    DocumentType documentType, {
    bool requiresESign = false,
    String caFirmId = '',
    int fileSize = 0,
    String mimeType = 'application/octet-stream',
  }) {
    return SharedDocument(
      documentId: documentId,
      clientId: clientId,
      caFirmId: caFirmId,
      title: title,
      documentType: documentType,
      fileSize: fileSize,
      mimeType: mimeType,
      sharedAt: DateTime.now(),
      requiresESign: requiresESign,
      eSigned: false,
      status: DocumentStatus.shared,
    );
  }

  /// Returns a copy of [doc] with [DocumentStatus.viewed] and [viewedAt] set.
  SharedDocument markDocumentViewed(SharedDocument doc) {
    return doc.copyWith(
      viewedAt: DateTime.now(),
      status: DocumentStatus.viewed,
    );
  }

  /// Returns a copy of [doc] with [DocumentStatus.eSigned], [eSigned] = true,
  /// and [eSignedAt] set to [signedAt].
  SharedDocument markDocumentSigned(SharedDocument doc, DateTime signedAt) {
    return doc.copyWith(
      eSigned: true,
      eSignedAt: signedAt,
      status: DocumentStatus.eSigned,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _generateId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
