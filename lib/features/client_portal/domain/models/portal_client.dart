/// Lifecycle status of a client's portal access.
enum PortalStatus {
  invited,
  active,
  inactive,
  suspended,
}

/// Domain model representing a CA client registered on the client portal.
///
/// Immutable — use [copyWith] to derive updated copies.
/// Equality and [hashCode] are based solely on [clientId].
class PortalClient {
  const PortalClient({
    required this.clientId,
    required this.pan,
    required this.name,
    required this.email,
    required this.mobile,
    required this.portalStatus,
    required this.caFirmId,
    required this.totalDocuments,
    this.inviteToken,
    this.inviteExpiry,
    this.lastLoginAt,
  });

  final String clientId;
  final String pan;
  final String name;
  final String email;

  /// Mobile in E.164 format without the '+' prefix, e.g. "919876543210".
  final String mobile;
  final PortalStatus portalStatus;
  final String caFirmId;
  final int totalDocuments;
  final String? inviteToken;
  final DateTime? inviteExpiry;
  final DateTime? lastLoginAt;

  PortalClient copyWith({
    String? clientId,
    String? pan,
    String? name,
    String? email,
    String? mobile,
    PortalStatus? portalStatus,
    String? caFirmId,
    int? totalDocuments,
    String? inviteToken,
    DateTime? inviteExpiry,
    DateTime? lastLoginAt,
  }) {
    return PortalClient(
      clientId: clientId ?? this.clientId,
      pan: pan ?? this.pan,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      portalStatus: portalStatus ?? this.portalStatus,
      caFirmId: caFirmId ?? this.caFirmId,
      totalDocuments: totalDocuments ?? this.totalDocuments,
      inviteToken: inviteToken ?? this.inviteToken,
      inviteExpiry: inviteExpiry ?? this.inviteExpiry,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortalClient && other.clientId == clientId;
  }

  @override
  int get hashCode => clientId.hashCode;
}
