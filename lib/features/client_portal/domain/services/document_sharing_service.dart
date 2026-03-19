import 'dart:math';

/// An immutable signed link that grants a specific client temporary access
/// to a document.
class SharedDocumentLink {
  const SharedDocumentLink({
    required this.linkId,
    required this.documentId,
    required this.documentName,
    required this.clientId,
    required this.signedUrl,
    required this.expiresAt,
    required this.isActive,
  });

  /// Unique identifier for this share link.
  final String linkId;

  /// Identifier of the underlying document in the document store.
  final String documentId;

  /// Human-readable document name shown to the client.
  final String documentName;

  /// Client this link was issued to.
  final String clientId;

  /// Time-limited signed URL; typically a pre-signed cloud storage URL.
  final String signedUrl;

  /// Hard expiry of the signed URL.
  final DateTime expiresAt;

  /// `false` once the link has been revoked via [DocumentSharingService.revokeLink].
  final bool isActive;

  /// Returns `true` when [DateTime.now()] is at or after [expiresAt].
  bool get isExpired => !DateTime.now().isBefore(expiresAt);

  SharedDocumentLink copyWith({
    String? linkId,
    String? documentId,
    String? documentName,
    String? clientId,
    String? signedUrl,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return SharedDocumentLink(
      linkId: linkId ?? this.linkId,
      documentId: documentId ?? this.documentId,
      documentName: documentName ?? this.documentName,
      clientId: clientId ?? this.clientId,
      signedUrl: signedUrl ?? this.signedUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedDocumentLink &&
        other.linkId == linkId &&
        other.documentId == documentId &&
        other.clientId == clientId;
  }

  @override
  int get hashCode => Object.hash(linkId, documentId, clientId);

  @override
  String toString() =>
      'SharedDocumentLink(linkId: $linkId, documentId: $documentId, '
      'clientId: $clientId, isActive: $isActive)';
}

/// Domain service for secure document sharing via time-limited signed links.
///
/// Stateless singleton — all persistent state (issued links, revocations)
/// is tracked in the in-memory registry. A production implementation would
/// delegate persistence to a repository.
///
/// Usage:
/// ```dart
/// final link = DocumentSharingService.instance.createShareLink(
///   'doc-001', 'client-42', const Duration(days: 7));
/// final links = DocumentSharingService.instance.getSharedDocuments('client-42');
/// DocumentSharingService.instance.revokeLink(link.linkId);
/// ```
class DocumentSharingService {
  DocumentSharingService._();

  static final DocumentSharingService instance = DocumentSharingService._();

  /// All links ever created in this session, keyed by [SharedDocumentLink.linkId].
  final Map<String, SharedDocumentLink> _links = {};

  final Random _random = Random.secure();

  // Base URL for pre-signed links; override in tests or staging.
  static const String _baseUrl = 'https://docs.caapp.in/share';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Creates a signed URL valid for [validity] and returns the
  /// [SharedDocumentLink].
  ///
  /// [documentId] is the stable identifier from the document store.
  /// [documentName] is used for display only.
  /// [clientId] restricts access to a single client.
  ///
  /// Throws [ArgumentError] if [documentId] or [clientId] is empty.
  SharedDocumentLink createShareLink(
    String documentId,
    String clientId,
    Duration validity, {
    String documentName = '',
  }) {
    if (documentId.isEmpty) {
      throw ArgumentError.value(documentId, 'documentId', 'must not be empty');
    }
    if (clientId.isEmpty) {
      throw ArgumentError.value(clientId, 'clientId', 'must not be empty');
    }

    final linkId = _generateLinkId();
    final expiresAt = DateTime.now().add(validity);
    final signedUrl = _buildSignedUrl(linkId, documentId, expiresAt);

    final link = SharedDocumentLink(
      linkId: linkId,
      documentId: documentId,
      documentName: documentName,
      clientId: clientId,
      signedUrl: signedUrl,
      expiresAt: expiresAt,
      isActive: true,
    );

    _links[linkId] = link;
    return link;
  }

  /// Returns all active (non-expired, non-revoked) links shared with [clientId].
  ///
  /// Links are returned in creation order (insertion-ordered map).
  List<SharedDocumentLink> getSharedDocuments(String clientId) {
    return _links.values
        .where((l) => l.clientId == clientId && l.isActive && !l.isExpired)
        .toList();
  }

  /// Returns all links — active and inactive — for [clientId].
  ///
  /// Useful for audit trails and history views.
  List<SharedDocumentLink> getAllLinksForClient(String clientId) {
    return _links.values.where((l) => l.clientId == clientId).toList();
  }

  /// Revokes the link identified by [linkId].
  ///
  /// Replaces the stored entry with a copy where [isActive] is `false`.
  /// If no link with [linkId] exists this is a no-op.
  void revokeLink(String linkId) {
    final existing = _links[linkId];
    if (existing == null) return;
    _links[linkId] = existing.copyWith(isActive: false);
  }

  /// Revokes all active links for [clientId].
  void revokeAllForClient(String clientId) {
    for (final entry in _links.entries) {
      if (entry.value.clientId == clientId && entry.value.isActive) {
        _links[entry.key] = entry.value.copyWith(isActive: false);
      }
    }
  }

  /// Returns the [SharedDocumentLink] for [linkId], or `null` if not found.
  SharedDocumentLink? findLink(String linkId) => _links[linkId];

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _generateLinkId() {
    final bytes = List<int>.generate(12, (_) => _random.nextInt(256));
    final buffer = StringBuffer('lnk-');
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  String _buildSignedUrl(String linkId, String documentId, DateTime expiresAt) {
    final expiry = expiresAt.millisecondsSinceEpoch ~/ 1000;
    return '$_baseUrl/$documentId?linkId=$linkId&exp=$expiry';
  }
}
