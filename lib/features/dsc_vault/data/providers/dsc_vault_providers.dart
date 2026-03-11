import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/dsc_certificate.dart';
import '../../domain/models/portal_credential.dart';

// ---------------------------------------------------------------------------
// Mock data — DSC Certificates
// ---------------------------------------------------------------------------

final List<DscCertificate> _mockCertificates = [
  DscCertificate(
    id: 'dsc-001',
    clientId: 'client-101',
    clientName: 'Tata Steel BSL Ltd',
    panOrDin: 'AAACT1234F',
    certHolder: 'Rajesh Kumar Sharma',
    issuedBy: 'eMudhra',
    expiryDate: DateTime(2027, 6, 15),
    status: DscStatus.valid,
    tokenType: DscTokenType.class3,
    usageCount: 48,
    lastUsedAt: DateTime(2026, 3, 8),
  ),
  DscCertificate(
    id: 'dsc-002',
    clientId: 'client-102',
    clientName: 'Infosys BPM Limited',
    panOrDin: 'AAACI5678G',
    certHolder: 'Priya Subramaniam',
    issuedBy: 'Sify',
    expiryDate: DateTime(2026, 4, 1),
    status: DscStatus.expiringSoon,
    tokenType: DscTokenType.usbToken,
    usageCount: 31,
    lastUsedAt: DateTime(2026, 3, 7),
  ),
  DscCertificate(
    id: 'dsc-003',
    clientId: 'client-103',
    clientName: 'Godrej Properties Ltd',
    panOrDin: 'AAACG9012H',
    certHolder: 'Anil Mehta',
    issuedBy: 'NSDL',
    expiryDate: DateTime(2025, 12, 31),
    status: DscStatus.expired,
    tokenType: DscTokenType.class3,
    usageCount: 72,
    lastUsedAt: DateTime(2026, 1, 5),
  ),
  DscCertificate(
    id: 'dsc-004',
    clientId: 'client-104',
    clientName: 'Bajaj Auto International',
    panOrDin: 'AAACB3456I',
    certHolder: 'Sunita Bajaj',
    issuedBy: 'eMudhra',
    expiryDate: DateTime(2026, 3, 20),
    status: DscStatus.expiringSoon,
    tokenType: DscTokenType.cloudDsc,
    usageCount: 15,
    lastUsedAt: DateTime(2026, 3, 10),
  ),
  DscCertificate(
    id: 'dsc-005',
    clientId: 'client-105',
    clientName: 'Wipro Technologies Ltd',
    panOrDin: 'AAACW7890J',
    certHolder: 'Vikram Nair',
    issuedBy: 'Sify',
    expiryDate: DateTime(2028, 1, 10),
    status: DscStatus.valid,
    tokenType: DscTokenType.class3,
    usageCount: 8,
    lastUsedAt: DateTime(2026, 2, 28),
  ),
  DscCertificate(
    id: 'dsc-006',
    clientId: 'client-106',
    clientName: 'HCL Technologies Ltd',
    panOrDin: 'AAACH2345K',
    certHolder: 'Deepa Krishnan',
    issuedBy: 'NSDL',
    expiryDate: DateTime(2025, 11, 30),
    status: DscStatus.revoked,
    tokenType: DscTokenType.usbToken,
    usageCount: 22,
    lastUsedAt: DateTime(2025, 10, 15),
  ),
  DscCertificate(
    id: 'dsc-007',
    clientId: 'client-107',
    clientName: 'Mahindra Finance Ltd',
    panOrDin: 'AAACM6789L',
    certHolder: 'Ramesh Parekh',
    issuedBy: 'eMudhra',
    expiryDate: DateTime(2027, 9, 30),
    status: DscStatus.valid,
    tokenType: DscTokenType.class2,
    usageCount: 56,
    lastUsedAt: DateTime(2026, 3, 9),
  ),
  DscCertificate(
    id: 'dsc-008',
    clientId: 'client-108',
    clientName: 'HDFC Life Insurance',
    panOrDin: 'AAACH0123M',
    certHolder: 'Kavitha Reddy',
    issuedBy: 'Sify',
    expiryDate: DateTime(2026, 3, 28),
    status: DscStatus.expiringSoon,
    tokenType: DscTokenType.cloudDsc,
    usageCount: 11,
    lastUsedAt: DateTime(2026, 3, 6),
  ),
];

// ---------------------------------------------------------------------------
// Mock data — Portal Credentials
// ---------------------------------------------------------------------------

