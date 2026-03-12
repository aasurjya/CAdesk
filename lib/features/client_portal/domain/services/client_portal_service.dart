import 'dart:math';

import 'package:ca_app/features/client_portal/domain/models/portal_client.dart';
import 'package:ca_app/features/client_portal/domain/models/shared_document.dart';

/// Domain service for client portal lifecycle: invitation, activation,
/// and document sharing.
///
/// All methods are pure and return new immutable instances — no state is
/// mutated in-place.
class ClientPortalService {
  ClientPortalService._();

  static final ClientPortalService instance = ClientPortalService._();

  final Random _random = Random();

  // ---------------------------------------------------------------------------
  // Client management
  // ---------------------------------------------------------------------------

  /// Creates a new [PortalClient] with [PortalStatus.invited] status.
  ///
  /// A unique [clientId] is generated automatically.
  PortalClient inviteClient(
    String pan,
    String name,
    String email,
    String mobile,
    String firmId,
  ) {
    return PortalClient(
      clientId: _generateId('client'),
      pan: pan,
      name: name,
      email: email,
      mobile: mobile,
      portalStatus: PortalStatus.invited,
      caFirmId: firmId,
      totalDocuments: 0,
    );
  }

  /// Returns a copy of [client] with a new random invite token and an
  /// expiry set 72 hours from now.
  PortalClient generateInviteToken(PortalClient client) {
    final token = _generateToken();
    final expiry = DateTime.now().add(const Duration(hours: 72));
    return client.copyWith(inviteToken: token, inviteExpiry: expiry);
  }

  /// Returns a copy of [client] with [PortalStatus.active] status.
  ///
  /// Throws [ArgumentError] if [token] does not match the stored invite token
  /// or if the invite has expired.
  PortalClient activatePortal(PortalClient client, String token) {
    if (client.inviteToken != token) {
      throw ArgumentError(
        'Invalid invite token for client ${client.clientId}.',
        'token',
      );
    }
    if (client.inviteExpiry != null &&
        client.inviteExpiry!.isBefore(DateTime.now())) {
      throw ArgumentError(
        'Invite token has expired for client ${client.clientId}.',
        'token',
      );
    }
    return client.copyWith(portalStatus: PortalStatus.active);
  }

  // ---------------------------------------------------------------------------
  // Document sharing
  // ---------------------------------------------------------------------------

  /// Creates a [SharedDocument] shared with a client.
  ///
  /// [documentId] is used as the stable identifier (caller-supplied, typically
  /// the storage layer's document ID).
  SharedDocument shareDocument(
    String clientId,
    String documentId,
    String title,
    DocumentType type, {
    bool requiresESign = false,
    String caFirmId = '',
    String mimeType = 'application/pdf',
    int fileSize = 0,
  }) {
    return SharedDocument(
      documentId: documentId,
      clientId: clientId,
      caFirmId: caFirmId,
      title: title,
      documentType: type,
      fileSize: fileSize,
      mimeType: mimeType,
      sharedAt: DateTime.now(),
      requiresESign: requiresESign,
      eSigned: false,
      status: DocumentStatus.shared,
    );
  }

  /// Returns a copy of [doc] with [viewedAt] set to now and status
  /// updated to [DocumentStatus.viewed].
  SharedDocument markDocumentViewed(SharedDocument doc) {
    return doc.copyWith(
      viewedAt: DateTime.now(),
      status: DocumentStatus.viewed,
    );
  }

  /// Returns a copy of [doc] marked as e-signed at [signedAt].
  ///
  /// Sets [eSigned] to `true`, [eSignedAt] to [signedAt], and
  /// [status] to [DocumentStatus.eSigned].
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

  String _generateId(String prefix) {
    final digits = _generateDigits(8);
    return '$prefix-$digits';
  }

  String _generateToken() => _generateDigits(32);

  String _generateDigits(int count) {
    final buffer = StringBuffer();
    for (var i = 0; i < count; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }
}
