import 'package:flutter/material.dart';

/// Status of a portal credential.
enum PortalCredStatus {
  active('Active', Color(0xFF1A7A3A), Icons.check_circle_rounded),
  expired('Expired', Color(0xFFC62828), Icons.cancel_rounded),
  locked('Locked', Color(0xFFD4890E), Icons.lock_rounded),
  unknown('Unknown', Color(0xFF718096), Icons.help_outline_rounded);

  const PortalCredStatus(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}

/// Immutable model representing portal login credentials for a client.
///
/// Passwords are never stored in plain text. Only [maskedPassword]
/// (last 4 characters visible) is retained.
class PortalCredential {
  const PortalCredential({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.portalName,
    required this.userId,
    required this.maskedPassword,
    required this.lastUpdatedAt,
    required this.status,
    required this.consentGiven,
    this.consentExpiresAt,
  });

  final String id;
  final String clientId;
  final String clientName;

  /// Human-readable portal name (e.g. "Income Tax Portal", "GST Portal").
  final String portalName;

  final String userId;

  /// Password with only the last 4 characters visible (e.g. "••••••ab12").
  final String maskedPassword;

  final DateTime lastUpdatedAt;
  final PortalCredStatus status;

  /// Whether the client has given explicit consent to store credentials.
  final bool consentGiven;

  /// Optional date after which consent expires and must be renewed.
  final DateTime? consentExpiresAt;

  // ---------------------------------------------------------------------------
  // Computed helpers
  // ---------------------------------------------------------------------------

  /// Masked user ID showing only last 4 chars (e.g. "****user").
  String get maskedUserId {
    if (userId.length <= 4) return userId;
    return '${'*' * (userId.length - 4)}${userId.substring(userId.length - 4)}';
  }

  /// True when consent has been given and has not yet expired.
  bool get isConsentActive {
    if (!consentGiven) return false;
    if (consentExpiresAt == null) return true;
    return consentExpiresAt!.isAfter(DateTime.now());
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  PortalCredential copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? portalName,
    String? userId,
    String? maskedPassword,
    DateTime? lastUpdatedAt,
    PortalCredStatus? status,
    bool? consentGiven,
    DateTime? consentExpiresAt,
  }) {
    return PortalCredential(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      portalName: portalName ?? this.portalName,
      userId: userId ?? this.userId,
      maskedPassword: maskedPassword ?? this.maskedPassword,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      status: status ?? this.status,
      consentGiven: consentGiven ?? this.consentGiven,
      consentExpiresAt: consentExpiresAt ?? this.consentExpiresAt,
    );
  }
}
