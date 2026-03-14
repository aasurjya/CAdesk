import 'package:ca_app/features/dsc_vault/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/dsc_vault/domain/models/portal_credential.dart';

/// Converts between [DscCertificate] / [PortalCredential] and JSON maps.
class DscVaultMapper {
  const DscVaultMapper._();

  static DscCertificate certFromJson(Map<String, dynamic> json) {
    return DscCertificate(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      panOrDin: json['pan_or_din'] as String,
      certHolder: json['cert_holder'] as String,
      issuedBy: json['issued_by'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      status: DscStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'valid'),
        orElse: () => DscStatus.valid,
      ),
      tokenType: DscTokenType.values.firstWhere(
        (e) => e.name == (json['token_type'] as String? ?? 'class3'),
        orElse: () => DscTokenType.class3,
      ),
      usageCount: (json['usage_count'] as num).toInt(),
      lastUsedAt: json['last_used_at'] != null
          ? DateTime.parse(json['last_used_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> certToJson(DscCertificate cert) {
    return {
      'id': cert.id,
      'client_id': cert.clientId,
      'client_name': cert.clientName,
      'pan_or_din': cert.panOrDin,
      'cert_holder': cert.certHolder,
      'issued_by': cert.issuedBy,
      'expiry_date': cert.expiryDate.toIso8601String(),
      'status': cert.status.name,
      'token_type': cert.tokenType.name,
      'usage_count': cert.usageCount,
      'last_used_at': cert.lastUsedAt?.toIso8601String(),
    };
  }

  static PortalCredential credFromJson(Map<String, dynamic> json) {
    return PortalCredential(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      portalName: json['portal_name'] as String,
      userId: json['user_id'] as String,
      maskedPassword: json['masked_password'] as String,
      lastUpdatedAt: DateTime.parse(json['last_updated_at'] as String),
      status: PortalCredStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'unknown'),
        orElse: () => PortalCredStatus.unknown,
      ),
      consentGiven: json['consent_given'] as bool? ?? false,
      consentExpiresAt: json['consent_expires_at'] != null
          ? DateTime.parse(json['consent_expires_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> credToJson(PortalCredential cred) {
    return {
      'id': cred.id,
      'client_id': cred.clientId,
      'client_name': cred.clientName,
      'portal_name': cred.portalName,
      'user_id': cred.userId,
      'masked_password': cred.maskedPassword,
      'last_updated_at': cred.lastUpdatedAt.toIso8601String(),
      'status': cred.status.name,
      'consent_given': cred.consentGiven,
      'consent_expires_at': cred.consentExpiresAt?.toIso8601String(),
    };
  }
}