final List<PortalCredential> _mockCredentials = [
  PortalCredential(
    id: 'cred-001',
    clientId: 'client-101',
    clientName: 'Tata Steel BSL Ltd',
    portalName: 'Income Tax Portal',
    userId: 'AAACT1234F',
    maskedPassword: '••••••7X9Z',
    lastUpdatedAt: DateTime(2026, 1, 15),
    status: PortalCredStatus.active,
    consentGiven: true,
    consentExpiresAt: DateTime(2026, 12, 31),
  ),
  PortalCredential(
    id: 'cred-002',
    clientId: 'client-102',
    clientName: 'Infosys BPM Limited',
    portalName: 'GST Portal',
    userId: '29AAACI5678G1ZP',
    maskedPassword: '••••••8B2M',
    lastUpdatedAt: DateTime(2026, 2, 1),
    status: PortalCredStatus.active,
    consentGiven: true,
    consentExpiresAt: DateTime(2026, 9, 30),
  ),
  PortalCredential(
    id: 'cred-003',
    clientId: 'client-103',
    clientName: 'Godrej Properties Ltd',
    portalName: 'MCA21',
    userId: 'AAACG9012H',
    maskedPassword: '••••••4K1T',
    lastUpdatedAt: DateTime(2025, 8, 20),
    status: PortalCredStatus.expired,
    consentGiven: true,
    consentExpiresAt: DateTime(2025, 12, 31),
  ),
  PortalCredential(
    id: 'cred-004',
    clientId: 'client-104',
    clientName: 'Bajaj Auto International',
    portalName: 'Income Tax Portal',
    userId: 'AAACB3456I',
    maskedPassword: '••••••2N6Q',
    lastUpdatedAt: DateTime(2026, 3, 1),
    status: PortalCredStatus.locked,
    consentGiven: true,
    consentExpiresAt: DateTime(2026, 6, 30),
  ),
  PortalCredential(
    id: 'cred-005',
    clientId: 'client-105',
    clientName: 'Wipro Technologies Ltd',
    portalName: 'TRACES',
    userId: 'AAACW7890J',
    maskedPassword: '••••••5R3V',
    lastUpdatedAt: DateTime(2026, 2, 10),
    status: PortalCredStatus.active,
    consentGiven: true,
    consentExpiresAt: DateTime(2026, 11, 30),
  ),
  PortalCredential(
    id: 'cred-006',
    clientId: 'client-107',
    clientName: 'Mahindra Finance Ltd',
    portalName: 'GST Portal',
    userId: '27AAACM6789L1ZK',
    maskedPassword: '••••••9W1A',
    lastUpdatedAt: DateTime(2026, 3, 5),
    status: PortalCredStatus.active,
    consentGiven: false,
  ),
];

// ---------------------------------------------------------------------------
// DSC Certificates — NotifierProvider
// ---------------------------------------------------------------------------

class _DscCertificatesNotifier extends Notifier<List<DscCertificate>> {
  @override
  List<DscCertificate> build() => List.unmodifiable(_mockCertificates);

  /// Replace a certificate with an updated copy (immutable update).
  void updateCertificate(DscCertificate updated) {
    state = [
      for (final cert in state)
        if (cert.id == updated.id) updated else cert,
    ];
  }
}

final allDscCertificatesProvider =
    NotifierProvider<_DscCertificatesNotifier, List<DscCertificate>>(
      _DscCertificatesNotifier.new,
    );

// ---------------------------------------------------------------------------
// Portal Credentials — NotifierProvider
// ---------------------------------------------------------------------------

class _PortalCredentialsNotifier extends Notifier<List<PortalCredential>> {
  @override
  List<PortalCredential> build() => List.unmodifiable(_mockCredentials);

  /// Replace a credential with an updated copy (immutable update).
  void updateCredential(PortalCredential updated) {
    state = [
      for (final cred in state)
        if (cred.id == updated.id) updated else cred,
    ];
  }
}

final allPortalCredentialsProvider =
    NotifierProvider<_PortalCredentialsNotifier, List<PortalCredential>>(
      _PortalCredentialsNotifier.new,
    );

// ---------------------------------------------------------------------------
// DSC Status filter
// ---------------------------------------------------------------------------

class _DscStatusFilterNotifier extends Notifier<DscStatus?> {
  @override
  DscStatus? build() => null;

  void update(DscStatus? value) => state = value;
}

final dscStatusFilterProvider =
    NotifierProvider<_DscStatusFilterNotifier, DscStatus?>(
      _DscStatusFilterNotifier.new,
    );

// ---------------------------------------------------------------------------
// Filtered DSC list
// ---------------------------------------------------------------------------

final filteredDscProvider = Provider<List<DscCertificate>>((ref) {
  final filter = ref.watch(dscStatusFilterProvider);
  final allCerts = ref.watch(allDscCertificatesProvider);
  if (filter == null) return allCerts;
  return allCerts.where((c) => c.status == filter).toList();
});

// ---------------------------------------------------------------------------
// Summary provider
// ---------------------------------------------------------------------------

final dscVaultSummaryProvider = Provider<DscVaultSummary>((ref) {
  final certs = ref.watch(allDscCertificatesProvider);
  final portals = ref.watch(allPortalCredentialsProvider);

  final totalDsc = certs.length;
  final expiringSoon = certs
      .where((c) => c.status == DscStatus.expiringSoon)
      .length;
  final expired = certs.where((c) => c.status == DscStatus.expired).length;
  final activePortals = portals
      .where((p) => p.status == PortalCredStatus.active)
      .length;

  return DscVaultSummary(
    totalDsc: totalDsc,
    expiringSoon: expiringSoon,
    expired: expired,
    activePortals: activePortals,
  );
});

// ---------------------------------------------------------------------------
// Summary data class
// ---------------------------------------------------------------------------

/// Immutable summary of DSC vault statistics.
class DscVaultSummary {
  const DscVaultSummary({
    required this.totalDsc,
    required this.expiringSoon,
    required this.expired,
    required this.activePortals,
  });

  final int totalDsc;
  final int expiringSoon;
  final int expired;
  final int activePortals;
}
