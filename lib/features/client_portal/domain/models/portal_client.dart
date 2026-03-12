/// Lifecycle status of a client's portal access.
enum PortalStatus {
  invited('Invited'),
  active('Active'),
  inactive('Inactive'),
  suspended('Suspended');

  const PortalStatus(this.label);

  final String label;
}

/// Immutable model representing a CA's client registered on the portal.
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

  /// Mobile number with country code, e.g. "919876543210" for India.
  final String mobile;

  final PortalStatus portalStatus;

  /// One-time token sent to the client to activate their portal access.
  final String? inviteToken;

  /// Timestamp after which [inviteToken] is no longer valid (72 hours from issue).
  final DateTime? inviteExpiry;

  final DateTime? lastLoginAt;
  final int totalDocuments;
  final String caFirmId;

  PortalClient copyWith({
    String? clientId,
    String? pan,
    String? name,
    String? email,
    String? mobile,
    PortalStatus? portalStatus,
    String? inviteToken,
    DateTime? inviteExpiry,
    DateTime? lastLoginAt,
    int? totalDocuments,
    String? caFirmId,
  }) {
    return PortalClient(
      clientId: clientId ?? this.clientId,
      pan: pan ?? this.pan,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      portalStatus: portalStatus ?? this.portalStatus,
      inviteToken: inviteToken ?? this.inviteToken,
      inviteExpiry: inviteExpiry ?? this.inviteExpiry,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      totalDocuments: totalDocuments ?? this.totalDocuments,
      caFirmId: caFirmId ?? this.caFirmId,
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
