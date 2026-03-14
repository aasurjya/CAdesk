import 'package:ca_app/features/dsc_vault/domain/models/dsc_certificate.dart';
import 'package:ca_app/features/dsc_vault/domain/models/portal_credential.dart';
import 'package:ca_app/features/dsc_vault/domain/repositories/dsc_vault_repository.dart';

/// In-memory mock implementation of [DscVaultRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockDscVaultRepository implements DscVaultRepository {
  static final List<DscCertificate> _seedCertificates = [
    DscCertificate(
      id: 'dsc-001',
      clientId: 'mock-client-001',
      clientName: 'Tata Steel Ltd',
      panOrDin: 'AAACT2727Q',
      certHolder: 'Koushik Chatterjee',
      issuedBy: 'eMudhra',
      expiryDate: DateTime(2027, 6, 30),
      status: DscStatus.valid,
      tokenType: DscTokenType.class3,
      usageCount: 48,
      lastUsedAt: DateTime(2026, 3, 10),
    ),
    DscCertificate(
      id: 'dsc-002',
      clientId: 'mock-client-002',
      clientName: 'Infosys Ltd',
      panOrDin: 'AAACI1681G',
      certHolder: 'Nilanjan Roy',
      issuedBy: 'Sify',
      expiryDate: DateTime(2026, 4, 15),
      status: DscStatus.expiringSoon,
      tokenType: DscTokenType.class3,
      usageCount: 112,
      lastUsedAt: DateTime(2026, 3, 12),
    ),
    DscCertificate(
      id: 'dsc-003',
      clientId: 'mock-client-003',
      clientName: 'Sharma & Associates',
      panOrDin: 'DIN00012345',
      certHolder: 'Vikram Sharma',
      issuedBy: 'NSDL',
      expiryDate: DateTime(2025, 12, 31),
      status: DscStatus.expired,
      tokenType: DscTokenType.usbToken,
      usageCount: 7,
      lastUsedAt: DateTime(2025, 12, 28),
    ),
  ];

  static final List<PortalCredential> _seedCredentials = [
    PortalCredential(
      id: 'cred-001',
      clientId: 'mock-client-001',
      clientName: 'Tata Steel Ltd',
      portalName: 'Income Tax Portal',
      userId: 'AAACT2727Q',
      maskedPassword: '••••••ab12',
      lastUpdatedAt: DateTime(2026, 1, 15),
      status: PortalCredStatus.active,
      consentGiven: true,
      consentExpiresAt: DateTime(2026, 12, 31),
    ),
    PortalCredential(
      id: 'cred-002',
      clientId: 'mock-client-001',
      clientName: 'Tata Steel Ltd',
      portalName: 'GST Portal',
      userId: '27AAACT2727Q1ZX',
      maskedPassword: '••••••cd34',
      lastUpdatedAt: DateTime(2026, 2, 1),
      status: PortalCredStatus.active,
      consentGiven: true,
      consentExpiresAt: DateTime(2026, 12, 31),
    ),
    PortalCredential(
      id: 'cred-003',
      clientId: 'mock-client-002',
      clientName: 'Infosys Ltd',
      portalName: 'MCA21',
      userId: 'L72200KA1981PLC013115',
      maskedPassword: '••••••ef56',
      lastUpdatedAt: DateTime(2025, 8, 10),
      status: PortalCredStatus.expired,
      consentGiven: false,
    ),
  ];

  final List<DscCertificate> _certificates = List.of(_seedCertificates);
  final List<PortalCredential> _credentials = List.of(_seedCredentials);

  @override
  Future<String> insertCertificate(DscCertificate certificate) async {
    _certificates.add(certificate);
    return certificate.id;
  }

  @override
  Future<List<DscCertificate>> getAllCertificates() async =>
      List.unmodifiable(_certificates);

  @override
  Future<List<DscCertificate>> getCertificatesByClient(String clientId) async =>
      List.unmodifiable(
        _certificates.where((c) => c.clientId == clientId).toList(),
      );

  @override
  Future<List<DscCertificate>> getCertificatesByStatus(
    DscStatus status,
  ) async => List.unmodifiable(
    _certificates.where((c) => c.status == status).toList(),
  );

  @override
  Future<bool> updateCertificate(DscCertificate certificate) async {
    final idx = _certificates.indexWhere((c) => c.id == certificate.id);
    if (idx == -1) return false;
    final updated = List<DscCertificate>.of(_certificates)..[idx] = certificate;
    _certificates
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteCertificate(String id) async {
    final before = _certificates.length;
    _certificates.removeWhere((c) => c.id == id);
    return _certificates.length < before;
  }

  @override
  Future<String> insertCredential(PortalCredential credential) async {
    _credentials.add(credential);
    return credential.id;
  }

  @override
  Future<List<PortalCredential>> getAllCredentials() async =>
      List.unmodifiable(_credentials);

  @override
  Future<List<PortalCredential>> getCredentialsByClient(
    String clientId,
  ) async => List.unmodifiable(
    _credentials.where((c) => c.clientId == clientId).toList(),
  );

  @override
  Future<bool> updateCredential(PortalCredential credential) async {
    final idx = _credentials.indexWhere((c) => c.id == credential.id);
    if (idx == -1) return false;
    final updated = List<PortalCredential>.of(_credentials)..[idx] = credential;
    _credentials
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteCredential(String id) async {
    final before = _credentials.length;
    _credentials.removeWhere((c) => c.id == id);
    return _credentials.length < before;
  }
}
